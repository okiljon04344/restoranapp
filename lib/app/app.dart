import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';
import 'locale_provider_hive.dart';

class RestaurantUniversalApp extends ConsumerWidget {
  const RestaurantUniversalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeInitializer = ref.watch(localeInitializerProvider);
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeNotifierProvider);

    return localeInitializer.when(
      data: (_) {
        return MaterialApp.router(
          title: 'Restaurant Universal App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
          locale: locale, // Tanlangan til bu yerda qo'llaniladi
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}
