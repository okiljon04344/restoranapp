import '../core/cafe_refs.dart';

class Ingredient {
  final String id;
  final String name;

  /// Stored unit code (`dona`, `kg`, `g`, `l`, `ml`, `box`, `pack`).
  final String unit;
  final double quantity;
  final double minimumQuantity;
  final DateTime? lastUpdated;

  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimumQuantity,
    this.lastUpdated,
  });

  /// At or below the alert threshold configured by the admin.
  bool get isLow => quantity <= minimumQuantity;

  factory Ingredient.fromFirestore(Map<String, dynamic> data, String id) {
    return Ingredient(
      id: id,
      name: readString(data['name']),
      unit: readString(data['unit'], 'dona'),
      quantity: readDouble(data['quantity']),
      minimumQuantity: readDouble(data['minimumQuantity']),
      lastUpdated: readDate(data['lastUpdated']),
    );
  }
}
