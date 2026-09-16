import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/core/i18n/l10n.dart';

/// Two Nepali strings on the family composite frame were once saved through a
/// tool that could not write Devanagari, so every letter became `?`. English
/// looked fine and nothing failed — Mummy and Papa would simply have seen rows
/// of question marks. This test fails the build instead.
void main() {
  final devanagari = RegExp(r'[ऀ-ॿ]');

  group('family composite frame', () {
    for (final en in const [
      'Our family portrait',
      'AI-composed from our photos',
    ]) {
      test('"$en" has real Nepali', () {
        expect(hasNepali(en), isTrue);
        final ne = trS(AppLang.ne, en);
        expect(ne, isNot(en));
        expect(ne, matches(devanagari));
        expect(ne, isNot(contains('??')));
      });
    }
  });

  test('no translation table holds a mangled (question-mark) value', () {
    final files = [
      'lib/core/i18n/l10n.dart',
      'lib/core/i18n/l10n_content.dart',
    ];
    final mangled = RegExp(r'''['"][^'"\n]*\?\?[^'"\n]*['"]''');
    for (final path in files) {
      final lines = File(path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        expect(
          mangled.hasMatch(lines[i]),
          isFalse,
          reason:
              '$path:${i + 1} looks like a lost-encoding value: ${lines[i].trim()}',
        );
      }
    }
  });
}
