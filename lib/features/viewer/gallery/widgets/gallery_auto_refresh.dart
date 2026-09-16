import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/gallery/gallery_providers.dart';

class GalleryAutoRefresh extends ConsumerStatefulWidget {
  const GalleryAutoRefresh({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<GalleryAutoRefresh> createState() => _GalleryAutoRefreshState();
}

class _GalleryAutoRefreshState extends ConsumerState<GalleryAutoRefresh>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(galleryRepositoryProvider) != null) {
        _start();
        _refresh();
      }
    });
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
  }

  void _refresh() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;
    if (!ref.read(cloudAlbumsProvider).isLoading) {
      ref.invalidate(cloudAlbumsProvider);
    }
    if (!ref.read(cloudPhotosProvider).isLoading) {
      ref.invalidate(cloudPhotosProvider);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed &&
        ref.read(galleryRepositoryProvider) != null) {
      _start();
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
