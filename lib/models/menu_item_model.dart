class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory MenuItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      id: id,
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num? ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
