import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/locale_provider_hive.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  String? _selectedCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select device language if supported
    final deviceLocale = getDeviceLocale();
    if (isLanguageSupported(deviceLocale.languageCode)) {
      _selectedCode = deviceLocale.languageCode;
    } else {
      _selectedCode = 'uz';
    }
  }

  Future<void> _confirm() async {
    if (_selectedCode == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final locale = Locale(_selectedCode!);
      await ref.read(localeNotifierProvider.notifier).setLocale(locale);

      if (!mounted) return;

      final isDesktop = kIsWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

      context.go(isDesktop ? '/role-select' : '/table-entry');
    } catch (e) {
      debugPrint('Language confirm error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = getSupportedLanguages();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.08),
              scheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        // ── Logo/Icon ──────────────────────────────────────
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 52,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Title ─────────────────────────────────────────
                        Text(
                          AppLocalizations.of(context)?.welcomeTitle ??
                              'Xush kelibsiz!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context)?.chooseLanguage ??
                              'Davom etish uchun tilni tanlang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Language Buttons ───────────────────────────────
                        ...languages.map(
                          (lang) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _LangTile(
                              language: lang,
                              isSelected: _selectedCode == lang.code,
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() => _selectedCode = lang.code);
                                      ref
                                          .read(localeNotifierProvider.notifier)
                                          .previewLocale(Locale(lang.code));
                                    },
                            ),
                          ),
                        ),

                        const Spacer(),

                        // ── Confirm Button ─────────────────────────────────
                        FilledButton(
                          onPressed: _isLoading ? null : _confirm,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(AppLocalizations.of(context)?.continueBtn ??
                                  'Davom etish →'),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Til tugmasi ────────────────────────────────────────────────────────────
class _LangTile extends StatelessWidget {
  final LanguageMetadata language;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LangTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? scheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Text(language.flag, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.75)
                            : scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        key: ValueKey(true),
                        color: Colors.white,
                        size: 26,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        key: const ValueKey(false),
                        color: scheme.outlineVariant,
                        size: 26,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
