import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/category_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../../services/firestore_service.dart';

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getCategories();
});

final menuItemsProvider = StreamProvider<List<MenuItemModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getMenuItems();
});

final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getOrders();
});

class CartNotifier extends StateNotifier<List<OrderItemModel>> {
  CartNotifier() : super([]);

  void addItem(MenuItemModel item) {
    final index = state.indexWhere((e) => e.menuItemId == item.id);
    if (index == -1) {
      state = [
        ...state,
        OrderItemModel(
            menuItemId: item.id,
            name: item.name,
            quantity: 1,
            price: item.price)
      ];
    } else {
      final updated = [...state];
      final old = updated[index];
      updated[index] = OrderItemModel(
          menuItemId: old.menuItemId,
          name: old.name,
          quantity: old.quantity + 1,
          price: old.price);
      state = updated;
    }
  }

  void increment(String id) {
    state = state
        .map((e) => e.menuItemId == id
            ? OrderItemModel(
                menuItemId: e.menuItemId,
                name: e.name,
                quantity: e.quantity + 1,
                price: e.price)
            : e)
        .toList();
  }

  void decrement(String id) {
    state = state
        .map((e) => e.menuItemId == id
            ? OrderItemModel(
                menuItemId: e.menuItemId,
                name: e.name,
                quantity: e.quantity - 1,
                price: e.price)
            : e)
        .where((e) => e.quantity > 0)
        .toList();
  }

  void clear() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<OrderItemModel>>(
    (ref) => CartNotifier());

final ordersProvider = Provider<List<OrderModel>>((ref) {
  return ref.watch(ordersStreamProvider).value ?? [];
});

class OrdersAction {
  final Ref ref;
  OrdersAction(this.ref);

  Future<void> placeOrder({
    required List<OrderItemModel> items,
    required String orderType,
    required String tableName,
    required int tableNumber,
  }) async {
    final total = items.fold<double>(0, (sum, item) => sum + item.total);
    final order = OrderModel(
      id: '',
      orderNumber:
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      orderType: orderType,
      tableName: tableName,
      tableNumber: tableNumber,
      items: items,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await ref.read(firestoreServiceProvider).placeOrder(order);
  }

  Future<void> updateStatus(String orderId, String status) async {
    await ref.read(firestoreServiceProvider).updateOrderStatus(orderId, status);
  }
}

final ordersActionProvider = Provider((ref) => OrdersAction(ref));
