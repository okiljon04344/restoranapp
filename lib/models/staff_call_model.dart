import 'package:cloud_firestore/cloud_firestore.dart';

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
