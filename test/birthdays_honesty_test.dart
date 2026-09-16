import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/data/mock/mock_data.dart';

/// mock_data.dart carries three stand-in birthdays for Mummy, Papa and Kopa,
/// and states the rule beside them:
///
///   "no countdown may ever point at one — a wrong birthday in a family album
///    is the one thing this app must not do quietly."
///
/// The Birthdays screen broke that rule for a long time by reading
/// `MockData.birthdays` (all of them) instead of `confirmedBirthdays`, so
/// three invented dates were displayed as fact and one of them could reach the
/// top of the calendar as the next celebration.
///
/// These tests make the rule mechanical, because a comment did not hold it.
void main() {
  group('no invented birthday can be treated as real', () {
    test('confirmedBirthdays excludes every placeholder', () {
      for (final id in MockData.placeholderBirthdays) {
        expect(MockData.confirmedBirthdays.containsKey(id), isFalse,
            reason: '$id has a stand-in date and must never appear in the '
                'confirmed set — countdowns read from that set.');
      }
    });

    test('confirmedBirthdays keeps every real one', () {
      final real = MockData.birthdays.keys
          .where((id) => !MockData.isPlaceholderBirthday(id));
      for (final id in real) {
        expect(MockData.confirmedBirthdays.containsKey(id), isTrue,
            reason: '$id has a date the family gave us; do not drop it.');
      }
      expect(MockData.confirmedBirthdays, isNotEmpty);
    });

    test('the dates the family gave us on 2026-08-05 are exactly these', () {
      // All three came from Diksha in BS and were converted with nepali_utils
      // (tool/convert_bs.dart). Pinned so a future edit can't quietly drift
      // one of them by a day — which hand-conversion very easily does.
      expect(MockData.confirmedBirthdays['f_father'], DateTime(1986, 5, 21),
          reason: 'Papa — जेष्ठ ७, २०४३');
      expect(MockData.confirmedBirthdays['f_mother'], DateTime(1987, 4, 18),
          reason: 'Mummy — बैशाख ५, २०४४');
      expect(MockData.confirmedBirthdays['f_grandpa'], DateTime(1968, 8, 30),
          reason: 'Kopa — भाद्र १५, २०२५');
    });

    test('nothing is a guess any more', () {
      expect(MockData.placeholderBirthdays, isEmpty,
          reason: 'Every date now came from the family. If someone adds a '
              'person whose date nobody knows, put them in this set — never '
              'a plausible-looking stand-in.');
      for (final id in MockData.birthdays.keys) {
        expect(MockData.isPlaceholderBirthday(id), isFalse);
      }
    });

    test('every placeholder still has an entry to fall back on', () {
      // The Celebration Hall lays their seat using the stand-in and marks it
      // "not confirmed"; it needs the value to exist.
      for (final id in MockData.placeholderBirthdays) {
        expect(MockData.birthdays.containsKey(id), isTrue);
      }
    });
  });
}
