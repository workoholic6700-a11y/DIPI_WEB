import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/constants/enums.dart';
import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/core/theme/app_theme.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/content_providers.dart';
import 'package:dear_dipisha/features/viewer/letters/letters_screen.dart';
import 'package:dear_dipisha/features/viewer/letters/widgets/envelope.dart';

/// The mailbox draws sealed and opened envelopes as physically different
/// objects, so the read-state behind them has to be real. An envelope that
/// reseals itself overnight would be the app misremembering her own history
/// with a letter — worse than not tracking it at all.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the treehouse fits the target phone in portrait', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const LettersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inside the Treehouse'), findsOneWidget);
    expect(find.byType(EnvelopeTile), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('opened letters', () {
    test('every letter starts sealed on a first-ever launch', () async {
      final c = container();
      c.read(openedLettersProvider);
      await settle();
      expect(c.read(openedLettersProvider), isEmpty);
      expect(c.read(unopenedLettersProvider).length, MockData.letters.length);
    });

    test('an opened letter stays open after a restart', () async {
      final first = MockData.letters.first;

      final c = container();
      await settle();
      c.read(openedLettersProvider.notifier).markOpened(first.id);
      await settle();
      expect(c.read(isLetterOpenedProvider(first.id)), isTrue);

      // A fresh launch over the same store.
      final c2 = container();
      c2.read(openedLettersProvider);
      await settle();
      expect(
        c2.read(isLetterOpenedProvider(first.id)),
        isTrue,
        reason: 'a letter she has read must not reseal itself',
      );
    });

    test('opening is idempotent and never un-opens', () async {
      final id = MockData.letters.first.id;
      final c = container();
      await settle();
      final n = c.read(openedLettersProvider.notifier);
      n.markOpened(id);
      n.markOpened(id);
      await settle();
      expect(c.read(openedLettersProvider).where((e) => e == id).length, 1);
      expect(n.isOpened(id), isTrue);
    });

    test('the mailbox offers the oldest sealed letter', () async {
      final c = container();
      c.read(openedLettersProvider);
      await settle();

      final unopened = c.read(unopenedLettersProvider);
      expect(unopened, isNotEmpty);
      for (var i = 1; i < unopened.length; i++) {
        expect(
          unopened[i - 1].dateWritten.isAfter(unopened[i].dateWritten),
          isFalse,
          reason: 'the tray must hand over the oldest sealed letter first',
        );
      }
    });

    test('opening removes it from the sealed pile', () async {
      final c = container();
      c.read(unopenedLettersProvider);
      await settle();

      final before = c.read(unopenedLettersProvider);
      final target = before.first;
      c.read(openedLettersProvider.notifier).markOpened(target.id);
      await settle();

      final after = c.read(unopenedLettersProvider);
      expect(after.length, before.length - 1);
      expect(after.map((l) => l.id), isNot(contains(target.id)));
    });
  });

  group('the mailbox speaks Nepali', () {
    test('every visible string is translated', () {
      const strings = [
        'Inside the Treehouse',
        'Letters from Nana',
        'Kept for whenever you need them',
        'A letter for today',
        'The box is empty',
        'You have opened every one.',
        'still sealed',
        'the last sealed one',
        'When you need…',
        'The letter tray',
        'Letters for that',
        'Search letters…',
        'No letters found',
        'Try another word.',
        'Letter not found',
        'opened',
        'The mailbox. A letter is waiting.',
        'The mailbox. Every letter has been opened.',
        'An opened letter',
        'A sealed letter',
        'Opens it.',
      ];
      for (final s in strings) {
        expect(hasNepali(s), isTrue, reason: 'no Nepali for "$s"');
        expect(trS(AppLang.ne, s), isNot(s));
      }
    });

    test('the three feelings on the shelf are translated', () {
      for (final c in [
        LetterCategory.whenSad,
        LetterCategory.whenHappy,
        LetterCategory.whenScared,
      ]) {
        expect(
          hasNepali(c.label),
          isTrue,
          reason: 'no Nepali for "${c.label}"',
        );
      }
    });

    test('every letter category currently in the tray is translated', () {
      for (final letter in MockData.letters) {
        expect(
          hasNepali(letter.category.label),
          isTrue,
          reason: 'no Nepali for "${letter.category.label}"',
        );
      }
    });
  });

  group('letter attachments tell the truth', () {
    test(
      'no letter claims a recording or photo that has not been supplied',
      () {
        for (final letter in MockData.letters) {
          expect(
            letter.hasVoice,
            isFalse,
            reason: '${letter.id} has no letter recording asset',
          );
          expect(
            letter.imageCount,
            0,
            reason: '${letter.id} has no letter photo asset',
          );
        }
      },
    );
  });
}
