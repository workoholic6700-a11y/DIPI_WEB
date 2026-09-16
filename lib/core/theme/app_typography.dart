import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for **Dear Dipisha**.
///
/// - Display / headings use **Quicksand** — a soft, rounded geometric sans that
///   feels warm and childlike without being cartoonish (matches the mockups).
/// - Body / UI text uses **Nunito** — highly readable with rounded terminals.
/// - The signature app title ("Dear Dipisha") uses **Pacifico**, a flowing
///   script, seen on the splash & admin login.
abstract final class AppTypography {
  AppTypography._();

  static TextStyle brandScript({
    double fontSize = 40,
    Color color = AppColors.textOnDark,
  }) =>
      GoogleFonts.pacifico(
        fontSize: fontSize,
        color: color,
        height: 1.1,
      );

  static TextTheme textTheme(Color primary, Color secondary) {
    final display = GoogleFonts.quicksandTextTheme();
    final body = GoogleFonts.nunitoTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
          fontSize: 40, fontWeight: FontWeight.w700, color: primary),
      displayMedium: display.displayMedium?.copyWith(
          fontSize: 32, fontWeight: FontWeight.w700, color: primary),
      displaySmall: display.displaySmall?.copyWith(
          fontSize: 28, fontWeight: FontWeight.w700, color: primary),
      headlineLarge: display.headlineLarge?.copyWith(
          fontSize: 26, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: display.headlineMedium?.copyWith(
          fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineSmall: display.headlineSmall?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      titleLarge: display.titleLarge?.copyWith(
          fontSize: 18, fontWeight: FontWeight.w700, color: primary),
      titleMedium: display.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleSmall: display.titleSmall?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: body.bodyLarge?.copyWith(
          fontSize: 16, height: 1.5, color: primary),
      bodyMedium: body.bodyMedium?.copyWith(
          fontSize: 14, height: 1.5, color: secondary),
      bodySmall: body.bodySmall?.copyWith(
          fontSize: 12, height: 1.4, color: secondary),
      labelLarge: body.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w700, color: primary),
      labelMedium: body.labelMedium?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w600, color: secondary),
      labelSmall: body.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w600, color: secondary),
    );
  }
}
