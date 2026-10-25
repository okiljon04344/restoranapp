import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../models/order_model.dart';
import '../../../orders/domain/order_providers.dart';

final _statusFilterProvider = StateProvider<String>((ref) => 'all');

class AdminKitchenPage extends ConsumerWidget {
  const AdminKitchenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final currentStatus = ref.watch(_statusFilterProvider);
    final theme = Theme.of(context);

    final filteredOrders = orders
        .where((o) => currentStatus == 'all' || o.status == currentStatus)
        .toList()
      ..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));

    int countOf(String status) =>
        orders.where((o) => o.status == status).length;

    return AppScaffold(
      title: 'Kitchen Orders',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _StatusFilter(
            currentStatus: currentStatus,
            onStatusChanged: (status) {
              ref.read(_statusFilterProvider.notifier).state = status;
            },
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: StatTile.gridDelegate,
              children: [
                StatTile(
                  label: 'Pending',
                  value: '${countOf('pending')}',
                  icon: Icons.schedule,
                ),
                StatTile(
                  label: 'Preparing',
                  value: '${countOf('preparing')}',
                  icon: Icons.restaurant,
                ),
                StatTile(
                  label: 'Ready',
                  value: '${countOf('ready')}',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (filteredOrders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No orders at the moment',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 280,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) =>
                    _KitchenOrderCard(order: filteredOrders[index]),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  const _StatusFilter({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final status in const ['all', 'pending', 'preparing', 'ready'])
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(status.toUpperCase()),
              selected: currentStatus == status,
              onSelected: (_) => onStatusChanged(status),
              showCheckmark: false,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: currentStatus == status
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
      ],
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final OrderModel order;

  const _KitchenOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        context.palette.statusColor(theme.colorScheme, order.status);
    final minute = order.createdAt.minute.toString().padLeft(2, '0');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: statusColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Table ${order.tableNumber}',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final item in order.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              '${item.quantity}x ${item.name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.status.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${order.createdAt.hour}:$minute',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        order.total.toStringAsFixed(0),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
