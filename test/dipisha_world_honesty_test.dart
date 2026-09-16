import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:dear_dipisha/core/router/app_routes.dart';
import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/features/viewer/dipisha/world/world_map.dart';

/// Dipisha's World is the easiest place for beautiful demonstration content to
/// start looking like family history. These tests keep its two hardest rules
/// mechanical: an empty space stays honest, and only the explicitly approved
/// world film is allowed to loop.
void main() {
  group('nothing is invented', () {
    test('unconfirmed personal collections stay empty', () {
      expect(
        MockData.achievements,
        isEmpty,
        reason: 'Add an achievement only with its real date from Diksha.',
      );
      expect(
        MockData.dreams,
        isEmpty,
        reason: 'A dream belongs here only after Dipisha says it herself.',
      );
      expect(
        MockData.futureMessages,
        isEmpty,
        reason: 'A sealed message exists only after Diksha writes it.',
      );
      expect(
        MockData.surprises,
        isEmpty,
        reason: 'Never seed a gift merely to demonstrate an unlock state.',
      );
    });

    test('the treehouse still leads to Nana letters through the world', () {
      final treehouse = kPlaces.singleWhere(
        (place) => place.kind == PlaceKind.treehouse,
      );
      expect(treehouse.route, Routes.letters);
    });

    test('portal descriptions do not claim complete personal archives', () {
      const forbidden = [
        'every photo',
        'every year of you',
        'every proud thing',
        'notes on everything',
      ];
      for (final place in kPlaces) {
        final blurb = place.blurb?.toLowerCase() ?? '';
        for (final phrase in forbidden) {
          expect(
            blurb,
            isNot(contains(phrase)),
            reason: '${place.label} overclaims what its route contains.',
          );
        }
      }
    });
  });

  group('only the approved world film loops', () {
    test('Dipisha screens have no repeating animation controllers', () {
      final sources = <File>[
        ...Directory('lib/features/viewer/dipisha')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart')),
        File('lib/shared/widgets/scrapbook.dart'),
      ];
      for (final file in sources) {
        final source = file.readAsStringSync();
        expect(
          source,
          isNot(contains('.repeat(')),
          reason: '${file.path} starts a looping animation.',
        );
        expect(
          source,
          isNot(contains('repeat: true')),
          reason: '${file.path} enables a looping animation.',
        );
        final videoLoops = 'setLooping(true)'.allMatches(source).length;
        if (file.path.endsWith('dipisha_world_map_screen.dart')) {
          expect(
            videoLoops,
            1,
            reason: 'The approved world film should be the one exception.',
          );
        } else {
          expect(
            videoLoops,
            0,
            reason: '${file.path} enables an unapproved looping video.',
          );
        }
      }
    });

    test('the exception is recorded as a family decision', () {
      final decisions = File('DECISIONS.md').readAsStringSync();
      expect(decisions, contains('only the world film loops'));
      expect(decisions, contains('assets/videos/dipisha_world.mp4'));
    });
  });

  group('the living world has a safe fallback', () {
    test('the world video and poster are bundled', () {
      final video = File(kWorldVideo);
      final poster = File(kWorldImage);
      expect(video.existsSync(), isTrue, reason: 'world video is missing');
      expect(video.lengthSync(), greaterThan(0));
      expect(
        video.lengthSync(),
        lessThan(16 * 1024 * 1024),
        reason: 'Keep the world clip light enough for the target phone.',
      );
      expect(poster.existsSync(), isTrue, reason: 'fallback poster is missing');

      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/videos/'));
    });

    test('playback is the explicit looping-film exception', () {
      final source = File(
        'lib/features/viewer/dipisha/world/dipisha_world_map_screen.dart',
      ).readAsStringSync();
      expect(source, contains('setLooping(true)'));
      expect(source, contains('Image.asset'));
      expect(source, contains('VideoPlayer(_worldVideo)'));
    });
  });

  group('the honest world speaks Nepali', () {
    test('all current world chrome and gaps are translated', () {
      const strings = [
        'A magical little world, made with love by Nana ✨',
        'Whisper the magic word 🤫',
        'your secret word',
        'psst… any word works in here 💜',
        'Open the door ✨',
        'Made with endless love, by Nana',
        'Double tap to explore',
        'Still to add 💌',
        'Ask Diksha',
        'The milestones Diksha has confirmed',
        'Dreams Dipisha has shared herself',
        'Letters Diksha has written for the years ahead',
        'Real messages, saved for the right day',
        'Waiting for her real stories',
        'A big warm hug',
        'A voice hug can be added after Diksha records it.',
      ];
      for (final string in strings) {
        expect(hasNepali(string), isTrue, reason: 'no Nepali for "$string"');
        expect(trS(AppLang.ne, string), isNot(string));
      }

      for (final place in kPlaces) {
        if (place.blurb case final blurb?) {
          expect(
            hasNepali(blurb),
            isTrue,
            reason: 'no Nepali for ${place.label}: "$blurb"',
          );
        }
      }
    });
  });
}
