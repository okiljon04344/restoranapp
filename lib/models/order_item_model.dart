class OrderItemModel {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] as num? ?? 0).toDouble(),
    );
  }
}
