import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_provider_hive.dart';
import '../ui/feedback.dart';

/// App bar action that switches the UI language and persists the choice.
class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(supportedLanguagesProvider);
    final current = ref.watch(localeNotifierProvider);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: context.l10n.chooseLanguage,
      initialValue: current.languageCode,
      onSelected: (code) =>
          ref.read(localeNotifierProvider.notifier).setLocale(Locale(code)),
      itemBuilder: (_) => [
        for (final language in languages)
          PopupMenuItem(
            value: language.code,
            child: Text('${language.flag}  ${language.nativeName}'),
          ),
      ],
    );
  }
}
