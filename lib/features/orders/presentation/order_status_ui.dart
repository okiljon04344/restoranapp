import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/order_status.dart';

String orderStatusLabel(AppLocalizations l, String status) => switch (status) {
      OrderStatus.pending => l.statusPending,
      OrderStatus.preparing => l.statusPreparing,
      OrderStatus.ready => l.statusReady,
      OrderStatus.served => l.statusServed,
      OrderStatus.paid => l.statusPaid,
      OrderStatus.cancelled => l.statusCancelled,
      _ => status,
    };

Color orderStatusColor(String status) => switch (status) {
      OrderStatus.pending => Colors.orange,
      OrderStatus.preparing => Colors.blue,
      OrderStatus.ready => Colors.green,
      OrderStatus.served => Colors.teal,
      OrderStatus.paid => Colors.grey,
      OrderStatus.cancelled => Colors.red,
      _ => Colors.grey,
    };

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        l == null ? status : orderStatusLabel(l, status),
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
