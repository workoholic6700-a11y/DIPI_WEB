import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';
import 'package:dear_dipisha/data/providers/content_providers.dart';
import 'package:dear_dipisha/features/viewer/gallery/album_screen.dart';
import 'package:dear_dipisha/shared/widgets/gallery_photo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the rejected house photo and Our Home album are removed', () async {
    const rejected = 'assets/images/albums/ilam_1.png';
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(null)],
    );
    addTearDown(container.dispose);
    expect(
      container.read(albumsProvider).map((album) => album.id),
      isNot(contains('ilam')),
    );
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(manifest.listAssets(), isNot(contains(rejected)));
    final photos = await container.read(galleryPhotosByAlbumProvider.future);
    expect(photos.containsKey('ilam'), isFalse);
    expect(
      photos.values.expand((album) => album).map((photo) => photo.assetPath),
      isNot(contains(rejected)),
    );
    expect(AppPhotos.storyScenes, isNot(contains(rejected)));
    expect(AppPhotos.albumCaptions.containsKey(rejected), isFalse);
    for (final album in ['hills_nature', AppPhotos.allPhotosAlbumId]) {
      expect(
        photos[album]!.where(
          (photo) => photo.assetPath == AppPhotos.ilamFields,
        ),
        hasLength(1),
        reason: 'The house-free environment belongs once in $album',
      );
    }
  });

  test(
    'both requested edits are bundled once in Little Dipisha and All Photos',
    () async {
      final container = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final grouped = await container.read(galleryPhotosByAlbumProvider.future);
      for (final album in ['dipisha', AppPhotos.allPhotosAlbumId]) {
        for (final asset in [
          AppPhotos.dipishaPinkWhite,
          AppPhotos.dipishaGownWhite,
        ]) {
          final photo = grouped[album]!
              .where((p) => p.assetPath == asset)
              .single;
          expect(photo.caption, 'AI-edited · white background');
          expect(photo.date, isNull);
        }
        expect(
          grouped[album]!.any(
            (p) => p.assetPath == AppPhotos.albumPhoto('dipisha', 7),
          ),
          isTrue,
        );
        expect(
          grouped[album]!.any(
            (p) => p.assetPath == AppPhotos.albumPhoto('dipisha', 8),
          ),
          isTrue,
        );
      }
    },
  );

  test(
    'all imagined graduation portraits appear once with no capture date',
    () async {
      final container = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final grouped = await container.read(galleryPhotosByAlbumProvider.future);
      for (final album in ['graduation', AppPhotos.allPhotosAlbumId]) {
        for (final asset in [
          AppPhotos.graduationFamilyPortrait,
          AppPhotos.graduationFamilyFullLength,
          AppPhotos.graduationFamilyStudio,
        ]) {
          final matching = grouped[album]!.where((p) => p.assetPath == asset);
          expect(
            matching,
            hasLength(1),
            reason: '$asset must appear once in $album',
          );
          expect(matching.single.caption, 'AI-composed from our photos');
          expect(matching.single.date, isNull);
          expect(matching.single.albumId, 'graduation');
        }
      }
    },
  );

  testWidgets('graduation album frames keep the whole family in view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const assets = [
      AppPhotos.graduationFamilyPortrait,
      AppPhotos.graduationFamilyFullLength,
      AppPhotos.graduationFamilyStudio,
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(null),
          bundledAlbumPhotosProvider.overrideWith(
            (ref) async => {'graduation': assets},
          ),
        ],
        child: const MaterialApp(home: AlbumScreen(albumId: 'graduation')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (final asset in assets) {
        await precacheImage(
          AssetImage(asset),
          tester.element(find.byType(AlbumScreen)),
        );
      }
    });
    await tester.pumpAndSettle();
    for (final asset in assets) {
      final rawFinder = find.descendant(
        of: find.image(AssetImage(asset)),
        matching: find.byType(RawImage),
      );
      final raw = tester.widget<RawImage>(rawFinder);
      expect(raw.image, isNotNull);
      final source = Size(
        raw.image!.width.toDouble(),
        raw.image!.height.toDouble(),
      );
      final fitted = applyBoxFit(
        raw.fit ?? BoxFit.scaleDown,
        source,
        tester.getSize(rawFinder),
      );
      expect(fitted.source, source, reason: '$asset must not crop anyone out');
    }
    expect(
      find.text('AI-composed from our photos'),
      findsNWidgets(assets.length),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test(
    'every imagined story scene is bundled once and has no capture date',
    () async {
      final container = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final grouped = await container.read(galleryPhotosByAlbumProvider.future);
      for (final asset in AppPhotos.storyScenes) {
        final all = grouped[AppPhotos.allPhotosAlbumId]!.where(
          (photo) => photo.assetPath == asset,
        );
        expect(all, hasLength(1), reason: '$asset must be bundled once');
        final photo = all.single;
        expect(photo.caption, AppPhotos.imaginedStoryCaption);
        expect(photo.date, isNull);
        expect(
          grouped[photo.albumId]!.where((item) => item.assetPath == asset),
          hasLength(1),
        );
      }
      expect(
        trS(AppLang.ne, AppPhotos.imaginedStoryCaption),
        isNot(AppPhotos.imaginedStoryCaption),
      );
    },
  );

  test(
    'Papa field scenes join Mummy and Papa and All Photos without replacing originals',
    () async {
      final container = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final grouped = await container.read(galleryPhotosByAlbumProvider.future);
      const scenes = [
        AppPhotos.papaWateringVegetables,
        AppPhotos.papaTeaFields,
        AppPhotos.papaCardamomGinger,
      ];
      for (final album in ['parents', AppPhotos.allPhotosAlbumId]) {
        final photos = grouped[album]!;
        for (final asset in scenes) {
          final matching = photos.where((photo) => photo.assetPath == asset);
          expect(
            matching,
            hasLength(1),
            reason: '$asset belongs once in $album',
          );
          expect(matching.single.albumId, 'parents');
          expect(matching.single.caption, AppPhotos.imaginedStoryCaption);
          expect(matching.single.date, isNull);
        }
        for (var index = 0; index < 6; index++) {
          expect(
            photos.where(
              (photo) =>
                  photo.assetPath == AppPhotos.albumPhoto('parents', index),
            ),
            hasLength(1),
            reason: 'Original parent photos must remain in $album',
          );
        }
        expect(
          photos.where((photo) => photo.assetPath == AppPhotos.mummyKitchen),
          hasLength(1),
        );
      }
      final papa = MockData.family.singleWhere(
        (member) => member.id == 'f_father',
      );
      expect(papa.photo, 'assets/images/family/father.jpg');
      expect(
        AppPhotos.storyChapterPhoto('He went far, so we could go far'),
        papa.photo,
        reason: 'The Malaysia chapter keeps Papa\'s real portrait',
      );
      expect(
        (await rootBundle.load(papa.photo!)).lengthInBytes,
        greaterThan(0),
      );
    },
  );

  for (final lang in AppLang.values) {
    testWidgets(
      'edited captions stay visible full-screen and follow swipes in ${lang.name}',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({'app_lang': lang.name});
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              galleryRepositoryProvider.overrideWithValue(null),
              bundledAlbumPhotosProvider.overrideWith(
                (ref) async => {
                  'dipisha': [
                    AppPhotos.dipishaPinkWhite,
                    AppPhotos.dipishaGownWhite,
                    AppPhotos.albumPhoto('dipisha', 7),
                  ],
                },
              ),
            ],
            child: const MaterialApp(home: AlbumScreen(albumId: 'dipisha')),
          ),
        );
        await tester.pumpAndSettle();
        final caption = trS(lang, 'AI-edited · white background');
        expect(find.text(caption), findsNWidgets(2));
        await tester.tap(find.byType(GalleryPhoto).first);
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(caption),
          ),
          findsOneWidget,
        );
        await tester.drag(find.byType(PhotoViewGallery), const Offset(-320, 0));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(caption),
          ),
          findsOneWidget,
        );
        await tester.drag(find.byType(PhotoViewGallery), const Offset(-320, 0));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(caption),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
