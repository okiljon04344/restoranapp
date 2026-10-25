import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_model.dart';

final analyticsProvider = Provider<OrderAnalytics>((ref) {
  return const OrderAnalytics();
});

class OrderAnalytics {
  const OrderAnalytics();

  Map<String, dynamic> getTodayStats(List<OrderModel> orders) {
    final today = DateTime.now();
    final todayOrders = orders
        .where((o) =>
            o.createdAt.year == today.year &&
            o.createdAt.month == today.month &&
            o.createdAt.day == today.day)
        .toList();

    double totalRevenue = 0;
    int completedCount = 0;
    int pendingCount = 0;
    int cancelledCount = 0;

    for (var order in todayOrders) {
      totalRevenue += order.total;
      if (order.status == 'completed') {
        completedCount++;
      } else if (order.status == 'cancelled') {
        cancelledCount++;
      } else {
        pendingCount++;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': todayOrders.length,
      'completedOrders': completedCount,
      'pendingOrders': pendingCount,
      'cancelledOrders': cancelledCount,
      'avgOrderValue':
          todayOrders.isEmpty ? 0 : totalRevenue / todayOrders.length,
    };
  }

  List<TopItem> getTopItems(List<OrderModel> orders) {
    final Map<String, int> itemOccurrences = {};

    for (var order in orders) {
      for (var item in order.items) {
        itemOccurrences[item.name] = (itemOccurrences[item.name] ?? 0) + 1;
      }
    }

    return itemOccurrences.entries
        .map((e) => TopItem(name: e.key, orderCount: e.value))
        .toList()
      ..sort((a, b) => b.orderCount.compareTo(a.orderCount));
  }
}

class TopItem {
  final String name;
  final int orderCount;
  TopItem({required this.name, required this.orderCount});
}
