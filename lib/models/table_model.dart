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
      name: data['name'] ?? '',
      number: data['number'] ?? 0,
      isActive: data['isActive'] ?? true,
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
