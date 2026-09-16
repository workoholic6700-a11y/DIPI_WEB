import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ==========================================================================
/// VILLAGE WIDGETS — small self-contained pieces for a Nepali hill village.
///
/// Every widget has a const constructor and a fixed intrinsic size (via
/// SizedBox). Plants/trees gently sway using flutter_animate only — no
/// manual AnimationControllers.
///
/// Public widgets:
///   MaizeClump · RicePaddyTuft · Haystack · WoodenFence ·
///   VillageTree · Bush · FlowerCluster · StoneWell
/// ==========================================================================

// Shared palette --------------------------------------------------------------
const _hillFront = Color(0xFF4C8C4C);
const _leafGreen = Color(0xFF5EA05C);
const _leafLight = Color(0xFF7FBE6A);
const _leafBright = Color(0xFF93C97A);
const _wood = Color(0xFF8A5A3C);
const _woodDark = Color(0xFF5E3B26);
const _hay = Color(0xFFE8C85F);
const _hayDark = Color(0xFFC79B3F);
const _paddyWater = Color(0xFFBFE0D8);

// ============================================================================
// 1) MAIZE CLUMP — 3–4 corn stalks with leaves and a cob. ~60px tall.
// ============================================================================
class MaizeClump extends StatelessWidget {
  const MaizeClump({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    final w = height * 0.72;
    return SizedBox(
      width: w,
      height: height,
      child: CustomPaint(painter: _MaizePainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.012,
          end: 0.012,
          duration: 2600.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _MaizePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // three-four stalks at slightly different x/heights
    final stalks = <_Stalk>[
      _Stalk(w * 0.30, h * 0.98, 0.86, -1, hasCob: true),
      _Stalk(w * 0.52, h * 0.99, 1.0, 1, hasCob: false),
      _Stalk(w * 0.72, h * 0.985, 0.80, -1, hasCob: true),
      _Stalk(w * 0.44, h * 0.99, 0.64, 1, hasCob: false),
    ];
    for (final s in stalks) {
      _drawStalk(canvas, w, h, s);
    }
  }

  void _drawStalk(Canvas canvas, double w, double h, _Stalk s) {
    final baseX = s.baseX;
    final baseY = s.baseY;
    final topY = baseY - h * s.tall;
    final topX = baseX + w * 0.05 * s.lean;

    // stem
    final stem = Paint()
      ..color = const Color(0xFF6FA24A)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path()
      ..moveTo(baseX, baseY)
      ..quadraticBezierTo(
          baseX + w * 0.03 * s.lean, (baseY + topY) / 2, topX, topY);
    canvas.drawPath(stemPath, stem);

    // leaves — long drooping blades at intervals
    final leafPaint = Paint()..style = PaintingStyle.fill;
    final nLeaves = 4;
    for (int i = 0; i < nLeaves; i++) {
      final t = 0.25 + i * 0.20;
      final ly = baseY - h * s.tall * t;
      final lx = baseX + w * 0.03 * s.lean * t;
      final dir = (i % 2 == 0) ? -1.0 : 1.0;
      final len = w * (0.34 - i * 0.03);
      final shade = i.isEven ? _leafGreen : _leafLight;
      leafPaint.color = shade;
      final leaf = Path()
        ..moveTo(lx, ly)
        ..quadraticBezierTo(
            lx + len * dir, ly - h * 0.06, lx + len * 1.05 * dir, ly + h * 0.05)
        ..quadraticBezierTo(
            lx + len * 0.55 * dir, ly + h * 0.02, lx, ly + h * 0.015)
        ..close();
      canvas.drawPath(leaf, leafPaint);
    }

    // tassel at top
    final tassel = Paint()
      ..color = const Color(0xFFE7D08C)
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final dx = (i - 1) * w * 0.05;
      canvas.drawLine(Offset(topX, topY),
          Offset(topX + dx, topY - h * 0.08), tassel);
    }

    // cob (husked ear) on some stalks
    if (s.hasCob) {
      final cy = baseY - h * s.tall * 0.52;
      final cx = baseX + w * 0.10 * -s.lean;
      final cob = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy), width: w * 0.14, height: h * 0.18),
        Radius.circular(w * 0.07),
      );
      canvas.drawRRect(cob, Paint()..color = _hay);
      // husk leaf over cob
      canvas.drawPath(
        Path()
          ..moveTo(cx - w * 0.06, cy - h * 0.08)
          ..quadraticBezierTo(cx - w * 0.12, cy + h * 0.02, cx - w * 0.02,
              cy + h * 0.09)
          ..quadraticBezierTo(
              cx - w * 0.02, cy, cx - w * 0.06, cy - h * 0.08)
          ..close(),
        Paint()..color = _leafBright,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Stalk {
  const _Stalk(this.baseX, this.baseY, this.tall, this.lean,
      {required this.hasCob});
  final double baseX;
  final double baseY;
  final double tall;
  final double lean;
  final bool hasCob;
}

// ============================================================================
// 2) RICE PADDY TUFT — bright-green rice sprouts in water. ~40px.
// ============================================================================
class RicePaddyTuft extends StatelessWidget {
  const RicePaddyTuft({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.1,
      height: size,
      child: CustomPaint(painter: _RicePainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.02,
          end: 0.02,
          duration: 2000.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _RicePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // small pool of water
    final pool = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.9), width: w * 0.92, height: h * 0.28);
    canvas.drawOval(pool, Paint()..color = _paddyWater);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.86), width: w * 0.6, height: h * 0.10),
      Paint()..color = const Color(0xFFDFF2EC).withValues(alpha: 0.7),
    );

    // sprout blades — clustered, splaying out
    final rnd = math.Random(7);
    final baseY = h * 0.9;
    final blade = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 14; i++) {
      final bx = w * (0.2 + rnd.nextDouble() * 0.6);
      final spread = (bx - w * 0.5) * 1.3;
      final tipY = baseY - h * (0.5 + rnd.nextDouble() * 0.42);
      final tipX = bx + spread * 0.3 + (rnd.nextDouble() - 0.5) * w * 0.12;
      blade
        ..color = i.isEven ? _leafBright : _leafLight
        ..strokeWidth = w * (0.03 + rnd.nextDouble() * 0.015);
      canvas.drawPath(
        Path()
          ..moveTo(bx, baseY)
          ..quadraticBezierTo((bx + tipX) / 2, (baseY + tipY) / 2 - h * 0.05,
              tipX, tipY),
        blade,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3) HAYSTACK — golden 'parali' haystack. ~70px.
// ============================================================================
class Haystack extends StatelessWidget {
  const Haystack({super.key, this.height = 70});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.95,
      height: height,
      child: CustomPaint(painter: _HaystackPainter()),
    );
  }
}

