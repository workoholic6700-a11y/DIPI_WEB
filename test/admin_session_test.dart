import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dear_dipisha/core/config/admin_auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const url = 'https://session-test.supabase.co';
  const savedKey = 'sb-session-test-auth-token';

  test(
    'upgrade removes only the old admin login and never stores a new one',
    () async {
      SharedPreferences.setMockInitialValues({
        savedKey: 'previously remembered session',
        'app_lang': 'ne',
        'home_style': 'room',
        'sb-another-project-auth-token': 'unrelated',
      });
      final storage = adminAuthOptions(url).localStorage!;
      await storage.initialize();
      await storage.persistSession('new session');
      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.accessToken(), isNull);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey(savedKey), isFalse);
      expect(preferences.getString('app_lang'), 'ne');
      expect(preferences.getString('home_style'), 'room');
      expect(
        preferences.getString('sb-another-project-auth-token'),
        'unrelated',
      );
    },
  );

  test(
    'admin stays signed in during use but a new app session starts signed out',
    () async {
      SharedPreferences.setMockInitialValues({});
      Future<Supabase> start() => Supabase.initialize(
        url: url,
        publishableKey: 'test-key',
        authOptions: adminAuthOptions(
          url,
        ).copyWith(detectSessionInUri: false, autoRefreshToken: false),
      );
      var app = await start();
      addTearDown(() async {
        if (Supabase.instance.isInitialized) await Supabase.instance.dispose();
      });
      expect(app.client.auth.currentSession, isNull);
      final expiry =
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;
      String encode(Object value) =>
          base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
      final token =
          '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({'sub': 'test-admin', 'exp': expiry})}.test';
      await app.client.auth.recoverSession(
        jsonEncode({
          'access_token': token,
          'refresh_token': 'test-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'expires_at': expiry,
          'user': {
            'id': 'test-admin',
            'app_metadata': {},
            'user_metadata': {},
            'aud': 'authenticated',
            'created_at': '2026-09-07T00:00:00Z',
          },
        }),
      );
      expect(app.client.auth.currentUser?.id, 'test-admin');
      expect(await adminAuthOptions(url).localStorage!.accessToken(), isNull);
      final binding = TestWidgetsFlutterBinding.instance;
      for (final state in [
        AppLifecycleState.resumed,
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        binding.handleAppLifecycleStateChanged(state);
      }
      expect(app.client.auth.currentUser?.id, 'test-admin');
      await app.dispose();
      app = await start();
      expect(app.client.auth.currentSession, isNull);
      expect(app.client.auth.currentUser, isNull);
    },
  );
}
