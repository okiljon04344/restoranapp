import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_provider.dart';
import 'admin_signup_page.dart';

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
    final l = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.enterEmailPassword),
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
      if (widget.targetRole == 'admin') {
        final isAdmin = await repo.isAdmin(user);
        if (!mounted) return;
        if (isAdmin) {
          context.go('/dashboard');
        } else {
          await repo.signOut();
          throw l.authNoAdminRights;
        }
      } else {
        if (!mounted) return;
        context.go('/kitchen');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = l.error('${e.message}');

      if (e.code == 'user-not-found') {
        errorMessage = l.authUserNotFound;
      } else if (e.code == 'wrong-password') {
        errorMessage = l.authWrongPassword;
      } else if (e.code == 'invalid-credential') {
        errorMessage = l.authInvalidCredential;
      } else if (e.code == 'network-request-failed') {
        errorMessage = l.authNetworkError;
      } else if (e.code == 'too-many-requests') {
        errorMessage = l.authTooManyRequests;
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
            content: Text(l.error(e.toString())),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
          title:
              Text(AppLocalizations.of(context)?.adminLogin ?? 'Admin Login')),
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
                  labelText: l.emailLabel,
                  hintText: 'name@example.com',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: l.passwordLabel,
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
                    : Text(AppLocalizations.of(context)?.login ?? 'Kirish'),
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
              child: Text(AppLocalizations.of(context)?.createAdminAccount ??
                  'Yangi admin akkaunt yaratish'),
            ),
          ],
        ),
      ),
    );
  }
}
