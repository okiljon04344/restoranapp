import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/models/menu_item_model.dart';
import 'package:restaurant_universal_app/models/order_item_model.dart';
import 'package:restaurant_universal_app/models/order_model.dart';
import 'package:restaurant_universal_app/models/table_model.dart';

void main() {
  group('OrderItemModel', () {
    test('total is price multiplied by quantity', () {
      const item = OrderItemModel(
        menuItemId: 'm1',
        name: 'Plov',
        quantity: 3,
        price: 12.5,
      );
      expect(item.total, 37.5);
    });

    test('toMap and fromMap round-trip', () {
      const item = OrderItemModel(
        menuItemId: 'm1',
        name: 'Plov',
        quantity: 2,
        price: 8,
      );
      final restored = OrderItemModel.fromMap(item.toMap());
      expect(restored.menuItemId, 'm1');
      expect(restored.name, 'Plov');
      expect(restored.quantity, 2);
      expect(restored.price, 8.0);
    });

    test('fromMap falls back to defaults for missing fields', () {
      final item = OrderItemModel.fromMap({});
      expect(item.menuItemId, '');
      expect(item.quantity, 0);
      expect(item.price, 0.0);
    });
  });

  group('OrderModel', () {
    final createdAt = DateTime.utc(2026, 1, 15, 12, 30);
    final order = OrderModel(
      id: 'o1',
      orderNumber: '001',
      orderType: 'dine_in',
      tableName: 'Table 4',
      tableNumber: 4,
      items: const [
        OrderItemModel(menuItemId: 'm1', name: 'Plov', quantity: 2, price: 8),
        OrderItemModel(menuItemId: 'm2', name: 'Tea', quantity: 1, price: 2),
      ],
      total: 18,
      status: 'pending',
      createdAt: createdAt,
    );

    test('toFirestore and fromFirestore round-trip', () {
      final restored = OrderModel.fromFirestore(order.toFirestore(), 'o1');
      expect(restored.id, 'o1');
      expect(restored.orderNumber, '001');
      expect(restored.tableNumber, 4);
      expect(restored.items.length, 2);
      expect(restored.items.first.name, 'Plov');
      expect(restored.total, 18.0);
      expect(restored.status, 'pending');
      expect(restored.createdAt.toUtc(), createdAt);
    });

    test('fromFirestore defaults status to pending', () {
      final data = {'createdAt': Timestamp.fromDate(createdAt)};
      expect(OrderModel.fromFirestore(data, 'x').status, 'pending');
    });

    test('copyWith changes only the status', () {
      final ready = order.copyWith(status: 'ready');
      expect(ready.status, 'ready');
      expect(ready.id, order.id);
      expect(ready.total, order.total);
      expect(order.status, 'pending');
    });
  });

  group('MenuItemModel and TableModel', () {
    test('MenuItemModel round-trip converts int price to double', () {
      final item = MenuItemModel.fromFirestore({
        'categoryId': 'c1',
        'name': 'Lagman',
        'description': 'Noodles',
        'price': 10,
        'imageUrl': '',
      }, 'm1');
      expect(item.price, 10.0);
      expect(item.toFirestore()['name'], 'Lagman');
    });

    test('TableModel defaults to active', () {
      final table = TableModel.fromFirestore({'name': 'T1', 'number': 1}, 't1');
      expect(table.isActive, isTrue);
      expect(table.toFirestore()['number'], 1);
    });
  });
}
