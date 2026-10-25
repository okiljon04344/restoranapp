import 'package:flutter/material.dart';

/// Brand and neutral colours. Screens read them through [ThemeData] /
/// [AppPalette] instead of hard-coding values.
abstract final class AppColors {
  static const terracotta = Color(0xFFB5452C);
  static const terracottaSoft = Color(0xFFF4E1D8);
  static const terracottaDark = Color(0xFF5E1F10);

  static const cream = Color(0xFFFAF7F2);
  static const paper = Color(0xFFFFFFFF);
  static const sand = Color(0xFFF1EBE0);
  static const line = Color(0xFFE6DED1);
  static const lineStrong = Color(0xFFCFC3B2);

  static const ink = Color(0xFF2E2622);
  static const inkMuted = Color(0xFF6F6259);

  static const danger = Color(0xFF9B2C2C);
  static const success = Color(0xFF4A6B2D);
  static const warning = Color(0xFF94610F);
  static const info = Color(0xFF3F6078);
}

/// Semantic colours that have no slot in [ColorScheme].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color success;
  final Color warning;
  final Color info;

  const AppPalette({
    required this.success,
    required this.warning,
    required this.info,
  });

  static const light = AppPalette(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  /// Colour for an order status. Unknown statuses fall back to muted ink.
  Color statusColor(ColorScheme scheme, String status) {
    switch (status) {
      case 'pending':
        return warning;
      case 'preparing':
      case 'cooking':
        return info;
      case 'ready':
      case 'delivered':
        return success;
      case 'cancelled':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  AppPalette copyWith({Color? success, Color? warning, Color? info}) {
    return AppPalette(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

class AppTheme {
  static const double radius = 12;
  static const double radiusSmall = 8;

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.terracotta,
      onPrimary: Colors.white,
      primaryContainer: AppColors.terracottaSoft,
      onPrimaryContainer: AppColors.terracottaDark,
      secondary: Color(0xFF7A5C45),
      onSecondary: Colors.white,
      secondaryContainer: AppColors.sand,
      onSecondaryContainer: AppColors.ink,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerLowest: AppColors.paper,
      surfaceContainerLow: AppColors.cream,
      surfaceContainer: AppColors.sand,
      surfaceContainerHigh: AppColors.sand,
      surfaceContainerHighest: AppColors.sand,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.line,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.cream,
      inversePrimary: AppColors.terracottaSoft,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
    );

    final textTheme = base.textTheme
        .copyWith(
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
          bodySmall: const TextStyle(fontSize: 12, height: 1.4),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSmall + 2),
      borderSide: const BorderSide(color: AppColors.lineStrong),
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: const [AppPalette.light],
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        shape: const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.inkMuted),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: AppColors.inkMuted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall + 2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.lineStrong),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall + 2),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall + 2),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paper,
        selectedColor: AppColors.terracotta,
        side: const BorderSide(color: AppColors.line),
        labelStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        titleTextStyle: textTheme.titleLarge,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.cream),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.terracotta,
        linearTrackColor: AppColors.sand,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
    );
  }
}
