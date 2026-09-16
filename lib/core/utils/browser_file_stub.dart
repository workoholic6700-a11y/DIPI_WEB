import 'dart:typed_data';

void downloadBytes(Uint8List bytes, String filename, String mimeType) =>
    throw UnsupportedError('Browser downloads are only available on the web');

Future<bool> shareBytes(
  Uint8List bytes,
  String filename,
  String mimeType, {
  String? text,
}) async => false;
