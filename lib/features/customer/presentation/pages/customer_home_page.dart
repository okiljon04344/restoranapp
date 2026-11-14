import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/ui/feedback.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../calls/data/calls_repository.dart';
import '../../application/table_provider.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tableNumber = ref.watch(currentTableProvider);

    return AppScaffold(
      title: l.appTitle,
      actions: [
        IconButton(
          onPressed: () => context.go('/customer/cart'),
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
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
                        l.tableInfo,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        tableNumber?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(currentTableProvider.notifier).state = null;
                    context.go('/table-entry');
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l.reset),
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
                colors: [Colors.blue.shade700, Colors.blue.shade500],
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
                  l.appTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l.restaurantDesc,
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
                  child: Text(l.openMenu),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _HomeActionCard(
                title: l.myOrders,
                icon: Icons.receipt_long,
                color: Colors.orange,
                onTap: () => context.go('/customer/orders'),
              ),
              const SizedBox(width: 16),
              _HomeActionCard(
                title: l.callStaff,
                icon: Icons.notifications_active,
                color: Colors.red,
                onTap: () => _callStaff(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _callStaff(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final tableNumber = ref.read(currentTableProvider);
  if (tableNumber == null) {
    showMessage(context, l.tableRequired, isError: true);
    return;
  }
  await runAction(
    context,
    () async {
      final uid =
          await ref.read(authRepositoryProvider).ensureCustomerSession();
      await ref
          .read(callsRepositoryProvider)
          .create(tableNumber: tableNumber, customerUid: uid);
    },
    successMessage: l.staffCalled,
  );
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
