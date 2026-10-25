import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Must match the cafe document id used in firestore.rules.
  final String cafeId = 'main_cafe';

  Stream<List<OrderModel>> getOrders() {
    return _db
        .collection('cafes')
        .doc(cafeId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> placeOrder(OrderModel order) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('orders')
        .add(order.toFirestore());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  Future<void> cancelOrder(String orderId) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('orders')
        .doc(orderId)
        .update({'status': 'cancelled'});
  }

  Stream<List<CategoryModel>> getCategories() {
    return _db
        .collection('cafes')
        .doc(cafeId)
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MenuItemModel>> getMenuItems() {
    return _db
        .collection('cafes')
        .doc(cafeId)
        .collection('menuItems')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<String> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    String? imageUrl,
  }) async {
    final docRef =
        await _db.collection('cafes').doc(cafeId).collection('menuItems').add({
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl ?? '',
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<String> createCategory({
    required String name,
    required String icon,
    required int sortOrder,
  }) async {
    final docRef =
        await _db.collection('cafes').doc(cafeId).collection('categories').add({
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('menuItems')
        .doc(itemId)
        .delete();
  }
}
