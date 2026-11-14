import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/feedback.dart';
import '../../../core/widgets/async_view.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/data/orders_repository.dart';
import '../../orders/presentation/order_status_ui.dart';

/// Open bills grouped by table. Staff record the payment here: closing a
/// bill marks every served order of the table as paid and frees the table.
class TableBillsView extends ConsumerWidget {
  const TableBillsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncView<List<OrderModel>>(
      value: ref.watch(activeOrdersProvider),
      onRetry: () => ref.invalidate(activeOrdersProvider),
      data: (orders) {
        final byTable = <int, List<OrderModel>>{};
        for (final order in orders) {
          byTable.putIfAbsent(order.tableNumber, () => []).add(order);
        }
        if (byTable.isEmpty) {
          return EmptyNotice(
              message: l.noOpenBills, icon: Icons.receipt_long_outlined);
        }
        final tables = byTable.keys.toList()..sort();
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final table in tables)
              SizedBox(
                width: 360,
                child: _BillCard(
                    tableNumber: table, orders: byTable[table] ?? const []),
              ),
          ],
        );
      },
    );
  }
}

class _BillCard extends ConsumerWidget {
  const _BillCard({required this.tableNumber, required this.orders});

  final int tableNumber;
  final List<OrderModel> orders;

  Future<void> _close(BuildContext context, WidgetRef ref, double total) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.closeBill,
      message: l.confirmCloseBill('$tableNumber', formatMoney(l, total)),
    );
    if (!confirmed || !context.mounted) return;
    await runAction(
      context,
      () => ref.read(ordersRepositoryProvider).closeTableBill(tableNumber),
      successMessage: l.billClosed('$tableNumber'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final total = orders.fold<double>(0, (sum, o) => sum + o.total);
    final allServed = orders.every((o) => o.status == OrderStatus.served);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.tableWithNumber('$tableNumber'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            for (final order in orders)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l.orderNumberLabel(order.orderNumber)} · ${formatMoney(l, order.total)}',
                      ),
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.billTotal),
                Text(
                  formatMoney(l, total),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    allServed ? () => _close(context, ref, total) : null,
                icon: const Icon(Icons.payments_outlined),
                label: Text(l.closeBill),
              ),
            ),
            if (!allServed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.errBillNotReady,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
