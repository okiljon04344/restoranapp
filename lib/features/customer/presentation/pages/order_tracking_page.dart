import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/table_provider.dart';
import '../../../orders/domain/order_providers.dart';

class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableId = ref.watch(tableIdProvider);
    final orders = ref.watch(ordersProvider);

    final tableOrders = orders
        .where((o) => o.tableNumber == int.tryParse(tableId ?? '0'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableId - Orders'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/customer'),
        ),
      ),
      body: tableOrders.isEmpty
          ? const Center(child: Text('No active orders for this table.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tableOrders.length,
              itemBuilder: (context, index) {
                final order = tableOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            _StatusBadge(status: order.status),
                          ],
                        ),
                        const Divider(height: 24),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${item.name}'),
                                  Text(
                                      '${(item.price * item.quantity).toStringAsFixed(0)}'),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${order.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: tableOrders.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Waitress notified for the bill.')),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Request Bill'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Preparing';
        break;
      case 'ready':
        color = Colors.green;
        text = 'Ready';
        break;
      case 'delivered':
        color = Colors.blue;
        text = 'Delivered';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
