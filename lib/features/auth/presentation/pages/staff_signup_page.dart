import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_provider.dart';
import '../../data/staff_repository.dart';

/// Creates an email/password account and files a kitchen access request.
/// The account can do nothing until an admin approves the request.
class StaffSignupPage extends ConsumerStatefulWidget {
  const StaffSignupPage({super.key});

  @override
  ConsumerState<StaffSignupPage> createState() => _StaffSignupPageState();
}

class _StaffSignupPageState extends ConsumerState<StaffSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _authMessage(AppLocalizations l, FirebaseAuthException e) {
    return switch (e.code) {
      'email-already-in-use' => l.authEmailInUse,
      'weak-password' => l.authWeakPassword,
      'invalid-email' => l.authInvalidEmail,
      'network-request-failed' => l.authNetworkError,
      _ => describeError(l, e),
    };
  }

  Future<void> _onSignup() async {
    final l = context.l10n;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty ||
        password.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      showMessage(context, l.fillAllFields, isError: true);
      return;
    }
    if (password != _confirmPasswordController.text) {
      showMessage(context, l.passwordsMismatch, isError: true);
      return;
    }
    if (password.length < 6) {
      showMessage(context, l.passwordTooShort, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final credential = await repo.signUp(email, password);
      final user = credential.user;
      if (user != null) {
        await ref
            .read(staffRepositoryProvider)
            .submitRequest(uid: user.uid, email: user.email ?? email);
      }
      await repo.signOut();
      if (!mounted) return;
      showMessage(context, l.staffRequestSent);
      context.go('/login');
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
      appBar: AppBar(title: Text(l.requestStaffAccount)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_rounded,
                    size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(l.staffSignupHint, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l.emailLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: l.passwordLabel,
                    helperText: l.passwordHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l.confirmPasswordLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _onSignup,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.register),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
