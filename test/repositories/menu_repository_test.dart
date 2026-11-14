import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/menu/data/menu_repository.dart';
import 'package:restaurant_universal_app/models/recipe_item_model.dart';

void main() {
  late FakeFirebaseFirestore db;
  late MenuRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = MenuRepository(db);
  });

  test('categories and menu items are readable via streams', () async {
    final categoryId = await repo.createCategory(name: 'Soups', sortOrder: 1);
    await repo.createMenuItem(
      name: 'Lagman',
      description: 'Noodles',
      price: 9.5,
      categoryId: categoryId,
    );

    final categories = await repo.watchCategories().first;
    final items = await repo.watchMenuItems().first;
    expect(categories.single.name, 'Soups');
    expect(items.single.name, 'Lagman');
    expect(items.single.price, 9.5);
    expect(items.single.canOrder, isTrue);
  });

  test('a new item whose recipe cannot be covered starts out of stock',
      () async {
    await db
        .collection('cafes')
        .doc('main_cafe')
        .collection('ingredients')
        .doc('rice')
        .set({'name': 'Rice', 'quantity': 0.1});
    final categoryId = await repo.createCategory(name: 'Main', sortOrder: 0);

    await repo.createMenuItem(
      name: 'Plov',
      description: '',
      price: 30,
      categoryId: categoryId,
      recipe: const [RecipeItem(ingredientId: 'rice', quantity: 0.2)],
    );

    final item = (await repo.watchMenuItems().first).single;
    expect(item.recipe.single.quantity, 0.2);
    expect(item.outOfStock, isTrue);
  });

  test('setAvailable takes an item off the menu and back', () async {
    final categoryId = await repo.createCategory(name: 'Main', sortOrder: 0);
    final id = await repo.createMenuItem(
        name: 'Plov', description: '', price: 30, categoryId: categoryId);

    await repo.setAvailable(id, isAvailable: false);
    expect((await repo.watchMenuItems().first).single.canOrder, isFalse);

    await repo.setAvailable(id, isAvailable: true);
    expect((await repo.watchMenuItems().first).single.canOrder, isTrue);
  });

  test('a category with items cannot be deleted', () async {
    final categoryId = await repo.createCategory(name: 'Main', sortOrder: 0);
    final itemId = await repo.createMenuItem(
        name: 'Plov', description: '', price: 30, categoryId: categoryId);

    await expectLater(repo.deleteCategory(categoryId),
        throwsA(isA<CategoryInUseException>()));

    await repo.deleteMenuItem(itemId);
    await repo.deleteCategory(categoryId);
    expect(await repo.watchCategories().first, isEmpty);
  });
}
