import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../orders/application/order_analytics.dart';
import '../../../orders/application/order_providers.dart';
import '../../application/ingredients_provider.dart';

/// Dashboard figures computed from the orders of the last seven days.
class OverviewView extends ConsumerWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lowStock = (ref.watch(ingredientsProvider).valueOrNull ?? const [])
        .where((i) => i.isLow)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.dashboardSubtitle,
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        AsyncView<OrderAnalytics>(
          value: ref.watch(orderAnalyticsProvider),
          onRetry: () => ref.invalidate(recentOrdersProvider),
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    title: l.todayRevenue,
                    value: formatMoney(l, stats.todayRevenue),
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: l.weekRevenue,
                    value: formatMoney(l, stats.weekRevenue),
                    icon: Icons.calendar_view_week,
                    color: Colors.teal,
                  ),
                  _StatCard(
                    title: l.todayOrdersCount,
                    value: '${stats.todayOrders}',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: l.weekOrdersCount,
                    value: '${stats.weekOrders}',
                    icon: Icons.stacked_bar_chart,
                    color: Colors.indigo,
                  ),
                  _StatCard(
                    title: l.averageOrder,
                    value: formatMoney(l, stats.averagePaidOrder),
                    icon: Icons.functions,
                    color: Colors.purple,
                  ),
                  _StatCard(
                    title: l.openOrdersCount,
                    value: '${stats.openOrders}',
                    icon: Icons.hourglass_bottom,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: l.cancelledToday,
                    value: '${stats.todayCancelled}',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l.topOrdered,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (stats.topItems.isEmpty)
                EmptyNotice(message: l.noOrdersFound)
              else
                Card(
                  child: Column(
                    children: [
                      for (final (index, item) in stats.topItems.indexed)
                        ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(item.name),
                          trailing: Text(
                            '× ${item.quantity}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (lowStock.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading:
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: Text(
                l.lowStockAlert('${lowStock.length}'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(lowStock.map((i) => i.name).join(', ')),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
