import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:dear_dipisha/data/gallery/gallery_repository.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';

void main() {
  test('actual album paths survive numbering gaps and mixed formats', () {
    final grouped = groupAlbumAssets([
      'assets/images/albums/ilam_10.png',
      'assets/images/albums/ilam_2.jpg',
      'assets/images/albums/ilam.jpg',
      'assets/images/albums/ilam_notes.txt',
      'assets/images/family/ilam_1.jpg',
    ]);
    expect(grouped['ilam'], [
      'assets/images/albums/ilam_2.jpg',
      'assets/images/albums/ilam_10.png',
    ]);
  });

  test(
    'upload creates bounded main and thumbnail images without inventing content',
    () {
      final source = img.Image(width: 2000, height: 1000);
      img.fill(source, color: img.ColorRgb8(140, 40, 80));
      final result = prepareGalleryImage(
        Uint8List.fromList(img.encodePng(source)),
      );
      final main = img.decodeJpg(result['image']!)!;
      final thumb = img.decodeJpg(result['thumb']!)!;
      expect((main.width, main.height), (1600, 800));
      expect((thumb.width, thumb.height), (400, 200));
      expect(main.getPixel(50, 50).r, closeTo(140, 3));
      expect(
        () => prepareGalleryImage(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
    },
  );

  test(
    'album combines actual bundled and cloud photos with honest counts',
    () async {
      final container = ProviderContainer(
        overrides: [
          bundledAlbumPhotosProvider.overrideWith(
            (ref) async => {
              'ilam': ['assets/images/albums/ilam_8.png'],
            },
          ),
          cloudPhotosProvider.overrideWith(
            (ref) async => [
              {
                'id': 'remote',
                'album_id': 'ilam',
                'caption': '',
                'storage_path': 'ilam/remote.jpg',
                'thumb_path': 'ilam/remote_thumb.jpg',
              },
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        albumPhotosProvider('ilam'),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(cloudPhotosProvider.future);
      await container.pump();
      final photos = await container.read(albumPhotosProvider('ilam').future);
      final counts = await container.read(albumPhotoCountsProvider.future);
      expect(counts['ilam'], 2);
      expect(photos.first.assetPath, 'assets/images/albums/ilam_8.png');
      expect(photos.last.storagePath, 'ilam/remote.jpg');
      expect(photos.every((p) => p.caption.isEmpty && p.date == null), isTrue);
    },
  );
}
