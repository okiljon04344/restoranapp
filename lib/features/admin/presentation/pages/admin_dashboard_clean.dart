import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../orders/application/order_providers.dart';
import '../../data/admin_repository.dart';
import '../../application/staff_calls_provider.dart';
import '../../application/analytics_provider.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'admin_ingredients_page.dart';

final _orderSearchProvider = StateProvider<String>((ref) => '');
final _orderStatusFilterProvider = StateProvider<String>((ref) => 'all');
final _audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});
final _selectedSectionProvider = StateProvider<String>((ref) => 'dashboard');

class AdminDashboardClean extends ConsumerWidget {
  const AdminDashboardClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 900;
    final selectedSection = ref.watch(_selectedSectionProvider);

    // Play an alert sound when a new pending staff call arrives.
    ref.listen<AsyncValue<List<StaffCall>>>(staffCallsProvider, (prev, next) {
      final prevLen = prev?.value?.length ?? 0;
      final nextLen = next.value?.length ?? 0;
      if (nextLen > prevLen) {
        ref
            .read(_audioPlayerProvider)
            .play(AssetSource('sounds/notification.wav'));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminPanel),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l.logout,
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      drawer: isMobile ? _buildSidebar(context, ref, selectedSection) : null,
      body: Row(
        children: [
          // Sidebar (Desktop only)
          if (!isMobile)
            Container(
              width: 260,
              color: Colors.grey.shade50,
              child: _buildSidebar(context, ref, selectedSection),
            ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildMainContent(context, ref, selectedSection),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
      BuildContext context, WidgetRef ref, String selectedSection) {
    final l = AppLocalizations.of(context)!;
    final sidebarItems = [
      ('dashboard', Icons.dashboard, l.dashboard),
      ('orders', Icons.receipt, l.orders),
      ('staff_calls', Icons.phone_in_talk, l.staffCalls),
      ('kitchen', Icons.restaurant, l.sidebarKitchen),
      ('ingredients', Icons.inventory_2, l.ingredients),
      ('qr', Icons.qr_code_2, l.qrCodes),
      ('menu', Icons.restaurant_menu, l.menu),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.adminPanel,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l.adminPanelSubtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: sidebarItems
                .map((item) => _buildSidebarItem(
                      context,
                      ref,
                      item.$1,
                      item.$2,
                      item.$3,
                      selectedSection == item.$1,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(BuildContext context, WidgetRef ref, String id,
      IconData icon, String label, bool isSelected) {
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, size: 24),
      title: Text(label),
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        ref.read(_selectedSectionProvider.notifier).state = id;
        if (MediaQuery.of(context).size.width < 900) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildMainContent(
      BuildContext context, WidgetRef ref, String selectedSection) {
    switch (selectedSection) {
      case 'dashboard':
        return _buildDashboardSection(context, ref);
      case 'orders':
        return _buildOrdersSection(context, ref);
      case 'staff_calls':
        return _buildStaffCallsSection(context, ref);
      case 'kitchen':
        return _buildKitchenSection(context, ref);
      case 'ingredients':
        return const AdminIngredientsPage();
      case 'qr':
        return _buildQRSection(context, ref);
      case 'menu':
        return _buildMenuSection(context, ref);
      default:
        return _buildDashboardSection(context, ref);
    }
  }

  Widget _buildDashboardSection(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final orders = ref.watch(ordersProvider);
    final analytics = ref.watch(analyticsProvider);
    final staffCallsAsync = ref.watch(staffCallsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);

    final todayStats = analytics.getTodayStats(orders);
    final topItems = analytics.getTopItems(orders);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dashboard,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l.dashboardSubtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        // Revenue Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.todayRevenue,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${todayStats['totalRevenue'] ?? 0} ${l.som}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.orderCount,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${todayStats['totalOrders'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.averageOrder,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${todayStats['avgOrderValue'] ?? 0} ${l.som}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Statistics Grid
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildStatisticCard(
              title: l.statusPending,
              value: '${todayStats['pendingOrders'] ?? 0}',
              icon: Icons.schedule,
              color: Colors.orange,
            ),
            _buildStatisticCard(
              title: l.statusReady,
              value: '${todayStats['completedOrders'] ?? 0}',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _buildStatisticCard(
              title: l.menuItemsCount,
              value: '${itemsAsync.value?.length ?? 0}',
              icon: Icons.fastfood,
              color: Colors.blue,
            ),
            _buildStatisticCard(
              title: l.categoriesLabel,
              value: '${categoriesAsync.value?.length ?? 0}',
              icon: Icons.category,
              color: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Staff Calls Alert
        staffCallsAsync.when(
          data: (calls) => calls.isNotEmpty
              ? _buildStaffCallsAlert(calls, context, ref)
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),

        // Top Items
        if (topItems.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l.topOrdered,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topItems.length > 5 ? 5 : topItems.length,
                    itemBuilder: (_, idx) {
                      final item = topItems[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${item.orderCount}x',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
    );
  }

  Widget _buildStaffCallsAlert(
      List<StaffCall> calls, BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red.shade50,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_in_talk, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.staffCalls,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${calls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...calls.take(3).map(
                (call) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.table_restaurant, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            Text(l.staffCallAtTable('${call.tableNumber}')),
                      ),
                      FilledButton.tonal(
                        onPressed: () =>
                            _resolveStaffCall(ref, call.id, context),
                        child: Text(l.markDone),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final orders = ref.watch(ordersProvider);
    final searchQuery = ref.watch(_orderSearchProvider);
    final statusFilter = ref.watch(_orderStatusFilterProvider);

    var filteredOrders = orders;
    if (statusFilter != 'all') {
      filteredOrders =
          filteredOrders.where((o) => o.status == statusFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((o) =>
              o.tableNumber.toString().contains(searchQuery) ||
              o.orderNumber.toString().contains(searchQuery))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.orders,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Search & Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  ref.read(_orderSearchProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: l.searchOrdersHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: statusFilter,
              items: [
                DropdownMenuItem(value: 'all', child: Text(l.all)),
                DropdownMenuItem(value: 'pending', child: Text(l.statusPending)),
                DropdownMenuItem(
                    value: 'preparing', child: Text(l.statusPreparing)),
                DropdownMenuItem(value: 'ready', child: Text(l.statusReady)),
                DropdownMenuItem(value: 'completed', child: Text(l.statusCompleted)),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(_orderStatusFilterProvider.notifier).state = value;
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Orders List
        if (filteredOrders.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l.noOrdersFound,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrders.length > 20 ? 20 : filteredOrders.length,
            itemBuilder: (_, idx) => _buildOrderCard(
              context,
              filteredOrders[idx],
              () => _confirmCancelOrder(context, ref, filteredOrders[idx]),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderCard(
      BuildContext context, dynamic order, VoidCallback onCancel) {
    final l = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getStatusColor(order.status),
              child: Icon(
                _getStatusIcon(order.status),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.tableNumberLabel('${order.tableNumber}'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.orderNumberLabel('${order.orderNumber}'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(l, order.status),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(order.status),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onCancel,
              tooltip: l.cancelOrder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCallsSection(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final staffCallsAsync = ref.watch(staffCallsProvider);

    return staffCallsAsync.when(
      data: (calls) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.staffCalls,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (calls.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle,
                          size: 48, color: Colors.green.shade200),
                      const SizedBox(height: 12),
                      Text(
                        l.noStaffCalls,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: calls.length,
              itemBuilder: (_, idx) {
                final call = calls[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              '${call.tableNumber}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.tableNumberLabel('${call.tableNumber}'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.staffRequested,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () =>
                              _resolveStaffCall(ref, call.id, context),
                          child: Text(l.markDone),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text(l.error('$err')),
    );
  }

  Widget _buildKitchenSection(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            l.kitchenView,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.go('/admin/kitchen'),
            child: Text(l.goToKitchen),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_2, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            l.qrGenerator,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.go('/admin/qr'),
            child: Text(l.manageQrCodes),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            l.menuManagement,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.go('/admin/menu'),
            child: Text(l.editMenu),
          ),
        ],
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
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(AppLocalizations l, String status) {
    switch (status) {
      case 'pending':
        return l.statusPending;
      case 'preparing':
        return l.statusPreparing;
      case 'ready':
        return l.statusReady;
      case 'completed':
        return l.statusCompleted;
      default:
        return status;
    }
  }

  void _confirmCancelOrder(BuildContext context, WidgetRef ref, dynamic order) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.cancelOrder),
        content: Text(l.confirmCancelTableOrder('${order.tableNumber}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.no),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(adminRepositoryProvider)
                  .cancelOrder(order.id as String);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.yes),
          ),
        ],
      ),
    );
  }

  void _resolveStaffCall(WidgetRef ref, String callId, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    ref.read(adminRepositoryProvider).deleteStaffCall(callId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.staffCallResolved)),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.logout),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.no),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: Text(l.yesLogout),
          ),
        ],
      ),
    );
  }
}
