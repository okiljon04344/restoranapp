import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/orders/application/order_analytics.dart';
import 'package:restaurant_universal_app/models/order_item_model.dart';
import 'package:restaurant_universal_app/models/order_model.dart';

OrderModel _order({
  required String status,
  required DateTime createdAt,
  DateTime? paidAt,
  double total = 0,
  Map<String, int> items = const {},
}) =>
    OrderModel(
      id: '${createdAt.microsecondsSinceEpoch}-$status',
      orderNumber: 'ORD',
      orderType: 'dine_in',
      tableNumber: 1,
      items: [
        for (final e in items.entries)
          OrderItemModel(
              menuItemId: e.key, name: e.key, quantity: e.value, price: 1),
      ],
      total: total,
      status: status,
      createdAt: createdAt,
      paidAt: paidAt,
    );

void main() {
  // Wednesday; the week therefore started on Monday 2026-03-09.
  final now = DateTime(2026, 3, 11, 20);
  final today = DateTime(2026, 3, 11, 12);
  final monday = DateTime(2026, 3, 9, 12);
  final lastSunday = DateTime(2026, 3, 8, 12);

  test('no orders gives zeros', () {
    final stats = OrderAnalytics.from(const [], now: now);

    expect(stats.todayRevenue, 0);
    expect(stats.weekRevenue, 0);
    expect(stats.todayOrders, 0);
    expect(stats.averagePaidOrder, 0);
    expect(stats.topItems, isEmpty);
  });

  test('revenue counts only paid orders, by the day the bill was closed', () {
    final stats = OrderAnalytics.from([
      _order(status: 'paid', createdAt: today, paidAt: today, total: 100),
      _order(status: 'paid', createdAt: today, paidAt: today, total: 50),
      // Served but not paid yet: no revenue.
      _order(status: 'served', createdAt: today, total: 70),
      _order(status: 'cancelled', createdAt: today, total: 999),
      // Ordered on Monday, paid on Monday: week only.
      _order(status: 'paid', createdAt: monday, paidAt: monday, total: 40),
      // Last week.
      _order(
          status: 'paid', createdAt: lastSunday, paidAt: lastSunday, total: 7),
    ], now: now);

    expect(stats.todayRevenue, 150);
    expect(stats.weekRevenue, 190);
    expect(stats.todayPaidOrders, 2);
    expect(stats.averagePaidOrder, 75);
  });

  test('order counts exclude cancelled orders', () {
    final stats = OrderAnalytics.from([
      _order(status: 'pending', createdAt: today),
      _order(status: 'preparing', createdAt: today),
      _order(status: 'paid', createdAt: today, paidAt: today),
      _order(status: 'cancelled', createdAt: today),
      _order(status: 'served', createdAt: monday),
      _order(status: 'paid', createdAt: lastSunday, paidAt: lastSunday),
    ], now: now);

    expect(stats.todayOrders, 3);
    expect(stats.weekOrders, 4);
    expect(stats.todayCancelled, 1);
    expect(stats.openOrders, 3); // pending, preparing, served
  });

  test('top items rank this week by portions sold, five at most', () {
    final stats = OrderAnalytics.from([
      _order(status: 'paid', createdAt: today, items: {'Plov': 3, 'Tea': 1}),
      _order(status: 'served', createdAt: monday, items: {'Tea': 4}),
      _order(status: 'cancelled', createdAt: today, items: {'Plov': 50}),
      _order(status: 'paid', createdAt: lastSunday, items: {'Soup': 99}),
      _order(
          status: 'pending',
          createdAt: today,
          items: {'A': 1, 'B': 1, 'C': 1, 'D': 1}),
    ], now: now);

    expect(stats.topItems, hasLength(5));
    expect(stats.topItems[0].name, 'Tea');
    expect(stats.topItems[0].quantity, 5);
    expect(stats.topItems[1].name, 'Plov');
    expect(stats.topItems[1].quantity, 3);
    expect(stats.topItems.map((i) => i.name), isNot(contains('Soup')));
  });
}
