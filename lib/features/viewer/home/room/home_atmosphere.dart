import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/theme_mode.dart';

/// The light inside the house, at this hour.
///
/// The room's *layout* never changes — only its light does. That's the whole
/// trick: a place you recognise, lit differently depending on when you walked
/// in. Nothing here animates continuously; the values are picked once when Home
/// builds and simply hold, so this costs nothing at all.
enum HomeHour { morning, afternoon, evening, night }

HomeHour homeHourFor([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  // Night wraps past midnight — 2am is night, not an early morning. Ilam wakes
  // around five.
  if (h >= 21 || h < 5) return HomeHour.night;
  if (h < 11) return HomeHour.morning;
  if (h < 17) return HomeHour.afternoon;
  return HomeHour.evening;
}

/// Everything that shifts with the hour, resolved in one place so the room
/// can't drift out of tune with itself.
class Atmosphere {
  const Atmosphere({
    required this.hour,
    required this.wall,
    required this.ink,
    required this.inkSoft,
    required this.shelfShadow,
    required this.frameWood,
    required this.warmth,
  });

  final HomeHour hour;

  /// The wall behind everything.
  final Gradient wall;

  final Color ink;
  final Color inkSoft;

  /// How hard the mantel and table objects sit on their surface. Long and soft
  /// in the evening, almost nothing at midday.
  final Color shelfShadow;

  /// The frame timber. Warms as the day goes.
  final Color frameWood;

  /// 0 at midday → 1 late at night. Drives the lamp glow on the window frame.
  final double warmth;

  /// The room with the lamp off — `AppThemeChoice.night`.
  ///
  /// This is not "the same room, darker". Reading in bed means one small warm
  /// light and everything else falling away, so the wall goes to the app's
  /// dark ink, the timber deepens, and the shadows go soft rather than
  /// stronger — there isn't enough light left to cast a hard one.
  static const _night = Atmosphere(
    hour: HomeHour.night,
    wall: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1C1526), Color(0xFF231A30)],
    ),
    ink: Color(0xFFF1E9F7),
    inkSoft: Color(0xFFB9AFC7),
    shelfShadow: Color(0x44000000),
    frameWood: Color(0xFF6B4E30),
    warmth: 1.0,
  );

  static Atmosphere forTheme(HomeHour hour, {required bool dark}) =>
      dark ? _night : of(hour);

  static Atmosphere of(HomeHour hour) => switch (hour) {
        // Pale, cool, a bit thin — the light before the day has warmed up.
        HomeHour.morning => const Atmosphere(
            hour: HomeHour.morning,
            wall: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFDF7F4), Color(0xFFFBF3E9)],
            ),
            ink: Color(0xFF3A2E4D),
            inkSoft: Color(0xFF7A6E8A),
            shelfShadow: Color(0x14000000),
            frameWood: Color(0xFFCBB08A),
            warmth: 0.25,
          ),
        // Flat, bright, honest. Photographs look their best here.
        HomeHour.afternoon => const Atmosphere(
            hour: HomeHour.afternoon,
            wall: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBF6EF), Color(0xFFF7F1E6)],
            ),
            ink: Color(0xFF3A2E4D),
            inkSoft: Color(0xFF7A6E8A),
            shelfShadow: Color(0x10000000),
            frameWood: Color(0xFFC0A176),
            warmth: 0.0,
          ),
        // The good hour. Long shadows, gold coming in sideways.
        HomeHour.evening => const Atmosphere(
            hour: HomeHour.evening,
            wall: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7EDE2), Color(0xFFEFE2E4)],
            ),
            ink: Color(0xFF3A2B47),
            inkSoft: Color(0xFF7C6A86),
            shelfShadow: Color(0x22000000),
            frameWood: Color(0xFFA9784A),
            warmth: 0.75,
          ),
        // Quiet. The window becomes the brightest thing in the room.
        HomeHour.night => const Atmosphere(
            hour: HomeHour.night,
            wall: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE9E1EC), Color(0xFFDCD3E2)],
            ),
            ink: Color(0xFF332746),
            inkSoft: Color(0xFF6E6280),
            shelfShadow: Color(0x2E000000),
            frameWood: Color(0xFF8A6440),
            warmth: 1.0,
          ),
      };
}

final homeHourProvider = Provider<HomeHour>((ref) => homeHourFor());

/// The hour decides the light — unless the lamp is off, in which case that
/// decides it instead.
final atmosphereProvider = Provider<Atmosphere>((ref) => Atmosphere.forTheme(
      ref.watch(homeHourProvider),
      dark: ref.watch(themeChoiceProvider) == AppThemeChoice.night,
    ));

// ── Which Home she gets ────────────────────────────────────────────────────

/// The room is a big change to a screen this family already knew by heart, so
/// the old grid stays one tap away and the choice is remembered.
enum HomeStyle { room, classic }

class HomeStyleNotifier extends Notifier<HomeStyle> {
  static const _prefsKey = 'home_style';

  @override
  HomeStyle build() {
    _restore();
    return HomeStyle.room;
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    if (p.getString(_prefsKey) == 'classic') state = HomeStyle.classic;
  }

  Future<void> _persist(HomeStyle s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, s == HomeStyle.classic ? 'classic' : 'room');
  }

  void toggle() {
    final next =
        state == HomeStyle.room ? HomeStyle.classic : HomeStyle.room;
    state = next;
    _persist(next);
  }
}

final homeStyleProvider =
    NotifierProvider<HomeStyleNotifier, HomeStyle>(HomeStyleNotifier.new);
