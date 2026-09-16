import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/core/router/app_routes.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/models/content_models.dart';
import 'package:dear_dipisha/data/providers/content_providers.dart';
import 'package:dear_dipisha/data/providers/memory_photos_provider.dart';
import 'package:dear_dipisha/features/viewer/memories/memories_screen.dart';
import 'package:dear_dipisha/features/viewer/memories/memory_detail_screen.dart';
import 'package:dear_dipisha/features/viewer/memories/memory_story_mode.dart';
import 'package:dear_dipisha/features/viewer/memories/widgets/memory_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  GoRouter memoriesRouter() {
    final router = GoRouter(
      initialLocation: Routes.memories,
      routes: [
        GoRoute(
          path: Routes.memories,
          builder: (context, state) => const MemoriesScreen(),
        ),
        GoRoute(
          path: Routes.memoryDetail,
          builder: (context, state) => MemoryDetailScreen(
            key: ValueKey(state.uri.path),
            memoryId: state.pathParameters['id']!,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return router;
  }

  testWidgets('searching mummy opens the real kitchen memory card', (
    tester,
  ) async {
    phone(tester);
    final router = memoriesRouter();
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Find a memory'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'mummy');
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(12, 120));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    final memory = MockData.memories.singleWhere((m) => m.id == 'm9');
    final card = find.text(memory.title);
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey(Routes.memoryOf(memory.id))), findsOneWidget);
    expect(find.byType(MemoryDetailScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('wide and paired scrapbook cards open their own memory IDs', (
    tester,
  ) async {
    phone(tester);
    final sample = MockData.memories.first;
    final memories = [
      for (var i = 0; i < 3; i++)
        Memory(
          id: 'layout-$i',
          title: 'Layout picture $i',
          description: 'Navigation test fixture.',
          date: DateTime(2026, 1, 3 - i),
          mood: sample.mood,
          category: sample.category,
        ),
    ];
    final router = memoriesRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [memoriesProvider.overrideWithValue(memories)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    for (final memory in memories) {
      final card = find.text(memory.title);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey(Routes.memoryOf(memory.id))), findsOneWidget);
      expect(tester.takeException(), isNull);
      router.pop();
      await tester.pumpAndSettle();
    }
    await tester.pumpWidget(const SizedBox());
  });

  test('missing frames stay absent and supplied frames keep numeric order', () {
    final cover = AppPhotos.memoryCardCover('m9');
    const second = 'assets/images/memories/m9_2.jpg';
    const tenth = 'assets/images/memories/m9_10.png';
    final pictures = memoryPhotosFromAssets('m9', [
      tenth,
      'assets/images/memories/m1_1.jpg',
      second,
      cover,
      cover,
    ]);
    expect(pictures.map((p) => p.assetPath), [cover, second, tenth]);
    expect(memoryPhotosFromAssets('m9', []), isEmpty);
    expect(
      memoryPhotosFromAssets('m9', [tenth]).single.assetPath,
      tenth,
      reason: 'A missing chosen cover must not become an empty photograph.',
    );
  });

  test(
    'story pictures are bundled and school and Stubby keep their originals',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final assets = await container.read(bundledMemoryAssetsProvider.future);
      for (final memory in MockData.memories) {
        final pictures = await container.read(
          memoryPhotosProvider(memory.id).future,
        );
        expect(
          pictures,
          isNotEmpty,
          reason: '${memory.id} needs its chosen cover',
        );
        expect(
          pictures.map((p) => p.assetPath).toSet().length,
          pictures.length,
        );
        for (final picture in pictures) {
          expect(assets, contains(picture.assetPath));
          await rootBundle.load(picture.assetPath);
        }
      }
      final kitchen = await container.read(memoryPhotosProvider('m9').future);
      expect(kitchen.first.assetPath, AppPhotos.memoryCardCover('m9'));
      expect(kitchen.first.caption, isNotNull);
      for (final original in {
        'm8': 'assets/images/family/dipisha_school.jpg',
        'm10': AppPhotos.stubby,
      }.entries) {
        final selected = await rootBundle.load(
          AppPhotos.memoryCardCover(original.key),
        );
        final source = await rootBundle.load(original.value);
        expect(
          selected.buffer.asUint8List(
            selected.offsetInBytes,
            selected.lengthInBytes,
          ),
          orderedEquals(
            source.buffer.asUint8List(
              source.offsetInBytes,
              source.lengthInBytes,
            ),
          ),
          reason: '${original.key} already has a real, relevant photograph',
        );
      }
    },
  );

  testWidgets('memory card counts supplied pictures rather than mock frames', (
    tester,
  ) async {
    phone(tester);
    final memory = MockData.memories.singleWhere((m) => m.id == 'm9');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bundledMemoryAssetsProvider.overrideWith(
            (ref) async => {AppPhotos.memoryCardCover('m9')},
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: MemoryCard(memory: memory),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('${memory.photoCount}'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final lang in AppLang.values) {
    testWidgets('kitchen artwork stays whole and labelled in ${lang.name}', (
      tester,
    ) async {
      phone(tester);
      SharedPreferences.setMockInitialValues({'app_lang': lang.name});
      final memory = MockData.memories.singleWhere((m) => m.id == 'm9');
      final asset = AppPhotos.memoryCardCover(memory.id);
      final caption = trS(lang, AppPhotos.captionFor(asset)!);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memoriesProvider.overrideWithValue([memory]),
          ],
          child: MaterialApp(home: MemoryDetailScreen(memoryId: memory.id)),
        ),
      );
      await tester.pumpAndSettle();
      final hero = find.byType(SliverAppBar);
      expect(
        find.descendant(of: hero, matching: find.image(AssetImage(asset))),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hero, matching: find.text(caption)),
        findsOneWidget,
      );
      expect(find.text(trS(lang, memory.description)), findsOneWidget);
      expect(
        find.text('${trS(lang, 'Pictures for this story')} · 1'),
        findsOneWidget,
      );
      expect(
        find.textContaining(trS(lang, 'Frames from this day')),
        findsNothing,
      );

      final experience = find.text(trS(lang, 'Experience this memory'));
      await tester.ensureVisible(experience);
      await tester.pumpAndSettle();
      await tester.tap(experience);
      await tester.pumpAndSettle();
      final story = find.byType(MemoryStoryMode);
      final storyImage = find.descendant(
        of: story,
        matching: find.image(AssetImage(asset)),
      );
      final storyCaption = find.descendant(
        of: story,
        matching: find.text(caption),
      );
      expect(storyImage, findsOneWidget);
      expect(tester.widget<Image>(storyImage).fit, BoxFit.contain);
      expect(storyCaption, findsOneWidget);
      expect(
        tester.getRect(storyImage).bottom,
        lessThanOrEqualTo(tester.getRect(storyCaption).top),
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      final thumbnail = find.byKey(ValueKey('story-picture-$asset'));
      await tester.ensureVisible(thumbnail);
      await tester.pumpAndSettle();
      final thumbnailImage = find.descendant(
        of: thumbnail,
        matching: find.image(AssetImage(asset)),
      );
      expect(tester.widget<Image>(thumbnailImage).fit, BoxFit.contain);
      await tester.tap(thumbnail);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text(caption), findsOneWidget);
      expect(
        tester.widget<Image>(find.image(AssetImage(asset))).fit,
        BoxFit.contain,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'missing assets show an honest empty list and a soft cover fallback',
    (tester) async {
      phone(tester);
      final memory = MockData.memories.singleWhere((m) => m.id == 'm9');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memoriesProvider.overrideWithValue([memory]),
            bundledMemoryAssetsProvider.overrideWith((ref) async => <String>{}),
          ],
          child: MaterialApp(
            home: DefaultAssetBundle(
              bundle: _MissingKitchenBundle(),
              child: MemoryDetailScreen(memoryId: memory.id),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pictures for this story · 0'), findsOneWidget);
      expect(
        find.text('No pictures added yet. Diksha can add one.'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey('story-picture-${AppPhotos.memoryCardCover('m9')}'),
        ),
        findsNothing,
      );
      expect(find.byIcon(Icons.local_florist_rounded), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

class _MissingKitchenBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key == AppPhotos.memoryCardCover('m9')) {
      return Future<ByteData>.error(FlutterError('Missing test picture'));
    }
    return rootBundle.load(key);
  }
}
