import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/core/cafe_refs.dart';
import 'package:restaurant_universal_app/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:restaurant_universal_app/features/kitchen/presentation/pages/kitchen_orders_page.dart';

import 'test_app.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() async {
    db = FakeFirebaseFirestore();
    final refs = CafeRefs(db);
    await refs.tables.doc('table_1').set({'number': 1, 'isActive': true});
    await refs.tables.doc('table_2').set({'number': 2, 'isActive': false});
    await refs.categories.doc('main').set({'name': 'Main', 'sortOrder': 0});
    await refs.ingredients.doc('rice').set({
      'name': 'Rice',
      'unit': 'kg',
      'quantity': 1,
      'minimumQuantity': 2,
    });
    await refs.menuItems.doc('plov').set({
      'name': 'Plov with a rather long descriptive name',
      'price': 30,
      'categoryId': 'main',
      'recipe': [
        {'ingredientId': 'rice', 'quantity': 0.2},
      ],
    });
    for (final (index, status)
        in ['pending', 'preparing', 'ready', 'served', 'paid', 'cancelled']
            .indexed) {
      await refs.orders.doc('o$index').set({
        'orderNumber': 'ORD-$index',
        'tableNumber': 1,
        'customerUid': 'c',
        'items': [
          {'menuItemId': 'plov', 'name': 'Plov', 'quantity': 2, 'price': 30},
        ],
        'total': 60,
        'status': status,
        'createdAt': DateTime.now(),
        if (status == 'paid') 'paidAt': DateTime.now(),
      });
    }
    await refs.calls.doc('c1').set({
      'tableNumber': 1,
      'type': 'bill',
      'status': 'pending',
      'createdAt': DateTime.now(),
    });
    await refs.staffRequests.doc('u1').set({'email': 'cook@example.com'});
    await refs.staff.doc('u2').set({'email': 'chef@example.com'});
  });

  // Every section has to lay out without overflow on a phone and on a
  // desktop-sized window (layout errors fail the test).
  for (final size in const [Size(390, 800), Size(1440, 900)]) {
    testWidgets('admin panel renders every section at ${size.width.toInt()}px',
        (tester) async {
      await pumpTestApp(tester, db: db, child: const AdminDashboardPage());
      tester.view.physicalSize = size;
      await settle(tester);

      final container = ProviderScope.containerOf(
          tester.element(find.byType(AdminDashboardPage)));
      for (final section in AdminSection.values) {
        container.read(adminSectionProvider.notifier).state = section;
        await settle(tester);
        expect(tester.takeException(), isNull, reason: section.name);
      }
    });

    testWidgets('kitchen screen renders its tabs at ${size.width.toInt()}px',
        (tester) async {
      await pumpTestApp(tester, db: db, child: const KitchenOrdersPage());
      tester.view.physicalSize = size;
      await settle(tester);
      expect(find.text('Start Cooking'), findsOneWidget);

      for (final tab in ['Bills', 'Staff Calls']) {
        await tester.tap(find.text(tab));
        await settle(tester);
        expect(tester.takeException(), isNull, reason: tab);
      }
      expect(find.textContaining('Bill requested'), findsWidgets);
    });
  }

  testWidgets('the overview shows figures computed from the orders',
      (tester) async {
    await pumpTestApp(tester, db: db, child: const AdminDashboardPage());

    // One paid order of 60 today; five non-cancelled orders; four open.
    expect(find.text('60 sum'), findsNWidgets(3)); // today, week, average
    expect(find.text('5'), findsNWidgets(2)); // orders today / this week
    expect(find.text('4'), findsOneWidget); // open orders
    expect(find.text('× 10'), findsOneWidget); // Plov: 5 orders x 2
    expect(find.textContaining('Low Stock (1'), findsOneWidget);
  });
}
