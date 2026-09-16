import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/data/mock/heritage_data.dart';
import 'package:dear_dipisha/data/models/heritage_models.dart';
import 'package:dear_dipisha/data/providers/heritage_providers.dart';

/// The Heritage section's whole value is that nothing in it is invented.
///
/// These tests guard that property mechanically, because it is exactly the kind
/// of rule that erodes later — somebody fills an empty method with "something
/// reasonable" to make a screen look finished, and the archive quietly stops
/// being trustworthy.
void main() {
  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('nothing is invented', () {
    test('a recipe either has real steps or says who to ask', () {
      for (final r in HeritageData.recipes) {
        expect(
          r.isComplete || r.missing != null,
          isTrue,
          reason: '${r.id} has no method and no note saying who holds it. '
              'An empty recipe must name the person who can fill it, never '
              'just sit blank.',
        );
      }
    });

    test('a recipe never has both a method and an unfilled gap', () {
      for (final r in HeritageData.recipes) {
        if (r.isComplete) {
          expect(r.missing, isNull,
              reason: '${r.id} is written down; drop its Collectable.');
        }
      }
    });

    test('every gap names somebody real to ask', () {
      const family = [
        'Mummy',
        'Papa',
        'Kopa',
        'Diksha',
        'Diya',
        'Dipisha',
      ];
      for (final c in container().read(toCollectProvider)) {
        expect(c.askWho, isNotEmpty);
        expect(
          family.any(c.askWho.contains) || c.askWho.startsWith('Anyone'),
          isTrue,
          reason: '"${c.askWho}" is not a person this family can actually go '
              'and ask.',
        );
      }
    });

    test('elder knowledge is flagged urgent', () {
      // Anything only Kopa holds is the kind that disappears.
      for (final c in container().read(toCollectProvider)) {
        if (c.askWho == 'Kopa') {
          expect(c.urgent, isTrue,
              reason: 'Something only Kopa knows should be marked urgent: '
                  '"${c.what}"');
        }
      }
      expect(container().read(urgentToCollectProvider), isNotEmpty);
    });

    test('no everyday Rai dialect words are seeded', () {
      // The family speaks one of ~30 Rai languages and nobody has told us
      // which. The Kirat words we DO ship are Mundhum/Sakela vocabulary that
      // the Sakela screen already used. If a future edit adds "water" or
      // "mother" in a guessed dialect, this is the tripwire.
      const ritual = {
        'w_sewa', 'w_mundhum', 'w_sakela', 'w_sili', 'w_ubhauli',
        'w_udhauli', 'w_than', 'w_sumnima', 'w_paruhang',
      };
      final kirat =
          HeritageData.words.where((w) => w.kind == WordKind.kirat);
      for (final w in kirat) {
        expect(ritual.contains(w.id), isTrue,
            reason: '"${w.roman}" was added as a Kirat word. Only Mundhum / '
                'Sakela vocabulary is safe to ship — everyday dialect must '
                'come from Kopa first.');
      }
      // And the gap is explicitly recorded.
      expect(
        HeritageData.wordsToCollect.any((c) => c.askWho == 'Kopa' && c.urgent),
        isTrue,
      );
    });

    test('no word claims a recording that does not exist', () {
      for (final w in HeritageData.words) {
        expect(w.audio, isNull,
            reason: '${w.id} points at an audio asset. Nothing has been '
                'recorded yet — wire the asset only when the file is real.');
      }
    });
  });

  group('structure', () {
    test('ids are unique across every heritage list', () {
      final ids = [
        ...HeritageData.words.map((e) => e.id),
        ...HeritageData.recipes.map((e) => e.id),
        ...HeritageData.traditions.map((e) => e.id),
        ...HeritageData.roots.map((e) => e.id),
      ];
      expect(ids.toSet().length, ids.length, reason: 'duplicate heritage id');
    });

    test('exactly one place is home', () {
      expect(HeritageData.roots.where((r) => r.isHome).length, 1);
      expect(container().read(homeRootProvider)?.place, contains('Ilam'));
    });

    test('words are grouped into every kind that has entries', () {
      final byKind = container().read(wordsByKindProvider);
      for (final entry in byKind.entries) {
        expect(entry.value, isNotEmpty);
        for (final w in entry.value) {
          expect(w.kind, entry.key);
        }
      }
      // All three kinds are actually populated.
      expect(byKind.keys.toSet(), WordKind.values.toSet());
    });

    test('tally matches the underlying lists', () {
      final t = container().read(heritageTallyProvider);
      expect(t.words, HeritageData.words.length);
      expect(t.recipes, HeritageData.recipes.length);
      expect(t.wordsWithAudio, 0);
      expect(t.recipesComplete, 0);
      expect(t.toCollect, greaterThan(0));
      expect(t.urgent, greaterThan(0));
    });
  });

  group('nepali', () {
    test('the honesty vocabulary is translated', () {
      // If these leak English, the section stops working for exactly the two
      // people most of it is about.
      const mustTranslate = [
        'Our Roots',
        'Our Words',
        'Our Recipes',
        'What We Do, and Why',
        'Where We Come From',
        'Still to add',
        'Ask while we can',
        'Ask',
        'No recording yet',
        'Made by',
        'There now',
        'Why',
        'How ours goes',
      ];
      for (final s in mustTranslate) {
        expect(hasNepali(s), isTrue, reason: 'no Nepali for "$s"');
        expect(trS(AppLang.ne, s), isNot(s));
      }
    });
  });
}
