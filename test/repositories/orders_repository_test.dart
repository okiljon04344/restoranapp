import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/core/cafe_refs.dart';
import 'package:restaurant_universal_app/features/orders/data/orders_repository.dart';
import 'package:restaurant_universal_app/models/order_item_model.dart';
import 'package:restaurant_universal_app/models/order_model.dart';
import 'package:restaurant_universal_app/models/order_status.dart';

Matcher _fails(OrderFailure failure) => throwsA(
    isA<OrderException>().having((e) => e.failure, 'failure', failure));

void main() {
  late FakeFirebaseFirestore db;
  late CafeRefs refs;
  late OrdersRepository repo;

  /// Menu: Plov (30) uses 0.2 kg rice + 0.1 kg meat, Soup (20) uses 0.1 kg
  /// meat, Tea (5) has no recipe. Stock: 1 kg rice, 0.5 kg meat.
  setUp(() async {
    db = FakeFirebaseFirestore();
    refs = CafeRefs(db);
    repo = OrdersRepository(db);

    await refs.ingredients
        .doc('rice')
        .set({'name': 'Rice', 'unit': 'kg', 'quantity': 1.0});
    await refs.ingredients
        .doc('meat')
        .set({'name': 'Meat', 'unit': 'kg', 'quantity': 0.5});
    await refs.menuItems.doc('plov').set({
      'name': 'Plov',
      'price': 30,
      'isAvailable': true,
      'outOfStock': false,
      'recipe': [
        {'ingredientId': 'rice', 'quantity': 0.2},
        {'ingredientId': 'meat', 'quantity': 0.1},
      ],
    });
    await refs.menuItems.doc('soup').set({
      'name': 'Soup',
      'price': 20,
      'isAvailable': true,
      'outOfStock': false,
      'recipe': [
        {'ingredientId': 'meat', 'quantity': 0.1},
      ],
    });
    await refs.menuItems.doc('tea').set({'name': 'Tea', 'price': 5});
  });

  OrderItemModel line(String id, int quantity, {double price = 1}) =>
      OrderItemModel(menuItemId: id, name: id, quantity: quantity, price: price);

  Future<String> place(List<OrderItemModel> items,
          {int table = 4, String uid = 'customer-1'}) =>
      repo.placeOrder(customerUid: uid, tableNumber: table, items: items);

  Future<OrderModel> read(String id) async {
    final snapshot = await refs.orders.doc(id).get();
    return OrderModel.fromFirestore(snapshot.data() ?? const {}, id);
  }

  Future<double> stock(String id) async =>
      readDouble((await refs.ingredients.doc(id).get()).data()?['quantity']);

  Future<bool> outOfStock(String id) async =>
      (await refs.menuItems.doc(id).get()).data()?['outOfStock'] == true;

  group('placeOrder', () {
    test('creates a pending order priced from the menu, not from the cart',
        () async {
      // The cart claims a price of 1 for everything.
      final id = await place([line('plov', 2), line('tea', 1)]);

      final order = await read(id);
      expect(order.status, OrderStatus.pending);
      expect(order.customerUid, 'customer-1');
      expect(order.tableNumber, 4);
      expect(order.items.map((i) => i.name), ['Plov', 'Tea']);
      expect(order.total, 65);
      final raw = (await refs.orders.doc(id).get()).data();
      expect(raw?['tableId'], 'table_4');
      expect(raw?['createdAt'], isNotNull);
    });

    test('does not touch stock', () async {
      await place([line('plov', 2)]);
      expect(await stock('rice'), 1.0);
    });

    test('rejects an empty cart', () async {
      await expectLater(place(const []), _fails(OrderFailure.emptyOrder));
      await expectLater(
          place([line('plov', 0)]), _fails(OrderFailure.emptyOrder));
    });

    test('rejects items that are out of stock, disabled or removed',
        () async {
      await refs.menuItems.doc('plov').update({'outOfStock': true});
      await refs.menuItems.doc('soup').update({'isAvailable': false});

      await expectLater(
          place([line('plov', 1)]), _fails(OrderFailure.itemUnavailable));
      await expectLater(
          place([line('soup', 1)]), _fails(OrderFailure.itemUnavailable));
      await expectLater(
          place([line('gone', 1)]), _fails(OrderFailure.itemUnavailable));
      expect((await refs.orders.get()).docs, isEmpty);
    });
  });

  group('lifecycle', () {
    test('pending -> preparing -> ready -> served -> paid', () async {
      final id = await place([line('tea', 1)]);

      await repo.acceptOrder(id);
      expect((await read(id)).status, OrderStatus.preparing);

      await repo.markReady(id);
      expect((await read(id)).status, OrderStatus.ready);

      await repo.markServed(id);
      expect((await read(id)).status, OrderStatus.served);
      expect((await read(id)).isActive, isTrue);

      final paid = await repo.closeTableBill(4);
      expect(paid, 5);
      final order = await read(id);
      expect(order.status, OrderStatus.paid);
      expect(order.paidAt, isNotNull);
      expect(order.isActive, isFalse);
    });

    test('steps cannot be skipped or repeated', () async {
      final id = await place([line('tea', 1)]);

      await expectLater(
          repo.markReady(id), _fails(OrderFailure.invalidTransition));
      await expectLater(
          repo.markServed(id), _fails(OrderFailure.invalidTransition));

      await repo.acceptOrder(id);
      await expectLater(
          repo.acceptOrder(id), _fails(OrderFailure.invalidTransition));
      expect((await read(id)).status, OrderStatus.preparing);
    });

    test('unknown orders are reported', () async {
      await expectLater(
          repo.acceptOrder('missing'), _fails(OrderFailure.notFound));
      await expectLater(
          repo.cancelOrder('missing'), _fails(OrderFailure.notFound));
    });
  });

  group('stock', () {
    test('accepting an order deducts the recipe quantities', () async {
      final id = await place([line('plov', 2), line('soup', 1)]);

      await repo.acceptOrder(id);

      expect(await stock('rice'), closeTo(0.6, 1e-9)); // 1 - 2*0.2
      expect(await stock('meat'), closeTo(0.2, 1e-9)); // 0.5 - 2*0.1 - 0.1
      final order = await read(id);
      expect(order.stockDeductions['rice'], closeTo(0.4, 1e-9));
      expect(order.stockDeductions['meat'], closeTo(0.3, 1e-9));
    });

    test('accepting re-prices the order from the current menu', () async {
      final id = await place([line('plov', 1)]);
      await refs.menuItems.doc('plov').update({'price': 35});

      await repo.acceptOrder(id);

      expect((await read(id)).total, 35);
    });

    test('items that can no longer be made are flagged out of stock',
        () async {
      // 4 plov use 0.8 kg rice and 0.4 kg meat: 0.2 rice and 0.1 meat stay,
      // enough for exactly one more plov or one soup.
      await repo.acceptOrder(await place([line('plov', 4)]));
      expect(await outOfStock('plov'), isFalse);
      expect(await outOfStock('soup'), isFalse);

      // One soup takes the last 0.1 kg of meat.
      await repo.acceptOrder(await place([line('soup', 1)]));
      expect(await stock('meat'), closeTo(0, 1e-9));
      expect(await outOfStock('soup'), isTrue);
      expect(await outOfStock('plov'), isTrue);

      // Customers can no longer order the flagged items.
      await expectLater(
          place([line('plov', 1)]), _fails(OrderFailure.itemUnavailable));
    });

    test('an order that exceeds stock is not accepted and changes nothing',
        () async {
      final id = await place([line('plov', 6)]); // needs 1.2 kg rice

      await expectLater(
        repo.acceptOrder(id),
        throwsA(isA<OrderException>()
            .having((e) => e.failure, 'failure', OrderFailure.insufficientStock)
            .having((e) => e.detail, 'detail', 'Rice')),
      );

      expect((await read(id)).status, OrderStatus.pending);
      expect(await stock('rice'), 1.0);
      expect(await stock('meat'), 0.5);
    });

    test('a recipe line pointing at a deleted ingredient is ignored',
        () async {
      await refs.ingredients.doc('rice').delete();
      final id = await place([line('plov', 1)]);

      await repo.acceptOrder(id);

      expect((await read(id)).status, OrderStatus.preparing);
      expect(await stock('meat'), closeTo(0.4, 1e-9));
    });
  });

  group('cancelOrder', () {
    test('a pending order is cancelled without touching stock', () async {
      final id = await place([line('plov', 1)]);

      await repo.cancelOrder(id);

      expect((await read(id)).status, OrderStatus.cancelled);
      expect(await stock('rice'), 1.0);
    });

    test('cancelling a preparing order returns its stock and clears flags',
        () async {
      final id = await place([line('plov', 5)]); // all the rice and meat
      await repo.acceptOrder(id);
      expect(await stock('rice'), closeTo(0, 1e-9));
      expect(await outOfStock('plov'), isTrue);
      expect(await outOfStock('soup'), isTrue);

      await repo.cancelOrder(id);

      expect((await read(id)).status, OrderStatus.cancelled);
      expect(await stock('rice'), closeTo(1.0, 1e-9));
      expect(await stock('meat'), closeTo(0.5, 1e-9));
      expect(await outOfStock('plov'), isFalse);
      expect(await outOfStock('soup'), isFalse);
    });

    test('orders that left the kitchen cannot be cancelled', () async {
      final id = await place([line('tea', 1)]);
      await repo.acceptOrder(id);
      await repo.markReady(id);

      await expectLater(
          repo.cancelOrder(id), _fails(OrderFailure.invalidTransition));
      await repo.markServed(id);
      await expectLater(
          repo.cancelOrder(id), _fails(OrderFailure.invalidTransition));
    });
  });

  group('closeTableBill', () {
    Future<String> served(List<OrderItemModel> items, {int table = 4}) async {
      final id = await place(items, table: table);
      await repo.acceptOrder(id);
      await repo.markReady(id);
      await repo.markServed(id);
      return id;
    }

    test('pays every served order of the table and frees it', () async {
      final a = await served([line('tea', 2)]);
      final b = await served([line('soup', 1)]);
      final other = await served([line('tea', 1)], table: 9);

      final total = await repo.closeTableBill(4);

      expect(total, 30);
      expect((await read(a)).status, OrderStatus.paid);
      expect((await read(b)).status, OrderStatus.paid);
      expect((await read(other)).status, OrderStatus.served);
      final active = await repo.watchActiveOrders().first;
      expect(active.map((o) => o.tableNumber), [9]);
    });

    test('is refused while an order of the table is still in the kitchen',
        () async {
      final done = await served([line('tea', 1)]);
      await place([line('tea', 1)]); // still pending

      await expectLater(
          repo.closeTableBill(4), _fails(OrderFailure.billNotReady));
      expect((await read(done)).status, OrderStatus.served);
    });

    test('ignores cancelled orders and reports an empty table', () async {
      final cancelled = await place([line('tea', 1)]);
      await repo.cancelOrder(cancelled);

      await expectLater(
          repo.closeTableBill(4), _fails(OrderFailure.nothingToPay));

      final id = await served([line('tea', 1)]);
      expect(await repo.closeTableBill(4), 5);
      expect((await read(id)).status, OrderStatus.paid);
      expect((await read(cancelled)).status, OrderStatus.cancelled);
    });
  });

  group('streams', () {
    test('a customer only sees the orders of their own session', () async {
      await place([line('tea', 1)], uid: 'alice');
      await place([line('tea', 2)], uid: 'bob');

      final orders = await repo.watchCustomerOrders('alice').first;

      expect(orders, hasLength(1));
      expect(orders.single.customerUid, 'alice');
    });

    test('watchActiveOrders drops paid and cancelled orders', () async {
      final keep = await place([line('tea', 1)], table: 1);
      final cancel = await place([line('tea', 1)], table: 2);
      await repo.cancelOrder(cancel);

      final active = await repo.watchActiveOrders().first;

      expect(active.map((o) => o.id), [keep]);
    });

    test('watchOrdersSince filters by creation time', () async {
      await place([line('tea', 1)]);

      final past = DateTime.now().subtract(const Duration(days: 1));
      final future = DateTime.now().add(const Duration(days: 1));
      expect(await repo.watchOrdersSince(past).first, hasLength(1));
      expect(await repo.watchOrdersSince(future).first, isEmpty);
    });
  });
}
