import '../core/cafe_refs.dart';
import 'recipe_item_model.dart';

class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  /// Switched by an admin to take an item off the menu manually.
  final bool isAvailable;

  /// Maintained by the app whenever stock changes: true while at least one
  /// recipe ingredient cannot cover a single portion.
  final bool outOfStock;

  final List<RecipeItem> recipe;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.outOfStock = false,
    this.recipe = const [],
  });

  bool get canOrder => isAvailable && !outOfStock;

  factory MenuItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    final rawRecipe = data['recipe'];
    return MenuItemModel(
      id: id,
      categoryId: readString(data['categoryId']),
      name: readString(data['name']),
      description: readString(data['description']),
      price: readDouble(data['price']),
      imageUrl: readString(data['imageUrl']),
      isAvailable: readBool(data['isAvailable'], fallback: true),
      outOfStock: readBool(data['outOfStock'], fallback: false),
      recipe: rawRecipe is List
          ? rawRecipe
              .whereType<Map>()
              .map((e) => RecipeItem.fromMap(Map<String, dynamic>.from(e)))
              .where((r) => r.ingredientId.isNotEmpty && r.quantity > 0)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'outOfStock': outOfStock,
      'recipe': recipe.map((r) => r.toMap()).toList(),
    };
  }
}
