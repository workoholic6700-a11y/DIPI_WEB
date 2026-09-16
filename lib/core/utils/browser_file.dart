/// Hands a file to the browser: a download, or the phone's share sheet.
///
/// The Android app saves photos and postcards through `MainActivity.kt`, which
/// a browser doesn't have. On the web these do the same jobs the browser way.
/// Everywhere else they are never called — callers check `kIsWeb` first.
library;

export 'browser_file_stub.dart' if (dart.library.js_interop) 'browser_file_web.dart';
