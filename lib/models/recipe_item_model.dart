import '../core/cafe_refs.dart';

/// One line of a menu item's recipe: how much of an ingredient a single
/// portion consumes (in the ingredient's own unit).
class RecipeItem {
  const RecipeItem({required this.ingredientId, required this.quantity});

  final String ingredientId;
  final double quantity;

  factory RecipeItem.fromMap(Map<String, dynamic> map) => RecipeItem(
        ingredientId: readString(map['ingredientId']),
        quantity: readDouble(map['quantity']),
      );

  Map<String, dynamic> toMap() =>
      {'ingredientId': ingredientId, 'quantity': quantity};
}
