import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cafe_refs.dart';
import '../../../core/firebase_providers.dart';
import '../../../models/category_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/recipe_item_model.dart';
import 'menu_availability.dart';

final menuRepositoryProvider =
    Provider((ref) => MenuRepository(ref.watch(firestoreProvider)));

/// Thrown when a category that still has menu items is deleted.
class CategoryInUseException implements Exception {
  const CategoryInUseException();
}

class MenuRepository {
  MenuRepository(this._db) : _refs = CafeRefs(_db);

  final FirebaseFirestore _db;
  final CafeRefs _refs;

  Stream<List<CategoryModel>> watchCategories() {
    return _refs.categories.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
  }

  Stream<List<MenuItemModel>> watchMenuItems() {
    return _refs.menuItems.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => MenuItemModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
  }

  Future<String> createCategory({
    required String name,
    required int sortOrder,
  }) async {
    final doc = await _refs.categories.add({
      'name': name,
      'icon': '',
      'sortOrder': sortOrder,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> deleteCategory(String categoryId) async {
    final used = await _refs.menuItems
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    if (used.docs.isNotEmpty) throw const CategoryInUseException();
    await _refs.categories.doc(categoryId).delete();
  }

  Future<String> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    String imageUrl = '',
    List<RecipeItem> recipe = const [],
  }) async {
    final doc = await _refs.menuItems.add({
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'isAvailable': true,
      'outOfStock': false,
      'recipe': recipe.map((r) => r.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await syncMenuAvailability(_db);
    return doc.id;
  }

  Future<void> updateMenuItem(
    String itemId, {
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required String imageUrl,
    required List<RecipeItem> recipe,
  }) async {
    await _refs.menuItems.doc(itemId).update({
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'recipe': recipe.map((r) => r.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // The recipe may have changed, so the stock flag has to be re-derived.
    await syncMenuAvailability(_db);
  }

  Future<void> setAvailable(String itemId, {required bool isAvailable}) async {
    await _refs.menuItems.doc(itemId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _refs.menuItems.doc(itemId).delete();
  }
}
