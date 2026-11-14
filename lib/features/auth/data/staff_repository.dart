import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cafe_refs.dart';
import '../../../core/firebase_providers.dart';
import '../../../models/staff_member_model.dart';

final staffRepositoryProvider =
    Provider((ref) => StaffRepository(ref.watch(firestoreProvider)));

/// Kitchen staff accounts. A new account files a request in
/// `staffRequests/{uid}`; an admin approves it, which creates `staff/{uid}`
/// (the document the security rules check for the kitchen role).
class StaffRepository {
  StaffRepository(this._db) : _refs = CafeRefs(_db);

  final FirebaseFirestore _db;
  final CafeRefs _refs;

  List<StaffMember> _map(QuerySnapshot<JsonMap> snapshot) => snapshot.docs
      .map((doc) => StaffMember.fromFirestore(doc.data(), doc.id))
      .toList()
    ..sort((a, b) => a.email.compareTo(b.email));

  Stream<List<StaffMember>> watchStaff() => _refs.staff.snapshots().map(_map);

  Stream<List<StaffMember>> watchRequests() =>
      _refs.staffRequests.snapshots().map(_map);

  Future<void> submitRequest({required String uid, required String email}) {
    return _refs.staffRequests.doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approve(StaffMember request) async {
    final batch = _db.batch()
      ..set(_refs.staff.doc(request.uid), {
        'email': request.email,
        'role': 'kitchen',
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..delete(_refs.staffRequests.doc(request.uid));
    await batch.commit();
  }

  Future<void> reject(String uid) => _refs.staffRequests.doc(uid).delete();

  Future<void> revoke(String uid) => _refs.staff.doc(uid).delete();
}