class _HaystackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // ground shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.96), width: w * 0.9, height: h * 0.12),
      Paint()..color = const Color(0xFF3E6B3A).withValues(alpha: 0.25),
    );

    // central pole poking out top
    canvas.drawLine(
      Offset(cx, h * 0.08),
      Offset(cx, h * 0.3),
      Paint()
        ..color = _woodDark
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round,
    );

    // dome/cone body — rounded haystack
    final body = Path()
      ..moveTo(w * 0.12, h * 0.92)
      ..quadraticBezierTo(w * 0.05, h * 0.5, cx, h * 0.12)
      ..quadraticBezierTo(w * 0.95, h * 0.5, w * 0.88, h * 0.92)
      ..quadraticBezierTo(cx, h, w * 0.12, h * 0.92)
      ..close();
    canvas.drawPath(body, Paint()..color = _hay);

    // shaded right side
    final shade = Path()
      ..moveTo(cx, h * 0.12)
      ..quadraticBezierTo(w * 0.95, h * 0.5, w * 0.88, h * 0.92)
      ..quadraticBezierTo(cx, h, cx, h * 0.9)
      ..lineTo(cx, h * 0.12)
      ..close();
    canvas.drawPath(shade, Paint()..color = _hayDark.withValues(alpha: 0.4));

    // straw texture strokes
    final straw = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    final rnd = math.Random(3);
    for (int i = 0; i < 40; i++) {
      final t = rnd.nextDouble();
      final ang = (rnd.nextDouble() - 0.5) * 0.5;
      final sx = w * (0.15 + rnd.nextDouble() * 0.7);
      final sy = h * (0.2 + t * 0.68);
      final len = h * (0.04 + rnd.nextDouble() * 0.05);
      straw.color = (i % 3 == 0)
          ? _hayDark.withValues(alpha: 0.5)
          : const Color(0xFFF3DE93).withValues(alpha: 0.7);
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + math.sin(ang) * len * 0.4, sy + len),
        straw,
      );
    }

    // rope bands wrapping the stack
    final rope = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..color = _woodDark.withValues(alpha: 0.55);
    for (final ry in [0.45, 0.68]) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.14, h * ry)
          ..quadraticBezierTo(cx, h * (ry + 0.06), w * 0.86, h * ry),
        rope,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 4) WOODEN FENCE — posts + rails. width param.
