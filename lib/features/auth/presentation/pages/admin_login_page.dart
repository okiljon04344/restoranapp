import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_provider.dart';
import 'admin_signup_page.dart';
import 'admin_debug_page.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  final String targetRole; // 'admin' or 'kitchen'
  const AdminLoginPage({super.key, required this.targetRole});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emailAndPasswordRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(
          _emailController.text.trim(), _passwordController.text.trim());

      final user = ref.read(firebaseAuthProvider).currentUser;
      if (mounted && widget.targetRole == 'admin') {
        if (repo.isAdmin(user?.email)) {
          if (mounted) {
            context.go('/dashboard');
          }
        } else {
          await repo.signOut();
          throw l10n.noAdminRights;
        }
      } else if (mounted) {
        context.go('/kitchen');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      String errorMessage = l10n.errorMessage(e.message ?? '');

      if (e.code == 'user-not-found') {
        errorMessage = l10n.userNotFound;
      } else if (e.code == 'wrong-password') {
        errorMessage = l10n.wrongPassword;
      } else if (e.code == 'invalid-credential') {
        errorMessage = l10n.invalidCredential;
      } else if (e.code == 'network-request-failed') {
        errorMessage = l10n.networkError;
      } else if (e.code == 'too-many-requests') {
        errorMessage = l10n.tooManyRequests;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminLogin)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: l10n.email,
                  hintText: l10n.emailHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: l10n.password,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _onLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.login),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AdminSignupPage(),
                        ),
                      ),
              child: Text(l10n.createNewAdmin),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AdminDebugPage(),
                        ),
                      ),
              child: Text('🔧 ${l10n.debugFirebase}'),
            ),
          ],
        ),
      ),
    );
  }
}
