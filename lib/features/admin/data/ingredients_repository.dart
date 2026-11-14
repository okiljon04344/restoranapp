import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cafe_refs.dart';
import '../../../core/firebase_providers.dart';
import '../../../models/ingredient_model.dart';
import '../../menu/data/menu_availability.dart';

final ingredientsRepositoryProvider =
    Provider((ref) => IngredientsRepository(ref.watch(firestoreProvider)));

class IngredientsRepository {
  IngredientsRepository(this._db) : _refs = CafeRefs(_db);

  final FirebaseFirestore _db;
  final CafeRefs _refs;

  /// All ingredients ordered by name.
  Stream<List<Ingredient>> watchAll() {
    return _refs.ingredients.orderBy('name').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Ingredient.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<String> add({
    required String name,
    required String unit,
    required double quantity,
    required double minimumQuantity,
  }) async {
    final doc = await _refs.ingredients.add({
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Saves the ingredient and refreshes the `outOfStock` flag of the menu
  /// items whose recipes depend on it.
  Future<void> update(
    String id, {
    required String name,
    required String unit,
    required double quantity,
    required double minimumQuantity,
  }) async {
    await _refs.ingredients.doc(id).update({
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    await syncMenuAvailability(_db);
  }

  Future<void> delete(String id) async {
    await _refs.ingredients.doc(id).delete();
    await syncMenuAvailability(_db);
  }
}
