import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/pages/admin_dashboard_clean.dart';
import '../features/admin/presentation/pages/admin_kitchen_page.dart';
import '../features/admin/presentation/pages/admin_menu_management_enhanced.dart';
import '../features/admin/presentation/pages/admin_qr_code_page.dart';
import '../features/auth/presentation/pages/admin_login_page.dart';
import '../features/auth/presentation/pages/admin_signup_page.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    errorBuilder: (context, state) => const ErrorPage(),
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/login',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginPage(targetRole: 'admin'),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AdminSignupPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AdminDashboardClean(),
      ),
      GoRoute(
        path: '/admin/menu',
        builder: (context, state) => const AdminMenuManagementPageEnhanced(),
      ),
      GoRoute(
        path: '/admin/kitchen',
        builder: (context, state) => const AdminKitchenPage(),
      ),
      GoRoute(
        path: '/admin/qr',
        builder: (context, state) => const AdminQRCodePage(),
      ),
    ],
  );
});

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xato')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Sahifa topilmadi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login-ga qaytish'),
            ),
          ],
        ),
      ),
    );
  }
}
