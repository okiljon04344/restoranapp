import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../orders/domain/order_providers.dart';

class AdminKitchenPage extends ConsumerWidget {
  const AdminKitchenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final currentStatus = ref.watch(_statusFilterProvider);

    // Filter orders by status
    final filteredOrders = orders
        .where((o) => currentStatus == 'all' ? true : o.status == currentStatus)
        .toList();

    // Sort by table and created time
    filteredOrders.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));

    return AppScaffold(
      title: 'Kitchen Orders',
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          child: Row(
            children: [
              _StatusFilter(
                currentStatus: currentStatus,
                onStatusChanged: (status) {
                  ref.read(_statusFilterProvider.notifier).state = status;
                },
              ),
            ],
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Summary cards
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _KitchenStat(
                    label: 'Pending',
                    value: orders
                        .where((o) => o.status == 'pending')
                        .length
                        .toString(),
                    color: Colors.orange,
                    icon: Icons.schedule,
                  ),
                  _KitchenStat(
                    label: 'Preparing',
                    value: orders
                        .where((o) => o.status == 'preparing')
                        .length
                        .toString(),
                    color: Colors.blue,
                    icon: Icons.restaurant,
                  ),
                  _KitchenStat(
                    label: 'Ready',
                    value: orders
                        .where((o) => o.status == 'ready')
                        .length
                        .toString(),
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Orders grid for kitchen display
              if (filteredOrders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No orders at the moment',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 1200 ? 4 : 2,
                    childAspectRatio: 1,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _KitchenOrderCard(order: order);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final _statusFilterProvider = StateProvider<String>((ref) => 'all');

class _StatusFilter extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const _StatusFilter({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['all', 'pending', 'preparing', 'ready'].map((status) {
        final isSelected = currentStatus == status;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton.tonal(
            onPressed: () => onStatusChanged(status),
            style: FilledButton.styleFrom(
              backgroundColor: isSelected
                  ? _getStatusColor(status)
                  : Colors.grey.withValues(alpha: 0.2),
              foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            child: Text(status.toUpperCase()),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final dynamic order;
  const _KitchenOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order number and table
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Table ${order.tableNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Items list
              Expanded(
                child: ListView(
                  children: order.items
                      .map<Widget>((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '${item.quantity}x ${item.name}',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Status and time
              Divider(color: statusColor.withValues(alpha: 0.3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${order.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _KitchenStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _KitchenStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
