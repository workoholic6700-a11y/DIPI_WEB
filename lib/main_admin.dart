import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/gallery_access.dart';
import 'features/admin/gallery_admin_screen.dart';

void main() => bootstrap(() => const ProviderScope(child: GalleryAdminApp()));

class GalleryAdminApp extends StatelessWidget {
  const GalleryAdminApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Dear Dipisha · Album Desk',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const Scaffold(
      body: SafeArea(
        child: GalleryAccess(adminOnly: true, child: GalleryAdminScreen()),
      ),
    ),
  );
}
