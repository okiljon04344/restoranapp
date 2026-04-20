import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../orders/domain/order_providers.dart';
import '../../domain/staff_calls_provider.dart';
import '../../domain/analytics_provider.dart';
import '../../../auth/domain/auth_provider.dart';

final _orderSearchProvider = StateProvider<String>((ref) => '');
final _orderStatusFilterProvider = StateProvider<String>((ref) => 'all');

class AdminDashboardPageEnhanced extends ConsumerWidget {
  const AdminDashboardPageEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final orders = ref.watch(ordersProvider);
    final staffCallsAsync = ref.watch(staffCallsProvider);
    final analytics = ref.watch(analyticsProvider);
    final searchQuery = ref.watch(_orderSearchProvider);
    final statusFilter = ref.watch(_orderStatusFilterProvider);

    // Apply filters
    var filteredOrders = orders;
    if (statusFilter != 'all') {
      filteredOrders =
          filteredOrders.where((o) => o.status == statusFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((o) =>
              o.tableNumber.toString().contains(searchQuery) ||
              o.orderNumber.toString().contains(searchQuery) ||
              o.id.contains(searchQuery))
          .toList();
    }

    final todayStats = analytics.getTodayStats(orders);
    final topItems = analytics.getTopItems(orders);

    return AppScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code),
          tooltip: 'QR Code Generator',
          onPressed: () => context.go('/admin/qr'),
        ),
        IconButton(
          icon: const Icon(Icons.restaurant_menu),
          tooltip: 'Menu Management',
          onPressed: () => context.go('/admin/menu'),
        ),
        IconButton(
          icon: const Icon(Icons.restaurant),
          tooltip: 'Kitchen Orders',
          onPressed: () => context.go('/admin/kitchen'),
        ),
        IconButton(
          icon: const Icon(Icons.cancel),
          tooltip: 'Cancel Order',
          onPressed: () => _showCancelOrderDialog(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _showLogoutDialog(context, ref),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TODAY'S REVENUE SECTION
            _RevenueCard(
              title: 'Today\'s Revenue',
              revenue: todayStats['totalRevenue'],
              orders: todayStats['totalOrders'],
              avgOrder: todayStats['avgOrderValue'],
            ),
            const SizedBox(height: 20),

            // STATISTICS GRID
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _StatCard(
                  title: 'Pending',
                  value: '${todayStats['pendingOrders']}',
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Completed',
                  value: '${todayStats['completedOrders']}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Menu Items',
                  value: '${itemsAsync.value?.length ?? 0}',
                  icon: Icons.fastfood,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Categories',
                  value: '${categoriesAsync.value?.length ?? 0}',
                  icon: Icons.category,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // TOP ITEMS
            if (topItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: topItems
                            .take(5)
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${item.orderCount}x',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // STAFF CALLS SECTION
            staffCallsAsync.when(
              data: (calls) => calls.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

            // ORDERS FILTER & SEARCH
            const Text(
              'Active Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Search & Filter Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      ref.read(_orderSearchProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by table, order ID...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: statusFilter,
                  items: ['all', 'pending', 'preparing', 'ready', 'completed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(_orderStatusFilterProvider.notifier).state =
                          value;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (filteredOrders.isEmpty)
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No orders found'))),
            ...filteredOrders.take(15).map((order) => _OrderCard(
                  order: order,
                  onCancel: () => _confirmCancelOrder(context, ref, order),
                )),
          ],
        ),
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Table #$tableNum order cancelled')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: No active order found for this table')),
        );
      }
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Siz admin paneldan chiqmoqchisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final repo = ref.read(authRepositoryProvider);
                await repo.signOut();
                if (!context.mounted) return;
                Navigator.pop(context);
                // Router will automatically redirect to login
                context.go('/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }
}

// Widgets
class _RevenueCard extends StatelessWidget {
  final double revenue;
  final int orders;
  final double avgOrder;
  final String title;

  const _RevenueCard({
    required this.revenue,
    required this.orders,
    required this.avgOrder,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${revenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            VerticalDivider(color: Colors.white.withValues(alpha: 0.3)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Orders: $orders',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Avg: ${avgOrder.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
          padding: const EdgeInsets.all(16),
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
              Text(
                title,
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

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onCancel;

  const _OrderCard({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('Order #${order.orderNumber}'),
        subtitle: Text('Table #${order.tableNumber}'),
        trailing: SizedBox(
          width: 140,
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
                      style: TextStyle(fontSize: 10, color: statusColor),
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
  final dynamic call;
  final VoidCallback onResolve;

  const _StaffCallCard({required this.call, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 8),
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
