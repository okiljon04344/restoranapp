import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/admin_login_page.dart';
import '../features/auth/presentation/pages/admin_signup_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_clean.dart';
import '../features/admin/presentation/pages/admin_menu_management_enhanced.dart';
import '../features/admin/presentation/pages/admin_kitchen_page.dart';
import '../features/admin/presentation/pages/admin_qr_code_page.dart';

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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Sahifa topilmadi', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login-ga qaytish'),
            ),
          ],
        ),
      ),
    );
  }
}
