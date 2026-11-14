import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../models/order_model.dart';
import '../../../../models/order_status.dart';
import '../../../../models/staff_call_model.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../calls/data/calls_repository.dart';
import '../../../orders/application/order_providers.dart';
import '../../../orders/data/orders_repository.dart';
import '../../../orders/presentation/order_status_ui.dart';
import '../../application/table_provider.dart';

/// Live status of the orders this customer session placed.
class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({super.key});

  Future<void> _requestBill(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final tableNumber = ref.read(currentTableProvider);
    if (tableNumber == null) {
      showMessage(context, l.tableRequired, isError: true);
      return;
    }
    await runAction(
      context,
      () async {
        final uid =
            await ref.read(authRepositoryProvider).ensureCustomerSession();
        await ref.read(callsRepositoryProvider).create(
              tableNumber: tableNumber,
              customerUid: uid,
              type: StaffCall.typeBill,
            );
      },
      successMessage: l.billRequested,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tableNumber = ref.watch(currentTableProvider);
    final ordersAsync = ref.watch(customerOrdersProvider);

    // Orders of this visit: everything still open plus what was closed or
    // cancelled during the last 12 hours.
    final cutoff = DateTime.now().subtract(const Duration(hours: 12));
    final orders = (ordersAsync.valueOrNull ?? const <OrderModel>[])
        .where((o) => o.isActive || o.createdAt.isAfter(cutoff))
        .toList();
    final open = orders.where((o) => o.isActive).toList();
    final billTotal = open.fold<double>(0, (sum, o) => sum + o.total);

    return AppScaffold(
      title: tableNumber == null
          ? l.myOrders
          : '${l.tableWithNumber('$tableNumber')} · ${l.myOrders}',
      fallbackLocation: '/customer',
      bottomNavigationBar: open.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.billTotal,
                            style: const TextStyle(fontSize: 16)),
                        Text(
                          formatMoney(l, billTotal),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _requestBill(context, ref),
                      icon: const Icon(Icons.receipt_long),
                      label: Text(l.requestBill),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      child: AsyncView<List<OrderModel>>(
        value: ordersAsync,
        onRetry: () => ref.invalidate(customerOrdersProvider),
        data: (_) => orders.isEmpty
            ? EmptyNotice(
                message: l.noActiveOrders, icon: Icons.receipt_long_outlined)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _OrderCard(order: orders[index]),
              ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.cancelOrder,
      message: l.confirmCancelOrder,
    );
    if (!confirmed || !context.mounted) return;
    await runAction(
      context,
      () => ref.read(ordersRepositoryProvider).cancelOrder(order.id),
      successMessage: l.orderCancelled,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${l.orderNumberLabel(order.orderNumber)} · ${formatTime(order.createdAt)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            if (order.status != OrderStatus.cancelled) ...[
              const SizedBox(height: 12),
              _Progress(status: order.status),
            ],
            const Divider(height: 24),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${item.quantity}x ${item.name}')),
                    Text(formatMoney(l, item.total)),
                  ],
                ),
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.subtotal,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  formatMoney(l, order.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            // Only possible until the kitchen accepts the order.
            if (order.status == OrderStatus.pending)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _cancel(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(l.cancelOrder),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Five-step progress bar: pending, preparing, ready, served, paid.
class _Progress extends StatelessWidget {
  const _Progress({required this.status});

  final String status;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.served,
    OrderStatus.paid,
  ];

  @override
  Widget build(BuildContext context) {
    final current = _steps.indexOf(status);
    final color = orderStatusColor(status);
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 4),
              decoration: BoxDecoration(
                color: i <= current ? color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}
