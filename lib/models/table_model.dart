import '../core/cafe_refs.dart';

class TableModel {
  final String id;
  final String name;
  final int number;
  final bool isActive;

  const TableModel({
    required this.id,
    required this.name,
    required this.number,
    required this.isActive,
  });

  factory TableModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TableModel(
      id: id,
      name: readString(data['name']),
      // `tableNumber` was written by an earlier version of the QR page.
      number: readInt(data['number'] ?? data['tableNumber']),
      isActive: readBool(data['isActive'], fallback: true),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'number': number,
      'isActive': isActive,
    };
  }
}