// ============================================================================
class WoodenFence extends StatelessWidget {
  const WoodenFence({super.key, this.width = 160, this.height = 46});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _FencePainter()),
    );
  }
}

class _FencePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final postW = h * 0.14;
    final nPosts = math.max(2, (w / (h * 0.9)).round());
    final gap = (w - postW) / (nPosts - 1);

    final railPaint = Paint()..color = _wood;
    final railShade = Paint()..color = _woodDark.withValues(alpha: 0.35);

    // two horizontal rails
    for (final ry in [0.4, 0.72]) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(postW * 0.3, h * ry, w - postW * 0.6, h * 0.1),
        Radius.circular(h * 0.05),
      );
      canvas.drawRRect(rr, railPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(postW * 0.3, h * ry + h * 0.06, w - postW * 0.6, h * 0.04),
          Radius.circular(h * 0.02),
        ),
        railShade,
      );
    }

    // posts on top
    for (int i = 0; i < nPosts; i++) {
      final px = postW * 0.5 + i * gap;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(px - postW * 0.5, h * 0.14, postW, h * 0.84),
        Radius.circular(postW * 0.3),
      );
      canvas.drawRRect(rect, railPaint);
      // pointed cap
      canvas.drawPath(
        Path()
          ..moveTo(px - postW * 0.5, h * 0.16)
          ..lineTo(px, h * 0.02)
          ..lineTo(px + postW * 0.5, h * 0.16)
          ..close(),
        railPaint,
      );
      // wood grain highlight
      canvas.drawLine(
        Offset(px - postW * 0.15, h * 0.2),
        Offset(px - postW * 0.15, h * 0.92),
        Paint()
          ..color = const Color(0xFFA9764A).withValues(alpha: 0.5)
          ..strokeWidth = postW * 0.12,
      );
      // right shadow edge
      canvas.drawLine(
        Offset(px + postW * 0.28, h * 0.2),
        Offset(px + postW * 0.28, h * 0.92),
        Paint()
          ..color = _woodDark.withValues(alpha: 0.4)
          ..strokeWidth = postW * 0.14,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 5) VILLAGE TREE — rounded leafy tree with trunk & soft shading. ~120px.
//    variant 0 = broad, 1 = tall, 2 = blossoming.
// ============================================================================
class VillageTree extends StatelessWidget {
  const VillageTree({super.key, this.height = 120, this.variant = 0});

  final double height;
  final int variant;

  @override
  Widget build(BuildContext context) {
    final v = variant % 3;
    final w = v == 1 ? height * 0.62 : height * 0.82;
    return SizedBox(
      width: w,
      height: height,
      child: _SwayCanopy(
        child: CustomPaint(
          size: Size(w, height),
          painter: _TreePainter(v),
        ),
      ),
    );
  }
}

