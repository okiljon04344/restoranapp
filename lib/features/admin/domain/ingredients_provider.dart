import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Ingredient {
  final String id;
  final String name;
  final String unit; // kg, l, dona, etc.
  final double quantity;
  final double minimumQuantity;
  final bool isOutOfStock;
  final DateTime lastUpdated;

  Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimumQuantity,
    required this.isOutOfStock,
    required this.lastUpdated,
  });

  factory Ingredient.fromFirestore(Map<String, dynamic> data, String id) {
    return Ingredient(
      id: id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? 'dona',
      quantity: (data['quantity'] ?? 0).toDouble(),
      minimumQuantity: (data['minimumQuantity'] ?? 0).toDouble(),
      isOutOfStock: data['isOutOfStock'] ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'unit': unit,
        'quantity': quantity,
        'minimumQuantity': minimumQuantity,
        'isOutOfStock': isOutOfStock,
        'lastUpdated': Timestamp.now(),
      };
}

final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  const cafeId = 'main_cafe';
  return FirebaseFirestore.instance
      .collection('cafes')
      .doc(cafeId)
      .collection('ingredients')
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc.data(), doc.id))
          .toList());
});

final outOfStockIngredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  const cafeId = 'main_cafe';
  return FirebaseFirestore.instance
      .collection('cafes')
      .doc(cafeId)
      .collection('ingredients')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc.data(), doc.id))
          .where((ing) => ing.quantity <= ing.minimumQuantity)
          .toList());
});
