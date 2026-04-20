import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../orders/domain/order_providers.dart';
import '../../domain/staff_calls_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final orders = ref.watch(ordersProvider);
    final staffCallsAsync = ref.watch(staffCallsProvider);

    return AppScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.restaurant_menu),
          tooltip: 'Menu Management',
          onPressed: () => context.go('/admin/menu'),
        ),
        IconButton(
          icon: const Icon(Icons.cancel),
          tooltip: 'Cancel Order by Table',
          onPressed: () => _showCancelOrderDialog(context, ref),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatGrid(
            categoryCount: categoriesAsync.value?.length ?? 0,
            itemCount: itemsAsync.value?.length ?? 0,
            orderCount: orders.length,
          ),
          const SizedBox(height: 24),
          // STAFF CALLS SECTION
          staffCallsAsync.when(
            data: (calls) => calls.isNotEmpty
                ? Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone_in_talk,
                              color: Colors.red, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Staff Calls',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${calls.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...calls.map((call) => _StaffCallCard(
                            call: call,
                            onResolve: () =>
                                _resolveStaffCall(ref, call.id, context),
                          )),
                      const SizedBox(height: 24),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          // ORDERS SECTION
          const Text(
            'Active Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(16), child: Text('No orders yet'))),
          ...orders.take(10).map((order) => _OrderCard(
                order: order,
                onCancel: () => _confirmCancelOrder(context, ref, order),
              )),
        ],
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context, WidgetRef ref) {
    final tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Cancel Order by Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter table number:'),
            const SizedBox(height: 12),
            TextField(
              controller: tableController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '1, 2, 3...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.table_restaurant),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final tableNum = int.tryParse(tableController.text.trim());
              if (tableNum != null) {
                await _cancelOrderByTable(ref, tableNum, context);
                if (!context.mounted) return;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Table number must be a number')),
                );
              }
            },
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrderByTable(
      WidgetRef ref, int tableNum, BuildContext context) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final orders = ref.read(ordersProvider);

    try {
      final order = orders.firstWhere((o) =>
          o.tableNumber == tableNum &&
          (o.status == 'pending' ||
              o.status == 'preparing' ||
              o.status == 'ready'));

      await firestoreService.cancelOrder(order.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table #$tableNum order cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No active order found for this table')),
      );
    }
  }

  Future<void> _resolveStaffCall(
      WidgetRef ref, String callId, BuildContext context) async {
    final db = FirebaseFirestore.instance;
    try {
      await db
          .collection('cafes')
          .doc('main_cafe')
          .collection('calls')
          .doc(callId)
          .update({'status': 'resolved'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff call resolved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmCancelOrder(BuildContext context, WidgetRef ref, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm'),
        content: Text('Cancel order for table #${order.tableNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () async {
              await _cancelOrderDirectly(ref, order.id, context);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrderDirectly(
      WidgetRef ref, String orderId, BuildContext context) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    try {
      await firestoreService.cancelOrder(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onCancel;

  const _OrderCard({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      child: ListTile(
        title: Text('Order #${order.orderNumber}'),
        subtitle: Text('Table #${order.tableNumber} • ${order.status}'),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(fontSize: 11, color: statusColor),
                    ),
                  ),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onCancel,
                    child: const Text('Cancel'),
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

class _StaffCallCard extends StatelessWidget {
  final StaffCall call;
  final VoidCallback onResolve;

  const _StaffCallCard({required this.call, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.phone_callback, color: Colors.white),
        ),
        title: Text(
          'Table #${call.tableNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Called at ${call.createdAt.hour}:${call.createdAt.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        trailing: FilledButton.tonal(
          onPressed: onResolve,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade100,
          ),
          child: const Text(
            'Resolve',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final int categoryCount;
  final int itemCount;
  final int orderCount;

  const _StatGrid(
      {required this.categoryCount,
      required this.itemCount,
      required this.orderCount});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
            title: 'Categories',
            value: '$categoryCount',
            icon: Icons.category,
            color: Colors.blue),
        _StatCard(
            title: 'Menu Items',
            value: '$itemCount',
            icon: Icons.fastfood,
            color: Colors.orange),
        _StatCard(
            title: 'Active Orders',
            value: '$orderCount',
            icon: Icons.receipt,
            color: Colors.green),
        _StatCard(
            title: 'System',
            value: 'Live',
            icon: Icons.settings,
            color: Colors.grey),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