/// Sways only the upper canopy region gently while trunk stays put.
class _SwayCanopy extends StatelessWidget {
  const _SwayCanopy({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.008,
          end: 0.008,
          duration: 3200.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter(this.variant);
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // ground shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.985), width: w * 0.7, height: h * 0.05),
      Paint()..color = const Color(0xFF3E6B3A).withValues(alpha: 0.25),
    );

    // trunk
    final trunkTop = variant == 1 ? h * 0.42 : h * 0.58;
    final trunk = Path()
      ..moveTo(cx - w * 0.06, h * 0.97)
      ..lineTo(cx - w * 0.035, trunkTop)
      ..lineTo(cx + w * 0.035, trunkTop)
      ..lineTo(cx + w * 0.06, h * 0.97)
      ..close();
    canvas.drawPath(trunk, Paint()..color = _wood);
    // trunk shade
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.005, h * 0.97)
        ..lineTo(cx + w * 0.01, trunkTop)
        ..lineTo(cx + w * 0.035, trunkTop)
        ..lineTo(cx + w * 0.06, h * 0.97)
        ..close(),
      Paint()..color = _woodDark.withValues(alpha: 0.45),
    );
    // a couple of branch stubs
    final branch = Paint()
      ..color = _wood
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, trunkTop + h * 0.06),
        Offset(cx - w * 0.14, trunkTop - h * 0.02), branch);
    canvas.drawLine(Offset(cx, trunkTop + h * 0.03),
        Offset(cx + w * 0.14, trunkTop - h * 0.04), branch);

    if (variant == 2) {
      _blossomCanopy(canvas, w, h, cx, trunkTop);
    } else if (variant == 1) {
      _tallCanopy(canvas, w, h, cx, trunkTop);
    } else {
      _broadCanopy(canvas, w, h, cx, trunkTop);
    }
  }

  // cluster of overlapping blobs for a soft leafy mass
  void _blob(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(c, r, Paint()..color = color);
  }

  void _broadCanopy(
      Canvas canvas, double w, double h, double cx, double trunkTop) {
    final cy = h * 0.34;
    // dark base mass
    final blobs = <List<double>>[
      [cx - w * 0.28, cy + h * 0.14, w * 0.26],
      [cx + w * 0.28, cy + h * 0.13, w * 0.26],
      [cx, cy + h * 0.18, w * 0.30],
      [cx - w * 0.18, cy - h * 0.02, w * 0.24],
      [cx + w * 0.18, cy - h * 0.02, w * 0.24],
      [cx, cy - h * 0.08, w * 0.27],
    ];
    for (final b in blobs) {
      _blob(canvas, Offset(b[0], b[1]), b[2], _leafGreen);
    }
    // mid highlights
    for (final b in blobs) {
      _blob(canvas, Offset(b[0] - w * 0.04, b[1] - h * 0.04), b[2] * 0.7,
          _leafLight);
    }
    // top-left sun highlights
    for (final b in blobs.take(4)) {
      _blob(canvas, Offset(b[0] - w * 0.07, b[1] - h * 0.06), b[2] * 0.4,
          _leafBright.withValues(alpha: 0.85));
    }
    _leafTexture(canvas, w, h, cx, cy, w * 0.34, h * 0.24);
  }

  void _tallCanopy(
      Canvas canvas, double w, double h, double cx, double trunkTop) {
    final cy = h * 0.28;
    final blobs = <List<double>>[
      [cx, cy + h * 0.16, w * 0.30],
      [cx - w * 0.16, cy + h * 0.02, w * 0.26],
      [cx + w * 0.16, cy + h * 0.02, w * 0.26],
      [cx, cy - h * 0.06, w * 0.30],
      [cx - w * 0.08, cy - h * 0.18, w * 0.22],
      [cx + w * 0.08, cy - h * 0.20, w * 0.20],
      [cx, cy - h * 0.28, w * 0.18],
    ];
    for (final b in blobs) {
      _blob(canvas, Offset(b[0], b[1]), b[2], _hillFront);
    }
    for (final b in blobs) {
      _blob(canvas, Offset(b[0] - w * 0.04, b[1] - h * 0.04), b[2] * 0.7,
          _leafGreen);
    }
    for (final b in blobs) {
      _blob(canvas, Offset(b[0] - w * 0.06, b[1] - h * 0.06), b[2] * 0.4,
          _leafLight.withValues(alpha: 0.9));
    }
    _leafTexture(canvas, w, h, cx, cy - h * 0.02, w * 0.26, h * 0.3);
  }

  void _blossomCanopy(
      Canvas canvas, double w, double h, double cx, double trunkTop) {
    final cy = h * 0.34;
    final blobs = <List<double>>[
      [cx - w * 0.26, cy + h * 0.12, w * 0.25],
      [cx + w * 0.26, cy + h * 0.12, w * 0.25],
      [cx, cy + h * 0.16, w * 0.29],
      [cx - w * 0.16, cy - h * 0.02, w * 0.23],
      [cx + w * 0.16, cy - h * 0.02, w * 0.23],
      [cx, cy - h * 0.08, w * 0.26],
    ];
    // soft green underlayer
    for (final b in blobs) {
      _blob(canvas, Offset(b[0], b[1]), b[2], _leafLight);
    }
    // blossom pink mass
    const blossom = Color(0xFFF3C3D6);
    const blossomLt = Color(0xFFFBE0EC);
    for (final b in blobs) {
      _blob(canvas, Offset(b[0] - w * 0.02, b[1] - h * 0.03), b[2] * 0.82,
          blossom);
    }
    for (final b in blobs) {
      _blob(canvas, Offset(b[0] - w * 0.06, b[1] - h * 0.06), b[2] * 0.42,
          blossomLt);
    }
    // little flower dots
    final rnd = math.Random(11);
    final dot = Paint()..color = const Color(0xFFE8749E);
    final dotW = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (int i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final rr = rnd.nextDouble() * w * 0.34;
      final px = cx + math.cos(a) * rr;
      final py = cy + h * 0.03 + math.sin(a) * rr * 0.7;
      canvas.drawCircle(Offset(px, py), w * 0.018, i.isEven ? dot : dotW);
    }
  }

  // scattered short curved strokes to suggest leaf clumps
  void _leafTexture(Canvas canvas, double w, double h, double cx, double cy,
      double rx, double ry) {
    final rnd = math.Random(5);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..color = _hillFront.withValues(alpha: 0.35);
    for (int i = 0; i < 30; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = rnd.nextDouble();
      final px = cx + math.cos(a) * rx * d;
      final py = cy + math.sin(a) * ry * d;
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(px, py), width: w * 0.06, height: w * 0.06),
        a,
        1.6,
        false,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 6a) BUSH — small rounded ground foliage.
