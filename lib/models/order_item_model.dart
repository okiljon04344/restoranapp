import '../core/cafe_refs.dart';

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

  OrderItemModel copyWith({String? name, int? quantity, double? price}) =>
      OrderItemModel(
        menuItemId: menuItemId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
      );

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
      menuItemId: readString(map['menuItemId']),
      name: readString(map['name']),
      quantity: readInt(map['quantity']),
      price: readDouble(map['price']),
    );
  }
}
