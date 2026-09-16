/// Environment configuration.
///
/// Values are injected at build/run time via `--dart-define` so that secrets
/// never live in source control. Example:
///
/// ```
/// flutter run -t lib/main_viewer.dart \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
/// ```
///
/// A `--dart-define-from-file=env.json` file is also supported (see README).
abstract final class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Fail fast in debug if the app was launched without credentials.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get missingConfigMessage =>
      'Supabase credentials are missing. Launch with '
      '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... '
      'or --dart-define-from-file=env.json';
}
