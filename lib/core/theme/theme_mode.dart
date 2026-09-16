import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which of the two themes the app wears.
///
/// [AppTheme.dark] has existed and been fully built since the beginning and
/// was unreachable — `themeMode` was hardcoded to light. This makes it a real
/// choice.
///
/// It deliberately does **not** follow the system setting. Half the phones in
/// this family sit in dark mode all the time, and a pastel scrapbook that
/// silently turns dark the first time it's opened would be a surprise, not a
/// feature. Light stays the default; dark is something you choose, for reading
/// in bed with the lamp off.
enum AppThemeChoice { light, night }

class ThemeChoiceNotifier extends Notifier<AppThemeChoice> {
  static const _prefsKey = 'theme_choice';

  @override
  AppThemeChoice build() {
    _restore();
    return AppThemeChoice.light;
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    if (p.getString(_prefsKey) == 'night') state = AppThemeChoice.night;
  }

  Future<void> _persist(AppThemeChoice c) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, c == AppThemeChoice.night ? 'night' : 'light');
  }

  void toggle() {
    final next = state == AppThemeChoice.light
        ? AppThemeChoice.night
        : AppThemeChoice.light;
    state = next;
    _persist(next);
  }
}

final themeChoiceProvider =
    NotifierProvider<ThemeChoiceNotifier, AppThemeChoice>(
        ThemeChoiceNotifier.new);

/// What `MaterialApp` actually needs.
final themeModeProvider = Provider<ThemeMode>((ref) =>
    ref.watch(themeChoiceProvider) == AppThemeChoice.night
        ? ThemeMode.dark
        : ThemeMode.light);
