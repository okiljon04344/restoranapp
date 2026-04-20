import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/table_provider.dart';
import '../../domain/table_status_provider.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final currentTableId = ref.watch(tableIdProvider);
    final tableNumber = int.tryParse(currentTableId ?? '0') ?? 0;
    final tableStatus = ref.watch(tableStatusProvider)(tableNumber);

    return AppScaffold(
      title: l10n.restaurantName,
      actions: [
        IconButton(
          onPressed: () => context.go('/customer/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Table Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_restaurant, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tableNumber,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        currentTableId ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (tableStatus)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.info, size: 12, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                l10n.tableOccupied,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(tableIdProvider.notifier).state = null;
                    context.go('/role-select');
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.reset),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.restaurantName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.restaurantDesc,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/customer/menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.openMenu),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _HomeActionCard(
                title: l10n.myOrders,
                icon: Icons.receipt_long,
                color: Colors.orange,
                onTap: () => context.go('/customer/tracking'),
              ),
              const SizedBox(width: 16),
              _HomeActionCard(
                title: l10n.callStaff,
                icon: Icons.notifications_active,
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.staffCalled)),
                  );
                },
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
  final Color color;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
