import 'package:flutter/widgets.dart';

/// Spacing, radius and elevation tokens. Keeping these centralized guarantees
/// consistent, comfortable spacing across every screen (a core design goal).
abstract final class AppDimens {
  AppDimens._();

  // Spacing scale (4pt grid).
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Corner radii — generous & rounded to feel soft.
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusPill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius brPill =
      BorderRadius.all(Radius.circular(radiusPill));

  // Common insets.
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // Responsive breakpoints (used mainly by the admin web dashboard).
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  static const double maxContentWidth = 1280;
}
