import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../../app/locale_provider_hive.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage>
    with WidgetsBindingObserver {
  bool _hasCheckedSelection = false;
  bool _isLoading = false;
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIfLanguageSelected();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkIfLanguageSelected() async {
    try {
      final hasSelected = await hasSelectedLanguage();
      if (hasSelected && mounted) {
        // User has already selected a language, navigate away
        await _navigateNext();
        return;
      }

      // Always show language selection screen on first launch
      // so the user can choose from 3 languages
      if (mounted) {
        setState(() {
          _hasCheckedSelection = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking language selection: $e');
      // If there's an error, show the language selection
      if (mounted) {
        setState(() {
          _hasCheckedSelection = true;
        });
      }
    }
  }

  Future<void> _navigateNext() async {
    try {
      if (!mounted) return;

      final isDesktop = kIsWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

      if (mounted) {
        context.go(isDesktop ? '/role-select' : '/table-entry');
      }
    } catch (e) {
      _showErrorSnackBar('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything until we've checked if language was selected
    if (!_hasCheckedSelection) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade50,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                ),
                SizedBox(height: 24),
                Text(
                  'Detecting device language...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                // Header Icon
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language,
                      size: 64,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  AppLocalizations.of(context)?.selectLanguage ?? 'Select Your Language',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                ),
                const SizedBox(height: 12),
                // Subtitle with device language info
                Column(
                  children: [
                    Text(
                      'Tilni tanlang / 言語を選択してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isDeviceLocaleSupported()) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '📱 ${AppLocalizations.of(context)?.deviceLanguage(_getDeviceLanguageName(getDeviceLocale().languageCode)) ?? 'Device language: ${_getDeviceLanguageName(getDeviceLocale().languageCode)}'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 48),
                // Language Buttons
                Expanded(
                  child: _buildLanguageButtonsList(),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButtonsList() {
    final supportedLanguages = getSupportedLanguages();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: supportedLanguages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final language = supportedLanguages[index];
        final isSelected = _selectedLanguageCode == language.code;

        return _LanguageButton(
          title: language.name,
          subtitle: language.nativeName,
          flag: language.flag,
          isSelected: isSelected,
          isLoading: _isLoading && isSelected,
          onTap: _isLoading ? null : () => _selectLanguage(language.code),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectLanguage(String languageCode) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _selectedLanguageCode = languageCode;
    });

    try {
      final locale = Locale(languageCode);

      // Save locale and wait for confirmation
      final saved =
          await ref.read(localeNotifierProvider.notifier).setLocale(locale);

      if (!saved) {
        _showErrorSnackBar(AppLocalizations.of(context)?.failedToSaveLanguage ?? 'Failed to save language preference');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _selectedLanguageCode = null;
          });
        }
        return;
      }

      // Add a small delay to ensure the UI updates
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigate to next screen
      await _navigateNext();
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)?.errorSelectingLanguage ?? 'Error selecting language'}: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedLanguageCode = null;
        });
      }
    }
  }

  String _getDeviceLanguageName(String code) {
    final metadata = getLanguageMetadata(code);
    return metadata?.name ?? code.toUpperCase();
  }
}

class _LanguageButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final String flag;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  const _LanguageButton({
    required this.title,
    required this.subtitle,
    required this.flag,
    this.isSelected = false,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<_LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<_LanguageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onTap != null ? (_) => _animationController.forward() : null,
      onTapUp:
          widget.onTap != null ? (_) => _animationController.reverse() : null,
      onTapCancel:
          widget.onTap != null ? () => _animationController.reverse() : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Card(
          elevation: widget.isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: widget.isSelected
                  ? Colors.green.shade600
                  : Colors.transparent,
              width: widget.isSelected ? 2 : 0,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.blue.shade50,
                      ],
                    )
                  : null,
              color: widget.isSelected ? null : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  // Flag
                  Text(
                    widget.flag,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 20),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Loading or Check Icon
                  if (widget.isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade600,
                        ),
                      ),
                    )
                  else if (widget.isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 28,
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
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
