import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/domain/order_providers.dart';
import '../../domain/table_provider.dart';

class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tableId = ref.watch(tableIdProvider);
    final orders = ref.watch(ordersProvider);

    final tableOrders = orders
        .where((o) => o.tableNumber == int.tryParse(tableId ?? '0'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.table} ${tableId ?? '-'} - ${l.orders}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/customer'),
        ),
      ),
      body: tableOrders.isEmpty
          ? Center(
              child: Text(
                l.noActiveOrders,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tableOrders.length,
                  itemBuilder: (context, index) {
                    final order = tableOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.id.substring(0, 5)}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                _OrderStatusBadge(status: order.status),
                              ],
                            ),
                            const Divider(height: 24),
                            for (final item in order.items)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.quantity}x ${item.name}'),
                                    Text(item.total.toStringAsFixed(0)),
                                  ],
                                ),
                              ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l.subtotal,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  order.total.toStringAsFixed(0),
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: tableOrders.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.billRequested)),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(l.requestBill),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final label = switch (status) {
      'pending' => l.statusPreparing,
      'ready' => l.ready,
      'delivered' => l.statusDelivered,
      _ => status,
    };

    return StatusBadge(
      label: label,
      color: context.palette.statusColor(Theme.of(context).colorScheme, status),
    );
  }
}
