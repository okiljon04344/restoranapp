import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================================
// LANGUAGE MANAGEMENT SYSTEM - Professional Localization Provider
// ============================================================================

/// Hive box uchun key
const String _localeBoxName = 'app_settings';
const String _languageCodeKey = 'language_code';
// 'user_confirmed_language' - foydalanuvchi o'zi tanlagan holda saqlanadi
// Eski 'language_selected' (auto-set) dan farq qiladi — migration uchun
const String _languageSelectedKey = 'user_confirmed_language';

/// Default locale (fallback language)
const Locale _defaultLocale = Locale('uz');

/// Language metadata - Easy to add new languages
/// To add a new language:
/// 1. Add entry below with language code
/// 2. Add translation files to lib/l10n/
/// 3. Run: flutter pub global run intl_utils:extract_to_arb
/// 4. That's it! Auto-detection and selection will work immediately
class LanguageMetadata {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isSupported;

  LanguageMetadata({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isSupported = true,
  });

  Locale toLocale() => Locale(code);

  @override
  String toString() => '$name ($nativeName)';
}

/// All available languages - Easily extensible
/// Add new languages here without modifying other code
final List<LanguageMetadata> allLanguages = [
  LanguageMetadata(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
    isSupported: true,
  ),
  LanguageMetadata(
    code: 'uz',
    name: 'Uzbek',
    nativeName: "O'zbekcha",
    flag: '🇺🇿',
    isSupported: true,
  ),
  LanguageMetadata(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
    isSupported: true,
  ),
  // Add more languages here:
  // LanguageMetadata(
  //   code: 'ru',
  //   name: 'Russian',
  //   nativeName: 'Русский',
  //   flag: '🇷🇺',
  //   isSupported: true,
  // ),
  // LanguageMetadata(
  //   code: 'es',
  //   name: 'Spanish',
  //   nativeName: 'Español',
  //   flag: '🇪🇸',
  //   isSupported: true,
  // ),
];

/// Supported language codes (for quick validation)
const List<String> _supportedLanguages = ['en', 'uz', 'ja'];

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/// Initialize Hive storage for locale persistence
Future<void> initializeLocaleStorage() async {
  try {
    await Hive.initFlutter();
    debugPrint('✓ Hive storage initialized successfully');
  } catch (e) {
    debugPrint('⚠ Hive already initialized: $e');
  }
}

/// Get language metadata by code
LanguageMetadata? getLanguageMetadata(String code) {
  try {
    return allLanguages.firstWhere(
      (lang) => lang.code == code && lang.isSupported,
      orElse: () => allLanguages.first,
    );
  } catch (e) {
    debugPrint('Error getting language metadata for $code: $e');
    return null;
  }
}

/// Get all supported languages
List<LanguageMetadata> getSupportedLanguages() {
  return allLanguages.where((lang) => lang.isSupported).toList();
}

/// Validate if language code is supported
bool isLanguageSupported(String code) {
  return _supportedLanguages.contains(code) &&
      allLanguages.any((lang) => lang.code == code && lang.isSupported);
}

// ============================================================================
// LOCALE PERSISTENCE FUNCTIONS
// ============================================================================

/// Get saved language from Hive or default to 'uz'
Future<Locale> getSavedLocale() async {
  try {
    final box = await Hive.openBox(_localeBoxName);
    final languageCode = box.get(_languageCodeKey, defaultValue: 'uz');

    // Validate language code
    if (languageCode is! String || languageCode.isEmpty) {
      debugPrint('Invalid saved language code, using default');
      return _defaultLocale;
    }

    // Validate that language is still supported
    if (!isLanguageSupported(languageCode)) {
      debugPrint(
          'Saved language $languageCode no longer supported, using default');
      return _defaultLocale;
    }

    debugPrint('✓ Loaded saved locale: $languageCode');
    return Locale(languageCode);
  } catch (e) {
    debugPrint('✗ Error getting saved locale: $e');
    return _defaultLocale;
  }
}

/// Check if user has already selected a language
Future<bool> hasSelectedLanguage() async {
  try {
    final box = await Hive.openBox(_localeBoxName);
    final selected = box.get(_languageSelectedKey, defaultValue: false);
    return selected is bool ? selected : false;
  } catch (e) {
    debugPrint('✗ Error checking if language selected: $e');
    return false;
  }
}

