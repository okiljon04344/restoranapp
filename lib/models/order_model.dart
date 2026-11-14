import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/cafe_refs.dart';
import 'order_item_model.dart';
import 'order_status.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String orderType;
  final int tableNumber;

  /// Uid of the (anonymous) customer session that placed the order.
  final String customerUid;
  final List<OrderItemModel> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;

  /// Ingredient quantities taken from stock when the kitchen accepted the
  /// order; used to put them back if the order is cancelled afterwards.
  final Map<String, double> stockDeductions;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.tableNumber,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.customerUid = '',
    this.paidAt,
    this.stockDeductions = const {},
  });

  static String tableDocId(int tableNumber) => 'table_$tableNumber';

  bool get isActive => OrderStatus.isActive(status);

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'orderType': orderType,
      'tableId': tableDocId(tableNumber),
      'tableNumber': tableNumber,
      'customerUid': customerUid,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    final rawItems = data['items'];
    final rawDeductions = data['stockDeductions'];
    return OrderModel(
      id: id,
      orderNumber: readString(data['orderNumber']),
      orderType: readString(data['orderType']),
      tableNumber: readInt(data['tableNumber']),
      customerUid: readString(data['customerUid']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((i) => OrderItemModel.fromMap(Map<String, dynamic>.from(i)))
              .toList()
          : const [],
      total: readDouble(data['total']),
      status: OrderStatus.normalize(data['status']),
      // A pending server timestamp is null in the local snapshot.
      createdAt: readDate(data['createdAt']) ?? DateTime.now(),
      paidAt: readDate(data['paidAt']),
      stockDeductions: rawDeductions is Map
          ? {
              for (final e in rawDeductions.entries)
                '${e.key}': readDouble(e.value),
            }
          : const {},
    );
  }
}
