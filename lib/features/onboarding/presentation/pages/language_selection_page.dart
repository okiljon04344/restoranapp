import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/locale_provider_hive.dart';
import '../../../../core/platform.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  late String _selectedCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final deviceCode = getDeviceLocale().languageCode;
    _selectedCode = isLanguageSupported(deviceCode) ? deviceCode : 'uz';

    // Show the page in the pre-selected language, once the saved locale has
    // been loaded so it cannot overwrite the preview.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(localeInitializerProvider.future);
      if (!mounted) return;
      ref
          .read(localeNotifierProvider.notifier)
          .previewLocale(Locale(_selectedCode));
    });
  }

  Future<void> _confirm() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(localeNotifierProvider.notifier)
          .setLocale(Locale(_selectedCode));

      if (!mounted) return;
      context.go(isDesktopLike ? '/role-select' : '/table-entry');
    } catch (e) {
      debugPrint('Language confirm error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _select(LanguageMetadata language) {
    setState(() => _selectedCode = language.code);
    ref
        .read(localeNotifierProvider.notifier)
        .previewLocale(Locale(language.code));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 22,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l?.appTitle ?? 'Universal Restoran',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    l?.welcomeTitle ?? 'Xush kelibsiz!',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l?.chooseLanguage ?? 'Davom etish uchun tilni tanlang',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (final language in getSupportedLanguages()) ...[
                    _LanguageTile(
                      language: language,
                      isSelected: _selectedCode == language.code,
                      onTap: _isLoading ? null : () => _select(language),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _confirm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Text(l?.continueBtn ?? 'Davom etish →'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageMetadata language;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: isSelected ? scheme.primaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? scheme.primary : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  language.code.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      language.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