/// Save language to Hive with validation
Future<bool> saveLocale(Locale locale) async {
  try {
    // Validate locale
    if (locale.languageCode.isEmpty) {
      debugPrint('✗ Invalid locale language code');
      return false;
    }

    // Validate support
    if (!isLanguageSupported(locale.languageCode)) {
      debugPrint('✗ Language ${locale.languageCode} is not supported');
      return false;
    }

    final box = await Hive.openBox(_localeBoxName);

    // Save with proper error handling
    await box.put(_languageCodeKey, locale.languageCode);
    await box.put(_languageSelectedKey, true);

    // Verify the save was successful
    final savedCode = box.get(_languageCodeKey);
    final savedSelected = box.get(_languageSelectedKey);

    final success = savedCode == locale.languageCode && savedSelected == true;

    if (success) {
      debugPrint('✓ Language saved: ${locale.languageCode}');
    } else {
      debugPrint('✗ Failed to verify locale save');
    }

    return success;
  } catch (e) {
    debugPrint('✗ Error saving locale: $e');
    return false;
  }
}

// ============================================================================
// DEVICE LANGUAGE DETECTION FUNCTIONS
// ============================================================================

/// Get device locale from system
Locale getDeviceLocale() {
  try {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    debugPrint('📱 Device locale detected: ${deviceLocale.languageCode}');
    return deviceLocale;
  } catch (e) {
    debugPrint('✗ Error getting device locale: $e');
    return _defaultLocale;
  }
}

// ============================================================================
// STATE NOTIFIER - Riverpod Integration
// ============================================================================

class LocaleNotifier extends StateNotifier<Locale> {
  // localeInitializerProvider startup da applyLocale() orqali to'g'ri qiymat beradi
  LocaleNotifier() : super(_defaultLocale);

  /// Set locale and save to Hive immediately
  Future<bool> setLocale(Locale locale) async {
    try {
      // Validate input
      if (locale.languageCode.isEmpty) {
        debugPrint('✗ Cannot set empty locale');
        return false;
      }

      // Validate support
      if (!isLanguageSupported(locale.languageCode)) {
        debugPrint('✗ Language ${locale.languageCode} is not supported');
        return false;
      }

      // Save to Hive first
      final saved = await saveLocale(locale);

      if (saved) {
        // Only update state after successful save
        state = locale;
        debugPrint('✓ Successfully changed locale to: ${locale.languageCode}');
        return true;
      } else {
        debugPrint('✗ Failed to save locale to Hive');
        return false;
      }
    } catch (e) {
      debugPrint('✗ Error setting locale: $e');
      return false;
    }
  }

  /// Preview locale (updates UI only, does NOT save to Hive)
  void previewLocale(Locale locale) {
    if (isLanguageSupported(locale.languageCode)) {
      state = locale;
    }
  }

  /// Apply locale directly (called by initializer, does NOT re-save to Hive)
  void applyLocale(Locale locale) {
    state = locale;
    debugPrint('✓ Applied locale from storage: ${locale.languageCode}');
  }

  /// Reset to default locale
  Future<bool> resetToDefault() async {
    return setLocale(_defaultLocale);
  }

  /// Get current locale
  Locale getCurrentLocale() => state;

  /// Get language metadata for current locale
  LanguageMetadata? getCurrentLanguageMetadata() {
    return getLanguageMetadata(state.languageCode);
  }
}

// ============================================================================
// RIVERPOD PROVIDERS
// ============================================================================

/// Provider that initializes locale from Hive on startup (runs ONCE)
final localeInitializerProvider = FutureProvider<void>((ref) async {
  try {
    await initializeLocaleStorage();
    // Load saved locale into the notifier (reads Hive once at startup)
    final savedLocale = await getSavedLocale();
    ref.read(localeNotifierProvider.notifier).applyLocale(savedLocale);
  } catch (e) {
    debugPrint('✗ Error in locale initializer: $e');
  }
});

/// Main locale provider using StateNotifierProvider
final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Get all supported languages provider
final supportedLanguagesProvider = Provider<List<LanguageMetadata>>((ref) {
  return getSupportedLanguages();
});

/// Get current language metadata provider
final currentLanguageProvider = Provider<LanguageMetadata?>((ref) {
  final locale = ref.watch(localeNotifierProvider);
  return getLanguageMetadata(locale.languageCode);
});
