import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/browser_file.dart' as browser;
import '../models/content_models.dart';
import 'gallery_providers.dart';
import 'gallery_repository.dart';

enum PhotoSaveResult { gallery, file, cancelled }

typedef PhotoWriter =
    Future<PhotoSaveResult> Function(
      Uint8List bytes,
      String filename,
      String mimeType,
    );

final photoDownloadServiceProvider = Provider<PhotoDownloadService>((ref) {
  return PhotoDownloadService(repository: ref.watch(galleryRepositoryProvider));
});

class PhotoDownloadService {
  PhotoDownloadService({
    this.repository,
    AssetBundle? bundle,
    PhotoWriter? writer,
  }) : _bundle = bundle ?? rootBundle,
       _writer = writer ?? writePhoto;

  final GalleryRepository? repository;
  final AssetBundle _bundle;
  final PhotoWriter _writer;
  static const channel = MethodChannel('com.rai.dear_dipisha/photos');

  static bool get supported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<PhotoSaveResult> save(Photo photo) async {
    final path = photo.storagePath ?? photo.assetPath;
    if (path == null) throw StateError('No photo file');
    final extension = path.split('.').last.toLowerCase();
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw const FormatException('Unsupported photo format'),
    };
    final Uint8List bytes;
    if (photo.storagePath != null) {
      final repo = repository;
      if (repo == null) throw StateError('Cloud unavailable');
      bytes = await repo
          .downloadPhoto(path)
          .timeout(const Duration(seconds: 45));
    } else {
      final data = await _bundle.load(path);
      bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    if (bytes.isEmpty) throw StateError('Empty photo file');
    final basename = path.split('/').last;
    final stem = basename
        .substring(0, basename.lastIndexOf('.'))
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename =
        'our-home-${stem.substring(0, stem.length.clamp(0, 80))}'
        '-${DateTime.now().microsecondsSinceEpoch}.$extension';
    return _writer(bytes, filename, mimeType);
  }

  static Future<PhotoSaveResult> writePhoto(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    if (!supported) throw UnsupportedError('Photo saving is unavailable');
    if (kIsWeb) {
      browser.downloadBytes(bytes, filename, mimeType);
      return PhotoSaveResult.file;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final saved = await channel.invokeMethod<bool>('savePhoto', {
        'bytes': bytes,
        'filename': filename,
        'mimeType': mimeType,
      });
      if (saved == true) return PhotoSaveResult.gallery;
    }
    final path = await FilePicker.platform.saveFile(
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: [filename.split('.').last],
      bytes: bytes,
    );
    return path == null ? PhotoSaveResult.cancelled : PhotoSaveResult.file;
  }
}
