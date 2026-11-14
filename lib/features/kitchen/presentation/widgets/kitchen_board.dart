import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../models/order_model.dart';
import '../../../../models/order_status.dart';
import '../../../orders/application/order_providers.dart';
import '../../../orders/data/orders_repository.dart';

/// Ids of orders with a write in flight; their buttons are disabled so a
/// double tap cannot fire the same transition twice.
final _busyOrdersProvider = StateProvider<Set<String>>((ref) => const {});

/// Kitchen display: new, cooking and ready orders with the action that moves
/// each one to the next stage. Columns side by side on wide screens.
class KitchenBoard extends ConsumerWidget {
  const KitchenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncView<List<OrderModel>>(
      value: ref.watch(activeOrdersProvider),
      onRetry: () => ref.invalidate(activeOrdersProvider),
      data: (orders) {
        // Oldest first: the kitchen works through the queue in order.
        List<OrderModel> stage(String status) =>
            orders.where((o) => o.status == status).toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        final sections = [
          _Stage(
            title: l.newOrders,
            color: Colors.red,
            orders: stage(OrderStatus.pending),
          ),
          _Stage(
            title: l.cooking,
            color: Colors.orange,
            orders: stage(OrderStatus.preparing),
          ),
          _Stage(
            title: l.ready,
            color: Colors.green,
            orders: stage(OrderStatus.ready),
          ),
        ];

        return LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in sections)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: section,
                    ),
                  ),
              ],
            );
          }
          return Column(
            children: [
              for (final section in sections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: section,
                ),
            ],
          );
        });
      },
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.title,
    required this.color,
    required this.orders,
  });

  final String title;
  final Color color;
  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${orders.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: color,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Text(context.l10n.noOrdersInStage,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        for (final order in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OrderCard(order: order, color: color),
          ),
      ],
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.color});

  final OrderModel order;
  final Color color;

  Future<void> _run(BuildContext context, WidgetRef ref,
      Future<void> Function(OrdersRepository repo) action) async {
    final busy = ref.read(_busyOrdersProvider.notifier);
    busy.state = {...busy.state, order.id};
    await runAction(context, () => action(ref.read(ordersRepositoryProvider)));
    busy.state = {...busy.state}..remove(order.id);
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.cancelOrder,
      message: l.confirmCancelTableOrder('${order.tableNumber}'),
    );
    if (!confirmed || !context.mounted) return;
    await _run(context, ref, (repo) => repo.cancelOrder(order.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isBusy = ref.watch(_busyOrdersProvider).contains(order.id);

    final (String label, Future<void> Function(OrdersRepository) next) =
        switch (order.status) {
      OrderStatus.pending => (
          l.startCooking,
          (repo) => repo.acceptOrder(order.id)
        ),
      OrderStatus.preparing => (
          l.markReady,
          (repo) => repo.markReady(order.id)
        ),
      _ => (l.markServed, (repo) => repo.markServed(order.id)),
    };
    final canCancel =
        OrderStatus.canTransition(order.status, OrderStatus.cancelled);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.tableWithNumber('${order.tableNumber}'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(formatTime(order.createdAt),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Text(l.orderNumberLabel(order.orderNumber),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(height: 20),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${item.quantity}x ${item.name}',
                    style: const TextStyle(fontSize: 16)),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed:
                        isBusy ? null : () => _run(context, ref, next),
                    child: Text(label),
                  ),
                ),
                if (canCancel) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isBusy ? null : () => _cancel(context, ref),
                    icon: const Icon(Icons.cancel_outlined),
                    color: Colors.red,
                    tooltip: l.cancelOrder,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
