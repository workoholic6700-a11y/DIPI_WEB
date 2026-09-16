import 'package:flutter/material.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/models/content_models.dart';
import 'package:dear_dipisha/data/providers/content_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/gallery/gallery_repository.dart';
import 'package:dear_dipisha/features/admin/gallery_access.dart';
import 'package:dear_dipisha/features/viewer/gallery/gallery_screen.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';

void main() {
  test(
    'renaming a built-in album keeps its ID and original photographs',
    () async {
      final original = MockData.albums.first;
      final container = ProviderContainer(
        overrides: [
          cloudAlbumsProvider.overrideWith(
            (ref) async => [
              {
                'id': original.id,
                'name': 'Our photographs',
                'created_at': '2026-09-07T00:00:00Z',
              },
            ],
          ),
          cloudPhotosProvider.overrideWith((ref) async => []),
          bundledAlbumPhotosProvider.overrideWith(
            (ref) async => {
              original.id: ['assets/original.jpg'],
            },
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(cloudAlbumsProvider.future);
      final albums = container.read(albumsProvider);
      expect(
        albums.where((a) => a.id == original.id).single.name,
        'Our photographs',
      );
      expect(albums.length, MockData.albums.length);
      final photos = await container.read(
        albumPhotosProvider(original.id).future,
      );
      expect(photos.single.assetPath, 'assets/original.jpg');
    },
  );

  test('a bundled cover chosen on the desk shows, else the first bundled', () {
    const bundled = {
      'diya': [
        'assets/images/albums/diya_1.jpg',
        'assets/images/albums/diya_2.jpg',
        'assets/images/albums/diya_3.jpg',
      ],
    };
    Album album({String? coverAsset}) => Album(
      id: 'diya',
      name: 'Diya',
      date: DateTime(2024, 7, 15),
      photoCount: 0,
      coverAsset: coverAsset,
    );
    expect(
      bundledCoverFor(album(), bundled),
      'assets/images/albums/diya_1.jpg',
    );
    expect(
      bundledCoverFor(
        album(coverAsset: 'assets/images/albums/diya_3.jpg'),
        bundled,
      ),
      'assets/images/albums/diya_3.jpg',
    );
    // A cover pointing at a photograph that no longer ships falls back
    // instead of showing a broken frame.
    expect(
      bundledCoverFor(
        album(coverAsset: 'assets/images/albums/diya_9.jpg'),
        bundled,
      ),
      'assets/images/albums/diya_1.jpg',
    );
    expect(bundledCoverFor(album(), const {}), isNull);
    expect(bundledCoverFor(album(), null), isNull);
  });

  test(
    'album cover uses only the selected published photo in that album',
    () async {
      final container = ProviderContainer(
        overrides: [
          cloudPhotosProvider.overrideWith(
            (ref) async => [
              {
                'album_id': 'other',
                'is_cover': true,
                'published': true,
                'thumb_path': 'other.jpg',
              },
              {
                'album_id': 'food',
                'is_cover': false,
                'published': true,
                'thumb_path': 'first.jpg',
              },
              {
                'album_id': 'food',
                'is_cover': true,
                'published': false,
                'thumb_path': 'draft.jpg',
              },
              {
                'album_id': 'food',
                'is_cover': true,
                'published': true,
                'thumb_path': 'chosen.jpg',
              },
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(cloudPhotosProvider.future);
      expect(container.read(galleryCoverProvider('food')), 'chosen.jpg');
      expect(container.read(galleryCoverProvider('missing')), isNull);
    },
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the sign-in password can be shown and hidden', (tester) async {
    final repository = GalleryRepository(
      SupabaseClient(
        'https://example.invalid',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(repository),
          galleryAuthProvider.overrideWith((ref) => const Stream.empty()),
          galleryRoleProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: GalleryAccess(adminOnly: true, child: Text('DESK')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final password = find.widgetWithText(TextField, 'Password');
    expect(tester.widget<TextField>(password).obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isFalse);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isTrue);
  });

  testWidgets('a viewer account cannot reach admin controls', (tester) async {
    final repository = GalleryRepository(
      SupabaseClient(
        'https://example.invalid',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(repository),
          galleryAuthProvider.overrideWith((ref) => const Stream.empty()),
          galleryRoleProvider.overrideWith((ref) async => 'viewer'),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: GalleryAccess(
              adminOnly: true,
              child: Text('PRIVATE UPLOAD CONTROLS'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PRIVATE UPLOAD CONTROLS'), findsNothing);
    expect(find.text('Your album desk'), findsOneWidget);
  });

  testWidgets(
    'family shelf fits a narrow phone and contains no upload controls',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(
              GalleryRepository(
                SupabaseClient(
                  'https://example.invalid',
                  'test-key',
                  authOptions: const AuthClientOptions(autoRefreshToken: false),
                ),
              ),
            ),
            galleryAuthProvider.overrideWith((ref) => const Stream.empty()),
            galleryRoleProvider.overrideWith((ref) async => null),
            cloudAlbumsProvider.overrideWith((ref) async => []),
            cloudPhotosProvider.overrideWith((ref) async => []),
            bundledAlbumPhotosProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: GalleryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Family album sign-in'), findsNothing);
      expect(find.text('Sign in'), findsNothing);
      expect(find.text('Take one down.'), findsOneWidget);
      expect(find.text('Add photos'), findsNothing);
      expect(find.text('Publish'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Your album desk'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Add photos'), findsNothing);
      expect(find.text('New album'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Take one down.'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
