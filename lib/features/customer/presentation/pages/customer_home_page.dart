import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../admin/domain/staff_call_action_provider.dart';
import '../../domain/table_provider.dart';
import '../../domain/table_status_provider.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  Future<void> _callStaff(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    final tableNumber = int.tryParse(ref.read(tableIdProvider) ?? '0') ?? 0;
    final messenger = ScaffoldMessenger.of(context);

    if (tableNumber == 0) {
      messenger.showSnackBar(SnackBar(content: Text(l.tableRequired)));
      return;
    }

    try {
      await ref.read(staffCallActionProvider).callStaff(tableNumber);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.staffCalled),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.error('Failed to call staff'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final currentTableId = ref.watch(tableIdProvider);
    final tableNumber = int.tryParse(currentTableId ?? '0') ?? 0;
    final tableStatus = ref.watch(tableStatusProvider)(tableNumber);

    return AppScaffold(
      title: l.appTitle,
      maxContentWidth: 720,
      actions: [
        IconButton(
          onPressed: () => context.go('/customer/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.table_restaurant_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.tableInfo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          currentTableId ?? '-',
                          style: theme.textTheme.titleLarge,
                        ),
                        if (tableStatus)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l.tableOccupiedBadge,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.palette.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(tableIdProvider.notifier).state = null;
                      context.go('/role-select');
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l.reset),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.restaurantDesc,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/customer/menu'),
                  child: Text(l.openMenu),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HomeActionCard(
                title: l.myOrders,
                icon: Icons.receipt_long_outlined,
                onTap: () => context.go('/customer/order-tracking'),
              ),
              const SizedBox(width: 16),
              _HomeActionCard(
                title: l.callStaff,
                icon: Icons.notifications_none,
                onTap: () => _callStaff(context, ref, l),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
