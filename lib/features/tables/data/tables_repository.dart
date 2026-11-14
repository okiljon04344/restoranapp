import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cafe_refs.dart';
import '../../../core/firebase_providers.dart';
import '../../../models/order_model.dart';
import '../../../models/table_model.dart';

final tablesRepositoryProvider =
    Provider((ref) => TablesRepository(ref.watch(firestoreProvider)));

enum TableLookup { ok, notFound, disabled }

class TableAlreadyExistsException implements Exception {
  const TableAlreadyExistsException();
}

class TablesRepository {
  TablesRepository(FirebaseFirestore db) : _refs = CafeRefs(db);

  final CafeRefs _refs;

  DocumentReference<JsonMap> _doc(int number) =>
      _refs.tables.doc(OrderModel.tableDocId(number));

  Stream<List<TableModel>> watchTables() {
    return _refs.tables.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TableModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number)));
  }

  /// Checks a scanned or typed table number against the registered tables.
  Future<TableLookup> lookup(int number) async {
    final snapshot = await _doc(number).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return TableLookup.notFound;
    final table = TableModel.fromFirestore(data, snapshot.id);
    return table.isActive ? TableLookup.ok : TableLookup.disabled;
  }

  Future<void> createTable(int number, {String name = ''}) async {
    final ref = _doc(number);
    final existing = await ref.get();
    if (existing.exists) throw const TableAlreadyExistsException();
    await ref.set({
      'number': number,
      'name': name,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setActive(int number, {required bool isActive}) async {
    await _doc(number).update({'isActive': isActive});
  }

  Future<void> deleteTable(int number) async {
    await _doc(number).delete();
  }
}
