import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode.dart';
import 'features/archive/archive_desk_screen.dart';

/// Private, device-local collection entry point for family archive drafts.
///
/// Run separately from the viewer:
///   flutter run -t lib/main_archive.dart
void main() => bootstrap(() => const ProviderScope(child: ArchiveDeskApp()));

class ArchiveDeskApp extends ConsumerWidget {
  const ArchiveDeskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Dear Dipisha · Archive Desk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: const ArchiveDeskScreen(),
    );
  }
}
