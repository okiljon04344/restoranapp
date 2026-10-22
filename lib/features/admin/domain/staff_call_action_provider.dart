import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final staffCallActionProvider = Provider<StaffCallActionService>((ref) {
  return StaffCallActionService();
});

class StaffCallActionService {
  final _db = FirebaseFirestore.instance;
  static const _cafeId = 'main_cafe';

  Future<void> callStaff(int tableNumber) async {
    await _db.collection('cafes').doc(_cafeId).collection('calls').add({
      'tableNumber': tableNumber,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveCall(String callId) async {
    await _db
        .collection('cafes')
        .doc(_cafeId)
        .collection('calls')
        .doc(callId)
        .update({'status': 'resolved'});
  }
}
