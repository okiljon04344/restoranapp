import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../models/order_model.dart';
import '../../../../models/order_status.dart';
import '../../../orders/application/order_providers.dart';
import '../../../orders/data/orders_repository.dart';
import '../../../orders/presentation/order_status_ui.dart';

final _orderSearchProvider = StateProvider<String>((ref) => '');
final _orderStatusFilterProvider = StateProvider<String?>((ref) => null);

/// Admin: every order of the last seven days with search, status filter and
/// cancellation of orders that are not out of the kitchen yet.
class OrdersAdminView extends ConsumerWidget {
  const OrdersAdminView({super.key});

  Future<void> _cancel(
      BuildContext context, WidgetRef ref, OrderModel order) async {
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.cancelOrder,
      message: l.confirmCancelTableOrder('${order.tableNumber}'),
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
    final query = ref.watch(_orderSearchProvider).trim().toLowerCase();
    final statusFilter = ref.watch(_orderStatusFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: (value) =>
                    ref.read(_orderSearchProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: l.searchOrdersHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            DropdownButton<String?>(
              value: statusFilter,
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(l.all)),
                for (final status in OrderStatus.all)
                  DropdownMenuItem<String?>(
                    value: status,
                    child: Text(orderStatusLabel(l, status)),
                  ),
              ],
              onChanged: (value) =>
                  ref.read(_orderStatusFilterProvider.notifier).state = value,
            ),
          ],
        ),
        const SizedBox(height: 16),
        AsyncView<List<OrderModel>>(
          value: ref.watch(recentOrdersProvider),
          onRetry: () => ref.invalidate(recentOrdersProvider),
          data: (orders) {
            final filtered = orders.where((o) {
              final matchesStatus =
                  statusFilter == null || o.status == statusFilter;
              final matchesQuery = query.isEmpty ||
                  o.orderNumber.toLowerCase().contains(query) ||
                  '${o.tableNumber}' == query;
              return matchesStatus && matchesQuery;
            }).toList();
            if (filtered.isEmpty) {
              return EmptyNotice(message: l.noOrdersFound);
            }
            return Column(
              children: [
                for (final order in filtered)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(
                        '${l.tableWithNumber('${order.tableNumber}')} · ${l.orderNumberLabel(order.orderNumber)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${_formatDate(order.createdAt)} · ${formatMoney(l, order.total)}',
                      ),
                      trailing: OrderStatusBadge(status: order.status),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in order.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                        '${item.quantity}x ${item.name}')),
                                Text(formatMoney(l, item.total)),
                              ],
                            ),
                          ),
                        if (OrderStatus.canTransition(
                            order.status, OrderStatus.cancelled))
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _cancel(context, ref, order),
                              icon: const Icon(Icons.cancel_outlined),
                              label: Text(l.cancelOrder),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _formatDate(DateTime time) =>
    '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${formatTime(time)}';
