import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../core/widgets/language_menu_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_provider.dart';
import '../../data/staff_repository.dart';

/// Sign-in for admins and kitchen staff. Where the user lands is decided by
/// the role documents in Firestore, not by a choice made in the UI.
class StaffLoginPage extends ConsumerStatefulWidget {
  const StaffLoginPage({super.key});

  @override
  ConsumerState<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends ConsumerState<StaffLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _authMessage(AppLocalizations l, FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => l.authUserNotFound,
      'wrong-password' => l.authWrongPassword,
      'invalid-credential' => l.authInvalidCredential,
      'invalid-email' => l.authInvalidEmail,
      'network-request-failed' => l.authNetworkError,
      'too-many-requests' => l.authTooManyRequests,
      _ => describeError(l, e),
    };
  }

  Future<void> _onLogin() async {
    final l = context.l10n;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      showMessage(context, l.enterEmailPassword, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final credential = await repo.signIn(email, password);
      final user = credential.user;
      final role = await repo.roleOf(user);
      if (!mounted) return;
      switch (role) {
        case StaffRole.admin:
          context.go('/admin');
        case StaffRole.kitchen:
          context.go('/kitchen');
        case StaffRole.none:
          // File (or keep) the access request so an admin can approve this
          // account, then drop the session: it has no staff rights yet.
          if (user != null) {
            try {
              await ref
                  .read(staffRepositoryProvider)
                  .submitRequest(uid: user.uid, email: user.email ?? email);
            } catch (_) {
              // A request already exists; the rules reject overwriting it.
            }
          }
          await repo.signOut();
          if (mounted) showMessage(context, l.authNoStaffAccess, isError: true);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) showMessage(context, _authMessage(l, e), isError: true);
    } catch (e) {
      if (mounted) showMessage(context, describeError(l, e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.staffLogin),
        actions: const [LanguageMenuButton()],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person_rounded,
                      size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l.emailLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _isLoading ? null : _onLogin(),
                    decoration: InputDecoration(
                      labelText: l.passwordLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _onLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.login),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => context.push('/signup'),
                    child: Text(l.requestStaffAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
