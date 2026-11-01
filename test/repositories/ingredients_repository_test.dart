import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/admin/data/ingredients_repository.dart';

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
    expect(all.last.isOutOfStock, isFalse);
  });

  test('update changes fields and recomputes isOutOfStock', () async {
    await repo.add(name: 'Rice', unit: 'kg', quantity: 10, minimumQuantity: 2);
    final id = (await repo.watchAll().first).single.id;

    await repo.update(id,
        name: 'Basmati', unit: 'kg', quantity: 1, minimumQuantity: 2);

    final updated = (await repo.watchAll().first).single;
    expect(updated.name, 'Basmati');
    expect(updated.quantity, 1);
    expect(updated.isOutOfStock, isTrue);
  });

  test('delete removes the document', () async {
    await repo.add(name: 'Rice', unit: 'kg', quantity: 10, minimumQuantity: 2);
    final id = (await repo.watchAll().first).single.id;

    await repo.delete(id);

    expect(await repo.watchAll().first, isEmpty);
  });

  test('watchLowStock returns only items at or below their minimum', () async {
    await repo.add(name: 'Plenty', unit: 'kg', quantity: 10, minimumQuantity: 2);
    await repo.add(name: 'AtMinimum', unit: 'l', quantity: 2, minimumQuantity: 2);
    await repo.add(name: 'Empty', unit: 'dona', quantity: 0, minimumQuantity: 5);

    final low = await repo.watchLowStock().first;

    expect(low.map((i) => i.name).toSet(), {'AtMinimum', 'Empty'});
  });
}
