import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/language_menu_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/staff_call_model.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../auth/presentation/widgets/staff_admin_view.dart';
import '../../../calls/application/calls_provider.dart';
import '../../../calls/presentation/staff_calls_view.dart';
import '../../../kitchen/presentation/widgets/kitchen_board.dart';
import '../../../tables/presentation/table_bills_view.dart';
import '../../../tables/presentation/tables_admin_view.dart';
import '../widgets/ingredients_view.dart';
import '../widgets/menu_admin_view.dart';
import '../widgets/orders_admin_view.dart';
import '../widgets/overview_view.dart';

enum AdminSection {
  overview,
  orders,
  kitchen,
  bills,
  calls,
  tables,
  menu,
  ingredients,
  staff,
}

final adminSectionProvider =
    StateProvider<AdminSection>((ref) => AdminSection.overview);

final _audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

(IconData, String) _sectionMeta(AppLocalizations l, AdminSection section) =>
    switch (section) {
      AdminSection.overview => (Icons.dashboard, l.dashboard),
      AdminSection.orders => (Icons.receipt, l.orders),
      AdminSection.kitchen => (Icons.restaurant, l.sidebarKitchen),
      AdminSection.bills => (Icons.payments_outlined, l.bills),
      AdminSection.calls => (Icons.notifications_active, l.staffCalls),
      AdminSection.tables => (Icons.qr_code_2, l.tablesAndQr),
      AdminSection.menu => (Icons.restaurant_menu, l.menu),
      AdminSection.ingredients => (Icons.inventory_2, l.ingredients),
      AdminSection.staff => (Icons.badge_outlined, l.staffSection),
    };

/// Admin panel shell: a sidebar on wide screens, a drawer on phones.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

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
    final isNarrow = MediaQuery.sizeOf(context).width < 900;
    final section = ref.watch(adminSectionProvider);

    // Play an alert sound when a new pending call arrives.
    ref.listen<AsyncValue<List<StaffCall>>>(staffCallsProvider, (prev, next) {
      final before = prev?.valueOrNull?.length ?? 0;
      final after = next.valueOrNull?.length ?? 0;
      if (prev != null && prev.hasValue && after > before) {
        // Browsers may refuse playback before the first user gesture.
        ref
            .read(_audioPlayerProvider)
            .play(AssetSource('sounds/notification.wav'))
            .catchError((Object e) => debugPrint('Alert sound failed: $e'));
      }
    });

    final sidebar = _Sidebar(
      selected: section,
      onSelected: (value) {
        ref.read(adminSectionProvider.notifier).state = value;
        if (isNarrow) Navigator.of(context).pop();
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isNarrow ? _sectionMeta(l, section).$2 : l.adminPanel),
        actions: [
          const LanguageMenuButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l.logout,
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      drawer: isNarrow ? Drawer(child: SafeArea(child: sidebar)) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isNarrow)
            SizedBox(
              width: 260,
              // A Material (not a plain coloured box) so the list tiles can
              // paint their selection and ink effects on it.
              child: Material(color: Colors.grey.shade50, child: sidebar),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isNarrow ? 12 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isNarrow)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _sectionMeta(l, section).$2,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                  switch (section) {
                    AdminSection.overview => const OverviewView(),
                    AdminSection.orders => const OrdersAdminView(),
                    AdminSection.kitchen => const KitchenBoard(),
                    AdminSection.bills => const TableBillsView(),
                    AdminSection.calls => const StaffCallsView(),
                    AdminSection.tables => const TablesAdminView(),
                    AdminSection.menu => const MenuAdminView(),
                    AdminSection.ingredients => const IngredientsView(),
                    AdminSection.staff => const StaffAdminView(),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.selected, required this.onSelected});

  final AdminSection selected;
  final ValueChanged<AdminSection> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final pendingCalls = ref.watch(staffCallsProvider).valueOrNull?.length ?? 0;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.adminPanel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(l.adminPanelSubtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final section in AdminSection.values)
          ListTile(
            leading: Badge(
              isLabelVisible:
                  section == AdminSection.calls && pendingCalls > 0,
              label: Text('$pendingCalls'),
              child: Icon(_sectionMeta(l, section).$1),
            ),
            title: Text(_sectionMeta(l, section).$2),
            selected: section == selected,
            onTap: () => onSelected(section),
          ),
      ],
    );
  }
}
