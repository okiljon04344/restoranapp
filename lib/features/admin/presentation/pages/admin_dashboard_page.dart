import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/order_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../orders/domain/order_providers.dart';
import '../../domain/staff_calls_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  final _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final orders = ref.watch(ordersProvider);
    final staffCallsAsync = ref.watch(staffCallsProvider);

    ref.listen<AsyncValue<List<StaffCall>>>(staffCallsProvider, (prev, next) {
      final prevLen = prev?.value?.length ?? 0;
      final nextLen = next.value?.length ?? 0;
      if (nextLen > prevLen) {
        _audioPlayer.play(AssetSource('sounds/notification.wav'));
      }
    });

    final theme = Theme.of(context);

    return AppScaffold(
      title: l.adminPanel,
      maxContentWidth: 960,
      actions: [
        IconButton(
          icon: const Icon(Icons.restaurant_menu),
          tooltip: 'Menu Management',
          onPressed: () => context.go('/admin/menu'),
        ),
        IconButton(
          icon: const Icon(Icons.cancel_outlined),
          tooltip: 'Cancel Order by Table',
          onPressed: () => _showCancelOrderDialog(context, ref),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: StatTile.gridDelegate,
            children: [
              StatTile(
                label: 'Categories',
                value: '${categoriesAsync.value?.length ?? 0}',
                icon: Icons.category_outlined,
              ),
              StatTile(
                label: 'Menu Items',
                value: '${itemsAsync.value?.length ?? 0}',
                icon: Icons.restaurant_menu,
              ),
              StatTile(
                label: 'Active Orders',
                value: '${orders.length}',
                icon: Icons.receipt_long_outlined,
              ),
              const StatTile(
                label: 'System',
                value: 'Live',
                icon: Icons.sensors,
              ),
            ],
          ),
          const SizedBox(height: 32),
          staffCallsAsync.when(
            data: (calls) => calls.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Staff Calls',
                              style: theme.textTheme.titleLarge),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: '${calls.length}',
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final call in calls) ...[
                        _StaffCallCard(
                          call: call,
                          onResolve: () =>
                              _resolveStaffCall(ref, call.id, context),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          Text(l.orders, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No orders yet'),
              ),
            ),
          for (final order in orders.take(10)) ...[
            _OrderCard(
              order: order,
              onCancel: () => _confirmCancelOrder(context, ref, order),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context, WidgetRef ref) {
    final tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order by Table'),
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
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
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
                  SnackBar(
                      content: Text(
                          AppLocalizations.of(context)?.tableInvalid ??
                              'Table number must be a number')),
                );
              }
            },
            child: Text(
                AppLocalizations.of(context)?.cancelOrder ?? 'Cancel Order'),
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

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table #$tableNum order cancelled')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No active order found for this table')),
      );
    }
  }

  Future<void> _resolveStaffCall(
      WidgetRef ref, String callId, BuildContext context) async {
    final db = FirebaseFirestore.instance;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await db
          .collection('cafes')
          .doc('main_cafe')
          .collection('calls')
          .doc(callId)
          .update({'status': 'resolved'});

      messenger.showSnackBar(
        const SnackBar(content: Text('Staff call resolved')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _confirmCancelOrder(
      BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Cancel order for table #${order.tableNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.no ?? 'No'),
          ),
          FilledButton(
            onPressed: () async {
              await _cancelOrderDirectly(ref, order.id, context);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)?.yes ?? 'Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrderDirectly(
      WidgetRef ref, String orderId, BuildContext context) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await firestoreService.cancelOrder(orderId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Order cancelled')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCancel;

  const _OrderCard({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        context.palette.statusColor(theme.colorScheme, order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Table #${order.tableNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.total.toStringAsFixed(0),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                StatusBadge(label: order.status, color: statusColor),
              ],
            ),
            PopupMenuButton<void>(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onCancel, child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCallCard extends StatelessWidget {
  final StaffCall call;
  final VoidCallback onResolve;

  const _StaffCallCard({required this.call, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final minute = call.createdAt.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: scheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table #${call.tableNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Called at ${call.createdAt.hour}:$minute',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onResolve,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}
