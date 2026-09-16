import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/gallery/gallery_repository.dart';
import 'package:dear_dipisha/data/gallery/photo_download_service.dart';
import 'package:dear_dipisha/data/models/content_models.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';
import 'package:dear_dipisha/features/viewer/gallery/album_screen.dart';
import 'package:dear_dipisha/shared/widgets/gallery_photo.dart';

const _local = Photo(
  id: 'local',
  albumId: 'everyday',
  caption: '',
  date: null,
  assetPath: 'assets/images/albums/everyday_1.jpg',
);
const _cloud = Photo(
  id: 'cloud',
  albumId: 'everyday',
  caption: '',
  date: null,
  storagePath: 'everyday/original.jpg',
  thumbPath: 'everyday/thumbnail.jpg',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'bundled download preserves exact file bytes and buffer boundaries',
    () async {
      final bundle = _PhotoBundle();
      final original = Uint8List.fromList([0xff, 0xd8, 11, 22, 0xff, 0xd9]);
      final padded = Uint8List.fromList([99, ...original, 88]);
      bundle.data = ByteData.sublistView(padded, 1, padded.length - 1);
      var saves = 0;
      final service = PhotoDownloadService(
        bundle: bundle,
        writer: (bytes, name, mime) async {
          saves++;
          expect(bytes, orderedEquals(original));
          expect(name, matches(r'^our-home-everyday_1-\d+\.jpg$'));
          expect(mime, 'image/jpeg');
          return PhotoSaveResult.gallery;
        },
      );
      expect(await service.save(_local), PhotoSaveResult.gallery);
      expect(bundle.requested, _local.assetPath);
      expect(saves, 1);
    },
  );

  test(
    'cloud download saves the full stored file instead of its thumbnail',
    () async {
      final repo = _DownloadRepository();
      final bundle = _PhotoBundle();
      final service = PhotoDownloadService(
        repository: repo,
        bundle: bundle,
        writer: (bytes, name, mime) async {
          expect(bytes, orderedEquals(repo.bytes));
          expect(mime, 'image/jpeg');
          return PhotoSaveResult.gallery;
        },
      );
      await service.save(_cloud);
      expect(repo.requested, _cloud.storagePath);
      expect(bundle.requested, isNull);
    },
  );

  test(
    'missing and empty originals fail without saving a placeholder',
    () async {
      final bundle = _PhotoBundle()..data = ByteData(0);
      final service = PhotoDownloadService(
        bundle: bundle,
        writer: (_, _, _) async {
          fail('No file should be written');
        },
      );
      await expectLater(service.save(_local), throwsStateError);
      await expectLater(service.save(_cloud), throwsStateError);
      await expectLater(
        service.save(
          const Photo(
            id: 'missing',
            albumId: 'everyday',
            caption: '',
            date: null,
            thumbPath: 'thumbnail.jpg',
          ),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'PNG and WebP keep their format and a cancelled save stays cancelled',
    () async {
      for (final extension in ['png', 'webp']) {
        final service = PhotoDownloadService(
          bundle: _PhotoBundle(),
          writer: (bytes, name, mime) async {
            expect(name, endsWith('.$extension'));
            expect(mime, 'image/$extension');
            return PhotoSaveResult.cancelled;
          },
        );
        expect(
          await service.save(
            Photo(
              id: extension,
              albumId: 'a',
              caption: '',
              date: null,
              assetPath: 'assets/photo.$extension',
            ),
          ),
          PhotoSaveResult.cancelled,
        );
      }
    },
  );

  test(
    'Android receives unchanged bytes and saving errors propagate',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final bytes = Uint8List.fromList([0xff, 0xd8, 42, 0xff, 0xd9]);
      messenger.setMockMethodCallHandler(PhotoDownloadService.channel, (
        call,
      ) async {
        expect(call.method, 'savePhoto');
        expect(call.arguments['bytes'], orderedEquals(bytes));
        expect(call.arguments['filename'], 'photo.jpg');
        expect(call.arguments['mimeType'], 'image/jpeg');
        return true;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          PhotoDownloadService.channel,
          null,
        ),
      );
      expect(
        await PhotoDownloadService.writePhoto(bytes, 'photo.jpg', 'image/jpeg'),
        PhotoSaveResult.gallery,
      );
      messenger.setMockMethodCallHandler(PhotoDownloadService.channel, (
        _,
      ) async {
        throw PlatformException(code: 'save_failed');
      });
      await expectLater(
        PhotoDownloadService.writePhoto(bytes, 'photo.jpg', 'image/jpeg'),
        throwsA(isA<PlatformException>()),
      );
    },
  );

  Future<void> openViewer(
    WidgetTester tester,
    PhotoDownloadService service,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(null),
          photoDownloadServiceProvider.overrideWithValue(service),
          bundledAlbumPhotosProvider.overrideWith(
            (ref) async => {
              'everyday': [
                AppPhotos.albumPhoto('everyday', 0),
                AppPhotos.albumPhoto('everyday', 1),
              ],
            },
          ),
        ],
        child: const MaterialApp(home: AlbumScreen(albumId: 'all_photos')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(GalleryPhoto).first);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'download follows swipes, ignores repeat taps and keeps the selected photo',
    (tester) async {
      final request = Completer<PhotoSaveResult>();
      final saved = <Photo>[];
      final service = _ViewerDownload((photo) {
        saved.add(photo);
        return request.future;
      });
      await openViewer(tester, service);
      await tester.drag(find.byType(PhotoViewGallery), const Offset(-320, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Download photo'));
      await tester.pump();
      expect(saved.single.assetPath, AppPhotos.albumPhoto('everyday', 1));
      final button = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (w) => w is IconButton && w.tooltip == 'Saving photo…',
        ),
      );
      expect(button.onPressed, isNull);
      await tester.drag(find.byType(PhotoViewGallery), const Offset(320, 0));
      await tester.pump(const Duration(milliseconds: 500));
      expect(saved.single.assetPath, AppPhotos.albumPhoto('everyday', 1));
      request.complete(PhotoSaveResult.gallery);
      await tester.pumpAndSettle();
      expect(find.text('Photo saved to Pictures/Our Home.'), findsOneWidget);
      expect(find.byTooltip('Download photo'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'failed download offers retry and cancelled save claims no success',
    (tester) async {
      var attempts = 0;
      await openViewer(
        tester,
        _ViewerDownload((_) async {
          if (attempts++ == 0) throw StateError('offline');
          return PhotoSaveResult.cancelled;
        }),
      );
      await tester.tap(find.byTooltip('Download photo'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not save photo. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Download photo'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.text('Photo saved.'), findsNothing);
      expect(find.text('Photo saved to Pictures/Our Home.'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('download feedback is translated', () {
    for (final text in [
      'Download photo',
      'Saving photo…',
      'Photo saved.',
      'Photo saved to Pictures/Our Home.',
      'Could not save photo. Please try again.',
    ]) {
      expect(hasNepali(text), isTrue, reason: text);
    }
  });
}

class _PhotoBundle extends CachingAssetBundle {
  ByteData data = ByteData.sublistView(Uint8List.fromList([1, 2, 3]));
  String? requested;
  @override
  Future<ByteData> load(String key) async {
    requested = key;
    return data;
  }
}

class _DownloadRepository implements GalleryRepository {
  final bytes = Uint8List.fromList([0xff, 0xd8, 1, 2, 3, 0xff, 0xd9]);
  String? requested;
  @override
  Future<Uint8List> downloadPhoto(String storagePath) async {
    requested = storagePath;
    return bytes;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ViewerDownload extends PhotoDownloadService {
  _ViewerDownload(this.onSave);
  final Future<PhotoSaveResult> Function(Photo) onSave;
  @override
  Future<PhotoSaveResult> save(Photo photo) => onSave(photo);
}
