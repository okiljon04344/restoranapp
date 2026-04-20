import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final staffCallsProvider = StreamProvider<List<StaffCall>>((ref) {
  final db = FirebaseFirestore.instance;
  const cafeId = 'main_cafe';

  return db
      .collection('cafes')
      .doc(cafeId)
      .collection('calls')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => StaffCall.fromFirestore(doc.data(), doc.id))
          .toList());
});

class StaffCall {
  final String id;
  final int tableNumber;
  final String status;
  final DateTime createdAt;

  StaffCall({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.createdAt,
  });

  factory StaffCall.fromFirestore(Map<String, dynamic> data, String id) {
    return StaffCall(
      id: id,
      tableNumber: data['tableNumber'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
