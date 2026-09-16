import 'package:flutter/material.dart';

import '../../data/models/cover.dart';

/// A pretty gradient placeholder standing in for a real photo during the UI
/// phase. Shows a soft decorative icon and an optional label. When Phase 2
/// lands, this is swapped for a `CachedNetworkImage` with this as the loader.
class GradientCover extends StatelessWidget {
  const GradientCover({
    super.key,
    required this.seed,
    this.icon,
    this.label,
    this.borderRadius,
    this.aspectRatio,
    this.height,
    this.showSparkle = true,
    this.asset,
    this.fit = BoxFit.cover,
  });

  final int seed;
  final IconData? icon;
  final String? label;
  final BorderRadius? borderRadius;
  final double? aspectRatio;
  final double? height;
  final bool showSparkle;

  /// Optional real photo asset path. When the named file exists it is shown
  /// (cropped to fill); otherwise this gracefully falls back to the gradient
  /// placeholder — so screens can reference a slot before the file is uploaded.
  final String? asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        gradient: CoverPalette.gradient(seed),
        borderRadius: borderRadius,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showSparkle)
            Positioned(
              right: 12,
              top: 12,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          Center(
            child: Icon(
              icon ?? CoverPalette.icon(seed),
              size: 40,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (label != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );

    // When a real photo slot is provided, show it filling the cover and fall
    // back to the gradient placeholder if that file isn't present yet.
    if (asset != null && asset!.isNotEmpty) {
      final placeholder = content;
      content = Image.asset(
        asset!,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }
    if (aspectRatio != null) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    } else if (height != null) {
      content = SizedBox(
        height: height,
        width: double.infinity,
        child: content,
      );
    }
    return content;
  }
}
