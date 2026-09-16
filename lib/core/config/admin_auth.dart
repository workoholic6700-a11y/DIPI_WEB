import 'package:supabase_flutter/supabase_flutter.dart';

FlutterAuthClientOptions adminAuthOptions(String url) =>
    FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      localStorage: SessionOnlyAuthStorage(url),
    );

class SessionOnlyAuthStorage extends EmptyLocalStorage {
  const SessionOnlyAuthStorage(this.url);
  final String url;

  @override
  Future<void> initialize() async {
    final previousStorage = SharedPreferencesLocalStorage(
      persistSessionKey:
          'sb-${Uri.parse(url).host.split('.').first}-auth-token',
    );
    await previousStorage.initialize();
    await previousStorage.removePersistedSession();
  }
}
