import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/category_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../auth/application/auth_provider.dart';
import '../../menu/data/menu_repository.dart';
import '../data/orders_repository.dart';
import 'order_analytics.dart';

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(menuRepositoryProvider).watchCategories();
});

final menuItemsProvider = StreamProvider<List<MenuItemModel>>((ref) {
  return ref.watch(menuRepositoryProvider).watchMenuItems();
});

/// Orders of the current customer session (empty until it has a uid).
final customerOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(ordersRepositoryProvider).watchCustomerOrders(uid);
});

/// Staff: orders whose bill is still open.
final activeOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchActiveOrders();
});

/// Staff: orders of the last seven days, which covers "today" and "this
/// week" for the dashboard.
final recentOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final now = DateTime.now();
  final since = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 7));
  return ref.watch(ordersRepositoryProvider).watchOrdersSince(since);
});

final orderAnalyticsProvider = Provider<AsyncValue<OrderAnalytics>>((ref) {
  return ref.watch(recentOrdersProvider).whenData(
      (orders) => OrderAnalytics.from(orders, now: DateTime.now()));
});

class CartNotifier extends StateNotifier<List<OrderItemModel>> {
  CartNotifier() : super(const []);

  void addItem(MenuItemModel item) {
    if (state.any((e) => e.menuItemId == item.id)) {
      increment(item.id);
      return;
    }
    state = [
      ...state,
      OrderItemModel(
          menuItemId: item.id, name: item.name, quantity: 1, price: item.price),
    ];
  }

  void increment(String id) => _change(id, 1);

  void decrement(String id) => _change(id, -1);

  void _change(String id, int delta) {
    state = [
      for (final e in state)
        if (e.menuItemId != id)
          e
        else if (e.quantity + delta > 0)
          e.copyWith(quantity: e.quantity + delta),
    ];
  }

  void clear() => state = const [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<OrderItemModel>>(
    (ref) => CartNotifier());
