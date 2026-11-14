import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/admin/data/ingredients_repository.dart';
import 'package:restaurant_universal_app/features/menu/data/menu_repository.dart';
import 'package:restaurant_universal_app/models/recipe_item_model.dart';

void main() {
  late FakeFirebaseFirestore db;
  late IngredientsRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = IngredientsRepository(db);
  });

  test('add writes to cafes/main_cafe/ingredients and watchAll reads back',
      () async {
    await repo.add(name: 'Rice', unit: 'kg', quantity: 10, minimumQuantity: 2);
    await repo.add(name: 'Carrot', unit: 'kg', quantity: 5, minimumQuantity: 1);

    final raw = await db
        .collection('cafes')
        .doc('main_cafe')
        .collection('ingredients')
        .get();
    expect(raw.docs, hasLength(2));

    final all = await repo.watchAll().first;
    expect(all.map((i) => i.name), ['Carrot', 'Rice']); // ordered by name
    expect(all.last.quantity, 10);
    expect(all.last.isLow, isFalse);
  });

  test('update changes fields and reports low stock', () async {
    await repo.add(name: 'Rice', unit: 'kg', quantity: 10, minimumQuantity: 2);
    final id = (await repo.watchAll().first).single.id;

    await repo.update(id,
        name: 'Basmati', unit: 'kg', quantity: 1, minimumQuantity: 2);

    final updated = (await repo.watchAll().first).single;
    expect(updated.name, 'Basmati');
    expect(updated.quantity, 1);
    expect(updated.isLow, isTrue);
  });

  test('delete removes the document', () async {
    await repo.add(name: 'Rice', unit: 'kg', quantity: 10, minimumQuantity: 2);
    final id = (await repo.watchAll().first).single.id;

    await repo.delete(id);

    expect(await repo.watchAll().first, isEmpty);
  });

  test('isLow is true at or below the minimum quantity', () async {
    await repo.add(name: 'Plenty', unit: 'kg', quantity: 10, minimumQuantity: 2);
    await repo.add(name: 'AtMinimum', unit: 'l', quantity: 2, minimumQuantity: 2);
    await repo.add(name: 'Empty', unit: 'dona', quantity: 0, minimumQuantity: 5);

    final low = (await repo.watchAll().first).where((i) => i.isLow);

    expect(low.map((i) => i.name).toSet(), {'AtMinimum', 'Empty'});
  });

  test('editing stock refreshes the outOfStock flag of dependent menu items',
      () async {
    final menu = MenuRepository(db);
    final riceId =
        await repo.add(name: 'Rice', unit: 'kg', quantity: 1, minimumQuantity: 0);
    final categoryId = await menu.createCategory(name: 'Main', sortOrder: 0);
    await menu.createMenuItem(
      name: 'Plov',
      description: '',
      price: 30,
      categoryId: categoryId,
      recipe: const [RecipeItem(ingredientId: 'placeholder', quantity: 1)],
    );
    final itemId = (await menu.watchMenuItems().first).single.id;
    await menu.updateMenuItem(
      itemId,
      name: 'Plov',
      description: '',
      price: 30,
      categoryId: categoryId,
      imageUrl: '',
      recipe: [RecipeItem(ingredientId: riceId, quantity: 0.5)],
    );
    expect((await menu.watchMenuItems().first).single.outOfStock, isFalse);

    // Less than one portion left: the item is flagged.
    await repo.update(riceId,
        name: 'Rice', unit: 'kg', quantity: 0.4, minimumQuantity: 0);
    expect((await menu.watchMenuItems().first).single.outOfStock, isTrue);
    expect((await menu.watchMenuItems().first).single.canOrder, isFalse);

    // Restocked: the flag clears again.
    await repo.update(riceId,
        name: 'Rice', unit: 'kg', quantity: 5, minimumQuantity: 0);
    expect((await menu.watchMenuItems().first).single.outOfStock, isFalse);
  });
}
