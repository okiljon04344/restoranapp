import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_model.dart';
import '../../../services/firestore_service.dart';

final analyticsProvider = Provider<OrderAnalytics>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OrderAnalytics(firestoreService);
});

class OrderAnalytics {
  final FirestoreService firestore;
  OrderAnalytics(this.firestore);

  // Get today's statistics
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

  // Get this week's stats
  Map<String, dynamic> getWeekStats(List<OrderModel> orders) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final weekOrders = orders
        .where((o) =>
            o.createdAt.isAfter(weekStart) &&
            o.createdAt.isBefore(now.add(const Duration(days: 1))))
        .toList();

    double totalRevenue = weekOrders.fold(0, (sum, order) => sum + order.total);

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': weekOrders.length,
      'avgDaily': weekOrders.isEmpty ? 0 : totalRevenue / 7,
    };
  }

  // Get busiest times
  List<BusyHour> getBusiestHours(List<OrderModel> orders) {
    final Map<int, int> hourCounts = {};

    for (var order in orders) {
      final hour = order.createdAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    return hourCounts.entries
        .map((e) => BusyHour(hour: e.key, orderCount: e.value))
        .toList()
      ..sort((a, b) => b.orderCount.compareTo(a.orderCount));
  }

  // Get top menu items
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
      ..sort((a, b) => b.orderCount.compareTo(a.orderCount))
      ..take(5);
  }
}

class BusyHour {
  final int hour;
  final int orderCount;
  BusyHour({required this.hour, required this.orderCount});

  String get timeString => '${hour.toString().padLeft(2, '0')}:00';
}

class TopItem {
  final String name;
  final int orderCount;
  TopItem({required this.name, required this.orderCount});
}
