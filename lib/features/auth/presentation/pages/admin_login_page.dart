import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_provider.dart';
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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email va parol-ni kiritib chiqing'),
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
      final role = StaffRole.fromName(widget.targetRole);
      final allowed = user != null && await repo.hasRole(user, role);
      if (!allowed) {
        await repo.signOut();
        throw 'Sizda bu bo\'limga kirish huquqi yo\'q.';
      }
      if (mounted) {
        context.go(role == StaffRole.admin ? '/dashboard' : '/kitchen');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Xato: ${e.message}';

      if (e.code == 'user-not-found') {
        errorMessage = 'Bu email-da foydalanuvchi topilmadi';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Parol noto\'g\'ri';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Email yoki parol noto\'g\'ri';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Internetga ulanishda xato';
      } else if (e.code == 'too-many-requests') {
        errorMessage =
            'Juda ko\'p urinish. Birozdan so\'ng qayta urinib ko\'ring';
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
            content: Text('Xato: ${e.toString()}'),
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
              decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'staff@example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                  labelText: 'Parol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock)),
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
