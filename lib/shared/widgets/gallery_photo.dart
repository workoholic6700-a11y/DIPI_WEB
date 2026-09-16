import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/gallery/gallery_providers.dart';

class GalleryPhoto extends ConsumerWidget {
  const GalleryPhoto({
    super.key,
    required this.path,
    this.remote = true,
    this.fit = BoxFit.cover,
    this.fallback,
  });
  final String path;
  final bool remote;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missing =
        fallback ??
        const ColoredBox(
          color: Color(0xFFE6D9EE),
          child: Center(child: Icon(Icons.photo_outlined)),
        );
    if (!remote) {
      return Image.asset(path, fit: fit, errorBuilder: (_, _, _) => missing);
    }
    return ref
        .watch(gallerySignedUrlProvider(path))
        .when(
          data: (url) => CachedNetworkImage(
            imageUrl: url,
            cacheKey: path,
            fit: fit,
            placeholder: (_, _) => missing,
            errorWidget: (_, _, _) => missing,
          ),
          loading: () => missing,
          error: (_, _) => missing,
        );
  }
}
