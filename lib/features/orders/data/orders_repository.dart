import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cafe_refs.dart';
import '../../../core/firebase_providers.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import '../../menu/data/menu_availability.dart';

final ordersRepositoryProvider =
    Provider((ref) => OrdersRepository(ref.watch(firestoreProvider)));

enum OrderFailure {
  emptyOrder,
  notFound,
  invalidTransition,
  itemUnavailable,
  insufficientStock,
  billNotReady,
  nothingToPay,
}

/// A business-rule failure of an order operation. [detail] names the menu
/// item or ingredient involved, when there is one.
class OrderException implements Exception {
  const OrderException(this.failure, [this.detail = '']);

  final OrderFailure failure;
  final String detail;

  @override
  String toString() => 'OrderException(${failure.name}, $detail)';
}

class OrdersRepository {
  OrdersRepository(this._db) : _refs = CafeRefs(_db);

  final FirebaseFirestore _db;
  final CafeRefs _refs;

  List<OrderModel> _map(QuerySnapshot<JsonMap> snapshot) => snapshot.docs
      .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Orders placed by one customer session, newest first.
  Stream<List<OrderModel>> watchCustomerOrders(String customerUid) {
    return _refs.orders
        .where('customerUid', isEqualTo: customerUid)
        .snapshots()
        .map(_map);
  }

  /// Orders whose bill is still open (staff only), newest first.
  Stream<List<OrderModel>> watchActiveOrders() {
    return _refs.orders
        .where('status', whereIn: OrderStatus.active)
        .snapshots()
        .map(_map);
  }

  /// Every order created at or after [since] (staff only); feeds the admin
  /// order list and the analytics.
  Stream<List<OrderModel>> watchOrdersSince(DateTime since) {
    return _refs.orders
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .snapshots()
        .map(_map);
  }

  /// Creates a `pending` order. Names and prices are taken from the current
  /// menu, not from the cart, and unavailable items are rejected.
  Future<String> placeOrder({
    required String customerUid,
    required int tableNumber,
    required List<OrderItemModel> items,
  }) async {
    final lines = items.where((i) => i.quantity > 0).toList();
    if (lines.isEmpty) throw const OrderException(OrderFailure.emptyOrder);

    final priced = <OrderItemModel>[];
    for (final line in lines) {
      final snapshot = await _refs.menuItems.doc(line.menuItemId).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw OrderException(OrderFailure.itemUnavailable, line.name);
      }
      final menuItem = MenuItemModel.fromFirestore(data, snapshot.id);
      if (!menuItem.canOrder) {
        throw OrderException(OrderFailure.itemUnavailable, menuItem.name);
      }
      priced.add(line.copyWith(name: menuItem.name, price: menuItem.price));
    }

