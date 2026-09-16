import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_photos.dart';
import '../models/content_models.dart';
import '../gallery/gallery_providers.dart';

Map<String, List<String>> groupAlbumAssets(Iterable<String> assets) {
  final result = <String, List<String>>{};
  final pattern = RegExp(
    r'^(.+)_([0-9]+)\.(jpg|jpeg|png|webp)$',
    caseSensitive: false,
  );
  for (final path in assets) {
    if (!path.startsWith(AppPhotos.albumsDir)) continue;
    final match = pattern.firstMatch(
      path.substring(AppPhotos.albumsDir.length),
    );
    if (match == null) continue;
    result.putIfAbsent(match[1]!, () => []).add(path);
  }
  for (final paths in result.values) {
    paths.sort((a, b) {
      int number(String p) => int.parse(
        pattern.firstMatch(p.substring(AppPhotos.albumsDir.length))![2]!,
      );
      return number(a).compareTo(number(b));
    });
  }
  return result;
}

/// The bundled photograph an album book shows when no uploaded photo is
/// marked as cover: the one chosen on the desk if it still ships in the app,
/// otherwise the first one.
String? bundledCoverFor(Album album, Map<String, List<String>>? bundled) {
  final paths = album.id == AppPhotos.allPhotosAlbumId
      ? bundled?.values.expand((p) => p).toList()
      : bundled?[album.id];
  if (paths == null || paths.isEmpty) return null;
  final chosen = album.coverAsset;
  if (chosen != null && paths.contains(chosen)) return chosen;
  return paths.first;
}

final bundledAlbumPhotosProvider = FutureProvider<Map<String, List<String>>>((
  ref,
) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return groupAlbumAssets(manifest.listAssets());
});

Map<String, List<Photo>> mergeAlbumPhotos(
  Map<String, List<String>> bundled,
  List<Map<String, dynamic>> cloud,
) {
  final albums = <String, Map<String, Photo>>{};
  void add(Photo photo, String key) {
    albums.putIfAbsent(photo.albumId, () => {})[key] = photo;
  }

  for (final entry in bundled.entries) {
    for (final path in entry.value) {
      add(
        Photo(
          id: path,
          albumId: entry.key,
          caption: AppPhotos.albumCaptions[path] ?? '',
          date: null,
          assetPath: path,
        ),
        'asset:$path',
      );
    }
  }
  for (final row in cloud) {
    final parent = row['gallery_albums'];
    if (row['published'] == false ||
        (parent is Map && parent['published'] == false)) {
      continue;
    }
    final path = row['storage_path'] as String;
    add(
      Photo(
        id: row['id'] as String,
        albumId: row['album_id'] as String,
        caption: row['caption'] as String? ?? '',
        date: null,
        storagePath: path,
        thumbPath: row['thumb_path'] as String?,
      ),
      'storage:$path',
    );
  }

  final all = <String, Photo>{
    ...?albums[AppPhotos.allPhotosAlbumId],
    for (final album in albums.entries)
      if (album.key != AppPhotos.allPhotosAlbumId) ...album.value,
  };
  return {
    for (final album in albums.entries) album.key: album.value.values.toList(),
    AppPhotos.allPhotosAlbumId: all.values.toList(),
  };
}

final galleryPhotosByAlbumProvider = FutureProvider<Map<String, List<Photo>>>((
  ref,
) async {
  final bundled = await ref.watch(bundledAlbumPhotosProvider.future);
  final cloud = ref.watch(cloudPhotosProvider);
  return mergeAlbumPhotos(bundled, cloud.value ?? []);
});

final albumPhotoCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final albums = await ref.watch(galleryPhotosByAlbumProvider.future);
  return {for (final album in albums.entries) album.key: album.value.length};
});

final albumPhotoCountProvider = Provider.family<int, String>(
  (ref, id) => ref.watch(albumPhotoCountsProvider).value?[id] ?? 0,
);

final albumPhotosProvider = FutureProvider.autoDispose
    .family<List<Photo>, String>((ref, id) async {
      final albums = await ref.watch(galleryPhotosByAlbumProvider.future);
      return albums[id] ?? [];
    });
