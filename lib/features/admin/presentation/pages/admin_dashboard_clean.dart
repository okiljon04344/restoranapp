import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/order_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../../orders/domain/order_providers.dart';
import '../../domain/analytics_provider.dart';
import '../../domain/staff_call_action_provider.dart';
import '../../domain/staff_calls_provider.dart';
import 'admin_ingredients_page.dart';

final _orderSearchProvider = StateProvider<String>((ref) => '');
final _orderStatusFilterProvider = StateProvider<String>((ref) => 'all');
final _selectedSectionProvider = StateProvider<String>((ref) => 'dashboard');

/// Width below which the sidebar becomes a drawer.
const _mobileBreakpoint = 900.0;

class AdminDashboardClean extends ConsumerWidget {
  const AdminDashboardClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBreakpoint;
    final selectedSection = ref.watch(_selectedSectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      drawer: isMobile ? _buildSidebar(context, ref, selectedSection) : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: _buildSidebar(context, ref, selectedSection),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
    const sidebarItems = [
      ('dashboard', Icons.dashboard_outlined, 'Dashboard'),
      ('orders', Icons.receipt_long_outlined, 'Sifarishlar'),
      ('staff_calls', Icons.notifications_none, 'Staff Calls'),
      ('kitchen', Icons.soup_kitchen_outlined, 'Oshxona'),
      ('ingredients', Icons.inventory_2_outlined, 'Massaliqlar'),
      ('qr', Icons.qr_code_2, 'QR Kodlar'),
      ('menu', Icons.menu_book_outlined, 'Menyu'),
    ];
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 20,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Panel', style: theme.textTheme.titleMedium),
                    Text(
                      'Restoran Boshqaruvi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final item in sidebarItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildSidebarItem(
                    context,
                    ref,
                    item.$1,
                    item.$2,
                    item.$3,
                    selectedSection == item.$1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(BuildContext context, WidgetRef ref, String id,
      IconData icon, String label, bool isSelected) {
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, size: 22),
      title: Text(label),
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      onTap: () {
        ref.read(_selectedSectionProvider.notifier).state = id;
        if (MediaQuery.sizeOf(context).width < _mobileBreakpoint) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildMainContent(
      BuildContext context, WidgetRef ref, String selectedSection) {
    switch (selectedSection) {
      case 'orders':
        return _buildOrdersSection(context, ref);
      case 'staff_calls':
        return _buildStaffCallsSection(context, ref);
      case 'kitchen':
        return _buildLinkSection(
          context,
          icon: Icons.soup_kitchen_outlined,
          title: 'Oshxona ko\'rinishi',
          buttonLabel: 'Oshxonaga o\'tish',
          route: '/admin/kitchen',
        );
      case 'ingredients':
        return const AdminIngredientsPage();
      case 'qr':
        return _buildLinkSection(
          context,
          icon: Icons.qr_code_2,
          title: 'QR Kod Generator',
          buttonLabel: 'QR Kodlarni Boshqarish',
          route: '/admin/qr',
        );
      case 'menu':
        return _buildLinkSection(
          context,
          icon: Icons.menu_book_outlined,
          title: 'Menyu Boshqaruvi',
          buttonLabel: 'Menyunu Tahrirlash',
          route: '/admin/menu',
        );
      default:
        return _buildDashboardSection(context, ref);
    }
  }

  Widget _buildDashboardSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orders = ref.watch(ordersProvider);
    final analytics = ref.watch(analyticsProvider);
    final staffCallsAsync = ref.watch(staffCallsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);

    final todayStats = analytics.getTodayStats(orders);
    final topItems = analytics.getTopItems(orders).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Bugungi statistika va real-time ma\'lumotlar',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 48,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                _LabeledValue(
                  label: 'Bugungi Daromad',
                  value: '${todayStats['totalRevenue'] ?? 0} so\'m',
                  large: true,
                ),
                _LabeledValue(
                  label: 'Sifarish soni',
                  value: '${todayStats['totalOrders'] ?? 0}',
                ),
                _LabeledValue(
                  label: 'O\'rtacha Sifarish',
                  value: '${todayStats['avgOrderValue'] ?? 0} so\'m',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: StatTile.gridDelegate,
          children: [
            StatTile(
              label: 'Kutilmoqdagi',
              value: '${todayStats['pendingOrders'] ?? 0}',
              icon: Icons.schedule,
            ),
            StatTile(
              label: 'Tayyor',
              value: '${todayStats['completedOrders'] ?? 0}',
              icon: Icons.check_circle_outline,
            ),
            StatTile(
              label: 'Menyu Mahsulotlari',
              value: '${itemsAsync.value?.length ?? 0}',
              icon: Icons.restaurant_menu,
            ),
            StatTile(
              label: 'Kategoriyalar',
              value: '${categoriesAsync.value?.length ?? 0}',
              icon: Icons.category_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        staffCallsAsync.when(
          data: (calls) => calls.isNotEmpty
              ? _buildStaffCallsAlert(calls, context, ref)
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
        if (topItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Eng ko\'p buyurtilgan', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (final item in topItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            '${item.orderCount}x',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStaffCallsAlert(
      List<StaffCall> calls, BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Staff Calls (Xodimlar chaqirilmoqda)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              StatusBadge(label: '${calls.length}', color: scheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          for (final call in calls.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Stol ${call.tableNumber} - Xodim chaqirdi',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _resolveStaffCall(ref, call.id, context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Tayyorlandi'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
              o.orderNumber.contains(searchQuery))
          .toList();
    }
    final visibleOrders = filteredOrders.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sifarishlar', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  ref.read(_orderSearchProvider.notifier).state = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Stol yoki order ID buldan qidiring...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall + 2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: statusFilter,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Hammasini')),
                    DropdownMenuItem(
                        value: 'pending', child: Text('Kutilmoqda')),
                    DropdownMenuItem(
                        value: 'preparing', child: Text('Tayyorlanmoqda')),
                    DropdownMenuItem(value: 'ready', child: Text('Tayyor')),
                    DropdownMenuItem(
                        value: 'completed', child: Text('Tugallandi')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(_orderStatusFilterProvider.notifier).state =
                          value;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (visibleOrders.isEmpty)
          const _EmptyCard(message: 'Sifarish topilmadi')
        else
          for (final order in visibleOrders) ...[
            _buildOrderCard(
              context,
              order,
              () => _confirmCancelOrder(context, ref, order),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildOrderCard(
      BuildContext context, OrderModel order, VoidCallback onCancel) {
    final theme = Theme.of(context);
    final color = context.palette.statusColor(theme.colorScheme, order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon(order.status), color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stol #${order.tableNumber}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(label: _statusText(order.status), color: color),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close, color: theme.colorScheme.error),
              onPressed: onCancel,
              tooltip: 'Bekor qilish',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCallsSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final staffCallsAsync = ref.watch(staffCallsProvider);

    return staffCallsAsync.when(
      data: (calls) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Staff Calls', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          if (calls.isEmpty)
            const _EmptyCard(
              message: 'Hech qanday chaqiruv yo\'q',
              icon: Icons.check_circle_outline,
            )
          else
            for (final call in calls) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${call.tableNumber}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stol #${call.tableNumber}',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'Xodim chaqirilmoqda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () =>
                            _resolveStaffCall(ref, call.id, context),
                        child: const Text('Tayyorlandi'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Xato: $err'),
    );
  }

  Widget _buildLinkSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String buttonLabel,
    required String route,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(route),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'preparing':
        return 'Tayyorlanmoqda';
      case 'ready':
        return 'Tayyor';
      case 'completed':
        return 'Tugallandi';
      default:
        return status;
    }
  }

  void _confirmCancelOrder(
      BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sifarishni Bekor Qilish'),
        content: Text('Stol #${order.tableNumber} ni bekor qilmoqchisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(firestoreServiceProvider).cancelOrder(order.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Ha, Bekor Qilish'),
          ),
        ],
      ),
    );
  }

  void _resolveStaffCall(WidgetRef ref, String callId, BuildContext context) {
    ref.read(staffCallActionProvider).resolveCall(callId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Staff call tayyorlandi')),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Sistemadan chiqmoqchisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Ha, Chiqish'),
          ),
        ],
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _LabeledValue({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: large
              ? theme.textTheme.headlineMedium?.copyWith(fontSize: 32)
              : theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final IconData? icon;

  const _EmptyCard({required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 40, color: muted),
                const SizedBox(height: 12),
              ],
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
