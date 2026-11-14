import '../core/cafe_refs.dart';

class StaffCall {
  static const typeStaff = 'staff';
  static const typeBill = 'bill';

  final String id;
  final int tableNumber;
  final String status;

  /// [typeStaff] for "call a waiter", [typeBill] for "bring the bill".
  final String type;
  final DateTime createdAt;

  StaffCall({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.createdAt,
    this.type = typeStaff,
  });

  bool get isBillRequest => type == typeBill;

  factory StaffCall.fromFirestore(Map<String, dynamic> data, String id) {
    return StaffCall(
      id: id,
      tableNumber: readInt(data['tableNumber']),
      status: readString(data['status'], 'pending'),
      type: readString(data['type'], typeStaff),
      createdAt: readDate(data['createdAt']) ?? DateTime.now(),
    );
  }
}
