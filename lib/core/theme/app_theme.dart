import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Builds the Material 3 [ThemeData] for both apps in light & dark variants.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.lavender,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lavenderSoft,
      onPrimaryContainer: AppColors.purpleDeep,
      secondary: AppColors.pink,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.pinkSoft,
      onSecondaryContainer: AppColors.pinkDeep,
      tertiary: AppColors.gold,
      onTertiary: AppColors.textPrimary,
      tertiaryContainer: AppColors.skyBlueSoft,
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.warmWhite,
      onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      surfaceContainerHighest:
          isDark ? AppColors.darkCard : AppColors.surfaceTint,
      onSurfaceVariant:
          isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      outline: isDark ? const Color(0xFF4A3D5C) : const Color(0xFFE4D9EE),
      outlineVariant: isDark ? const Color(0xFF3A2E4D) : const Color(0xFFF0E8F7),
      shadow: Colors.black.withValues(alpha: 0.08),
      scrim: Colors.black54,
      inverseSurface: isDark ? AppColors.warmWhite : AppColors.textPrimary,
      onInverseSurface: isDark ? AppColors.textPrimary : AppColors.warmWhite,
      inversePrimary: AppColors.lavenderLight,
      surfaceTint: Colors.transparent,
    );

    final textTheme = AppTypography.textTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBg : AppColors.cream,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brLg),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.xl, vertical: AppDimens.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brPill),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brPill),
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.xl, vertical: AppDimens.lg),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.xl, vertical: AppDimens.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppDimens.brPill),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg, vertical: AppDimens.lg),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimens.brMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lavenderSoft,
        selectedColor: scheme.primary,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.xs),
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brPill),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: scheme.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.lavenderSoft,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brLg),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.purpleMid,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brMd),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: AppDimens.lg,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.lavender,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      extensions: const [_placeholder],
    );
  }

  // Reserved slot for a future custom ThemeExtension (e.g. gradient tokens).
  static const _placeholder = _NoopThemeExtension();
}

class _NoopThemeExtension extends ThemeExtension<_NoopThemeExtension> {
  const _NoopThemeExtension();
  @override
  ThemeExtension<_NoopThemeExtension> copyWith() => this;
  @override
  ThemeExtension<_NoopThemeExtension> lerp(
          ThemeExtension<_NoopThemeExtension>? other, double t) =>
      this;
}
