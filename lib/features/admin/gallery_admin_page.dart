import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gallery/gallery_providers.dart';
import '../viewer/visitors/garden_visitors.dart';
import 'gallery_access.dart';
import 'gallery_admin_screen.dart';

class GalleryAdminPage extends ConsumerStatefulWidget {
  const GalleryAdminPage({super.key});

  @override
  ConsumerState<GalleryAdminPage> createState() => _GalleryAdminPageState();
}

/// The desk is a workplace: the garden visitors stay outside while it is
/// open, and while anything opened from it sits on top.
class _GalleryAdminPageState extends ConsumerState<GalleryAdminPage> {
  // Read once here; looking it up again in dispose() is not allowed.
  late final VisitorsHoldNotifier _held = ref.read(
    visitorsHeldProvider.notifier,
  );

  @override
  void initState() {
    super.initState();
    final held = _held;
    Future.microtask(() {
      if (mounted) held.hold();
    });
  }

  @override
  void dispose() {
    Future.microtask(_held.release);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(galleryRoleProvider).value == 'admin';
    return Scaffold(
      appBar: isAdmin ? null : AppBar(),
      body: const SafeArea(
        child: GalleryAccess(adminOnly: true, child: GalleryAdminScreen()),
      ),
    );
  }
}
