import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/features/admin/gallery_admin_page.dart';
import 'package:dear_dipisha/features/viewer/visitors/garden_visitors.dart';

/// The bee and butterfly Diksha asked for on 2026-09-10, and the limits that
/// came with them. See DECISIONS.md.
const fast = VisitorTiming(
  firstVisit: Duration(milliseconds: 100),
  betweenVisits: (Duration(milliseconds: 200), Duration(milliseconds: 200)),
  flightLeg: (Duration(milliseconds: 300), Duration(milliseconds: 300)),
  restOnFlower: (Duration(milliseconds: 200), Duration(milliseconds: 200)),
  bubble: Duration(milliseconds: 500),
);

void main() {
  var tapped = false;

  setUp(() {
    tapped = false;
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer container({int seed = 1}) {
    final c = ProviderContainer(
      overrides: [
        visitorTimingProvider.overrideWithValue(fast),
        visitorRandomProvider.overrideWithValue(math.Random(seed)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Widget app(ProviderContainer c, {bool reduceMotion = false}) {
    return UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: Stack(
            fit: StackFit.expand,
            children: [child!, const GardenVisitors()],
          ),
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () => tapped = true,
              child: const Text('UNDER'),
            ),
          ),
        ),
      ),
    );
  }

  final visitor = find.byType(LottieBuilder);
  bool present() => visitor.evaluate().isNotEmpty;

  /// Pumps 50ms at a time until [done], returning how many steps it took,
  /// or -1 if it never happened.
  Future<int> pumpUntil(
    WidgetTester tester,
    bool Function() done, {
    int maxSteps = 80,
  }) async {
    for (var i = 0; i < maxSteps; i++) {
      if (done()) return i;
      await tester.pump(const Duration(milliseconds: 50));
    }
    return -1;
  }

  void phoneSized(WidgetTester tester) {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('a visitor flies in, moves, leaves, and another one follows', (
    tester,
  ) async {
    phoneSized(tester);
    await tester.pumpWidget(app(container()));
    await tester.pump();
    expect(present(), isFalse, reason: 'the app opens quiet');

    expect(await pumpUntil(tester, present), isNonNegative);
    final a = tester.getCenter(visitor);
    await tester.pump(const Duration(milliseconds: 100));
    final b = tester.getCenter(visitor);
    expect(a, isNot(equals(b)), reason: 'it is flying, not pasted on');

    expect(
      await pumpUntil(tester, () => !present(), maxSteps: 200),
      isNonNegative,
      reason: 'it leaves after resting',
    );
    expect(
      await pumpUntil(tester, present),
      isNonNegative,
      reason: 'another visitor comes later',
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'touching a visitor makes it speak; touching elsewhere reaches the app',
    (tester) async {
      phoneSized(tester);
      await tester.pumpWidget(app(container()));
      await tester.pump();

      await tester.tap(find.text('UNDER'));
      expect(tapped, isTrue, reason: 'nothing blocks the screen while empty');
      tapped = false;

      expect(await pumpUntil(tester, present), isNonNegative);
      // Wait until the visitor is fully on screen and well away from the
      // button in the top-left corner.
      expect(
        await pumpUntil(tester, () {
          if (!present()) return false;
          final c = tester.getCenter(visitor);
          return c.dx > 160 && c.dy > 160 && c.dx < 320 && c.dy < 760;
        }, maxSteps: 200),
        isNonNegative,
      );
      await tester.tap(find.text('UNDER'));
      expect(tapped, isTrue, reason: 'the overlay lets touches through');

      await tester.tap(visitor);
      await tester.pump();
      final bubble = find.byKey(const Key('visitor-bubble'));
      expect(bubble, findsOneWidget);
      // Above the Navigator there is no Material; without one the line
      // draws in a bare font with yellow underlines.
      expect(
        find.descendant(of: bubble, matching: find.byType(Material)),
        findsOneWidget,
      );
      final line = tester.widget<Text>(
        find.descendant(of: bubble, matching: find.byType(Text)),
      );
      expect(line.style?.decoration, TextDecoration.none);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(find.byKey(const Key('visitor-bubble')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a held screen sends the visitor away and keeps others out', (
    tester,
  ) async {
    phoneSized(tester);
    final c = container();
    await tester.pumpWidget(app(c));
    await tester.pump();
    expect(await pumpUntil(tester, present), isNonNegative);

    c.read(visitorsHeldProvider.notifier).hold();
    await tester.pump();
    expect(present(), isFalse, reason: 'gone the moment the desk opens');
    expect(await pumpUntil(tester, present, maxSteps: 30), -1);

    c.read(visitorsHeldProvider.notifier).release();
    expect(await pumpUntil(tester, present), isNonNegative);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('the cabinet switch is remembered and keeps them resting', (
    tester,
  ) async {
    phoneSized(tester);
    SharedPreferences.setMockInitialValues({'garden_visitors': false});
    final c = container();
    await tester.pumpWidget(app(c));
    await tester.pump();
    expect(await pumpUntil(tester, present, maxSteps: 30), -1);

    c.read(visitorsEnabledProvider.notifier).toggle();
    expect(await pumpUntil(tester, present), isNonNegative);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion means no visitors at all', (tester) async {
    phoneSized(tester);
    await tester.pumpWidget(app(container(), reduceMotion: true));
    await tester.pump();
    expect(await pumpUntil(tester, present, maxSteps: 30), -1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('the album desk holds the visitors while it is open', (
    tester,
  ) async {
    final c = ProviderContainer(
      overrides: [
        galleryRepositoryProvider.overrideWithValue(null),
        galleryRoleProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: GalleryAdminPage()),
      ),
    );
    await tester.pump();
    expect(c.read(visitorsHeldProvider), 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(c.read(visitorsHeldProvider), 0);
    expect(tester.takeException(), isNull);
  });
}
