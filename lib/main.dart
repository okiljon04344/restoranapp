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
  } catch (_) {}

  // Har doim tilni tanlash sahifasidan boshlanadi (restoran uchun to'g'ri)
  // Hive localeInitializerProvider ichida ishga tushiriladi
  runApp(const ProviderScope(child: RestaurantUniversalApp()));
}
