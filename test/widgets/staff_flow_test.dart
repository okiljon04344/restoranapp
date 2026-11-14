import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/core/cafe_refs.dart';
import 'package:restaurant_universal_app/features/auth/application/auth_provider.dart';
import 'package:restaurant_universal_app/features/auth/presentation/widgets/role_gate.dart';
import 'package:restaurant_universal_app/features/kitchen/presentation/widgets/kitchen_board.dart';
import 'package:restaurant_universal_app/features/tables/presentation/table_bills_view.dart';
import 'package:restaurant_universal_app/features/tables/presentation/table_qr_printer.dart';

import 'test_app.dart';

void main() {
  late FakeFirebaseFirestore db;
  late CafeRefs refs;

  setUp(() async {
    db = FakeFirebaseFirestore();
    refs = CafeRefs(db);
    await refs.ingredients.doc('rice').set({'name': 'Rice', 'quantity': 0.5});
    await refs.menuItems.doc('plov').set({
      'name': 'Plov',
      'price': 30,
      'recipe': [
        {'ingredientId': 'rice', 'quantity': 0.2},
      ],
    });
  });

  Future<void> addOrder(String id, String status,
      {int quantity = 1, int table = 4}) {
    return refs.orders.doc(id).set({
      'orderNumber': 'ORD-$id',
      'tableNumber': table,
      'customerUid': 'customer-1',
      'items': [
        {
          'menuItemId': 'plov',
          'name': 'Plov',
          'quantity': quantity,
          'price': 30,
        },
      ],
      'total': 30.0 * quantity,
      'status': status,
      'createdAt': DateTime.now(),
    });
  }

  Future<String?> statusOf(WidgetTester tester, String id) async {
    final doc = await tester.runAsync(() => refs.orders.doc(id).get());
    return doc?.data()?['status'] as String?;
  }

  Widget page(Widget child) =>
      Scaffold(body: SingleChildScrollView(child: child));

  testWidgets('the kitchen moves an order through every stage',
      (tester) async {
    await addOrder('a', 'pending', quantity: 2);
    await pumpTestApp(tester, db: db, child: page(const KitchenBoard()));

    await tester.tap(find.text('Start Cooking'));
    await settle(tester);
    expect(await statusOf(tester, 'a'), 'preparing');
    final rice = await tester.runAsync(() => refs.ingredients.doc('rice').get());
    expect(rice?.data()?['quantity'], closeTo(0.1, 1e-9));

    await tester.tap(find.text('Mark as Ready'));
    await settle(tester);
    expect(await statusOf(tester, 'a'), 'ready');

    await tester.tap(find.text('Mark as Served'));
    await settle(tester);
    expect(await statusOf(tester, 'a'), 'served');
    // Served orders leave the kitchen queue.
    expect(find.text('Mark as Served'), findsNothing);
  });

  testWidgets('accepting without enough stock shows the missing ingredient',
      (tester) async {
    await addOrder('a', 'pending', quantity: 5); // needs 1.0, stock is 0.5
    await pumpTestApp(tester, db: db, child: page(const KitchenBoard()));

    await tester.tap(find.text('Start Cooking'));
    await settle(tester);

    expect(find.text('Not enough stock: Rice.'), findsOneWidget);
    expect(await statusOf(tester, 'a'), 'pending');
  });

  testWidgets('the kitchen can cancel a pending order', (tester) async {
    await addOrder('a', 'pending');
    await pumpTestApp(tester, db: db, child: page(const KitchenBoard()));

    await tester.tap(find.byTooltip('Cancel Order'));
    await settle(tester);
    await tester.tap(find.text('Yes'));
    await settle(tester);

    expect(await statusOf(tester, 'a'), 'cancelled');
  });

  testWidgets('staff close the bill of a table once everything is served',
      (tester) async {
    await addOrder('a', 'served', table: 4);
    await addOrder('b', 'served', table: 4);
    await addOrder('c', 'preparing', table: 7);
    await pumpTestApp(tester, db: db, child: page(const TableBillsView()));

    expect(find.text('Table 4'), findsOneWidget);
    expect(find.text('60 sum'), findsOneWidget);
    // Table 7 still has an order in the kitchen: its button is disabled.
    final buttons = tester
        .widgetList<FilledButton>(find.bySubtype<FilledButton>())
        .toList();
    expect(buttons.where((b) => b.onPressed == null), hasLength(1));

    await tester.tap(find.text('Close bill (paid)').first);
    await settle(tester);
    await tester.tap(find.text('Yes'));
    await settle(tester);

    expect(await statusOf(tester, 'a'), 'paid');
    expect(await statusOf(tester, 'b'), 'paid');
    expect(await statusOf(tester, 'c'), 'preparing');
    expect(find.text('Table 4'), findsNothing);
  });

  group('RoleGate', () {
    Future<void> pump(WidgetTester tester, StaffRole role,
        {bool adminOnly = false}) {
      return pumpTestApp(
        tester,
        db: db,
        child: RoleGate(adminOnly: adminOnly, child: const Text('secret')),
        overrides: [staffRoleProvider.overrideWith((ref) => role)],
      );
    }

    testWidgets('hides staff screens from accounts without a role',
        (tester) async {
      await pump(tester, StaffRole.none);
      expect(find.text('secret'), findsNothing);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('lets kitchen staff into staff screens but not admin ones',
        (tester) async {
      await pump(tester, StaffRole.kitchen);
      expect(find.text('secret'), findsOneWidget);

      await pump(tester, StaffRole.kitchen, adminOnly: true);
      expect(find.text('secret'), findsNothing);
    });

    testWidgets('lets admins into admin screens', (tester) async {
      await pump(tester, StaffRole.admin, adminOnly: true);
      expect(find.text('secret'), findsOneWidget);
    });
  });

  test('the QR sheet for the selected tables is a PDF document', () async {
    final bytes = await buildTableQrPdf([1, 2, 3, 4, 5, 6, 7]);

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });
}
