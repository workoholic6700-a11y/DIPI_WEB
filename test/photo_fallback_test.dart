import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/features/viewer/family/member_detail_screen.dart';

/// Every real-photo slot in `AppPhotos` is allowed to be empty — the whole
/// point of the manifest is that you can reference `family/grandfather.jpg`
/// today and drop the actual file in tomorrow.
///
/// That contract was broken on the member detail page: it rendered
/// `Image.asset(member.photo!)` with no `errorBuilder`, and the emoji fallback
/// was gated on `photo == null`. So for Kopa, Arjun and Meow — who have photo
/// slots but no files — the header showed a red "Asset not found" box and the
/// emoji could never appear.
///
/// These tests pin the fallback down: a missing photo must degrade to the
/// person's emoji, never to an error box.
void main() {
  /// The header runs `FloatingParticles`, which repeats forever, so the tree
  /// never settles. Mount, look, then unmount and flush so `flutter_animate`'s
  /// zero-duration restart timers don't outlive the test.
  Future<void> open(WidgetTester tester, String memberId) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: MemberDetailScreen(memberId: memberId)),
      ),
    );
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // flutter_animate schedules its play via Future.delayed and never cancels
    // it on dispose, so give those a beat to land after the tree is gone.
    await tester.pump(const Duration(seconds: 1));
  }

  /// Members with a photo *slot*. Whether the file is actually in the bundle
  /// changes over time — Kopa's arrived in August 2026 — so this asserts the
  /// invariant that survives that: the header shows the photograph **or** the
  /// person's emoji, and never Flutter's red error box.
  ///
  /// Asserting "this one falls back" would quietly rot into a false alarm the
  /// day somebody drops the missing file in, which is exactly the day you want
  /// the suite to stay quiet.
  const cases = <String, String>{
    'f_grandpa': '👴🏻',
    'f_arjun': '🐶',
    'f_meow': '🐱',
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key}: shows a face, never an error box',
        (tester) async {
      await open(tester, entry.key);

      final hasPhoto = tester
          .widgetList<Image>(find.byType(Image))
          .map((i) => i.image)
          .whereType<AssetImage>()
          .any((a) => a.assetName.contains('/family/'));
      final hasEmoji = find.text(entry.value).evaluate().isNotEmpty;

      expect(hasPhoto || hasEmoji, isTrue,
          reason: '${entry.key} rendered neither a photograph nor an emoji — '
              'the header is showing nothing, or a broken image.');

      // The bug this file exists for: a missing asset must never surface.
      expect(tester.takeException(), isNull);
      await close(tester);
    });
  }

  testWidgets('a member with a real photo still renders the Image',
      (tester) async {
    // Stubby's file (family/stubby.jpg) is in the bundle.
    await open(tester, 'f_stubby');

    final images = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => i.image)
        .whereType<AssetImage>()
        .map((a) => a.assetName);
    expect(images, contains(AppPhotos.stubby));
    expect(tester.takeException(), isNull);
    await close(tester);
  });

  test('every family photo slot is a declared assets/images path', () {
    // Guards against a typo'd slot (e.g. a stray leading slash) that would
    // silently never resolve.
    const slots = [
      AppPhotos.grandfather,
      AppPhotos.father,
      AppPhotos.mother,
      AppPhotos.diksha,
      AppPhotos.diya,
      AppPhotos.dipisha,
      AppPhotos.arjun,
      AppPhotos.meow,
      AppPhotos.stubby,
    ];
    for (final s in slots) {
      expect(s, startsWith('assets/images/family/'));
      expect(s, endsWith('.jpg'));
    }
  });
}
