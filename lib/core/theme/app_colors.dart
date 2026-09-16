import 'package:flutter/material.dart';

/// Central color palette for **Dear Dipisha**.
///
/// The palette is intentionally soft and warm — lavender, baby pink, sky blue,
/// cream and a golden accent. Nothing harsh. These tokens are the single source
/// of truth for both the viewer (mobile) app and the admin (web) dashboard.
abstract final class AppColors {
  AppColors._();

  // ── Brand / Primary (Lavender → Purple) ──────────────────────────────
  static const Color lavender = Color(0xFF9B72CF);
  static const Color lavenderLight = Color(0xFFB79BE0);
  static const Color lavenderSoft = Color(0xFFEBDDF7);
  static const Color purpleDeep = Color(0xFF5B2B8A);
  static const Color purpleMid = Color(0xFF6B3FA0);

  // ── Secondary (Baby Pink) ────────────────────────────────────────────
  static const Color pink = Color(0xFFF4A9C7);
  static const Color pinkLight = Color(0xFFFAD3E1);
  static const Color pinkSoft = Color(0xFFFDEAF1);
  static const Color pinkDeep = Color(0xFFE8749E);

  // ── Accents ──────────────────────────────────────────────────────────
  static const Color skyBlue = Color(0xFFA9D3F0);
  static const Color skyBlueSoft = Color(0xFFE3F1FB);
  static const Color gold = Color(0xFFF2C879);
  static const Color goldDeep = Color(0xFFE0A93E);

  // ── Neutrals / Surfaces ──────────────────────────────────────────────
  static const Color cream = Color(0xFFFBF6EF);
  static const Color warmWhite = Color(0xFFFFFDFB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFF6F0FA);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF3A2E4D);
  static const Color textSecondary = Color(0xFF7A6E8A);
  static const Color textMuted = Color(0xFFA99FB5);
  static const Color textOnDark = Color(0xFFFDF7FF);

  // ── Feedback ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF7BC47F);
  static const Color warning = Color(0xFFF2B84B);
  static const Color error = Color(0xFFE07A7A);
  static const Color info = skyBlue;

  // ── Dark theme surfaces ──────────────────────────────────────────────
  static const Color darkBg = Color(0xFF1C1526);
  static const Color darkSurface = Color(0xFF261C33);
  static const Color darkCard = Color(0xFF302442);
  static const Color darkTextPrimary = Color(0xFFF1E9F7);
  static const Color darkTextSecondary = Color(0xFFB9AFC7);

  // ── Signature gradients ──────────────────────────────────────────────

  /// Deep dreamy splash / hug-screen background (mockup: splash + hug).
  static const LinearGradient dreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6B3FA0), Color(0xFF8B5CC0), Color(0xFF9B72CF)],
  );

  /// Soft lavender→pink used on cards and headers.
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEBDDF7), Color(0xFFFDEAF1)],
  );

  /// Warm home background wash.
  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFDF6FB), Color(0xFFFBF6EF)],
  );

  /// The signature "hug" heart gradient (mockup: hug screen heart).
  static const LinearGradient heartGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4A9C7), Color(0xFFE8749E)],
  );

  /// Golden accent gradient for celebratory highlights.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7D89B), Color(0xFFE0A93E)],
  );
}
