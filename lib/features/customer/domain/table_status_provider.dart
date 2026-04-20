import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/domain/order_providers.dart';

// Provider to check if a table has active orders
final tableStatusProvider = Provider((ref) {
  final orders = ref.watch(ordersProvider);
  return (int tableNumber) {
    return orders.any((order) =>
        order.tableNumber == tableNumber &&
        (order.status == 'pending' ||
            order.status == 'preparing' ||
            order.status == 'ready'));
  };
});

// Provider to get active order for a table
final tableActiveOrderProvider = Provider((ref) {
  final orders = ref.watch(ordersProvider);
  return (int tableNumber) {
    try {
      return orders.firstWhere((order) =>
          order.tableNumber == tableNumber &&
          (order.status == 'pending' ||
              order.status == 'preparing' ||
              order.status == 'ready' ||
              order.status == 'unpaid'));
    } catch (e) {
      return null;
    }
  };
});

// Function to cancel order by table number
Future<void> cancelOrderByTable(int tableNumber, WidgetRef ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  final orders = ref.read(ordersProvider);

  try {
    final order = orders.firstWhere((o) => o.tableNumber == tableNumber);
    await firestoreService.cancelOrder(order.id);
  } catch (e) {
    print('Error cancelling order: $e');
  }
}
