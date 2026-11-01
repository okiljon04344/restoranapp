import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/pages/admin_dashboard_clean.dart';
import '../features/admin/presentation/pages/admin_kitchen_page.dart';
import '../features/admin/presentation/pages/admin_menu_management_enhanced.dart';
import '../features/admin/presentation/pages/admin_qr_code_page.dart';
import '../features/auth/presentation/pages/role_select_page.dart';
import '../features/auth/presentation/pages/admin_login_page.dart';
import '../features/customer/presentation/pages/cart_page.dart';
import '../features/customer/presentation/pages/customer_home_page.dart';
import '../features/customer/presentation/pages/menu_page.dart';
import '../features/customer/presentation/pages/order_tracking_page.dart';
import '../features/kitchen/presentation/pages/kitchen_orders_page.dart';
import '../features/onboarding/presentation/pages/language_selection_page.dart';
import '../features/customer/presentation/pages/table_entry_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (context, state) {
          if (kIsWeb ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux) {
            return const RoleSelectPage();
          } else {
            return const TableEntryPage();
          }
        },
      ),
      GoRoute(
        path: '/login/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'admin';
          return AdminLoginPage(targetRole: role);
        },
      ),
      GoRoute(
        path: '/table-entry',
        builder: (context, state) => const TableEntryPage(),
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerHomePage(),
        routes: [
          GoRoute(
            path: 'menu',
            builder: (context, state) => const MenuPage(),
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: 'order-tracking',
            builder: (context, state) => const OrderTrackingPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/kitchen',
        builder: (context, state) => const KitchenOrdersPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardClean(),
      ),
      // Targets of the navigation buttons inside the admin dashboard.
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
      // The dashboard's logout action navigates here.
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginPage(targetRole: 'admin'),
      ),
    ],
  );
});
