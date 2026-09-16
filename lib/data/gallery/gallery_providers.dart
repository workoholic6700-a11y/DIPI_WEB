import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/bootstrap.dart';
import '../../core/config/env.dart';
import 'gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository?>(
  (ref) => Env.isConfigured && !isDemoMode ? GalleryRepository(supabase) : null,
);

final galleryAuthProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(galleryRepositoryProvider)?.client.auth.onAuthStateChange ??
      const Stream.empty();
});

final galleryRoleProvider = FutureProvider<String?>((ref) async {
  ref.watch(galleryAuthProvider);
  return ref.watch(galleryRepositoryProvider)?.role();
});

final cloudAlbumsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  ref.watch(galleryAuthProvider);
  return await ref
          .watch(galleryRepositoryProvider)
          ?.albums(publishedOnly: true) ??
      [];
});

final cloudPhotosProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  ref.watch(galleryAuthProvider);
  return await ref
          .watch(galleryRepositoryProvider)
          ?.photos(publishedOnly: true) ??
      [];
});

final gallerySignedUrlProvider = FutureProvider.autoDispose
    .family<String, String>((ref, path) async {
      ref.watch(galleryAuthProvider);
      final repository = ref.watch(galleryRepositoryProvider)!;
      final timer = Timer(const Duration(minutes: 45), ref.invalidateSelf);
      ref.onDispose(timer.cancel);
      return repository.client.storage
          .from(GalleryRepository.bucket)
          .createSignedUrl(path, 3600);
    });

final galleryCoverProvider = Provider.family<String?, String>((ref, albumId) {
  final photos = ref.watch(cloudPhotosProvider).value ?? [];
  for (final photo in photos) {
    if (photo['album_id'] == albumId &&
        photo['is_cover'] == true &&
        photo['published'] == true) {
      return photo['thumb_path'] as String;
    }
  }
  return null;
});
