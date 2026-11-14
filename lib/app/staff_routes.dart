import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/feedback.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/auth/presentation/pages/staff_login_page.dart';
import '../features/auth/presentation/pages/staff_signup_page.dart';
import '../features/auth/presentation/widgets/role_gate.dart';
import '../features/kitchen/presentation/pages/kitchen_orders_page.dart';

/// Routes shared by the combined app and the admin web entry point. The
/// staff screens are wrapped in a [RoleGate], so opening them by URL without
/// a matching account shows an access-denied page instead of the data.
List<GoRoute> staffRoutes() => [
      GoRoute(
        path: '/login',
        builder: (context, state) => const StaffLoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const StaffSignupPage(),
      ),
      GoRoute(
        path: '/kitchen',
        builder: (context, state) =>
            const RoleGate(child: KitchenOrdersPage()),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) =>
            const RoleGate(adminOnly: true, child: AdminDashboardPage()),
      ),
    ];

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, required this.homeLocation});

  final String homeLocation;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l.pageNotFound, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(homeLocation),
              child: Text(l.goBack),
            ),
          ],
        ),
      ),
    );
  }
}
