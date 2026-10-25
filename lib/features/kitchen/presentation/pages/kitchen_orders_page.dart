import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/order_model.dart';
import '../../../orders/domain/order_providers.dart';

class KitchenOrdersPage extends ConsumerWidget {
  const KitchenOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return AppScaffold(
      title: l.kitchenScreen,
      maxContentWidth: 800,
      child: ordersAsync.when(
        data: (orders) {
          List<OrderModel> withStatus(String status) =>
              orders.where((e) => e.status == status).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _KitchenSection(
                title: l.newOrders,
                orders: withStatus('pending'),
                nextStatus: 'cooking',
                color: scheme.primary,
                buttonText: l.startCooking,
              ),
              const SizedBox(height: 32),
              _KitchenSection(
                title: l.cooking,
                orders: withStatus('cooking'),
                nextStatus: 'ready',
                color: palette.warning,
                buttonText: l.markReady,
              ),
              const SizedBox(height: 32),
              _KitchenSection(
                title: l.ready,
                orders: withStatus('ready'),
                nextStatus: 'served',
                color: palette.success,
                buttonText: l.markServed,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _KitchenSection extends ConsumerWidget {
  final String title;
  final List<OrderModel> orders;
  final String nextStatus;
  final Color color;
  final String buttonText;

  const _KitchenSection({
    required this.title,
    required this.orders,
    required this.nextStatus,
    required this.color,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(width: 8),
            Text(
              '${orders.length}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Text(
            AppLocalizations.of(context)?.noOrdersInStage ??
                'No orders in this stage.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (final order in orders)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  order.tableName.replaceAll(RegExp(r'[^0-9]'), ''),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
              title: Text(
                'Order #${order.orderNumber.substring(order.orderNumber.length - 4)}',
              ),
              subtitle: Text(
                "${order.items.length} items • ${order.total.toStringAsFixed(0)} so'm",
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final item in order.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.quantity}x ${item.name}',
                                style: theme.textTheme.bodyLarge,
                              ),
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: theme.colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                      const Divider(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: color),
                          onPressed: () => ref
                              .read(ordersActionProvider)
                              .updateStatus(order.id, nextStatus),
                          child: Text(buttonText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
