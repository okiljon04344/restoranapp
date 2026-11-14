import '../../../models/order_model.dart';
import '../../../models/order_status.dart';

class TopItem {
  const TopItem({required this.name, required this.quantity});

  final String name;
  final int quantity;
}

/// Figures shown on the admin dashboard, derived from real orders.
///
/// Revenue only counts orders staff marked as paid, attributed to the day
/// the bill was closed. Order counts exclude cancelled orders.
class OrderAnalytics {
  const OrderAnalytics({
    required this.todayRevenue,
    required this.weekRevenue,
    required this.todayOrders,
    required this.weekOrders,
    required this.todayPaidOrders,
    required this.openOrders,
    required this.todayCancelled,
    required this.topItems,
  });

  final double todayRevenue;

  /// Revenue since Monday 00:00 of the current week.
  final double weekRevenue;
  final int todayOrders;
  final int weekOrders;
  final int todayPaidOrders;

  /// Orders whose bill is still open, regardless of the day.
  final int openOrders;
  final int todayCancelled;

  /// Best sellers of the current week by portions sold.
  final List<TopItem> topItems;

  double get averagePaidOrder =>
      todayPaidOrders == 0 ? 0 : todayRevenue / todayPaidOrders;

  factory OrderAnalytics.from(List<OrderModel> orders, {required DateTime now}) {
    final dayStart = DateTime(now.year, now.month, now.day);
    final weekStart = dayStart.subtract(Duration(days: now.weekday - 1));

    var todayRevenue = 0.0;
    var weekRevenue = 0.0;
    var todayOrders = 0;
    var weekOrders = 0;
    var todayPaid = 0;
    var open = 0;
    var todayCancelled = 0;
    final sold = <String, int>{};

    for (final order in orders) {
      final createdToday = !order.createdAt.isBefore(dayStart);
      final createdThisWeek = !order.createdAt.isBefore(weekStart);

      if (order.status == OrderStatus.cancelled) {
        if (createdToday) todayCancelled++;
        continue;
      }
      if (order.isActive) open++;
      if (createdToday) todayOrders++;
      if (createdThisWeek) {
        weekOrders++;
        for (final item in order.items) {
          sold[item.name] = (sold[item.name] ?? 0) + item.quantity;
        }
      }
      if (order.status == OrderStatus.paid) {
        final paidAt = order.paidAt ?? order.createdAt;
        if (!paidAt.isBefore(weekStart)) weekRevenue += order.total;
        if (!paidAt.isBefore(dayStart)) {
          todayRevenue += order.total;
          todayPaid++;
        }
      }
    }

    final top = sold.entries
        .map((e) => TopItem(name: e.key, quantity: e.value))
        .toList()
      ..sort((a, b) {
        final byQuantity = b.quantity.compareTo(a.quantity);
        return byQuantity != 0 ? byQuantity : a.name.compareTo(b.name);
      });

    return OrderAnalytics(
      todayRevenue: todayRevenue,
      weekRevenue: weekRevenue,
      todayOrders: todayOrders,
      weekOrders: weekOrders,
      todayPaidOrders: todayPaid,
      openOrders: open,
      todayCancelled: todayCancelled,
      topItems: top.take(5).toList(),
    );
  }
}
