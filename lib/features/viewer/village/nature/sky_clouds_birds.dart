import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ============================================================================
/// DriftingClouds
/// ----------------------------------------------------------------------------
/// Several soft, fluffy, realistic clouds built from many overlapping low-alpha
/// white radial-gradient blobs (NOT rounded rectangles). Each cloud drifts
/// horizontally at its own slow speed via flutter_animate. IgnorePointer so it
/// never blocks touches.
///
/// Place across the sky band (roughly y 0.02–0.42 of the scene). Give it the
/// full sky width and the sky-band height.
/// ============================================================================
class DriftingClouds extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> motion;

  const DriftingClouds({
    super.key,
    required this.width,
    required this.height,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    // Cloud definitions expressed as FRACTIONS of the widget's size so the
    // whole thing scales. Each: horizontal center, vertical center, base
    // radius (as fraction of width), opacity, drift distance & duration.
    final clouds = <_CloudSpec>[
      _CloudSpec(
        cx: 0.14,
        cy: 0.20,
        scale: 0.135,
        opacity: 0.95,
        drift: 0.055,
        seed: 1,
      ),
      _CloudSpec(
        cx: 0.40,
        cy: 0.12,
        scale: 0.100,
        opacity: 0.80,
        drift: 0.045,
        seed: 2,
      ),
      _CloudSpec(
        cx: 0.63,
        cy: 0.28,
        scale: 0.165,
        opacity: 0.92,
        drift: 0.070,
        seed: 3,
      ),
      _CloudSpec(
        cx: 0.83,
        cy: 0.16,
        scale: 0.115,
        opacity: 0.72,
        drift: 0.050,
        seed: 4,
      ),
      _CloudSpec(
        cx: 0.28,
        cy: 0.40,
        scale: 0.085,
        opacity: 0.55,
        drift: 0.035,
        seed: 5,
      ),
      _CloudSpec(
        cx: 0.55,
        cy: 0.46,
        scale: 0.070,
        opacity: 0.48,
        drift: 0.030,
        seed: 6,
      ),
    ];

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final c in clouds)
              Positioned(
                left: c.cx * width - (c.scale * width) * 2.4,
                top: c.cy * height - (c.scale * width) * 0.9,
                child: AnimatedBuilder(
                  animation: motion,
                  child: SizedBox(
                    width: c.scale * width * 4.8,
                    height: c.scale * width * 1.9,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _CloudPainter(
                          radius: c.scale * width,
                          opacity: c.opacity,
                          seed: c.seed,
                        ),
                      ),
                    ),
                  ),
                  builder: (context, child) {
                    final angle = motion.value * math.pi * 2 + c.seed * 0.72;
                    return Transform.translate(
                      offset: Offset(
                        math.sin(angle) * c.drift * width,
                        math.cos(angle * 0.55) * 2.5,
                      ),
                      child: child,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CloudSpec {
  final double cx, cy, scale, opacity, drift;
  final int seed;
  const _CloudSpec({
    required this.cx,
    required this.cy,
    required this.scale,
    required this.opacity,
    required this.drift,
    required this.seed,
  });
}

class _CloudPainter extends CustomPainter {
  final double radius;
  final double opacity;
  final int seed;

  _CloudPainter({
    required this.radius,
    required this.opacity,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    // A cloud = a cluster of blobs. Each blob is drawn as several concentric
    // radial-gradient circles going from near-white core to fully transparent
    // edge, giving very soft, feathered edges.
    final blobs = <_Blob>[
      _Blob(-1.9, 0.35, 0.62),
      _Blob(-1.15, -0.05, 0.92),
      _Blob(-0.35, -0.35, 1.15),
      _Blob(0.45, -0.28, 1.05),
      _Blob(1.25, 0.02, 0.85),
      _Blob(1.95, 0.38, 0.58),
      _Blob(-0.7, 0.30, 0.80),
      _Blob(0.7, 0.32, 0.78),
      _Blob(0.0, 0.10, 1.0),
    ];

    // Soft under-shadow for volume (cool snow-shadow tint), drawn first.
    final shadowPaint = Paint()
      ..color = const Color(0xFFCAD8E6).withValues(alpha: 0.18 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.35);
    for (final b in blobs) {
      final bx = cx + b.dx * radius;
      final by = cy + (b.dy + 0.28) * radius;
      canvas.drawCircle(Offset(bx, by), b.r * radius * 0.9, shadowPaint);
    }

    // Feathered white body: layered radial gradients per blob.
    for (final b in blobs) {
      final bx = cx + b.dx * radius + (rnd.nextDouble() - 0.5) * radius * 0.08;
      final by = cy + b.dy * radius + (rnd.nextDouble() - 0.5) * radius * 0.08;
      final br = b.r * radius;

      final rect = Rect.fromCircle(center: Offset(bx, by), radius: br);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.85 * opacity),
            const Color(0xFFF4F8FB).withValues(alpha: 0.55 * opacity),
            const Color(0xFFFFFFFF).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect);
      canvas.drawCircle(Offset(bx, by), br, paint);
    }

    // Bright sunlit highlight along the upper edge (warm sun-glow tint).
    final hlPaint = Paint()
      ..color = const Color(0xFFFFE9A8).withValues(alpha: 0.22 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.22);
    for (final b in [blobs[2], blobs[3], blobs[8]]) {
      final bx = cx + b.dx * radius;
      final by = cy + (b.dy - 0.18) * radius;
      canvas.drawCircle(Offset(bx, by), b.r * radius * 0.55, hlPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}

class _Blob {
  final double dx, dy, r;
  const _Blob(this.dx, this.dy, this.r);
}

/// ============================================================================
/// BirdFlock
/// ----------------------------------------------------------------------------
/// A few distant birds drawn as soft "M"/shallow-V wing strokes. They gently
/// flap (subtle vertical bob) and slowly glide across. Fixed small size.
///
/// Place high in the sky, e.g. y ~ 0.12–0.22 of the scene, off toward one side.
/// ============================================================================
class BirdFlock extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> motion;

  const BirdFlock({
    super.key,
    this.width = 140,
    this.height = 60,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: motion,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(width, height),
            painter: _BirdFlockPainter(),
          ),
        ),
        builder: (context, child) {
          final angle = motion.value * math.pi * 2;
          return Transform.translate(
            offset: Offset(
              math.sin(angle) * width * 0.12,
              math.sin(angle * 4) * height * 0.06,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _BirdFlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Each bird: center (fraction), size (fraction of width), wing droop.
    final birds = <_BirdSpec>[
      _BirdSpec(0.22, 0.40, 0.20, 0.9),
      _BirdSpec(0.44, 0.28, 0.16, 0.75),
      _BirdSpec(0.60, 0.52, 0.14, 0.68),
      _BirdSpec(0.78, 0.34, 0.12, 0.6),
      _BirdSpec(0.90, 0.60, 0.10, 0.5),
    ];

    for (final b in birds) {
      final cx = b.cx * w;
      final cy = b.cy * h;
      final span = b.span * w;
      final droop = span * 0.42; // how far wingtips sit below the shoulder

      // Soft, distant bird colour — a muted slate that reads against sky.
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(1.2, span * 0.09)
        ..color = const Color(0xFF6E8FA2).withValues(alpha: b.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);

      // A shallow "M": left wingtip up, dip to shoulder, small body peak,
      // dip, right wingtip up — drawn with smooth quadratic curves.
      final path = Path();
      final leftTip = Offset(cx - span, cy - droop * 0.35);
      final leftMid = Offset(cx - span * 0.5, cy + droop * 0.15);
      final centre = Offset(cx, cy - droop * 0.28);
      final rightMid = Offset(cx + span * 0.5, cy + droop * 0.15);
      final rightTip = Offset(cx + span, cy - droop * 0.35);

      path.moveTo(leftTip.dx, leftTip.dy);
      path.quadraticBezierTo(
        cx - span * 0.72,
        cy + droop * 0.05,
        leftMid.dx,
        leftMid.dy,
      );
      path.quadraticBezierTo(
        cx - span * 0.22,
        cy - droop * 0.10,
        centre.dx,
        centre.dy,
      );
      path.quadraticBezierTo(
        cx + span * 0.22,
        cy - droop * 0.10,
        rightMid.dx,
        rightMid.dy,
      );
      path.quadraticBezierTo(
        cx + span * 0.72,
        cy + droop * 0.05,
        rightTip.dx,
        rightTip.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BirdFlockPainter oldDelegate) => false;
}

class _BirdSpec {
  final double cx, cy, span, opacity;
  const _BirdSpec(this.cx, this.cy, this.span, this.opacity);
}