    final millis = DateTime.now().millisecondsSinceEpoch.toString();
    final doc = await _refs.orders.add({
      'orderNumber': 'ORD-${millis.substring(millis.length - 6)}',
      'orderType': 'dine_in',
      'tableId': OrderModel.tableDocId(tableNumber),
      'tableNumber': tableNumber,
      'customerUid': customerUid,
      'items': priced.map((i) => i.toMap()).toList(),
      'total': priced.fold<double>(0, (total, i) => total + i.total),
      'status': OrderStatus.pending,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Kitchen accepts a pending order: `pending -> preparing`.
  ///
  /// In one transaction this re-prices the order from the menu, takes the
  /// recipe quantities out of stock (failing with
  /// [OrderFailure.insufficientStock] if any ingredient is short) and
  /// refreshes the `outOfStock` flag of every menu item that shares one of
  /// the touched ingredients.
  Future<void> acceptOrder(String orderId) async {
    // Queries cannot run inside a transaction, so the menu is listed first;
    // the documents that decide the outcome are re-read transactionally.
    final menu = await _loadMenu();
    final failure = await _db.runTransaction<OrderException?>((tx) async {
      final orderRef = _refs.orders.doc(orderId);
      final order = await _readOrder(tx, orderRef);
      if (order == null) return const OrderException(OrderFailure.notFound);
      if (order.status != OrderStatus.pending) {
        return const OrderException(OrderFailure.invalidTransition);
      }

      final required = <String, double>{};
      final priced = <OrderItemModel>[];
      for (final line in order.items) {
        final snapshot = await tx.get(_refs.menuItems.doc(line.menuItemId));
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          // The item was removed from the menu after ordering; keep the line
          // as ordered, there is no recipe left to deduct.
          priced.add(line);
          continue;
        }
        final menuItem = MenuItemModel.fromFirestore(data, snapshot.id);
        priced.add(line.copyWith(price: menuItem.price));
        for (final r in menuItem.recipe) {
          required[r.ingredientId] =
              (required[r.ingredientId] ?? 0) + r.quantity * line.quantity;
        }
      }

      final affected = _itemsUsing(menu, required.keys.toSet());
      final stock = await _readStock(tx, {
        ...required.keys,
        for (final item in affected) ...item.recipe.map((r) => r.ingredientId),
      });

      final deductions = <String, double>{};
      for (final entry in required.entries) {
        final current = stock[entry.key];
        // A recipe line pointing at a deleted ingredient is skipped.
        if (current == null) continue;
        if (current.quantity + stockEpsilon < entry.value) {
          return OrderException(OrderFailure.insufficientStock, current.name);
        }
        deductions[entry.key] = entry.value;
      }

      final quantities = {
        for (final e in stock.entries) e.key: e.value.quantity,
      };
      for (final entry in deductions.entries) {
        final remaining =
            normalizeStock((quantities[entry.key] ?? 0) - entry.value);
        quantities[entry.key] = remaining;
        tx.update(_refs.ingredients.doc(entry.key), {
          'quantity': remaining,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
      _writeAvailability(tx, affected, quantities);

      tx.update(orderRef, {
        'status': OrderStatus.preparing,
        'items': priced.map((i) => i.toMap()).toList(),
        'total': priced.fold<double>(0, (total, i) => total + i.total),
        'stockDeductions': deductions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    });
    if (failure != null) throw failure;
  }

  /// `preparing -> ready`.
  Future<void> markReady(String orderId) =>
      _advance(orderId, OrderStatus.ready);

  /// `ready -> served`.
  Future<void> markServed(String orderId) =>
      _advance(orderId, OrderStatus.served);

  Future<void> _advance(String orderId, String to) async {
    final failure = await _db.runTransaction<OrderException?>((tx) async {
      final orderRef = _refs.orders.doc(orderId);
      final order = await _readOrder(tx, orderRef);
      if (order == null) return const OrderException(OrderFailure.notFound);
      if (!OrderStatus.canTransition(order.status, to)) {
        return const OrderException(OrderFailure.invalidTransition);
      }
      tx.update(orderRef, {
        'status': to,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    });
    if (failure != null) throw failure;
  }

  /// Cancels an order that is still `pending` or `preparing`. Stock taken
  /// when a `preparing` order was accepted is returned.
  ///
  /// A pending order only has `status`/`updatedAt` written, which is exactly
  /// what the security rules let the customer who placed it do.
  Future<void> cancelOrder(String orderId) async {
    final menu = await _loadMenu();
    final failure = await _db.runTransaction<OrderException?>((tx) async {
      final orderRef = _refs.orders.doc(orderId);
      final order = await _readOrder(tx, orderRef);
      if (order == null) return const OrderException(OrderFailure.notFound);
      if (!OrderStatus.canTransition(order.status, OrderStatus.cancelled)) {
        return const OrderException(OrderFailure.invalidTransition);
      }

      final restore = order.stockDeductions;
      if (restore.isNotEmpty) {
        final affected = _itemsUsing(menu, restore.keys.toSet());
        final stock = await _readStock(tx, {
          ...restore.keys,
          for (final item in affected)
            ...item.recipe.map((r) => r.ingredientId),
        });
        final quantities = {
          for (final e in stock.entries) e.key: e.value.quantity,
        };
        for (final entry in restore.entries) {
          final current = quantities[entry.key];
          if (current == null) continue;
          final restored = normalizeStock(current + entry.value);
          quantities[entry.key] = restored;
          tx.update(_refs.ingredients.doc(entry.key), {
            'quantity': restored,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        _writeAvailability(tx, affected, quantities);
      }

      tx.update(orderRef, {
        'status': OrderStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    });
    if (failure != null) throw failure;
  }

  /// Staff closes the bill of a table: every `served` order becomes `paid`,
  /// which frees the table. Returns the amount settled.
  ///
  /// Fails with [OrderFailure.billNotReady] while an order of the table is
  /// still in the kitchen, so nothing is left behind unpaid.
  Future<double> closeTableBill(int tableNumber) async {
    final snapshot = await _refs.orders
        .where('tableNumber', isEqualTo: tableNumber)
        .get();
    final open = _map(snapshot).where((o) => o.isActive).toList();
    if (open.isEmpty) throw const OrderException(OrderFailure.nothingToPay);
    if (open.any((o) => o.status != OrderStatus.served)) {
      throw const OrderException(OrderFailure.billNotReady);
    }
    final batch = _db.batch();
    for (final order in open) {
      batch.update(_refs.orders.doc(order.id), {
        'status': OrderStatus.paid,
        'paidAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return open.fold<double>(0, (total, o) => total + o.total);
  }

  Future<List<MenuItemModel>> _loadMenu() async {
    final snapshot = await _refs.menuItems.get();
    return snapshot.docs
        .map((doc) => MenuItemModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<OrderModel?> _readOrder(
      Transaction tx, DocumentReference<JsonMap> ref) async {
    final snapshot = await tx.get(ref);
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return OrderModel.fromFirestore(data, snapshot.id);
  }

  Future<Map<String, ({String name, double quantity})>> _readStock(
      Transaction tx, Set<String> ingredientIds) async {
    final stock = <String, ({String name, double quantity})>{};
    for (final id in ingredientIds) {
      final snapshot = await tx.get(_refs.ingredients.doc(id));
      final data = snapshot.data();
      if (!snapshot.exists || data == null) continue;
      stock[id] = (
        name: readString(data['name']),
        quantity: readDouble(data['quantity']),
      );
    }
    return stock;
  }

  List<MenuItemModel> _itemsUsing(
          List<MenuItemModel> menu, Set<String> ingredientIds) =>
      menu
          .where((item) =>
              item.recipe.any((r) => ingredientIds.contains(r.ingredientId)))
          .toList();

  void _writeAvailability(Transaction tx, List<MenuItemModel> items,
      Map<String, double> quantities) {
    for (final item in items) {
      final outOfStock = isRecipeOutOfStock(item.recipe, quantities);
      if (outOfStock != item.outOfStock) {
        tx.update(_refs.menuItems.doc(item.id), {
          'outOfStock': outOfStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
