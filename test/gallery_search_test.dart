import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/album_photos_provider.dart';
import 'package:dear_dipisha/features/viewer/gallery/gallery_screen.dart';
import 'package:dear_dipisha/features/viewer/gallery/widgets/album_book.dart';

void main() {
  Future<void> pumpShelf(
    WidgetTester tester, {
    AppLang lang = AppLang.en,
  }) async {
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
        child: const MaterialApp(home: GalleryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the album desk sits beside the title, search beside refresh', (
    tester,
  ) async {
    await pumpShelf(tester);
    final title = tester.getRect(find.text('Family Albums'));
    final desk = tester.getCenter(find.byTooltip('Your album desk'));
    final hint = tester.getRect(find.text('Take one down.'));
    final search = tester.getCenter(find.byTooltip('Search albums…'));
    final refresh = tester.getCenter(find.byTooltip('Refresh'));

    expect(desk.dx, greaterThan(title.right));
    expect(desk.dy, lessThan(hint.top), reason: 'the desk is in the title row');
    expect(search.dy, refresh.dy, reason: 'search and refresh share a row');
    expect(search.dy, closeTo(hint.center.dy, 12));
    expect(search.dx, lessThan(refresh.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the magnifier finds albums by name and closes back to all', (
    tester,
  ) async {
    await pumpShelf(tester);
    final all = find.byType(AlbumBook).evaluate().length;
    expect(all, MockData.albums.length);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byTooltip('Search albums…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'GRADUATION');
    await tester.pumpAndSettle();
    expect(find.byType(AlbumBook), findsOneWidget);
    expect(find.text("Diksha's Graduation 🎓"), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'no such album');
    await tester.pumpAndSettle();
    expect(find.byType(AlbumBook), findsNothing);
    expect(find.text('No albums found'), findsOneWidget);

    // Closing the search puts every album back, not the last results.
    await tester.tap(find.byTooltip('Search albums…'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(AlbumBook).evaluate().length, all);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Nepali reader finds an album by its Nepali name', (
    tester,
  ) async {
    await pumpShelf(tester, lang: AppLang.ne);
    await tester.tap(find.byTooltip(trS(AppLang.ne, 'Search albums…')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'परिवार');
    await tester.pumpAndSettle();
    expect(find.text(trS(AppLang.ne, 'Family Together')), findsOneWidget);
    expect(
      find.byType(AlbumBook).evaluate().length,
      lessThan(MockData.albums.length),
    );
    expect(tester.takeException(), isNull);
  });

  test('album search reads in Nepali', () {
    for (final text in [
      'Search albums…',
      'No albums found',
      'Try another word.',
    ]) {
      expect(hasNepali(text), isTrue, reason: text);
    }
  });
}
