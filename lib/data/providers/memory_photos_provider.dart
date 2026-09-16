import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_photos.dart';

class MemoryPhoto {
  const MemoryPhoto({required this.assetPath, this.caption});

  final String assetPath;
  final String? caption;
}

List<MemoryPhoto> memoryPhotosFromAssets(
  String memoryId,
  Iterable<String> assets,
) {
  final bundled = assets.toSet();
  final cover = AppPhotos.memoryCardCover(memoryId);
  final indexed = RegExp(
    '^assets/images/memories/${RegExp.escape(memoryId)}_([0-9]+)\\.'
    r'(jpg|jpeg|png|webp)$',
    caseSensitive: false,
  );
  final originals = bundled.where(indexed.hasMatch).toList()
    ..sort((a, b) {
      final first = int.parse(indexed.firstMatch(a)![1]!);
      final second = int.parse(indexed.firstMatch(b)![1]!);
      final byIndex = first.compareTo(second);
      return byIndex == 0 ? a.compareTo(b) : byIndex;
    });
  final paths = <String>{if (bundled.contains(cover)) cover, ...originals};
  return [
    for (final path in paths)
      MemoryPhoto(assetPath: path, caption: AppPhotos.captionFor(path)),
  ];
}

final bundledMemoryAssetsProvider = FutureProvider<Set<String>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest.listAssets().toSet();
});

final memoryPhotosProvider = FutureProvider.family<List<MemoryPhoto>, String>((
  ref,
  memoryId,
) async {
  final assets = await ref.watch(bundledMemoryAssetsProvider.future);
  return memoryPhotosFromAssets(memoryId, assets);
});
