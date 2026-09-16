import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'config/admin_auth.dart';

/// Shared startup routine for both the viewer and admin apps.
///
/// Initializes Flutter bindings, the local Hive cache and the Supabase client
/// before running the given [appBuilder]. If credentials are missing it renders
/// a clear diagnostic instead of crashing on a null client.
Future<void> bootstrap(Widget Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Local key-value cache for offline support (stores model JSON blobs).
  await Hive.initFlutter();

  // Demo mode: if no credentials are supplied, the app still runs on bundled
  // sample data so screens can be developed & previewed without a backend.
  if (!Env.isConfigured) {
    debugPrint(
      'ℹ️  Running in DEMO MODE (no Supabase credentials). '
      '${Env.missingConfigMessage}',
    );
    _isDemoMode = true;
    runApp(appBuilder());
    return;
  }

  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // Accepts both a legacy anon JWT and a new sb_publishable_ key.
      publishableKey: Env.supabaseAnonKey,
      authOptions: adminAuthOptions(Env.supabaseUrl),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.error,
      ),
    );
  } catch (e) {
    debugPrint('⚠️  Supabase init failed, falling back to DEMO MODE: $e');
    _isDemoMode = true;
  }

  runApp(appBuilder());
}

bool _isDemoMode = false;

/// True when the app is running without a live Supabase backend.
bool get isDemoMode => _isDemoMode;

/// Convenience accessor for the initialized Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
