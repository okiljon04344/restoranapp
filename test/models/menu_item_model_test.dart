import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/models/menu_item_model.dart';

void main() {
  test('fromFirestore converts integer prices to double', () {
    final item = MenuItemModel.fromFirestore(
      {'name': 'Lagman', 'price': 1500, 'categoryId': 'c1'},
      'm1',
    );
    expect(item.price, 1500.0);
    expect(item.description, isEmpty);
    expect(item.imageUrl, isEmpty);
  });

  test('toFirestore / fromFirestore round-trips', () {
    const item = MenuItemModel(
      id: 'm1',
      categoryId: 'c1',
      name: 'Samsa',
      description: 'Baked pastry',
      price: 450.5,
      imageUrl: 'https://example.com/samsa.png',
    );
    final restored = MenuItemModel.fromFirestore(item.toFirestore(), item.id);
    expect(restored.name, item.name);
    expect(restored.price, item.price);
    expect(restored.imageUrl, item.imageUrl);
  });
}
