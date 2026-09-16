import 'dart:convert';
import 'dart:io';

import 'package:dear_dipisha/core/web/phone_frame.dart';
import 'package:dear_dipisha/shared/widgets/landscape_scope.dart';
import 'package:dear_dipisha/shared/widgets/portrait_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the browser tab names the family app, not the Flutter template', () {
    final page = File('web/index.html').readAsStringSync();
    expect(page, contains('<title>Our Home · The Rai Family</title>'));
    expect(page, isNot(contains('A new Flutter project')));
    expect(page, isNot(contains('dear_dipisha')));
  });

  test('a family scrapbook asks search engines to stay out', () {
    final page = File('web/index.html').readAsStringSync();
    expect(page, contains('<meta name="robots" content="noindex, nofollow">'));
  });

  test('an installed web app can still turn sideways for the World', () {
    // Dipisha's World and her rooms are landscape. A portrait lock in the
    // manifest would hold an installed web app upright and stop them turning.
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(manifest['orientation'], 'any');
    expect(manifest['short_name'], 'Our Home');
  });

  test('photos and postcards save in a browser, not only on a phone', () {
    // The phone saves through MainActivity.kt, which a browser doesn't have.
    // Without these branches the download button hides itself on the web
    // and the postcard buttons fail silently.
    final download = File(
      'lib/data/gallery/photo_download_service.dart',
    ).readAsStringSync();
    expect(download, contains('kIsWeb ||'));
    expect(download, contains('browser.downloadBytes'));
    final postcard = File(
      'lib/features/viewer/village/village_photography.dart',
    ).readAsStringSync();
    expect(postcard, contains('browser.downloadBytes'));
    expect(postcard, contains('browser.shareBytes'));
  });

  test('the family app is wrapped in the phone-width frame', () {
    final main = File('lib/main_viewer.dart').readAsStringSync();
    expect(main, contains('PhoneFrame('));
  });

  group('on a wide browser window', () {
    const probe = Key('screen');

    Future<double> screenWidth(
      WidgetTester tester, {
      required Size window,
      required Widget Function(Widget screen) wrap,
    }) async {
      tester.view.physicalSize = window;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => PhoneFrame(child: child!),
          home: wrap(const SizedBox.expand(key: probe)),
        ),
      );
      // Scopes register after the frame, the way a phone rotates late.
      await tester.pump();
      return tester.getSize(find.byKey(probe)).width;
    }

    testWidgets('the family app keeps its phone width', (tester) async {
      final width = await screenWidth(
        tester,
        window: const Size(1366, 768),
        wrap: (screen) => screen,
      );
      expect(width, PhoneFrame.phoneWidth);
    });

    testWidgets('Dipisha\'s World takes the whole window', (tester) async {
      final width = await screenWidth(
        tester,
        window: const Size(1366, 768),
        wrap: (screen) => LandscapeScope(child: screen),
      );
      expect(width, 1366);
    });

    testWidgets('a letter opened from the World is phone width again', (
      tester,
    ) async {
      final width = await screenWidth(
        tester,
        window: const Size(1366, 768),
        wrap: (screen) => LandscapeScope(child: PortraitScope(child: screen)),
      );
      expect(width, PhoneFrame.phoneWidth);
    });

    testWidgets('a phone browser gets the app exactly as it is', (
      tester,
    ) async {
      final width = await screenWidth(
        tester,
        window: const Size(384, 854),
        wrap: (screen) => screen,
      );
      expect(width, 384);
    });
  });
}
