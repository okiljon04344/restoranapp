import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cafe_refs.dart';
import '../../../core/firebase_providers.dart';
import '../../../models/order_model.dart';
import '../../../models/staff_call_model.dart';

final callsRepositoryProvider =
    Provider((ref) => CallsRepository(ref.watch(firestoreProvider)));

/// "Call staff" and "bring the bill" requests sent from a table.
class CallsRepository {
  CallsRepository(FirebaseFirestore db) : _refs = CafeRefs(db);

  final CafeRefs _refs;

  /// Pending calls, oldest first. Sorted on the client so the query needs no
  /// composite index.
  Stream<List<StaffCall>> watchPending() {
    return _refs.calls
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StaffCall.fromFirestore(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  Future<void> create({
    required int tableNumber,
    required String customerUid,
    String type = StaffCall.typeStaff,
  }) async {
    await _refs.calls.add({
      'tableId': OrderModel.tableDocId(tableNumber),
      'tableNumber': tableNumber,
      'customerUid': customerUid,
      'type': type,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolve(String callId) async {
    await _refs.calls.doc(callId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
