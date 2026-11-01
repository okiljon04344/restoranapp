import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
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

  // The app always starts from the language selection page (suits a restaurant setting)
  // Hive is initialized inside localeInitializerProvider
  runApp(const ProviderScope(child: RestaurantUniversalApp()));
}
