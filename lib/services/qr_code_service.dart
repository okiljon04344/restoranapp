import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final qrCodeServiceProvider = Provider((ref) => QRCodeService());

class QRCodeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String cafeId = "main_cafe";

  // Generate QR code data for a table
  String generateTableQRData(int tableNumber) {
    return 'table_$tableNumber';
  }

  // Parse QR code data
  int? parseTableQRData(String qrData) {
    try {
      if (qrData.startsWith('table_')) {
        return int.parse(qrData.replaceFirst('table_', ''));
      }
      return int.tryParse(qrData);
    } catch (e) {
      return null;
    }
  }

  // Save QR code metadata
  Future<void> saveTableQR(int tableNumber, String qrData) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('tables')
        .doc('table_$tableNumber')
        .set({
      'tableNumber': tableNumber,
      'qrData': qrData,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    }, SetOptions(merge: true));
  }

  // Get all tables QR codes
  Stream<List<TableQR>> getAllTablesQR() {
    return _db
        .collection('cafes')
        .doc(cafeId)
        .collection('tables')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TableQR.fromFirestore(doc.data()))
            .toList());
  }

  // Delete table QR
  Future<void> deleteTableQR(int tableNumber) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('tables')
        .doc('table_$tableNumber')
        .delete();
  }
}

class TableQR {
  final int tableNumber;
  final String qrData;
  final DateTime createdAt;
  final String status;

  TableQR({
    required this.tableNumber,
    required this.qrData,
    required this.createdAt,
    required this.status,
  });

  factory TableQR.fromFirestore(Map<String, dynamic> data) {
    return TableQR(
      tableNumber: data['tableNumber'] ?? 0,
      qrData: data['qrData'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'active',
    );
  }
}
