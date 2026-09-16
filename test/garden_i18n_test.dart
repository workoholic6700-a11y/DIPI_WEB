import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/core/i18n/l10n.dart';

/// `trS` falls back to the English string when a key isn't in the `_ne` map —
/// which is the right runtime behaviour, but it means a typo'd or re-wrapped
/// key fails **silently**: the screen just stays English and nobody notices.
///
/// These are the exact strings the Flower Garden passes to `trS`. If someone
/// re-flows one of those string literals, this test fails instead of the
/// Nepali quietly disappearing for Mummy and Papa.
void main() {
  const gardenStrings = <String>[
    'Flower Garden',
    'The flowers we grow',
    'Who visits our garden',
    'Our little ones, playing',
    'Who tends it',
    'Every pot in our aagan was carried, filled and watered by somebody who '
        'loves you. Sit a while — the garden is awake.',
    'Nepal\'s national flower. It sets the Ilam hills on fire, red across every '
        'ridge, every spring.',
    'The Tihar flower — we string it into malas for Stubby and Arjun on Kukur '
        'Tihar.',
    'In a clay pot by the door, growing wherever it likes.',
    'Ilam orange — sweet, cold, and best eaten in the winter sun.',
    'guarding the marigolds',
    'watching from behind the pots 🌈',
    'dancing through the pots like she owns them — because she does',
    'Mummy & her girls',
    'Sanchu planted most of these. Three daughters grew up in this aagan beside '
        'them — and Meow supervised.',
    'Dipisha, watering',
    'Every evening, one pot at a time — and a long talk with each flower about '
        'its day.',
  ];

  group('Flower Garden Nepali', () {
    for (final s in gardenStrings) {
      test('"${s.length > 45 ? '${s.substring(0, 45)}…' : s}" translates', () {
        final ne = trS(AppLang.ne, s);
        expect(
          ne,
          isNot(equals(s)),
          reason: 'No Nepali for this exact string — it would silently render '
              'in English. Check the key in l10n.dart `_ne` matches the '
              'literal in flower_garden_screen.dart character for character.',
        );
      });
    }

    test('English mode never translates', () {
      for (final s in gardenStrings) {
        expect(trS(AppLang.en, s), equals(s));
      }
    });
  });
}
