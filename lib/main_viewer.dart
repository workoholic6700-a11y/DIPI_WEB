import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode.dart';
import 'core/web/phone_frame.dart';
import 'features/viewer/visitors/garden_visitors.dart';

/// Entrypoint for **Our Home** — the Rai family storybook.
///
///   flutter run -t lib/main_viewer.dart
void main() => bootstrap(() => const ProviderScope(child: OurHomeApp()));

class OurHomeApp extends ConsumerWidget {
  const OurHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '${AppConstants.appName} · ${AppConstants.familyName}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // AppTheme.dark was fully built and unreachable — `themeMode` was
      // hardcoded to light. It's a remembered choice now, not the system's.
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: appRouter,
      // The bees and butterfly live above every screen of the family app.
      // They let touches through wherever they are not, and the album desk
      // holds them off while it is open.
      builder: (context, child) => PhoneFrame(
        child: Stack(
          fit: StackFit.expand,
          children: [child!, const GardenVisitors()],
        ),
      ),
    );
  }
}
