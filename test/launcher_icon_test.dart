import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// The web copy has no android/ or ios/ folders, so only the source artwork and
// the browser icons are checked here. The phone launcher tests live in DIPI.
void main() {
  test('web icons use the selected pink-dress artwork on white', () {
    final config = File(
      'pubspec.yaml',
    ).readAsStringSync().replaceAll('\r\n', '\n');
    final launcher = config
        .split('flutter_launcher_icons:\n')
        .last
        .split('\nflutter:')
        .first;
    expect(
      launcher,
      contains('image_path: "assets/images/albums/dipisha_13.png"'),
    );
    expect(launcher, isNot(contains('assets/images/family/dipisha.jpg')));
  });

  test('shipped icon sizes keep a white backdrop and visible photo', () {
    for (final path in [
      'assets/images/albums/dipisha_13.png',
      'web/icons/Icon-192.png',
      'web/icons/Icon-512.png',
    ]) {
      final image = img.decodePng(File(path).readAsBytesSync())!;
      expect(image.width, image.height, reason: path);
      for (final point in [
        (0, 0),
        (image.width - 1, 0),
        (0, image.height - 1),
        (image.width - 1, image.height - 1),
      ]) {
        final pixel = image.getPixel(point.$1, point.$2);
        expect(
          [pixel.r, pixel.g, pixel.b].every((c) => c >= 248),
          isTrue,
          reason: '$path has a non-white corner',
        );
        expect(pixel.a, 255, reason: '$path must be opaque');
      }
      final face = image.getPixel(image.width ~/ 2, image.height ~/ 8);
      expect(
        face.r + face.g + face.b,
        lessThan(700),
        reason: '$path must contain the photograph',
      );
    }
  });
}
