import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import 'package:dear_dipisha/shared/widgets/lottie_art.dart';

/// Guards the Lottie art.
///
/// A Lottie only fails at *runtime*, and a JSON that references external images
/// (`"e":0`) silently renders **blank** — which is how a page ends up quietly
/// empty on Dipisha's phone. These tests catch both at CI time.
void main() {
  const assets = <String>[
    Anim.cherryBlossom,
    Anim.bloomingFlowers,
    Anim.flowerGrowing,
    Anim.flowerPetals,
    Anim.treeInWind,
    Anim.walkingPothos,
    Anim.girlWateringPlants,
    Anim.walkingOrange,
    Anim.honeyBee,
    Anim.butterfly,
    Anim.butterflyOrange,
    Anim.cutePig,
    Anim.happyBird,
    Anim.parrot,
    Anim.birdPairLove,
    Anim.heartValleyBirds,
    Anim.danceCat,
    Anim.cuteDoggie,
    Anim.dogPeeking,
    Anim.bunniesCuddle,
    Anim.catCrying,
    Anim.momAndKids,
    Anim.girlCycling,
  ];

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lottie assets', () {
    for (final path in assets) {
      test('$path parses and has no missing external images', () async {
        final raw = await rootBundle.loadString(path);
        final json = jsonDecode(raw) as Map<String, dynamic>;

        // Every image asset must be inlined (e == 1). e == 0 means the file
        // points at an images/ folder we do not ship -> renders blank.
        final images = (json['assets'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .where((a) => a.containsKey('p'));
        final external = images.where((a) => a['e'] != 1).toList();
        expect(
          external,
          isEmpty,
          reason: '$path references ${external.length} external image(s) '
              '(e:0) that are not bundled — it would render blank.',
        );

        // And it must actually decode as a Lottie composition.
        final composition = await LottieComposition.fromByteData(
          ByteData.sublistView(Uint8List.fromList(utf8.encode(raw))),
        );
        expect(composition.duration.inMilliseconds, greaterThan(0),
            reason: '$path decoded to a zero-length animation.');
      });
    }
  });
}
