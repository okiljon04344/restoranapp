import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonMap = Map<String, dynamic>;

/// Typed access to the Firestore layout used by the app. Everything a single
/// restaurant owns lives under `cafes/{cafeId}`; role documents are top level.
class CafeRefs {
  const CafeRefs(this.db);

  static const cafeId = 'main_cafe';

  final FirebaseFirestore db;

  DocumentReference<JsonMap> get _cafe => db.collection('cafes').doc(cafeId);

  CollectionReference<JsonMap> get orders => _cafe.collection('orders');
  CollectionReference<JsonMap> get menuItems => _cafe.collection('menuItems');
  CollectionReference<JsonMap> get categories => _cafe.collection('categories');
  CollectionReference<JsonMap> get tables => _cafe.collection('tables');
  CollectionReference<JsonMap> get ingredients =>
      _cafe.collection('ingredients');
  CollectionReference<JsonMap> get calls => _cafe.collection('calls');

  CollectionReference<JsonMap> get admins => db.collection('admins');
  CollectionReference<JsonMap> get staff => db.collection('staff');
  CollectionReference<JsonMap> get staffRequests =>
      db.collection('staffRequests');
}

/// Reads a Firestore timestamp field without assuming it is present. A
/// pending `serverTimestamp()` is `null` in the local snapshot.
DateTime? readDate(Object? value) => value is Timestamp ? value.toDate() : null;

double readDouble(Object? value) => value is num ? value.toDouble() : 0;

int readInt(Object? value) => value is num ? value.toInt() : 0;

String readString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

bool readBool(Object? value, {required bool fallback}) =>
    value is bool ? value : fallback;
