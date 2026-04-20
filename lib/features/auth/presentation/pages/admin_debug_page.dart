import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/auth_provider.dart';

class AdminDebugPage extends ConsumerStatefulWidget {
  const AdminDebugPage({super.key});

  @override
  ConsumerState<AdminDebugPage> createState() => _AdminDebugPageState();
}

class _AdminDebugPageState extends ConsumerState<AdminDebugPage> {
  bool _firebaseInitialized = false;
  bool _authEnabled = false;
  bool _firestoreConnected = false;
  String _debugMessage = '';

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  Future<void> _checkFirebaseStatus() async {
    try {
      final auth = ref.read(firebaseAuthProvider);
      setState(() => _firebaseInitialized = true);

      // Check if auth is enabled
      try {
        // Try to create a temporary user to test
        await auth.createUserWithEmailAndPassword(
          email: 'test_${DateTime.now().millisecondsSinceEpoch}@test.com',
          password: 'TestPassword123!',
        );
        setState(() => _authEnabled = true);
      } catch (e) {
        if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
            e.toString().contains('not configured')) {
          setState(() {
            _authEnabled = false;
            _debugMessage = 'Firebase Authentication web-da configured emas';
          });
        } else {
          setState(() => _authEnabled = true);
        }
      }

      // Check Firestore connection
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('_test').doc('test').get();
        setState(() => _firestoreConnected = true);
      } catch (e) {
        setState(() {
          _firestoreConnected = false;
          _debugMessage = 'Firestore ulanishida xato: $e';
        });
      }
    } catch (e) {
      setState(() => _debugMessage = 'Firebase xatosi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug - Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Status Check',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _StatusCard(
              label: 'Firebase Initialized',
              status: _firebaseInitialized,
            ),
            const SizedBox(height: 12),
            _StatusCard(
              label: 'Auth Provider',
              status: _authEnabled,
            ),
            const SizedBox(height: 12),
            _StatusCard(
              label: 'Firestore Connected',
              status: _firestoreConnected,
            ),
            const SizedBox(height: 24),
            if (_debugMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xato:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_debugMessage),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Admin Email Whitelist:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• admin@gmail.com'),
            const Text('• oqiljonnabiyev0434@gmail.com'),
            const Text('• 123@gmail.com'),
            const SizedBox(height: 16),
            const Text('Qadam-qadam yo\'l tutish:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('1. "Yangi admin akkaunt yaratish" tugmasini bosing'),
            const Text('2. Yuqorida ro\'yxatdagi email-lardan birini kiriting'),
            const Text('3. Kuchli parol yarating (kamida 6 ta belgi)'),
            const Text('4. Shunday email va parol bilan login qiling'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Login sahifasiga qaytish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final bool status;

  const _StatusCard({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            status ? '✓' : '✗',
            style: TextStyle(
              fontSize: 20,
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
