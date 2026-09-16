import 'dart:async';
import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/gallery/gallery_repository.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';
import 'package:dear_dipisha/features/admin/gallery_admin_screen.dart';
import 'package:dear_dipisha/features/admin/gallery_desk_paper.dart';
import 'package:dear_dipisha/features/viewer/gallery/gallery_screen.dart';
import 'package:dear_dipisha/features/viewer/gallery/widgets/album_book.dart';
import 'package:dear_dipisha/shared/widgets/gallery_photo.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('album never calls a loading or failed count empty', (
    tester,
  ) async {
    final counts = Completer<Map<String, int>>();
    final container = ProviderContainer(
      overrides: [
        albumPhotoCountsProvider.overrideWith((ref) => counts.future),
        cloudPhotosProvider.overrideWith((ref) async => []),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: AlbumBook(
              album: MockData.albums.first,
              width: 160,
              height: 218,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('Checking photos…'), findsOneWidget);
    expect(find.text('Still to fill'), findsNothing);
    counts.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Photo count unavailable'), findsOneWidget);
    expect(find.text('Still to fill'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final lang in AppLang.values) {
    testWidgets('shelf remains usable at large text in ${lang.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'app_lang': lang.name});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(null),
            cloudAlbumsProvider.overrideWith((ref) async => []),
            cloudPhotosProvider.overrideWith((ref) async => []),
            bundledAlbumPhotosProvider.overrideWith((ref) async => {}),
          ],
          child: MaterialApp(
            theme: ThemeData(
              brightness: lang == AppLang.ne
                  ? Brightness.dark
                  : Brightness.light,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const GalleryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final books = find.byType(AlbumBook);
      expect(tester.getSize(books.first).width, greaterThan(280));
      expect(find.byTooltip(trS(lang, 'Your album desk')), findsOneWidget);
      final semantics = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(books.first)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      semantics.dispose();
      expect(find.text(trS(lang, 'Still to fill')), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'desk keeps draft and published controls at narrow large text in ${lang.name}',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({'app_lang': lang.name});
        final repo = (await tester.runAsync(() async => _DeskRepository()))!;
        addTearDown(() => tester.runAsync(repo.client.dispose));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              galleryRepositoryProvider.overrideWithValue(repo),
              bundledAlbumPhotosProvider.overrideWith((ref) async => {}),
              gallerySignedUrlProvider.overrideWith(
                (ref, path) async => throw StateError('offline'),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(
                brightness: lang == AppLang.ne
                    ? Brightness.dark
                    : Brightness.light,
              ),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: const GalleryAdminScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(GalleryDeskPaper), findsOneWidget);
        final prints = tester
            .widgetList<GalleryDeskPrint>(find.byType(GalleryDeskPrint))
            .toList();
        expect(prints.map((p) => p.draft), [true, false]);
        expect(find.text(trS(lang, 'Draft')), findsOneWidget);
        expect(find.text(trS(lang, 'Published')), findsOneWidget);
        expect(tester.takeException(), isNull);
        final publish = find.widgetWithText(TextButton, trS(lang, 'Publish'));
        await tester.ensureVisible(publish);
        await tester.pumpAndSettle();
        await tester.tap(publish);
        await tester.pumpAndSettle();
        expect(repo.published, isTrue);
        expect(find.text(trS(lang, 'Draft')), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('album desk lays photographs two to a row on the phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = (await tester.runAsync(() async => _DeskRepository()))!;
    addTearDown(() => tester.runAsync(repo.client.dispose));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(repo),
          bundledAlbumPhotosProvider.overrideWith((ref) async => {}),
          gallerySignedUrlProvider.overrideWith(
            (ref, path) async => throw StateError('offline'),
          ),
        ],
        child: const MaterialApp(home: GalleryAdminScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final prints = find.byType(GalleryDeskPrint);
    expect(prints, findsNWidgets(2));
    final first = tester.getTopLeft(prints.at(0));
    final second = tester.getTopLeft(prints.at(1));
    expect(second.dy, first.dy, reason: 'both prints share one row');
    expect(second.dx, greaterThan(first.dx));

    // Publishing stays in plain sight on a draft; everything else waits
    // until the print itself is tapped and opened.
    expect(find.widgetWithText(TextButton, 'Publish'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
    final print = find.byType(GalleryPhoto).last;
    await tester.ensureVisible(print);
    await tester.pumpAndSettle();
    await tester.tap(print);
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Unpublish'), findsOneWidget);
    expect(find.text('Edit caption'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('shelf albums built into the app refuse deletion', () async {
    final repo = GalleryRepository(
      SupabaseClient(
        'https://example.invalid',
        'test',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
    );
    addTearDown(() => repo.client.dispose());
    expect(GalleryRepository.isShelfAlbum(MockData.albums.first.id), isTrue);
    expect(GalleryRepository.isShelfAlbum('something-diksha-made'), isFalse);
    await expectLater(
      repo.deleteAlbum(MockData.albums.first.id),
      throwsArgumentError,
    );
  });

  Future<void> pumpDesk(
    WidgetTester tester,
    _DeskRepository repo, {
    Map<String, List<String>> bundled = const {},
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(repo),
          bundledAlbumPhotosProvider.overrideWith((ref) async => bundled),
          gallerySignedUrlProvider.overrideWith(
            (ref, path) async => throw StateError('offline'),
          ),
        ],
        child: const MaterialApp(home: GalleryAdminScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an album made on the desk can be deleted after confirming', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = (await tester.runAsync(() async => _DeskRepository()))!;
    addTearDown(() => tester.runAsync(repo.client.dispose));
    await pumpDesk(tester, repo);

    final button = find.widgetWithText(TextButton, 'Delete album');
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Delete this album?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(repo.deletedAlbum, isNull);

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(repo.deletedAlbum, 'test');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a photograph bundled in the app can become the cover', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = (await tester.runAsync(() async => _DeskRepository()))!;
    addTearDown(() => tester.runAsync(repo.client.dispose));
    const path = 'assets/images/albums/test_1.jpg';
    await pumpDesk(
      tester,
      repo,
      bundled: {
        'test': [path],
      },
    );

    expect(find.byType(GalleryDeskPrint), findsNWidgets(3));
    expect(find.text('Included in the app'), findsOneWidget);
    final print = find.byType(GalleryPhoto).first;
    await tester.ensureVisible(print);
    await tester.pumpAndSettle();
    await tester.tap(print);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use as album cover'));
    await tester.pumpAndSettle();
    expect(repo.bundledCover, path);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  // A new album is a private draft, and the family gallery doesn't show it.
  // The desk used to stay on the previous album and say "Saved." under that
  // album's "visible to family" line, so nothing showed it was still hidden.
  testWidgets('a new album opens on the desk as a private draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = (await tester.runAsync(() async => _NewAlbumRepository()))!;
    addTearDown(() => tester.runAsync(repo.client.dispose));
    await pumpDesk(tester, repo);
    expect(find.text('Album is visible to family.'), findsOneWidget);

    await tester.tap(find.text('New album'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A new album');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repo.created, 'A new album');
    expect(find.text('Album is a private draft.'), findsOneWidget);
    expect(find.text('Album is visible to family.'), findsNothing);
    expect(
      find.text(
        'New album saved as a private draft. The family sees it once you publish it.',
      ),
      findsOneWidget,
    );
    expect(find.text('Publish album'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // The name dialog disposes its field a second after closing.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a shelf album built into the app offers no delete', (
    tester,
  ) async {
    final repo = (await tester.runAsync(() async => _ShelfRepository()))!;
    addTearDown(() => tester.runAsync(repo.client.dispose));
    await pumpDesk(tester, repo);
    expect(find.text('Unpublish album'), findsOneWidget);
    expect(find.text('Delete album'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('gallery controls have readable Nepali translations', () {
    for (final text in [
      'Your album desk',
      'Use as album cover',
      'Published',
      'Draft',
      'Add photos',
      'Publish all drafts',
      'Still to fill',
      'Checking photos…',
      'Photo count unavailable',
      'Room for your photographs',
      'Delete album',
      'Delete this album?',
      'Signing in…',
      'New album saved as a private draft. The family sees it once you publish it.',
    ]) {
      expect(hasNepali(text), isTrue, reason: text);
      expect(trS(AppLang.ne, text), isNot(contains('?')), reason: text);
    }
  });
}

class _DeskRepository extends GalleryRepository {
  _DeskRepository()
    : super(
        SupabaseClient(
          'https://example.invalid',
          'test',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  bool published = false;
  String? deletedAlbum;
  String? bundledCover;
  @override
  Future<void> ensureShelfAlbums() async {}
  @override
  Future<void> setBundledCover(String albumId, String? assetPath) async {
    bundledCover = assetPath;
  }
  @override
  Future<void> deleteAlbum(String id) async {
    deletedAlbum = id;
  }
  @override
  Future<List<Map<String, dynamic>>> albums({
    bool publishedOnly = false,
  }) async => [
    {
      'id': 'test',
      'name': 'A long album name for a narrow phone',
      'published': true,
    },
  ];
  @override
  Future<List<Map<String, dynamic>>> photos({
    String? albumId,
    bool publishedOnly = false,
  }) async => [
    {
      'id': 'draft',
      'caption': 'A photograph waiting to be published',
      'published': published,
      'is_cover': false,
      'thumb_path': 'draft.jpg',
    },
    {
      'id': 'published',
      'caption': '',
      'published': true,
      'is_cover': true,
      'thumb_path': 'published.jpg',
    },
  ];
  @override
  Future<void> updatePhoto(String id, String caption, bool value) async {
    if (id == 'draft') published = value;
  }
}

/// A desk where "New album" really adds one, unpublished as the table does.
class _NewAlbumRepository extends _DeskRepository {
  String? created;
  @override
  Future<String> createAlbum(String name, {String? id}) async {
    created = name;
    return 'new';
  }

  @override
  Future<List<Map<String, dynamic>>> albums({
    bool publishedOnly = false,
  }) async => [
    ...await super.albums(),
    if (created != null) {'id': 'new', 'name': created, 'published': false},
  ];

  @override
  Future<List<Map<String, dynamic>>> photos({
    String? albumId,
    bool publishedOnly = false,
  }) async => albumId == 'new' ? [] : super.photos(albumId: albumId);
}

/// A desk showing one of the albums that ship inside the app.
class _ShelfRepository extends _DeskRepository {
  @override
  Future<List<Map<String, dynamic>>> albums({
    bool publishedOnly = false,
  }) async => [
    {
      'id': MockData.albums.first.id,
      'name': MockData.albums.first.name,
      'published': true,
    },
  ];
}
