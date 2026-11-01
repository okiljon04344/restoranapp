import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../../../models/staff_call_model.dart';

final adminRepositoryProvider =
    Provider((ref) => AdminRepository(ref.watch(firestoreProvider)));

/// Firestore access for the admin dashboard: staff calls and the dashboard's
/// order/call actions.
class AdminRepository {
  AdminRepository(this._db);

  final FirebaseFirestore _db;
  static const _cafeId = 'main_cafe';

  CollectionReference<Map<String, dynamic>> get _calls =>
      _db.collection('cafes').doc(_cafeId).collection('calls');

  /// Pending staff calls, newest first (max 20).
  Stream<List<StaffCall>> watchPendingStaffCalls() {
    return _calls
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StaffCall.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> callStaff(int tableNumber) async {
    await _calls.add({
      'tableNumber': tableNumber,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveCall(String callId) async {
    await _calls.doc(callId).update({'status': 'resolved'});
  }

  /// Marks an order in the top-level `orders` collection as cancelled.
  ///
  /// Kept as the dashboard has always done it; note that the order streams
  /// elsewhere read from `cafes/main_cafe/orders`.
  Future<void> cancelOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'cancelled'});
  }

  /// Deletes a document from the top-level `staff_calls` collection (the
  /// dashboard's "resolve" action).
  Future<void> deleteStaffCall(String callId) async {
    await _db.collection('staff_calls').doc(callId).delete();
  }
}
