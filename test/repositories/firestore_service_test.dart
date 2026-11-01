import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/models/order_model.dart';
import 'package:restaurant_universal_app/services/firestore_service.dart';

OrderModel _order(String number, int table) => OrderModel(
      id: '',
      orderNumber: number,
      orderType: 'dine_in',
      tableName: 'Table $table',
      tableNumber: table,
      items: const [],
      total: 25,
      status: 'pending',
      createdAt: DateTime(2024, 1, 1, 12),
    );

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = FirestoreService(db);
  });

  test('placeOrder writes an order that getOrders reads back', () async {
    await service.placeOrder(_order('A1', 5));

    final orders = await service.getOrders().first;
    expect(orders, hasLength(1));
    expect(orders.single.orderNumber, 'A1');
    expect(orders.single.tableNumber, 5);
  });

  test('updateOrderStatus and cancelOrder change the status', () async {
    await service.placeOrder(_order('A1', 5));
    final id = (await service.getOrders().first).single.id;

    await service.updateOrderStatus(id, 'preparing');
    expect((await service.getOrders().first).single.status, 'preparing');

    await service.cancelOrder(id);
    expect((await service.getOrders().first).single.status, 'cancelled');
  });

  test('createCategory and createMenuItem are readable via streams', () async {
    final categoryId =
        await service.createCategory(name: 'Soups', icon: 'soup', sortOrder: 1);
    await service.createMenuItem(
      name: 'Lagman',
      description: 'Noodles',
      price: 9.5,
      categoryId: categoryId,
    );

    final categories = await service.getCategories().first;
    final items = await service.getMenuItems().first;
    expect(categories.single.name, 'Soups');
    expect(items.single.name, 'Lagman');
    expect(items.single.price, 9.5);
  });

  test('callStaff writes a pending call', () async {
    await service.callStaff(2);

    final calls = await db
        .collection('cafes')
        .doc('main_cafe')
        .collection('calls')
        .get();
    expect(calls.docs.single.data()['status'], 'pending');
  });
}
