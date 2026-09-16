import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/constants/app_photos.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/features/viewer/home/room/widgets/todays_table.dart';
import 'package:dear_dipisha/features/viewer/memories/memory_detail_screen.dart';
import 'package:dear_dipisha/features/viewer/memories/memory_story_mode.dart';

void main() {
  for (final lang in AppLang.values) {
    testWidgets(
      'birthday portrait follows Home to the opened page and story in ${lang.name}',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({'app_lang': lang.name});
        final memory = MockData.memories.singleWhere((m) => m.id == 'm2');
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TodaysTable(
                    memory: memory,
                    letter: MockData.letters.first,
                    birthday: (name: 'Diksha', days: 6),
                    quote: MockData.quotes.first,
                    onMemory: () => context.push('/memory/${memory.id}'),
                    onLetter: () {},
                    onBirthday: () {},
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/memory/:id',
              builder: (context, state) =>
                  MemoryDetailScreen(memoryId: state.pathParameters['id']!),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        final portrait = find.image(
          const AssetImage(AppPhotos.dipishaGownWhite),
        );
        expect(portrait, findsOneWidget);
        expect(
          find.image(const AssetImage(AppPhotos.dipishaPinkWhite)),
          findsNothing,
        );
        expect(find.text(memory.title), findsOneWidget);
        expect(
          find.text(trS(lang, 'AI-edited · white background')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(portrait);
        await tester.pumpAndSettle();
        expect(find.byType(MemoryDetailScreen), findsOneWidget);
        expect(
          find.descendant(of: find.byType(SliverAppBar), matching: portrait),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SliverAppBar),
            matching: find.text(trS(lang, 'AI-edited · white background')),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        final experience = find.text(trS(lang, 'Experience this memory'));
        await tester.ensureVisible(experience);
        await tester.pumpAndSettle();
        await tester.tap(experience);
        await tester.pumpAndSettle();
        expect(find.byType(MemoryStoryMode), findsOneWidget);
        expect(portrait, findsOneWidget);
        expect(
          find.text(trS(lang, 'AI-edited · white background')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  test('chosen birthday cover preserves original memory photo slots', () {
    expect(AppPhotos.memory('m2'), 'assets/images/memories/m2.jpg');
    expect(AppPhotos.memoryPhoto('m2', 0), 'assets/images/memories/m2_1.jpg');
    expect(AppPhotos.memoryCardCover('m2'), AppPhotos.dipishaGownWhite);
    expect(AppPhotos.memoryCardCover('m10'), AppPhotos.memory('m10'));
  });
}
