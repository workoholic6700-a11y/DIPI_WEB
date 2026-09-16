import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../mock/mock_data.dart';

/// Re-encoding removes camera metadata; dates/captions are never inferred.
Map<String, Uint8List> prepareGalleryImage(Uint8List bytes) {
  if (bytes.length > 30 * 1024 * 1024) {
    throw const FormatException('Image is too large');
  }
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    throw const FormatException('Unsupported or damaged image');
  }
  if (decoded == null) throw const FormatException('Unsupported image');
  final oriented = img.bakeOrientation(decoded);
  img.Image resize(int side) =>
      oriented.width <= side && oriented.height <= side
      ? oriented
      : img.copyResize(
          oriented,
          width: oriented.width >= oriented.height ? side : null,
          height: oriented.height > oriented.width ? side : null,
        );
  Uint8List encode(int side, int quality) {
    final resized = resize(side);
    final clean = img.Image(width: resized.width, height: resized.height);
    img.compositeImage(clean, resized);
    return Uint8List.fromList(img.encodeJpg(clean, quality: quality));
  }

  return {'image': encode(1600, 80), 'thumb': encode(400, 70)};
}

class GalleryRepository {
  GalleryRepository(this.client);
  final SupabaseClient client;
  static const bucket = 'family-gallery';

  Future<Uint8List> downloadPhoto(String storagePath) =>
      client.storage.from(bucket).download(storagePath);

  Future<String?> role() async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await client
        .from('gallery_members')
        .select('role')
        .eq('user_id', uid)
        .maybeSingle();
    return row?['role'] as String?;
  }

  Future<List<Map<String, dynamic>>> albums({
    bool publishedOnly = false,
  }) async {
    var query = client.from('gallery_albums').select();
    if (publishedOnly) query = query.eq('published', true);
    return await query.order('created_at');
  }

  Future<List<Map<String, dynamic>>> photos({
    String? albumId,
    bool publishedOnly = false,
  }) async {
    var query = client
        .from('gallery_photos')
        .select('*, gallery_albums!inner(published)');
    if (albumId != null) query = query.eq('album_id', albumId);
    if (publishedOnly) {
      query = query.eq('published', true).eq('gallery_albums.published', true);
    }
    return await query.order('created_at');
  }

  Future<void> ensureShelfAlbums() async {
    await client
        .from('gallery_albums')
        .upsert(
          [
            for (final album in MockData.albums)
              {'id': album.id, 'name': album.name, 'published': true},
          ],
          onConflict: 'id',
          ignoreDuplicates: true,
        );
  }

  Future<void> setCover(String photoId) async {
    await client.rpc('gallery_set_cover', params: {'photo_id': photoId});
  }

  /// Chooses one of the photographs bundled in the app as the album's cover.
  /// Needs `202609100001_album_bundled_cover.sql`; the cover_asset write goes
  /// first so a project without it changes nothing.
  Future<void> setBundledCover(String albumId, String? assetPath) async {
    await client
        .from('gallery_albums')
        .update({'cover_asset': assetPath})
        .eq('id', albumId);
    // An uploaded cover would otherwise still win in the family app.
    await client
        .from('gallery_photos')
        .update({'is_cover': false})
        .eq('album_id', albumId)
        .eq('is_cover', true);
  }

  /// New albums start as private drafts (the table's default); the family
  /// app only shows them once they are published.
  Future<String> createAlbum(String name, {String? id}) async {
    final albumId = id ?? const Uuid().v4();
    await client.from('gallery_albums').insert({
      'id': albumId,
      'name': name.trim(),
    });
    return albumId;
  }

  Future<void> updateAlbum(String id, String name, bool published) async {
    await client
        .from('gallery_albums')
        .update({'name': name.trim(), 'published': published})
        .eq('id', id);
  }

  Future<void> upload(String albumId, Uint8List bytes, String caption) async {
    final data = await compute(prepareGalleryImage, bytes);
    final id = const Uuid().v4();
    final path = '$albumId/$id.jpg';
    final thumb = '$albumId/${id}_thumb.jpg';
    final storage = client.storage.from(bucket);
    final uploaded = <String>[];
    try {
      for (final entry in {
        path: data['image']!,
        thumb: data['thumb']!,
      }.entries) {
        await storage.uploadBinary(
          entry.key,
          entry.value,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
        uploaded.add(entry.key);
      }
      await client.from('gallery_photos').insert({
        'id': id,
        'album_id': albumId,
        'caption': caption.trim(),
        'storage_path': path,
        'thumb_path': thumb,
      });
    } catch (_) {
      // A failed metadata insert must not leave an apparently published photo.
      if (uploaded.isNotEmpty) {
        try {
          await storage.remove(uploaded);
        } catch (_) {
          /* retry via storage dashboard */
        }
      }
      rethrow;
    }
  }

  Future<void> updatePhoto(String id, String caption, bool published) async {
    await client
        .from('gallery_photos')
        .update({'caption': caption.trim(), 'published': published})
        .eq('id', id);
  }

  Future<void> publishDrafts(String albumId, List<String> photoIds) async {
    if (photoIds.isEmpty) return;
    await client
        .from('gallery_photos')
        .update({'published': true})
        .eq('album_id', albumId)
        .eq('published', false)
        .inFilter('id', photoIds);
    await client
        .from('gallery_albums')
        .update({'published': true})
        .eq('id', albumId);
  }

  /// Shelf albums are defined in the app itself and come back on the next
  /// load, so only albums created on the desk can be deleted.
  static bool isShelfAlbum(String id) =>
      MockData.albums.any((album) => album.id == id);

  Future<void> deleteAlbum(String id) async {
    if (isShelfAlbum(id)) {
      throw ArgumentError.value(id, 'id', 'Shelf albums are built into the app');
    }
    // Hide first, so an interrupted delete never leaves a half-empty album
    // visible to the family.
    await client
        .from('gallery_albums')
        .update({'published': false})
        .eq('id', id);
    final rows = await photos(albumId: id);
    final paths = [
      for (final p in rows) ...[
        p['storage_path'] as String,
        p['thumb_path'] as String,
      ],
    ];
    if (paths.isNotEmpty) await client.storage.from(bucket).remove(paths);
    await client.from('gallery_photos').delete().eq('album_id', id);
    await client.from('gallery_albums').delete().eq('id', id);
  }

  Future<void> deletePhoto(Map<String, dynamic> photo) async {
    // Unpublish first, so interrupted deletion never exposes a broken photo.
    await updatePhoto(photo['id'] as String, photo['caption'] as String, false);
    await client.storage.from(bucket).remove([
      photo['storage_path'] as String,
      photo['thumb_path'] as String,
    ]);
    await client
        .from('gallery_photos')
        .delete()
        .eq('id', photo['id'] as String);
  }
}
