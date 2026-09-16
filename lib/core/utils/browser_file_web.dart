import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Saves [bytes] to the browser's Downloads folder as [filename].
void downloadBytes(Uint8List bytes, String filename, String mimeType) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // The click has already handed the blob to the download; a later revoke
  // just lets the browser free it.
  Future<void>.delayed(
    const Duration(seconds: 30),
    () => web.URL.revokeObjectURL(url),
  );
}

/// Opens the phone's share sheet with the file attached.
///
/// Returns false when this browser can't share files (most desktop browsers)
/// or refused to, so the caller can fall back to a download. Closing the share
/// sheet without choosing anyone counts as handled, not as a failure.
Future<bool> shareBytes(
  Uint8List bytes,
  String filename,
  String mimeType, {
  String? text,
}) async {
  try {
    final file = web.File(
      [bytes.toJS].toJS,
      filename,
      web.FilePropertyBag(type: mimeType),
    );
    final data = web.ShareData(files: [file].toJS);
    if (text != null) data.text = text;
    if (!web.window.navigator.canShare(data)) return false;
    await web.window.navigator.share(data).toDart;
    return true;
  } catch (error) {
    return error.toString().contains('AbortError');
  }
}
