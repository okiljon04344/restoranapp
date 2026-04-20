import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String orderType;
  final String tableName;
  final int tableNumber;
  final List<OrderItemModel> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.tableName,
    required this.tableNumber,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'orderType': orderType,
      'tableName': tableName,
      'tableNumber': tableNumber,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      orderNumber: data['orderNumber'] ?? '',
      orderType: data['orderType'] ?? '',
      tableName: data['tableName'] ?? '',
      tableNumber: data['tableNumber'] ?? 0,
      items: (data['items'] as List? ?? [])
          .map((i) => OrderItemModel.fromMap(i as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num? ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      orderType: orderType,
      tableName: tableName,
      tableNumber: tableNumber,
      items: items,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
