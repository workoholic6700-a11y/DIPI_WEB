import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';
import 'package:dear_dipisha/features/viewer/gallery/album_screen.dart';
import 'package:dear_dipisha/features/viewer/gallery/widgets/album_book.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'bundled photographs have one copy and belong to current albums',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final albums = groupAlbumAssets(manifest.listAssets());
      final ids = MockData.albums.map((album) => album.id).toSet();
      expect(ids, contains('graduation'));
      expect(ids, isNot(contains('graduation_days')));
      expect(ids, isNot(contains('out_and_about')));
      expect(albums.containsKey(AppPhotos.allPhotosAlbumId), isFalse);
      final copies = <String, String>{};
      for (final album in albums.entries) {
        expect(ids, contains(album.key));
        for (final path in album.value) {
          final data = await rootBundle.load(path);
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          final fingerprint = base64Encode(bytes);
          expect(
            copies[fingerprint],
            isNull,
            reason: '$path duplicates ${copies[fingerprint]}',
          );
          copies[fingerprint] = path;
        }
      }
      expect(copies, isNotEmpty);
    },
  );

  testWidgets(
    'All Photos uses a person album cover while the cloud is loading',
    (tester) async {
      final pending = Completer<List<Map<String, dynamic>>>();
      final path = AppPhotos.albumPhoto('dipisha', 0);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(null),
            cloudPhotosProvider.overrideWith((ref) => pending.future),
            bundledAlbumPhotosProvider.overrideWith(
              (ref) async => {
                'dipisha': [path],
              },
            ),
          ],
          child: DefaultAssetBundle(
            bundle: _MissingAllPhotosCoverBundle(),
            child: MaterialApp(
              home: Scaffold(
                body: AlbumBook(
                  album: MockData.albums.firstWhere(
                    (a) => a.id == AppPhotos.allPhotosAlbumId,
                  ),
                  width: 160,
                  height: 218,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 photo'), findsOneWidget);
      expect(
        tester
            .widgetList<Image>(find.byType(Image))
            .map((i) => i.image)
            .whereType<AssetImage>()
            .map((i) => i.assetName),
        contains(path),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      pending.complete([]);
    },
  );

  testWidgets(
    'cloud album decoration, Nepali counts, pages and actions stay current',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'app_lang': 'ne'});
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(null),
            cloudAlbumsProvider.overrideWith(
              (ref) async => [
                {
                  'id': AppPhotos.allPhotosAlbumId,
                  'name': 'All Photos 📸',
                  'created_at': '2026-09-09T00:00:00Z',
                },
              ],
            ),
            bundledAlbumPhotosProvider.overrideWith(
              (ref) async => {
                'dipisha': [
                  for (var i = 0; i < 5; i++)
                    AppPhotos.albumPhoto('dipisha', i),
                ],
              },
            ),
          ],
          child: const MaterialApp(
            home: AlbumScreen(albumId: AppPhotos.allPhotosAlbumId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('सबै तस्बिरहरू 🌿'), findsOneWidget);
      expect(find.text('5 तस्बिरहरू'), findsOneWidget);
      expect(find.text('खुला एल्बम · 2 मध्ये पृष्ठ 1'), findsOneWidget);
      expect(find.bySemanticsLabel('तस्बिर खोल्नुहोस्।'), findsWidgets);
      await tester.tap(find.byTooltip('अर्को पृष्ठ'));
      await tester.pumpAndSettle();
      expect(find.text('खुला एल्बम · 2 मध्ये पृष्ठ 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}

class _MissingAllPhotosCoverBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key == AppPhotos.album(AppPhotos.allPhotosAlbumId)) {
      throw FlutterError('No dedicated All Photos cover');
    }
    return rootBundle.load(key);
  }
}
