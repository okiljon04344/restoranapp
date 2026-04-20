import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/order_model.dart';
import '../../../orders/domain/order_providers.dart';

class KitchenOrdersPage extends ConsumerWidget {
  const KitchenOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // StreamProvider'dan ma'lumotlarni watch qilamiz
    final ordersAsync = ref.watch(ordersStreamProvider);

    return AppScaffold(
      title: l10n.kitchenScreen,
      child: ordersAsync.when(
        data: (orders) {
          final pending = orders.where((e) => e.status == 'pending').toList();
          final cooking = orders.where((e) => e.status == 'cooking').toList();
          final ready = orders.where((e) => e.status == 'ready').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _KitchenSection(
                title: l10n.newOrders,
                orders: pending,
                nextStatus: 'cooking',
                color: Colors.red,
                buttonText: l10n.startCooking,
              ),
              const SizedBox(height: 24),
              _KitchenSection(
                title: l10n.cooking,
                orders: cooking,
                nextStatus: 'ready',
                color: Colors.orange,
                buttonText: l10n.markAsReady,
              ),
              const SizedBox(height: 24),
              _KitchenSection(
                title: l10n.ready,
                orders: ready,
                nextStatus: 'served',
                color: Colors.green,
                buttonText: l10n.markAsServed,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorMessage(err.toString()))),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 24, color: color),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          Text(l10n.noOrdersInStage,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ...orders.map((order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Text(order.tableName.replaceAll(RegExp(r'[^0-9]'), ''),
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
                title: Text(
                    'Order #${order.orderNumber.substring(order.orderNumber.length - 4)}'),
                subtitle: Text(
                    '${order.items.length} ${l10n.items} • ${order.total.toStringAsFixed(0)} ${l10n.currency}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${item.name}',
                                      style: const TextStyle(fontSize: 15)),
                                  const Icon(Icons.check_circle_outline,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            )),
                        const Divider(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            style:
                                FilledButton.styleFrom(backgroundColor: color),
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
            )),
      ],
    );
  }
}
