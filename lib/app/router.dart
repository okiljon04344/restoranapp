import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/role_select_page.dart';
import '../features/customer/application/table_provider.dart';
import '../features/customer/presentation/pages/cart_page.dart';
import '../features/customer/presentation/pages/customer_home_page.dart';
import '../features/customer/presentation/pages/menu_page.dart';
import '../features/customer/presentation/pages/order_tracking_page.dart';
import '../features/customer/presentation/pages/table_entry_page.dart';
import '../features/onboarding/presentation/pages/language_selection_page.dart';
import 'staff_routes.dart';

bool get _isDesktopOrWeb =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundPage(homeLocation: '/'),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: '/role-select',
        // Phones go straight to table check-in; the staff entry points are
        // offered on desktop and web.
        builder: (context, state) =>
            _isDesktopOrWeb ? const RoleSelectPage() : const TableEntryPage(),
      ),
      GoRoute(
        path: '/table-entry',
        builder: (context, state) => const TableEntryPage(),
      ),
      GoRoute(
        path: '/customer',
        // Ordering needs a validated table; without one (e.g. after a page
        // reload) the customer checks in again.
        redirect: (context, state) =>
            ref.read(currentTableProvider) == null ? '/table-entry' : null,
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
            path: 'orders',
            builder: (context, state) => const OrderTrackingPage(),
          ),
        ],
      ),
      ...staffRoutes(),
    ],
  );
});
