import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _localeBoxName = 'app_settings';
const _languageCodeKey = 'language_code';

// Set only after the user confirms a language on the selection screen.
const _languageSelectedKey = 'user_confirmed_language';

const _defaultLocale = Locale('uz');

class LanguageMetadata {
  final String code;
  final String name;
  final String nativeName;

  const LanguageMetadata({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

/// Languages offered on the selection screen. A new language also needs
/// translation files in `lib/l10n/`.
const supportedLanguages = [
  LanguageMetadata(code: 'en', name: 'English', nativeName: 'English'),
  LanguageMetadata(code: 'uz', name: 'Uzbek', nativeName: "O'zbekcha"),
  LanguageMetadata(code: 'ja', name: 'Japanese', nativeName: '日本語'),
];

List<LanguageMetadata> getSupportedLanguages() => supportedLanguages;

bool isLanguageSupported(String code) {
  return supportedLanguages.any((lang) => lang.code == code);
}

Future<void> initializeLocaleStorage() async {
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive initialisation skipped: $e');
  }
}

Future<Locale> getSavedLocale() async {
  try {
    final box = await Hive.openBox(_localeBoxName);
    final languageCode = box.get(_languageCodeKey, defaultValue: 'uz');
    if (languageCode is String && isLanguageSupported(languageCode)) {
      return Locale(languageCode);
    }
  } catch (e) {
    debugPrint('Could not read saved locale: $e');
  }
  return _defaultLocale;
}

Future<bool> saveLocale(Locale locale) async {
  if (!isLanguageSupported(locale.languageCode)) return false;

  try {
    final box = await Hive.openBox(_localeBoxName);
    await box.put(_languageCodeKey, locale.languageCode);
    await box.put(_languageSelectedKey, true);

    return box.get(_languageCodeKey) == locale.languageCode &&
        box.get(_languageSelectedKey) == true;
  } catch (e) {
    debugPrint('Could not save locale: $e');
    return false;
  }
}

Locale getDeviceLocale() {
  try {
    return WidgetsBinding.instance.platformDispatcher.locale;
  } catch (e) {
    debugPrint('Could not read device locale: $e');
    return _defaultLocale;
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_defaultLocale);

  /// Persists [locale] and, only if that succeeded, switches the app to it.
  Future<bool> setLocale(Locale locale) async {
    if (!await saveLocale(locale)) return false;
    state = locale;
    return true;
  }

  /// Switches the UI language without persisting it.
  void previewLocale(Locale locale) {
    if (isLanguageSupported(locale.languageCode)) {
      state = locale;
    }
  }

  /// Applies a locale that was just read from storage.
  void applyLocale(Locale locale) {
    state = locale;
  }
}

/// Loads the saved locale from Hive once at startup.
final localeInitializerProvider = FutureProvider<void>((ref) async {
  await initializeLocaleStorage();
  final savedLocale = await getSavedLocale();
  ref.read(localeNotifierProvider.notifier).applyLocale(savedLocale);
});

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
