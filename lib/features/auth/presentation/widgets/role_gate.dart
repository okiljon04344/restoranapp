import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/async_view.dart';
import '../../application/auth_provider.dart';

/// Shows [child] only to signed-in staff ([adminOnly]: only to admins).
/// The security rules enforce the same roles on the data itself; this keeps
/// the screens from being opened by URL without a matching account.
class RoleGate extends ConsumerWidget {
  const RoleGate({super.key, required this.child, this.adminOnly = false});

  final Widget child;
  final bool adminOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(staffRoleProvider);
    return role.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: ErrorNotice(
          error: error,
          onRetry: () => ref.invalidate(staffRoleProvider),
        ),
      ),
      data: (role) {
        final allowed = adminOnly
            ? role == StaffRole.admin
            : role == StaffRole.admin || role == StaffRole.kitchen;
        return allowed ? child : const _AccessDenied();
      },
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(l.accessDenied, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: Text(l.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
