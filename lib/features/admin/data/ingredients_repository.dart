import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../../../models/ingredient_model.dart';

final ingredientsRepositoryProvider =
    Provider((ref) => IngredientsRepository(ref.watch(firestoreProvider)));

class IngredientsRepository {
  IngredientsRepository(this._db);

  final FirebaseFirestore _db;
  static const _cafeId = 'main_cafe';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('cafes').doc(_cafeId).collection('ingredients');

  /// All ingredients ordered by name.
  Stream<List<Ingredient>> watchAll() {
    return _collection.orderBy('name').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Ingredient.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  /// Ingredients whose quantity has dropped to (or below) their minimum.
  /// Firestore cannot compare two fields of a document, so this is filtered
  /// on the client.
  Stream<List<Ingredient>> watchLowStock() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Ingredient.fromFirestore(doc.data(), doc.id))
        .where((ing) => ing.quantity <= ing.minimumQuantity)
        .toList());
  }

  Future<void> add({
    required String name,
    required String unit,
    required double quantity,
    required double minimumQuantity,
  }) async {
    await _collection.add({
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'isOutOfStock': false,
      'lastUpdated': Timestamp.now(),
    });
  }

  Future<void> update(
    String id, {
    required String name,
    required String unit,
    required double quantity,
    required double minimumQuantity,
  }) async {
    await _collection.doc(id).update({
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'isOutOfStock': quantity <= minimumQuantity,
      'lastUpdated': Timestamp.now(),
    });
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
