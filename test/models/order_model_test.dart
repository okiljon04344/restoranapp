import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/models/order_item_model.dart';
import 'package:restaurant_universal_app/models/order_model.dart';

void main() {
  final createdAt = DateTime(2026, 10, 25, 12, 30);

  OrderModel buildOrder() => OrderModel(
        id: 'o1',
        orderNumber: 'ORD-001',
        orderType: 'Dine-in',
        tableName: 'Table 3',
        tableNumber: 3,
        items: const [
          OrderItemModel(menuItemId: 'm1', name: 'Plov', quantity: 2, price: 1200),
          OrderItemModel(menuItemId: 'm2', name: 'Tea', quantity: 1, price: 300),
        ],
        total: 2700,
        status: 'pending',
        createdAt: createdAt,
      );

  test('OrderItemModel.total multiplies price by quantity', () {
    const item = OrderItemModel(menuItemId: 'm1', name: 'Plov', quantity: 3, price: 1200);
    expect(item.total, 3600);
  });

  test('toFirestore / fromFirestore round-trips every field', () {
    final order = buildOrder();
    final restored = OrderModel.fromFirestore(order.toFirestore(), order.id);

    expect(restored.id, 'o1');
    expect(restored.orderNumber, 'ORD-001');
    expect(restored.tableNumber, 3);
    expect(restored.items.map((i) => i.total), [2400, 300]);
    expect(restored.total, 2700);
    expect(restored.status, 'pending');
    expect(restored.createdAt, createdAt);
  });

  test('toFirestore writes exactly the keys allowed by firestore.rules', () {
    expect(buildOrder().toFirestore().keys.toSet(), {
      'orderNumber',
      'orderType',
      'tableName',
      'tableNumber',
      'items',
      'total',
      'status',
      'createdAt',
    });
  });

  test('fromFirestore tolerates missing optional fields', () {
    final order = OrderModel.fromFirestore(
      {'createdAt': Timestamp.fromDate(createdAt), 'total': 5},
      'o2',
    );
    expect(order.status, 'pending');
    expect(order.items, isEmpty);
    expect(order.total, 5.0);
  });

  test('copyWith only changes the status', () {
    final cancelled = buildOrder().copyWith(status: 'cancelled');
    expect(cancelled.status, 'cancelled');
    expect(cancelled.orderNumber, 'ORD-001');
    expect(cancelled.items.length, 2);
  });
}
