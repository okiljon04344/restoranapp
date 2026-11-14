import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'locale_provider_hive.dart';
import 'router_admin.dart';

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Loads the saved language from Hive and applies it to the notifier.
    ref.watch(localeInitializerProvider);
    final router = ref.watch(adminRouterProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.adminPanel ?? '',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
