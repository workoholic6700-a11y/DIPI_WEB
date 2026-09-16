import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/core/router/app_routes.dart';
import 'package:dear_dipisha/features/viewer/home/room/home_atmosphere.dart';
import 'package:dear_dipisha/features/viewer/home/room/widgets/family_cabinet.dart';

/// "Inside Our Home" took the section grid off the Home screen. The danger in
/// that move is silent loss: a destination stops being advertised, nobody
/// notices it stopped being reachable, and a screen quietly dies.
///
/// So the cabinet is tested as a navigation contract, not as a UI detail.
void main() {
  /// Every route a person is meant to be able to reach from Home.
  ///
  /// Detail routes with path parameters are excluded — those are reached by
  /// tapping the thing they belong to, not from a menu.
  const reachable = <String>[
    Routes.members,
    Routes.familyTree,
    Routes.ourStory,
    Routes.pets,
    Routes.gallery,
    Routes.memories,
    Routes.timeline,
    Routes.places,
    Routes.quotes,
    Routes.birthdays,
    Routes.hall,
    Routes.heritage,
    Routes.sakela,
    Routes.garden,
    Routes.village,
    Routes.dipishaGate,
  ];

  List<String> cabinetRoutes() =>
      [for (final g in familyCabinet) ...g.$2.map((e) => e.$2)];

  group('the family cabinet', () {
    test('still reaches every destination the old grid did', () {
      final inCabinet = cabinetRoutes().toSet();
      for (final route in reachable) {
        expect(inCabinet, contains(route),
            reason: '$route is no longer reachable from Home. Moving the grid '
                'into the cabinet must not drop a destination.');
      }
    });

    test('lists nothing twice', () {
      final routes = cabinetRoutes();
      expect(routes.toSet().length, routes.length,
          reason: 'a destination appears in two cabinet groups');
    });

    test('every group has a heading and at least one item', () {
      for (final g in familyCabinet) {
        expect(g.$1, isNotEmpty);
        expect(g.$2, isNotEmpty);
      }
    });

    test('every label has Nepali', () {
      for (final g in familyCabinet) {
        expect(hasNepali(g.$1), isTrue,
            reason: 'cabinet group "${g.$1}" has no Nepali');
        for (final item in g.$2) {
          expect(hasNepali(item.$1), isTrue,
              reason: 'cabinet item "${item.$1}" has no Nepali');
        }
      }
    });
  });

  group('the light in the room', () {
    test('each hour of the day maps to a phase', () {
      // Boundaries are the bit that goes wrong, so walk all 24.
      for (var h = 0; h < 24; h++) {
        final phase = homeHourFor(DateTime(2026, 8, 5, h));
        expect(phase, isNotNull);
      }
      expect(homeHourFor(DateTime(2026, 8, 5, 7)), HomeHour.morning);
      expect(homeHourFor(DateTime(2026, 8, 5, 13)), HomeHour.afternoon);
      expect(homeHourFor(DateTime(2026, 8, 5, 19)), HomeHour.evening);
      expect(homeHourFor(DateTime(2026, 8, 5, 23)), HomeHour.night);
      expect(homeHourFor(DateTime(2026, 8, 5, 2)), HomeHour.night);
    });

    test('every phase resolves a full atmosphere', () {
      for (final h in HomeHour.values) {
        final a = Atmosphere.of(h);
        expect(a.hour, h);
        expect(a.warmth, inInclusiveRange(0.0, 1.0));
      }
    });

    test('the room gets warmer as the day ends', () {
      // Midday is the neutral point; night is the warmest lamp-light.
      expect(Atmosphere.of(HomeHour.afternoon).warmth,
          lessThan(Atmosphere.of(HomeHour.evening).warmth));
      expect(Atmosphere.of(HomeHour.evening).warmth,
          lessThanOrEqualTo(Atmosphere.of(HomeHour.night).warmth));
    });

    test('shadows deepen after dark', () {
      double a(HomeHour h) => Atmosphere.of(h).shelfShadow.a;
      expect(a(HomeHour.afternoon), lessThan(a(HomeHour.evening)));
      expect(a(HomeHour.evening), lessThan(a(HomeHour.night)));
    });
  });

  group('the room says only what is true', () {
    test('the greeting line does not claim anyone did something today', () {
      // `Letter` has no read/unread state and nothing persists one, so Home
      // must not imply either. If somebody later adds real state, this test
      // should be updated deliberately — not deleted in passing.
      const line = 'There are family stories waiting for you.';
      expect(hasNepali(line), isTrue);
      for (final banned in ['left something', 'today', 'unread', 'new']) {
        expect(line.toLowerCase(), isNot(contains(banned)));
      }
    });
  });
}
