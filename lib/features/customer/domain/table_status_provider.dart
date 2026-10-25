import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/domain/order_providers.dart';

/// Returns whether a table currently has an unfinished order.
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
