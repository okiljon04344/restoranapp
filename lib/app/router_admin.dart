import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'staff_routes.dart';

/// Router of the staff-only web entry point (`lib/main_admin.dart`).
final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    errorBuilder: (context, state) =>
        const NotFoundPage(homeLocation: '/login'),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      ...staffRoutes(),
    ],
  );
});
