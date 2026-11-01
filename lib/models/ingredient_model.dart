import 'package:cloud_firestore/cloud_firestore.dart';

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
