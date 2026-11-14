import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/language_menu_button.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../calls/application/calls_provider.dart';
import '../../../calls/presentation/staff_calls_view.dart';
import '../../../tables/presentation/table_bills_view.dart';
import '../widgets/kitchen_board.dart';

/// Screen for kitchen/floor staff: the order queue, the open bills and the
/// calls coming from tables.
class KitchenOrdersPage extends ConsumerWidget {
  const KitchenOrdersPage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final confirmed =
        await confirm(context, title: l.logout, message: l.logoutConfirm);
    if (!confirmed || !context.mounted) return;
    final done = await runAction(
        context, () => ref.read(authRepositoryProvider).signOut());
    if (done && context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final pendingCalls = ref.watch(staffCallsProvider).valueOrNull?.length ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(l.kitchenScreen),
          actions: [
            const LanguageMenuButton(),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l.logout,
              onPressed: () => _logout(context, ref),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.restaurant), text: l.orders),
              Tab(icon: const Icon(Icons.receipt_long), text: l.bills),
              Tab(
                icon: Badge(
                  isLabelVisible: pendingCalls > 0,
                  label: Text('$pendingCalls'),
                  child: const Icon(Icons.notifications_active),
                ),
                text: l.staffCalls,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChildScrollView(
                padding: EdgeInsets.all(16), child: KitchenBoard()),
            SingleChildScrollView(
                padding: EdgeInsets.all(16), child: TableBillsView()),
            SingleChildScrollView(
                padding: EdgeInsets.all(16), child: StaffCallsView()),
          ],
        ),
      ),
    );
  }
}
