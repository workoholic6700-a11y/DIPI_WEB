import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/features/viewer/places/places_screen.dart';
import 'package:dear_dipisha/features/viewer/story/our_story_screen.dart';
import 'package:dear_dipisha/shared/widgets/scrapbook.dart';

void main() {
  const rejectedHomePhoto = 'assets/images/albums/ilam_1.png';

  test(
    'Ilam shares the new fields scene without restoring the rejected house',
    () {
      expect(
        AppPhotos.storyChapterPhoto('Growing up in Ilam'),
        AppPhotos.ilamFields,
      );
      expect(AppPhotos.place('pl1'), AppPhotos.ilamFields);
      expect(AppPhotos.storyScenes, contains(AppPhotos.ilamFields));
      expect(
        AppPhotos.captionFor(AppPhotos.ilamFields),
        AppPhotos.imaginedStoryCaption,
      );
      expect(AppPhotos.storyScenes, isNot(contains(rejectedHomePhoto)));
      expect(
        AppPhotos.landscapeAlbumPhotos,
        isNot(contains(rejectedHomePhoto)),
      );
      expect(AppPhotos.albumCaptions, isNot(contains(rejectedHomePhoto)));
      expect(
        MockData.story.map(
          (chapter) => AppPhotos.storyChapterPhoto(chapter.title),
        ),
        isNot(contains(rejectedHomePhoto)),
      );
      expect(
        MockData.places.map((place) => AppPhotos.place(place.id)),
        isNot(contains(rejectedHomePhoto)),
      );
    },
  );

  void narrowPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openAndClosePhoto(
    WidgetTester tester,
    Finder frame,
    String asset,
    String? provenance,
  ) async {
    await tester.ensureVisible(frame);
    await tester.tap(frame);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.image(AssetImage(asset)), findsOneWidget);
    expect(
      tester.widget<Image>(find.image(AssetImage(asset))).fit,
      BoxFit.contain,
    );
    if (provenance != null) {
      expect(find.text(provenance), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
  }

  for (final lang in AppLang.values) {
    testWidgets(
      'all eleven story chapters have uncropped inspectable photos in ${lang.name}',
      (tester) async {
        narrowPhone(tester);
        SharedPreferences.setMockInitialValues({'app_lang': lang.name});
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OurStoryScreen())),
        );
        await tester.pumpAndSettle();

        expect(MockData.story, hasLength(11));
        for (var index = 0; index < MockData.story.length; index++) {
          final chapter = MockData.story[index];
          final asset = AppPhotos.storyChapterPhoto(chapter.title);
          expect(asset, isNotNull, reason: '${chapter.title} needs its photo');
          final frame = find.byKey(ValueKey('story-photo-${chapter.title}'));
          expect(frame, findsOneWidget);
          expect(find.text(chapter.year.toUpperCase()), findsOneWidget);
          final caption = AppPhotos.captionFor(asset!);
          final translated = caption == null ? null : trS(lang, caption);
          final image = find.descendant(
            of: frame,
            matching: find.image(AssetImage(asset)),
          );
          expect(image, findsOneWidget);
          expect(tester.widget<Image>(image).fit, BoxFit.contain);
          expect(find.image(const AssetImage(rejectedHomePhoto)), findsNothing);
          if (translated != null) {
            expect(
              find.descendant(of: frame, matching: find.text(translated)),
              findsOneWidget,
            );
          }
          await openAndClosePhoto(tester, frame, asset, translated);
          expect(find.text(trS(lang, chapter.body)), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (index < MockData.story.length - 1) {
            await tester.tap(find.text(trS(lang, 'Next')));
            await tester.pumpAndSettle();
          }
        }
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'five places show inspectable scenes without invented photo totals in ${lang.name}',
      (tester) async {
        narrowPhone(tester);
        SharedPreferences.setMockInitialValues({'app_lang': lang.name});
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: PlacesScreen())),
        );
        await tester.pumpAndSettle();

        expect(MockData.places, hasLength(5));
        for (final place in MockData.places) {
          final selector = find.byKey(ValueKey('place-selector-${place.id}'));
          await tester.ensureVisible(selector);
          await tester.tap(selector);
          await tester.pumpAndSettle();
          final asset = AppPhotos.place(place.id);
          final frame = find.byKey(ValueKey('place-photo-${place.id}'));
          expect(frame, findsOneWidget);
          final caption = AppPhotos.captionFor(asset);
          expect(caption, isNotNull, reason: 'Imagined places need provenance');
          final translated = trS(lang, caption!);
          expect(
            find.descendant(of: frame, matching: find.image(AssetImage(asset))),
            findsOneWidget,
          );
          expect(
            find.descendant(of: frame, matching: find.text(translated)),
            findsOneWidget,
          );
          expect(find.image(const AssetImage(rejectedHomePhoto)), findsNothing);
          await openAndClosePhoto(tester, frame, asset, translated);
          expect(
            find.text('${place.photoCount} ${trS(lang, 'photos')}'),
            findsNothing,
          );
          expect(find.text(trS(lang, place.story)), findsOneWidget);
          expect(
            find.text('${trS(lang, place.region)} · ${place.year}'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('a missing scrapbook photo keeps its caption and soft fallback', (
    tester,
  ) async {
    narrowPhone(tester);
    const missing = 'assets/images/missing-story-photo.png';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Polaroid(
              seed: 3,
              assetPath: missing,
              caption: 'Mummy',
              provenance: 'AI-composed from our photos',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('🌸'), findsOneWidget);
    expect(find.text('AI-composed from our photos'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await openAndClosePhoto(
      tester,
      find.byType(Polaroid),
      missing,
      'AI-composed from our photos',
    );
    expect(find.text('🌸'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
