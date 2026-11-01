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

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('cafes').doc(_cafeId).collection('orders');

  /// Marks an order as cancelled. Uses the same `cafes/{cafe}/orders` path
  /// the customer and kitchen screens read from.
  Future<void> cancelOrder(String orderId) async {
    await _orders.doc(orderId).update({'status': 'cancelled'});
  }

  /// The dashboard's "resolved" action for a staff call. Marks the call as
  /// resolved in `cafes/{cafe}/calls` so it leaves the pending stream.
  Future<void> deleteStaffCall(String callId) => resolveCall(callId);
}
