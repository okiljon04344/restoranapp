import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/models/menu_item_model.dart';
import 'package:restaurant_universal_app/models/order_item_model.dart';
import 'package:restaurant_universal_app/models/order_model.dart';
import 'package:restaurant_universal_app/models/order_status.dart';
import 'package:restaurant_universal_app/models/table_model.dart';

void main() {
  group('OrderItemModel', () {
    test('total is price multiplied by quantity', () {
      const item = OrderItemModel(
        menuItemId: 'm1',
        name: 'Plov',
        quantity: 3,
        price: 12.5,
      );
      expect(item.total, 37.5);
    });

    test('toMap and fromMap round-trip', () {
      const item = OrderItemModel(
        menuItemId: 'm1',
        name: 'Plov',
        quantity: 2,
        price: 8,
      );
      final restored = OrderItemModel.fromMap(item.toMap());
      expect(restored.menuItemId, 'm1');
      expect(restored.name, 'Plov');
      expect(restored.quantity, 2);
      expect(restored.price, 8.0);
    });

    test('fromMap falls back to defaults for missing fields', () {
      final item = OrderItemModel.fromMap({});
      expect(item.menuItemId, '');
      expect(item.quantity, 0);
      expect(item.price, 0.0);
    });
  });

  group('OrderModel', () {
    final createdAt = DateTime.utc(2026, 1, 15, 12, 30);
    final order = OrderModel(
      id: 'o1',
      orderNumber: '001',
      orderType: 'dine_in',
      tableNumber: 4,
      items: const [
        OrderItemModel(menuItemId: 'm1', name: 'Plov', quantity: 2, price: 8),
        OrderItemModel(menuItemId: 'm2', name: 'Tea', quantity: 1, price: 2),
      ],
      total: 18,
      status: 'pending',
      createdAt: createdAt,
      customerUid: 'u1',
    );

    test('toFirestore and fromFirestore round-trip', () {
      final restored = OrderModel.fromFirestore(order.toFirestore(), 'o1');
      expect(restored.id, 'o1');
      expect(restored.orderNumber, '001');
      expect(restored.tableNumber, 4);
      expect(restored.items.length, 2);
      expect(restored.items.first.name, 'Plov');
      expect(restored.total, 18.0);
      expect(restored.status, 'pending');
      expect(restored.createdAt.toUtc(), createdAt);
    });

    test('fromFirestore defaults status to pending', () {
      final data = {'createdAt': Timestamp.fromDate(createdAt)};
      expect(OrderModel.fromFirestore(data, 'x').status, 'pending');
    });

    test('toFirestore stores the customer and the table document id', () {
      final data = order.toFirestore();
      expect(data['customerUid'], 'u1');
      expect(data['tableId'], 'table_4');
    });

    test('fromFirestore tolerates a pending server timestamp', () {
      // A just-written serverTimestamp() is null in the local snapshot.
      final restored = OrderModel.fromFirestore({'status': 'ready'}, 'x');
      expect(restored.status, 'ready');
      expect(restored.items, isEmpty);
      expect(restored.paidAt, isNull);
    });

    test('fromFirestore maps legacy status values onto the lifecycle', () {
      expect(OrderModel.fromFirestore({'status': 'cooking'}, 'x').status,
          OrderStatus.preparing);
      expect(OrderModel.fromFirestore({'status': 'completed'}, 'x').status,
          OrderStatus.paid);
      expect(OrderModel.fromFirestore({'status': 'bogus'}, 'x').status,
          OrderStatus.pending);
    });
  });

  group('OrderStatus', () {
    test('allows only the lifecycle transitions', () {
      expect(OrderStatus.canTransition('pending', 'preparing'), isTrue);
      expect(OrderStatus.canTransition('preparing', 'ready'), isTrue);
      expect(OrderStatus.canTransition('ready', 'served'), isTrue);
      expect(OrderStatus.canTransition('served', 'paid'), isTrue);
      expect(OrderStatus.canTransition('pending', 'cancelled'), isTrue);
      expect(OrderStatus.canTransition('preparing', 'cancelled'), isTrue);

      expect(OrderStatus.canTransition('pending', 'ready'), isFalse);
      expect(OrderStatus.canTransition('ready', 'cancelled'), isFalse);
      expect(OrderStatus.canTransition('served', 'cancelled'), isFalse);
      expect(OrderStatus.canTransition('paid', 'pending'), isFalse);
      expect(OrderStatus.canTransition('cancelled', 'pending'), isFalse);
    });

    test('a table stays occupied until the order is paid or cancelled', () {
      expect(OrderStatus.isActive('served'), isTrue);
      expect(OrderStatus.isActive('paid'), isFalse);
      expect(OrderStatus.isActive('cancelled'), isFalse);
    });
  });

  group('MenuItemModel and TableModel', () {
    test('MenuItemModel round-trip converts int price to double', () {
      final item = MenuItemModel.fromFirestore({
        'categoryId': 'c1',
        'name': 'Lagman',
        'description': 'Noodles',
        'price': 10,
        'imageUrl': '',
      }, 'm1');
      expect(item.price, 10.0);
      expect(item.toFirestore()['name'], 'Lagman');
      expect(item.canOrder, isTrue);
      expect(item.recipe, isEmpty);
    });

    test('MenuItemModel reads the recipe and the availability flags', () {
      final item = MenuItemModel.fromFirestore({
        'name': 'Plov',
        'price': 30,
        'isAvailable': true,
        'outOfStock': true,
        'recipe': [
          {'ingredientId': 'rice', 'quantity': 0.2},
          {'ingredientId': '', 'quantity': 1}, // malformed line is dropped
        ],
      }, 'm1');
      expect(item.canOrder, isFalse);
      expect(item.recipe.single.ingredientId, 'rice');
      expect(item.recipe.single.quantity, 0.2);
    });

    test('TableModel reads the number written by the old QR page', () {
      final table = TableModel.fromFirestore({'tableNumber': 7}, 'table_7');
      expect(table.number, 7);
    });

    test('TableModel defaults to active', () {
      final table = TableModel.fromFirestore({'name': 'T1', 'number': 1}, 't1');
      expect(table.isActive, isTrue);
      expect(table.toFirestore()['number'], 1);
    });
  });
}
