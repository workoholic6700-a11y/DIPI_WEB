import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';
import 'package:dear_dipisha/features/viewer/gallery/album_screen.dart';
import 'package:dear_dipisha/features/viewer/gallery/widgets/album_book.dart';

Map<String, dynamic> cloudPhoto(
  String id,
  String album, {
  String? path,
  bool published = true,
  bool albumPublished = true,
}) => {
  'id': id,
  'album_id': album,
  'caption': '',
  'storage_path': path ?? '$album/$id.jpg',
  'thumb_path': '$album/${id}_thumb.jpg',
  'published': published,
  'gallery_albums': {'published': albumPublished},
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('All Photos combines every album once and excludes drafts', () {
    final grouped = mergeAlbumPhotos(
      {
        'all_photos': ['legacy.jpg', 'shared.jpg'],
        'everyday': ['everyday.jpg', 'shared.jpg'],
        'new_album': ['new.jpg'],
      },
      [
        cloudPhoto('cloud', 'another_album'),
        cloudPhoto(
          'shared_cloud',
          'all_photos',
          path: 'another_album/cloud.jpg',
        ),
        cloudPhoto('private_photo', 'everyday', published: false),
        cloudPhoto('private_album', 'draft_album', albumPublished: false),
      ],
    );
    final all = grouped[AppPhotos.allPhotosAlbumId]!;
    expect(all.map((p) => p.assetPath ?? p.storagePath), [
      'legacy.jpg',
      'shared.jpg',
      'another_album/cloud.jpg',
      'everyday.jpg',
      'new.jpg',
    ]);
    expect(grouped['everyday']!.length, 2);
    expect(grouped['another_album']!.single.albumId, 'another_album');
    expect(grouped.containsKey('draft_album'), isFalse);
    expect(all.every((p) => p.caption.isEmpty && p.date == null), isTrue);
    expect(mergeAlbumPhotos({}, [])[AppPhotos.allPhotosAlbumId], isEmpty);
  });

  test(
    'bundled photos load before the cloud, refresh, and survive failure',
    () async {
      var request = Completer<List<Map<String, dynamic>>>();
      final container = ProviderContainer(
        overrides: [
          bundledAlbumPhotosProvider.overrideWith(
            (ref) async => {
              'everyday': ['assets/images/albums/everyday_1.jpg'],
            },
          ),
          cloudPhotosProvider.overrideWith((ref) => request.future),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(
        albumPhotosProvider('all_photos'),
        (_, _) {},
      );
      addTearDown(sub.close);
      expect(
        (await container.read(albumPhotosProvider('all_photos').future)).length,
        1,
      );
      expect(
        (await container.read(albumPhotoCountsProvider.future))['all_photos'],
        1,
      );

      request.complete([cloudPhoto('added_later', 'a_new_album')]);
      await container.read(cloudPhotosProvider.future);
      await container.pump();
      expect(
        (await container.read(albumPhotosProvider('all_photos').future)).length,
        2,
      );
      expect(
        (await container.read(albumPhotoCountsProvider.future))['all_photos'],
        2,
      );

      request = Completer<List<Map<String, dynamic>>>();
      container.invalidate(cloudPhotosProvider);
      final failed = expectLater(
        container.read(cloudPhotosProvider.future),
        throwsStateError,
      );
      request.completeError(StateError('offline'));
      await failed;
      await container.pump();
      final offline = await container.read(
        albumPhotosProvider('all_photos').future,
      );
      expect(
        offline.any(
          (p) => p.assetPath == 'assets/images/albums/everyday_1.jpg',
        ),
        isTrue,
      );
      expect(container.read(cloudPhotosProvider).hasError, isTrue);
    },
  );

  test(
    'all 43 imported files are represented by 39 real bundled photos',
    () async {
      final manifest =
          jsonDecode(
                File('tool/photo_imports/2026-09-09.json').readAsStringSync(),
              )
              as Map;
      final imported = (manifest['photos'] as List).cast<Map>();
      final sourceNames = imported
          .expand((p) => (p['sources'] as List).cast<String>())
          .toList();
      expect(sourceNames.length, 43);
      expect(sourceNames.toSet().length, 43);
      expect(imported.length, 39);
      expect(imported.map((p) => p['sha256']).toSet().length, 39);
      expect(imported.map((p) => p['asset']).toSet().length, 39);

      final container = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      final grouped = await container.read(galleryPhotosByAlbumProvider.future);
      final all = grouped[AppPhotos.allPhotosAlbumId]!;
      final allPaths = all.map((p) => p.assetPath).toList();
      expect(allPaths.toSet().length, allPaths.length);
      final counts = await container.read(albumPhotoCountsProvider.future);
      expect(counts[AppPhotos.allPhotosAlbumId], all.length);
      expect(allPaths.any((p) => p?.contains('/all_photos_') ?? false), isFalse);
      for (final row in imported) {
        final path = row['asset'] as String;
        final album = row['album'] as String;
        expect(MockData.albums.any((a) => a.id == album), isTrue);
        expect(grouped[album]!.map((p) => p.assetPath), contains(path));
        expect(allPaths.where((p) => p == path).length, 1);
        final bytes = await rootBundle.load(path);
        expect(bytes.lengthInBytes, greaterThan(100));
        expect(bytes.getUint16(0), 0xffd8, reason: '$path must be a JPEG');
      }
      expect(hasNepali('Family Together'), isTrue);
    },
  );

  testWidgets(
    'All Photos fits 100 photographs on a narrow phone and opens the last page',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(null),
            bundledAlbumPhotosProvider.overrideWith(
              (ref) async => {
                'everyday': [
                  for (var i = 1; i <= 100; i++)
                    'assets/images/albums/missing_$i.jpg',
                ],
              },
            ),
          ],
          child: const MaterialApp(home: AlbumScreen(albumId: 'all_photos')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('100 photographs'), findsOneWidget);
      expect(find.text('Open album · page 1 of 25'), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 24; i++) {
        await tester.tap(find.byTooltip('Next page'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Open album · page 25 of 25'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
            )
            .onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('a new album uses its bundled photograph as its cover', (
    tester,
  ) async {
    final album = MockData.albums.firstWhere((a) => a.id == 'family_together');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [galleryRepositoryProvider.overrideWithValue(null)],
        child: MaterialApp(
          home: Scaffold(
            body: AlbumBook(
              album: album,
              width: 160,
              height: 218,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .map((i) => i.image)
          .whereType<AssetImage>()
          .map((i) => i.assetName),
      contains(AppPhotos.albumPhoto('family_together', 0)),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
