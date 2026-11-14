import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/tables/data/table_qr_codec.dart';
import 'package:restaurant_universal_app/features/tables/data/tables_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late TablesRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = TablesRepository(db);
  });

  group('TableQrCodec', () {
    test('the generated code is the one the scanner accepts', () {
      expect(TableQrCodec.encode(12), 'table_12');
      expect(TableQrCodec.decode(TableQrCodec.encode(12)), 12);
    });

    test('accepts a typed number and surrounding whitespace', () {
      expect(TableQrCodec.decode(' 7 '), 7);
      expect(TableQrCodec.decode('table_7\n'), 7);
    });

    test('rejects anything that is not a table code', () {
      expect(TableQrCodec.decode('https://example.com'), isNull);
      expect(TableQrCodec.decode('table_'), isNull);
      expect(TableQrCodec.decode('table_x'), isNull);
      expect(TableQrCodec.decode('0'), isNull);
      expect(TableQrCodec.decode('-3'), isNull);
      expect(TableQrCodec.decode(''), isNull);
    });
  });

  test('createTable registers an active table at tables/table_<n>', () async {
    await repo.createTable(3);

    final doc = await db
        .collection('cafes')
        .doc('main_cafe')
        .collection('tables')
        .doc('table_3')
        .get();
    expect(doc.data()?['number'], 3);
    expect(doc.data()?['isActive'], isTrue);
    expect(await repo.lookup(3), TableLookup.ok);
  });

  test('a table number can only be registered once', () async {
    await repo.createTable(3);

    await expectLater(
        repo.createTable(3), throwsA(isA<TableAlreadyExistsException>()));
  });

  test('lookup rejects unknown and disabled tables', () async {
    await repo.createTable(3);

    expect(await repo.lookup(99), TableLookup.notFound);

    await repo.setActive(3, isActive: false);
    expect(await repo.lookup(3), TableLookup.disabled);

    await repo.setActive(3, isActive: true);
    expect(await repo.lookup(3), TableLookup.ok);
  });

  test('watchTables is sorted by number and deleteTable removes a table',
      () async {
    await repo.createTable(10);
    await repo.createTable(2);

    expect((await repo.watchTables().first).map((t) => t.number), [2, 10]);

    await repo.deleteTable(2);
    expect((await repo.watchTables().first).map((t) => t.number), [10]);
    expect(await repo.lookup(2), TableLookup.notFound);
  });
}