// ============================================================================
class Bush extends StatelessWidget {
  const Bush({super.key, this.width = 70, this.seed = 0});

  final double width;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final h = width * 0.62;
    return SizedBox(
      width: width,
      height: h,
      child: CustomPaint(painter: _BushPainter(seed)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.006,
          end: 0.006,
          duration: 2800.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _BushPainter extends CustomPainter {
  _BushPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rnd = math.Random(seed + 1);

    // shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.96), width: w * 0.85, height: h * 0.14),
      Paint()..color = const Color(0xFF3E6B3A).withValues(alpha: 0.22),
    );

    final n = 5;
    final base = <Offset>[];
    for (int i = 0; i < n; i++) {
      final bx = w * (0.15 + 0.7 * i / (n - 1));
      final by = h * (0.7 - rnd.nextDouble() * 0.18);
      base.add(Offset(bx, by));
    }
    // dark base
    for (final b in base) {
      canvas.drawCircle(b, w * (0.16 + rnd.nextDouble() * 0.05), Paint()..color = _hillFront);
    }
    // mid green
    for (final b in base) {
      canvas.drawCircle(Offset(b.dx - w * 0.02, b.dy - h * 0.06),
          w * 0.13, Paint()..color = _leafGreen);
    }
    // light highlights top-left
    for (final b in base) {
      canvas.drawCircle(Offset(b.dx - w * 0.04, b.dy - h * 0.11),
          w * 0.07, Paint()..color = _leafLight.withValues(alpha: 0.9));
    }
    // tiny leaf flecks
    final fleck = Paint()..color = _leafBright.withValues(alpha: 0.8);
    for (int i = 0; i < 12; i++) {
      canvas.drawCircle(
        Offset(w * (0.2 + rnd.nextDouble() * 0.6),
            h * (0.3 + rnd.nextDouble() * 0.35)),
        w * 0.015,
        fleck,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 6b) FLOWER CLUSTER — small dots of flowers (pink/yellow/lavender/white).
// ============================================================================
class FlowerCluster extends StatelessWidget {
  const FlowerCluster({super.key, this.width = 60, this.seed = 0});

  final double width;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final h = width * 0.7;
    return SizedBox(
      width: width,
      height: h,
      child: CustomPaint(painter: _FlowerPainter(seed)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.02,
          end: 0.02,
          duration: 2200.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _FlowerPainter extends CustomPainter {
  _FlowerPainter(this.seed);
  final int seed;

  static const _colors = [
    Color(0xFFE8749E), // pink
    Color(0xFFF2C879), // yellow
    Color(0xFFB79BE0), // lavender
    Color(0xFFFFFFFF), // white
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rnd = math.Random(seed + 3);

    // green stems + tuft base
    final stem = Paint()
      ..color = _leafGreen
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;

    final flowers = <_Flower>[];
    final n = 6 + rnd.nextInt(3);
    for (int i = 0; i < n; i++) {
      final fx = w * (0.12 + rnd.nextDouble() * 0.76);
      final fy = h * (0.15 + rnd.nextDouble() * 0.5);
      flowers.add(_Flower(
        Offset(fx, fy),
        _colors[rnd.nextInt(_colors.length)],
        w * (0.05 + rnd.nextDouble() * 0.03),
      ));
    }
    // stems from ground
    for (final f in flowers) {
      canvas.drawLine(
          Offset(f.pos.dx, h * 0.95), Offset(f.pos.dx, f.pos.dy), stem);
    }
    // small leaves on stems
    for (final f in flowers) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(f.pos.dx + w * 0.02, (f.pos.dy + h * 0.9) / 2),
            width: w * 0.05,
            height: w * 0.025),
        Paint()..color = _leafLight,
      );
    }
    // flower heads: 5 petals + center
    for (final f in flowers) {
      _drawFlower(canvas, f, w);
    }
  }

  void _drawFlower(Canvas canvas, _Flower f, double w) {
    final petal = Paint()..color = f.color;
    for (int p = 0; p < 5; p++) {
      final a = p / 5 * math.pi * 2;
      final px = f.pos.dx + math.cos(a) * f.r * 0.7;
      final py = f.pos.dy + math.sin(a) * f.r * 0.7;
      canvas.drawCircle(Offset(px, py), f.r * 0.55, petal);
    }
    // center
    canvas.drawCircle(
        f.pos, f.r * 0.5, Paint()..color = const Color(0xFFF7E27A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Flower {
  const _Flower(this.pos, this.color, this.r);
  final Offset pos;
  final Color color;
  final double r;
}

// ============================================================================
// 7) STONE WELL — round stone well with a little wooden roof.
// ============================================================================
class StoneWell extends StatelessWidget {
  const StoneWell({super.key, this.height = 110});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.9,
      height: height,
      child: CustomPaint(painter: _WellPainter()),
    );
  }
}

class _WellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // ground shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.97), width: w * 0.86, height: h * 0.08),
      Paint()..color = const Color(0xFF3E6B3A).withValues(alpha: 0.25),
    );

    // --- stone drum body ---
    final drumTop = h * 0.5;
    final drumBot = h * 0.94;
    final drumW = w * 0.66;
    final left = cx - drumW / 2;

    final body = Path()
      ..moveTo(left, drumTop)
      ..lineTo(left, drumBot)
      ..quadraticBezierTo(cx, drumBot + h * 0.05, left + drumW, drumBot)
      ..lineTo(left + drumW, drumTop)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFB6B0A4));
    // shaded right
    canvas.drawPath(
      Path()
        ..moveTo(cx, drumTop)
        ..lineTo(cx, drumBot + h * 0.025)
        ..quadraticBezierTo(
            cx + drumW * 0.25, drumBot + h * 0.02, left + drumW, drumBot)
        ..lineTo(left + drumW, drumTop)
        ..close(),
      Paint()..color = const Color(0xFF8C8578).withValues(alpha: 0.45),
    );

    // stone blocks
    final stone = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008
      ..color = const Color(0xFF7C766B).withValues(alpha: 0.6);
    final rnd = math.Random(9);
    for (int row = 0; row < 3; row++) {
      final ry = drumTop + (drumBot - drumTop) * (0.25 + row * 0.28);
      canvas.drawLine(Offset(left, ry), Offset(left + drumW, ry), stone);
      final offset = row.isEven ? 0.0 : drumW * 0.16;
      for (double bx = left + offset; bx < left + drumW; bx += drumW * 0.32) {
        canvas.drawLine(Offset(bx, ry),
            Offset(bx, ry - (drumBot - drumTop) * 0.28), stone);
      }
      // subtle stone shading blobs
      for (int i = 0; i < 2; i++) {
        canvas.drawCircle(
          Offset(left + drumW * (0.2 + rnd.nextDouble() * 0.6),
              ry - (drumBot - drumTop) * 0.14),
          w * 0.02,
          Paint()..color = const Color(0xFFCEC8BC).withValues(alpha: 0.5),
        );
      }
    }

    // --- top rim (opening) ---
    final rimRect = Rect.fromCenter(
        center: Offset(cx, drumTop), width: drumW, height: h * 0.09);
    canvas.drawOval(rimRect, Paint()..color = const Color(0xFF9C968A));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, drumTop), width: drumW * 0.72, height: h * 0.06),
      Paint()..color = const Color(0xFF3B5560),
    );
    // water glint
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - w * 0.06, drumTop),
          width: drumW * 0.3,
          height: h * 0.025),
      Paint()..color = const Color(0xFFCDEDEF).withValues(alpha: 0.7),
    );

    // --- two posts ---
    final post = Paint()..color = _wood;
    final postShade = Paint()..color = _woodDark.withValues(alpha: 0.4);
    final postW = w * 0.05;
    for (final side in [-1.0, 1.0]) {
      final px = cx + side * drumW * 0.42;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(px - postW / 2, h * 0.16, postW, drumTop - h * 0.14),
          Radius.circular(postW * 0.3),
        ),
        post,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(px + postW * 0.1, h * 0.18, postW * 0.35,
              drumTop - h * 0.16),
          Radius.circular(postW * 0.15),
        ),
        postShade,
      );
    }

    // --- roller bar + rope + bucket ---
    canvas.drawLine(
      Offset(cx - drumW * 0.42, h * 0.2),
      Offset(cx + drumW * 0.42, h * 0.2),
      Paint()
        ..color = _woodDark
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round,
    );
    // rope
    canvas.drawLine(
      Offset(cx + w * 0.06, h * 0.2),
      Offset(cx + w * 0.06, h * 0.4),
      Paint()
        ..color = const Color(0xFFB49A6B)
        ..strokeWidth = w * 0.01,
    );
    // bucket
    final bkt = Path()
      ..moveTo(cx + w * 0.02, h * 0.4)
      ..lineTo(cx + w * 0.1, h * 0.4)
      ..lineTo(cx + w * 0.085, h * 0.48)
      ..lineTo(cx + w * 0.035, h * 0.48)
      ..close();
    canvas.drawPath(bkt, Paint()..color = _wood);
    canvas.drawLine(
      Offset(cx + w * 0.02, h * 0.4),
      Offset(cx + w * 0.1, h * 0.4),
      Paint()
        ..color = _woodDark
        ..strokeWidth = w * 0.008,
    );

    // --- pitched wooden roof ---
    final roofPeak = h * 0.02;
    final roofBaseY = h * 0.2;
    final roofHalf = drumW * 0.62;
    final roof = Path()
      ..moveTo(cx, roofPeak)
      ..lineTo(cx + roofHalf, roofBaseY)
      ..lineTo(cx + roofHalf * 0.86, roofBaseY + h * 0.03)
      ..lineTo(cx, roofPeak + h * 0.03)
      ..lineTo(cx - roofHalf * 0.86, roofBaseY + h * 0.03)
      ..lineTo(cx - roofHalf, roofBaseY)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF9A6540));
    // right roof shade
    canvas.drawPath(
      Path()
        ..moveTo(cx, roofPeak)
        ..lineTo(cx + roofHalf, roofBaseY)
        ..lineTo(cx + roofHalf * 0.86, roofBaseY + h * 0.03)
        ..lineTo(cx, roofPeak + h * 0.03)
        ..close(),
      Paint()..color = _woodDark.withValues(alpha: 0.35),
    );
    // roof planks
    final plank = Paint()
      ..color = _woodDark.withValues(alpha: 0.4)
      ..strokeWidth = w * 0.006;
    for (int i = 1; i < 4; i++) {
      final t = i / 4;
      canvas.drawLine(
        Offset(cx - roofHalf * t, roofPeak + (roofBaseY - roofPeak) * t),
        Offset(cx + roofHalf * t, roofPeak + (roofBaseY - roofPeak) * t),
        plank,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}