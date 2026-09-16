import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dear_dipisha/data/gallery/gallery_repository.dart';

void main() {
  test(
    'batch publishing targets only the selected album and draft IDs',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requests = <({String method, Uri uri, dynamic body})>[];
      server.listen((request) async {
        requests.add((
          method: request.method,
          uri: request.uri,
          body: jsonDecode(await utf8.decoder.bind(request).join()),
        ));
        request.response.headers.contentType = ContentType.json;
        request.response.write('[]');
        await request.response.close();
      });
      final client = SupabaseClient(
        'http://127.0.0.1:${server.port}',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(() async {
        await client.dispose();
        await server.close(force: true);
      });
      final repo = GalleryRepository(client);
      await repo.publishDrafts('food', []);
      expect(requests, isEmpty);
      await repo.publishDrafts('food', ['photo-one', 'photo-two']);
      expect(requests.length, 2);
      final photos = requests.first;
      expect(photos.method, 'PATCH');
      expect(photos.uri.path, '/rest/v1/gallery_photos');
      expect(photos.uri.queryParameters['album_id'], 'eq.food');
      expect(photos.uri.queryParameters['published'], 'eq.false');
      expect(photos.uri.queryParameters['id'], 'in.("photo-one","photo-two")');
      expect(photos.body, {'published': true});
      expect(requests.last.uri.path, '/rest/v1/gallery_albums');
      expect(requests.last.uri.queryParameters['id'], 'eq.food');
      expect(requests.last.body, {'published': true});
    },
  );
}
