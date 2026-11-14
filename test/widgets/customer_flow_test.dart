import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/core/cafe_refs.dart';
import 'package:restaurant_universal_app/features/customer/application/table_provider.dart';
import 'package:restaurant_universal_app/features/customer/presentation/pages/cart_page.dart';
import 'package:restaurant_universal_app/features/customer/presentation/pages/menu_page.dart';
import 'package:restaurant_universal_app/features/customer/presentation/pages/order_tracking_page.dart';
import 'package:restaurant_universal_app/features/customer/presentation/pages/table_entry_page.dart';
import 'package:restaurant_universal_app/features/orders/application/order_providers.dart';
import 'package:restaurant_universal_app/models/menu_item_model.dart';

import 'test_app.dart';

void main() {
  late FakeFirebaseFirestore db;
  late CafeRefs refs;

  setUp(() {
    db = FakeFirebaseFirestore();
    refs = CafeRefs(db);
  });

  Future<void> addOrder(String id, String status,
      {String uid = 'customer-1', double total = 10}) {
    return refs.orders.doc(id).set({
      'orderNumber': 'ORD-$id',
      'tableNumber': 4,
      'tableId': 'table_4',
      'customerUid': uid,
      'items': [
        {'menuItemId': 'tea', 'name': 'Tea', 'quantity': 2, 'price': 5},
      ],
      'total': total,
      'status': status,
      'createdAt': DateTime.now(),
    });
  }

  group('table check-in', () {
    Future<void> enter(WidgetTester tester, String value) async {
      await tester.enterText(find.byType(TextField), value);
      await tester.tap(find.text('Go to Menu'));
      await settle(tester);
    }

    testWidgets('unknown and disabled tables are rejected with a message',
        (tester) async {
      await refs.tables.doc('table_2').set({'number': 2, 'isActive': false});
      await pumpTestApp(tester, db: db, child: const TableEntryPage());

      await enter(tester, '9');
      expect(find.textContaining('Table 9 is not registered'), findsOneWidget);

      await enter(tester, '2');
      expect(find.textContaining('Table 2 is currently not available'),
          findsOneWidget);

      await enter(tester, 'abc');
      expect(find.text('Table number must be a number'), findsOneWidget);
      expect(find.byType(TableEntryPage), findsOneWidget);
    });

    testWidgets('a registered table (typed or as QR payload) opens the app',
        (tester) async {
      await refs.tables.doc('table_5').set({'number': 5, 'isActive': true});
      await pumpTestApp(tester, db: db, child: const TableEntryPage());

      await enter(tester, 'table_5');

      expect(find.text('route:/customer'), findsOneWidget);
      final container = ProviderScope.containerOf(
          tester.element(find.text('route:/customer')));
      expect(container.read(currentTableProvider), 5);
    });
  });

  group('menu and cart', () {
    setUp(() async {
      await refs.tables.doc('table_4').set({'number': 4, 'isActive': true});
      await refs.menuItems
          .doc('tea')
          .set({'name': 'Tea', 'price': 5, 'isAvailable': true});
      await refs.menuItems.doc('plov').set(
          {'name': 'Plov', 'price': 30, 'isAvailable': true, 'outOfStock': true});
    });

    testWidgets('out-of-stock items are shown as sold out and cannot be added',
        (tester) async {
      await pumpTestApp(tester, db: db, child: const MenuPage());

      expect(find.text('Sold out'), findsOneWidget);
      expect(find.text('5 sum'), findsOneWidget);

      await tester.tap(find.text('Plov'));
      await settle(tester);
      await tester.tap(find.text('Tea'));
      await settle(tester);

      final container =
          ProviderScope.containerOf(tester.element(find.byType(MenuPage)));
      expect(container.read(cartProvider).map((e) => e.name), ['Tea']);
    });

    testWidgets('placing the cart creates a pending order for the table',
        (tester) async {
      await pumpTestApp(
        tester,
        db: db,
        child: const CartPage(),
        overrides: [currentTableProvider.overrideWith((ref) => 4)],
      );
      final container =
          ProviderScope.containerOf(tester.element(find.byType(CartPage)));
      container.read(cartProvider.notifier).addItem(const MenuItemModel(
          id: 'tea',
          categoryId: '',
          name: 'Tea',
          description: '',
          price: 5,
          imageUrl: ''));
      await settle(tester);

      await tester.tap(find.text('Place Order'));
      await settle(tester);

      final orders = await tester.runAsync(() => refs.orders.get());
      final data = orders?.docs.single.data();
      expect(data?['status'], 'pending');
      expect(data?['tableNumber'], 4);
      expect(data?['customerUid'], 'customer-1');
      expect(data?['total'], 5);
      expect(container.read(cartProvider), isEmpty);
      expect(find.text('route:/customer/orders'), findsOneWidget);
    });
  });

  group('order tracking', () {
    testWidgets('shows every lifecycle status of the customer\'s own orders',
        (tester) async {
      await addOrder('a', 'pending');
      await addOrder('b', 'preparing');
      await addOrder('c', 'ready');
      await addOrder('d', 'served');
      await addOrder('e', 'paid');
      await addOrder('f', 'cancelled');
      await addOrder('other', 'pending', uid: 'someone-else');

      await pumpTestApp(
        tester,
        db: db,
        child: const OrderTrackingPage(),
        overrides: [currentTableProvider.overrideWith((ref) => 4)],
      );

      for (final label in [
        'Pending',
        'Preparing',
        'Ready',
        'Served',
        'Paid',
        'Cancelled'
      ]) {
        expect(find.text(label, skipOffstage: false), findsOneWidget,
            reason: label);
      }
      expect(find.textContaining('ORD-other', skipOffstage: false),
          findsNothing);
      // Open bill: pending + preparing + ready + served, 10 each.
      expect(find.text('40 sum'), findsOneWidget);
      // Only the pending order can still be cancelled by the customer.
      expect(find.text('Cancel Order', skipOffstage: false), findsOneWidget);
    });

    testWidgets('the customer can cancel a pending order', (tester) async {
      await addOrder('a', 'pending');
      await pumpTestApp(
        tester,
        db: db,
        child: const OrderTrackingPage(),
        overrides: [currentTableProvider.overrideWith((ref) => 4)],
      );

      await tester.tap(find.text('Cancel Order'));
      await settle(tester);
      await tester.tap(find.text('Yes'));
      await settle(tester);

      final doc = await tester.runAsync(() => refs.orders.doc('a').get());
      expect(doc?.data()?['status'], 'cancelled');
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Cancel Order'), findsNothing);
    });

    testWidgets('requesting the bill notifies staff', (tester) async {
      await addOrder('a', 'served');
      await pumpTestApp(
        tester,
        db: db,
        child: const OrderTrackingPage(),
        overrides: [currentTableProvider.overrideWith((ref) => 4)],
      );

      await tester.tap(find.text('Request Bill'));
      await settle(tester);

      final calls = await tester.runAsync(() => refs.calls.get());
      final data = calls?.docs.single.data();
      expect(data?['type'], 'bill');
      expect(data?['tableNumber'], 4);
      expect(data?['status'], 'pending');
    });
  });
}
