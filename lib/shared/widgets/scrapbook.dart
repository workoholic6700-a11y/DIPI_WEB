import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/cover.dart';

/// Shared handwriting style for scrapbook captions & notes.
/// Ink for words written straight onto the page background rather than onto a
/// card.
///
/// Cards in this app keep their warm white in both themes, so text on them can
/// stay dark. Anything written on the *background* has to follow the theme —
/// several handwritten notes were a fixed muted purple and all but vanished
/// once the lamp went off.
Color pageInk(BuildContext context, {bool strong = false}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  if (strong) {
    return dark ? AppColors.lavenderLight : AppColors.purpleMid;
  }
  return dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
}

TextStyle handwriting({
  double fontSize = 16,
  Color color = const Color(0xFF6B5B7B),
  FontWeight weight = FontWeight.w600,
  double height = 1.2,
}) => GoogleFonts.caveat(
  fontSize: fontSize,
  color: color,
  fontWeight: weight,
  height: height,
);

/// A Polaroid-style photo frame with a caption and a gentle tilt — the
/// signature scrapbook element used across the app.
class Polaroid extends StatelessWidget {
  const Polaroid({
    super.key,
    required this.seed,
    this.caption,
    this.rotation = -0.03,
    this.width = 160,
    this.icon,
    this.onTap,
    this.tape = true,
    this.heroTag,
    this.assetPath,
    this.fit = BoxFit.contain,
    this.provenance,
  });

  final int seed;
  final String? caption;
  final double rotation;
  final double width;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool tape;
  final String? heroTag;
  final String? assetPath;
  final BoxFit fit;
  final String? provenance;

  Widget _missingPhoto() => Container(
    decoration: BoxDecoration(gradient: CoverPalette.gradient(seed)),
    alignment: Alignment.center,
    child: const Text('🌸', style: TextStyle(fontSize: 34)),
  );

  void _openPhoto(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF211C26),
          body: SafeArea(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: CloseButton(color: Colors.white),
                ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.asset(
                        assetPath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => _missingPhoto(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (caption != null)
                        Text(
                          caption!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (provenance != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          provenance!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget photo = Container(
      height: width,
      width: width,
      decoration: BoxDecoration(
        gradient: CoverPalette.gradient(seed),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: assetPath == null
          ? Icon(
              icon ?? CoverPalette.icon(seed),
              color: Colors.white.withValues(alpha: 0.85),
              size: 34,
            )
          : ColoredBox(
              color: const Color(0xFFFFFDF8),
              child: Image.asset(
                assetPath!,
                fit: fit,
                errorBuilder: (_, _, _) => _missingPhoto(),
              ),
            ),
    );
    if (heroTag != null) {
      photo = Hero(
        tag: heroTag!,
        child: Material(type: MaterialType.transparency, child: photo),
      );
    }

    final card = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          photo,
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: SizedBox(
                width: width,
                child: Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: handwriting(fontSize: 16),
                ),
              ),
            ),
          if (provenance != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 2),
              child: SizedBox(
                width: width,
                child: Text(
                  provenance!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap ?? (assetPath == null ? null : () => _openPhoto(context)),
      child: Transform.rotate(
        angle: rotation,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            card,
            if (tape)
              Positioned(
                top: -10,
                child: WashiTape(
                  width: width * 0.42,
                  rotation: rotation + 0.02,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A translucent decorative "washi tape" strip.
class WashiTape extends StatelessWidget {
  const WashiTape({
    super.key,
    this.width = 60,
    this.height = 24,
    this.color = AppColors.lavenderLight,
    this.rotation = 0,
  });

  final double width;
  final double height;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          border: Border.symmetric(
            vertical: BorderSide(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
        ),
        child: CustomPaint(painter: _StripePainter(color)),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 3;
    for (double x = -size.height; x < size.width; x += 10) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A little sticky note with a soft shadow and slight tilt.
class StickyNote extends StatelessWidget {
  const StickyNote({
    super.key,
    required this.text,
    this.color = const Color(0xFFFFF3C4),
    this.rotation = 0.02,
    this.width = 160,
    this.emoji,
  });

  final String text;
  final Color color;
  final double rotation;
  final double width;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 20)),
            Text(
              text,
              style: handwriting(
                fontSize: 18,
                height: 1.3,
                color: const Color(0xFF5A4A38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Softly drifting hearts, stars & sparkles used as a subtle background layer
/// behind emotional screens. Non-interactive.
class FloatingParticles extends StatelessWidget {
  const FloatingParticles({
    super.key,
    this.count = 12,
    this.color,
    this.icons = const [
      Icons.favorite_rounded,
      Icons.auto_awesome_rounded,
      Icons.star_rounded,
    ],
  });

  final int count;
  final Color? color;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lavender.withValues(alpha: 0.10);
    final rand = math.Random(7);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            for (var i = 0; i < count; i++)
              Positioned(
                left: rand.nextDouble() * box.maxWidth,
                top: rand.nextDouble() * box.maxHeight,
                child: Icon(
                  icons[i % icons.length],
                  size: 10.0 + rand.nextDouble() * 16,
                  color: c,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A paper-like card surface (subtle warm texture + soft edge).
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFE7DA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB79BE0).withValues(alpha: 0.14),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
