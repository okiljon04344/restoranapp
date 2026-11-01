import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_admin.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Keep the app running (e.g. in tests or without Firebase config); the
    // failure is surfaced in the debug console.
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const ProviderScope(child: AdminApp()));
}
