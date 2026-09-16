import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ===========================================================================
/// ILAM VILLAGE — flora, figures & farm-bird widgets (self-contained).
///
/// A cohesive set of small hand-crafted Flutter widgets for a hilly
/// eastern-Nepal (Ilam) village scene: cardamom & millet crops, banana &
/// assorted trees, a marigold bed, standing villagers and tiny farm birds.
///
/// All shapes are drawn with CustomPainter — no images, no assets. Gentle,
/// slow, cheap sway is added with flutter_animate.
/// ===========================================================================

// Shared palette (matches the wider scene).
const Color _kLeafBack = Color(0xFF3E7540);
const Color _kLeafMid = Color(0xFF4C8C4C);
const Color _kLeafFront = Color(0xFF5EA05C);
const Color _kLeafLight = Color(0xFF7CB874);
const Color _kStem = Color(0xFF6E8B4A);
const Color _kWood = Color(0xFF8A5A3C);
const Color _kWoodDark = Color(0xFF5E3B26);
const Color _kMarigold = Color(0xFFF2953C);
const Color _kMarigoldDeep = Color(0xFFE87A2C);
const Color _kMarigoldYellow = Color(0xFFF2C879);
const Color _kSkinTone = Color(0xFFE7B98F);
const Color _kClothRed = Color(0xFFC0453E);
const Color _kClothBlue = Color(0xFF3E6E8C);
const Color _kTopiCream = Color(0xFFEDE3C6);
const Color _kHair = Color(0xFF2E2320);
const Color _kShadow = Color(0x33203018);

/// Soft contact-shadow ellipse used under most standing objects.
void _paintGroundShadow(Canvas canvas, Offset center, double w, double h) {
  final paint = Paint()
    ..color = _kShadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
  canvas.drawOval(
    Rect.fromCenter(center: center, width: w, height: h),
    paint,
  );
}

/// ===========================================================================
/// 1) CardamomPlant — tall broad-leaved alaichi clump (~70px).
/// ===========================================================================
class CardamomPlant extends StatelessWidget {
  const CardamomPlant({super.key, this.size = 70});

  final double size;

  @override
  Widget build(BuildContext context) {
    final w = size * 0.82;
    return SizedBox(
      width: w,
      height: size,
      child: CustomPaint(painter: const _CardamomPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.012,
          end: 0.012,
          duration: 3400.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _CardamomPainter extends CustomPainter {
  const _CardamomPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseX = w / 2;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(baseX, baseY - 1), w * 0.7, h * 0.06);

    // Several arching pseudostems, each with a long lance-shaped leaf.
    final leafSpecs = <_CardamomLeaf>[
      _CardamomLeaf(-0.9, 0.98, _kLeafBack),
      _CardamomLeaf(0.85, 0.94, _kLeafBack),
      _CardamomLeaf(-0.5, 0.86, _kLeafMid),
      _CardamomLeaf(0.5, 0.9, _kLeafMid),
      _CardamomLeaf(-0.15, 1.0, _kLeafFront),
      _CardamomLeaf(0.2, 0.96, _kLeafFront),
      _CardamomLeaf(0.02, 1.02, _kLeafLight),
    ];

    for (final s in leafSpecs) {
      _drawArchLeaf(canvas, baseX, baseY, w, h, s);
    }

    // Ground-level cardamom pods (the prized spice) as small ochre clusters.
    final podPaint = Paint()..color = const Color(0xFFB98B4E);
    final podShade = Paint()..color = const Color(0xFF8A6636);
    for (int i = 0; i < 5; i++) {
      final px = baseX + (i - 2) * w * 0.09;
      final py = baseY - h * 0.03 - (i.isEven ? h * 0.02 : 0);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py), width: w * 0.09, height: h * 0.05),
        podShade,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(px - 0.4, py - 0.5), width: w * 0.07, height: h * 0.035),
        podPaint,
      );
    }
  }

  void _drawArchLeaf(Canvas canvas, double baseX, double baseY, double w,
      double h, _CardamomLeaf s) {
    final tipX = baseX + s.dir * w * 0.42;
    final tipY = baseY - h * s.len;
    final midX = baseX + s.dir * w * 0.22;
    final midY = baseY - h * s.len * 0.55;

    // Stem.
    final stemPaint = Paint()
      ..color = _kStem
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    final stem = Path()
      ..moveTo(baseX, baseY)
      ..quadraticBezierTo(baseX + s.dir * w * 0.05, midY, midX, midY);
    canvas.drawPath(stem, stemPaint);

    // Broad lance leaf (two curved sides meeting at the tip).
    final leaf = Path()
      ..moveTo(midX, midY)
      ..quadraticBezierTo(
          midX + s.dir * w * 0.02 - w * 0.05, (midY + tipY) / 2, tipX, tipY)
      ..quadraticBezierTo(
          midX + s.dir * w * 0.02 + w * 0.05, (midY + tipY) / 2 + h * 0.03,
          midX, midY)
      ..close();
    canvas.drawPath(leaf, Paint()..color = s.color);

    // Central vein.
    canvas.drawPath(
      Path()
        ..moveTo(midX, midY)
        ..quadraticBezierTo(
            (midX + tipX) / 2, (midY + tipY) / 2 + h * 0.015, tipX, tipY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardamomLeaf {
  const _CardamomLeaf(this.dir, this.len, this.color);
  final double dir;
  final double len;
  final Color color;
}

/// ===========================================================================
/// 2) MilletStalk — clump of finger-millet (kodo) with drooping heads (~64px).
/// ===========================================================================
class MilletStalk extends StatelessWidget {
  const MilletStalk({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final w = size * 0.7;
    return SizedBox(
      width: w,
      height: size,
      child: CustomPaint(painter: const _MilletPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.016,
          end: 0.016,
          duration: 2800.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _MilletPainter extends CustomPainter {
  const _MilletPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseX = w / 2;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(baseX, baseY - 1), w * 0.8, h * 0.06);

    final stalks = <double>[-0.34, -0.1, 0.14, 0.36, 0.0];
    for (int i = 0; i < stalks.length; i++) {
      final off = stalks[i];
      final topX = baseX + off * w + off * w * 0.4;
      final topY = baseY - h * (0.7 + (i % 3) * 0.09);

      // Slender stalk.
      final stalkPaint = Paint()
        ..color = const Color(0xFF9BAF63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()
          ..moveTo(baseX + off * w * 0.4, baseY)
          ..quadraticBezierTo(baseX + off * w * 0.7, (baseY + topY) / 2, topX, topY),
        stalkPaint,
      );

      // A couple of thin blade leaves low on the stalk.
      final bladePaint = Paint()
        ..color = const Color(0xFF7FA64E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round;
      final ly = baseY - h * 0.28;
      canvas.drawPath(
        Path()
          ..moveTo(baseX + off * w * 0.5, ly)
          ..quadraticBezierTo(baseX + off * w - w * 0.18, ly - h * 0.05,
              baseX + off * w - w * 0.28, ly + h * 0.02),
        bladePaint,
      );

      // Drooping finger-like millet head: several short curved "fingers".
      _drawMilletHead(canvas, topX, topY, w, h, off);
    }
  }

  void _drawMilletHead(
      Canvas canvas, double x, double y, double w, double h, double off) {
    final grainPaint = Paint()..color = const Color(0xFFB98A4A);
    final fingerCount = 4;
    for (int f = 0; f < fingerCount; f++) {
      final ang = math.pi * (0.35 + f * 0.16) + off; // fan downward
      final len = h * 0.16;
      final ex = x + math.cos(ang) * len * 0.6;
      final ey = y + math.sin(ang).abs() * len + h * 0.02;
      // Finger core.
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + (ex - x) * 0.4, y + len * 0.3, ex, ey),
        Paint()
          ..color = const Color(0xFF8C6636)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.06
          ..strokeCap = StrokeCap.round,
      );
      // Grain dots along finger.
      for (int g = 0; g < 4; g++) {
        final t = g / 3.0;
        final gx = x + (ex - x) * t;
        final gy = y + (ey - y) * t + math.sin(t * 3) * 0.4;
        canvas.drawCircle(Offset(gx, gy), w * 0.028, grainPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// 3) BananaTree — banana plant with big broad leaves (~110px).
/// ===========================================================================
class BananaTree extends StatelessWidget {
  const BananaTree({super.key, this.size = 110});

  final double size;

  @override
  Widget build(BuildContext context) {
    final w = size * 0.95;
    return SizedBox(
      width: w,
      height: size,
      child: CustomPaint(painter: const _BananaPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.01,
          end: 0.01,
          duration: 4200.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _BananaPainter extends CustomPainter {
  const _BananaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseX = w / 2;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(baseX, baseY - 1), w * 0.5, h * 0.045);

    // Pseudostem trunk.
    final trunk = Path()
      ..moveTo(baseX - w * 0.06, baseY)
      ..lineTo(baseX - w * 0.045, baseY - h * 0.5)
      ..lineTo(baseX + w * 0.045, baseY - h * 0.5)
      ..lineTo(baseX + w * 0.06, baseY)
      ..close();
    canvas.drawPath(trunk, Paint()..color = const Color(0xFF7E9A56));
    canvas.drawPath(
      Path()
        ..moveTo(baseX, baseY)
        ..lineTo(baseX + w * 0.01, baseY - h * 0.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );

    final crownX = baseX;
    final crownY = baseY - h * 0.5;

    // Big banana leaves radiating from the crown, with torn edges & midrib.
    final leaves = <_BananaLeaf>[
      _BananaLeaf(-1.0, -0.15, 0.5, _kLeafBack),
      _BananaLeaf(1.0, -0.2, 0.5, _kLeafBack),
      _BananaLeaf(-0.7, -0.55, 0.48, _kLeafMid),
      _BananaLeaf(0.75, -0.6, 0.48, _kLeafMid),
      _BananaLeaf(-0.25, -0.95, 0.42, _kLeafFront),
      _BananaLeaf(0.3, -0.95, 0.42, _kLeafFront),
      _BananaLeaf(0.02, -1.05, 0.36, _kLeafLight),
    ];
    for (final l in leaves) {
      _drawBananaLeaf(canvas, crownX, crownY, w, h, l);
    }

    // A hanging banana bunch + purple flower.
    final bunchX = crownX + w * 0.14;
    final bunchY = crownY + h * 0.06;
    final bananaPaint = Paint()..color = const Color(0xFFE3C24C);
    for (int i = 0; i < 4; i++) {
      final by = bunchY + i * h * 0.03;
      canvas.drawPath(
        Path()
          ..moveTo(bunchX, by)
          ..quadraticBezierTo(bunchX + w * 0.08, by - h * 0.01,
              bunchX + w * 0.1, by + h * 0.02),
        Paint()
          ..color = bananaPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
        Offset(bunchX + w * 0.02, bunchY + h * 0.14), w * 0.05,
        Paint()..color = const Color(0xFF6E3B57));
  }

  void _drawBananaLeaf(
      Canvas canvas, double cx, double cy, double w, double h, _BananaLeaf l) {
    final tipX = cx + l.dx * w * 0.5;
    final tipY = cy + l.dy * h * l.len;
    final ctrlX = cx + l.dx * w * 0.28;
    final ctrlY = cy + l.dy * h * l.len * 0.45;

    final leaf = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
          ctrlX - l.dx * w * 0.12, ctrlY, tipX, tipY)
      ..quadraticBezierTo(
          ctrlX + l.dx * w * 0.12, ctrlY + h * 0.02, cx, cy)
      ..close();
    canvas.drawPath(leaf, Paint()..color = l.color);

    // Midrib.
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(ctrlX, ctrlY + h * 0.01, tipX, tipY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015,
    );

    // A few lateral vein hints.
    final veinPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008;
    for (int i = 1; i <= 3; i++) {
      final t = i / 4.0;
      final vx = cx + (tipX - cx) * t;
      final vy = cy + (tipY - cy) * t;
      canvas.drawLine(
          Offset(vx, vy), Offset(vx + l.dx * w * 0.06, vy + h * 0.02),
          veinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BananaLeaf {
  const _BananaLeaf(this.dx, this.dy, this.len, this.color);
  final double dx;
  final double dy;
  final double len;
  final Color color;
}

/// ===========================================================================
/// 4) MarigoldRow — bed/row of orange-yellow marigold (sayapatri). width ~90.
/// ===========================================================================
class MarigoldRow extends StatelessWidget {
  const MarigoldRow({super.key, this.width = 90, this.height = 40});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: const _MarigoldRowPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.006,
          end: 0.006,
          duration: 3000.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _MarigoldRowPainter extends CustomPainter {
  const _MarigoldRowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Low mounded green foliage bed.
    final bed = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.68);
    for (double x = 0; x <= w; x += w * 0.16) {
      bed.quadraticBezierTo(
          x + w * 0.08, h * 0.55, x + w * 0.16, h * 0.68);
    }
    bed
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(bed, Paint()..color = const Color(0xFF4C8C4C));
    // Foliage texture flecks.
    final fleck = Paint()..color = const Color(0xFF3E7540);
    for (int i = 0; i < 14; i++) {
      final fx = (i * 53 % 100) / 100 * w;
      final fy = h * 0.7 + (i * 31 % 100) / 100 * h * 0.28;
      canvas.drawCircle(Offset(fx, fy), w * 0.012, fleck);
    }

    // Row of marigold blooms across the bed.
    final n = (w / 16).clamp(4, 9).toInt();
    for (int i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      final cx = t * w;
      final cy = h * (0.5 + (i.isEven ? 0.0 : 0.06));
      final r = w * 0.07;
      _drawMarigold(canvas, cx, cy, r, i.isEven);
    }
  }

  void _drawMarigold(Canvas canvas, double cx, double cy, double r, bool orange) {
    final outer = orange ? _kMarigoldDeep : _kMarigold;
    final inner = orange ? _kMarigold : _kMarigoldYellow;

    // Ruffled pom-pom: two rings of small overlapping petals.
    final outerPaint = Paint()..color = outer;
    for (int i = 0; i < 12; i++) {
      final a = i / 12 * math.pi * 2;
      final px = cx + math.cos(a) * r;
      final py = cy + math.sin(a) * r;
      canvas.drawCircle(Offset(px, py), r * 0.42, outerPaint);
    }
    final innerPaint = Paint()..color = inner;
    for (int i = 0; i < 8; i++) {
      final a = i / 8 * math.pi * 2 + 0.3;
      final px = cx + math.cos(a) * r * 0.55;
      final py = cy + math.sin(a) * r * 0.55;
      canvas.drawCircle(Offset(px, py), r * 0.4, innerPaint);
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.45,
        Paint()..color = _kMarigoldYellow);
    canvas.drawCircle(Offset(cx - r * 0.12, cy - r * 0.12), r * 0.18,
        Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// 5) VillageTree2 — pine / flowering / broadleaf via [variant] (~120px).
///    variant: 0 = conifer pine, 1 = flowering (pink), 2 = round broadleaf.
/// ===========================================================================
class VillageTree2 extends StatelessWidget {
  const VillageTree2({super.key, this.variant = 0, this.size = 120});

  final int variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final w = size * 0.78;
    return SizedBox(
      width: w,
      height: size,
      child: CustomPaint(painter: _VillageTree2Painter(variant % 3)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.008,
          end: 0.008,
          duration: 4600.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _VillageTree2Painter extends CustomPainter {
  const _VillageTree2Painter(this.variant);
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseX = w / 2;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(baseX, baseY - 1), w * 0.6, h * 0.05);

    switch (variant) {
      case 0:
        _paintPine(canvas, w, h, baseX, baseY);
        break;
      case 1:
        _paintFlowering(canvas, w, h, baseX, baseY);
        break;
      default:
        _paintBroadleaf(canvas, w, h, baseX, baseY);
    }
  }

  void _paintTrunk(Canvas canvas, double baseX, double baseY, double w,
      double topFrac, double h) {
    final trunk = Path()
      ..moveTo(baseX - w * 0.045, baseY)
      ..lineTo(baseX - w * 0.02, baseY - h * topFrac)
      ..lineTo(baseX + w * 0.02, baseY - h * topFrac)
      ..lineTo(baseX + w * 0.045, baseY)
      ..close();
    canvas.drawPath(trunk, Paint()..color = _kWood);
    canvas.drawPath(
      Path()
        ..moveTo(baseX + w * 0.005, baseY)
        ..lineTo(baseX + w * 0.012, baseY - h * topFrac),
      Paint()
        ..color = _kWoodDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
  }

  void _paintPine(Canvas canvas, double w, double h, double baseX, double baseY) {
    _paintTrunk(canvas, baseX, baseY, w, 0.2, h);
    // Stacked conical tiers of needled foliage.
    final tiers = 5;
    final topY = baseY - h * 0.98;
    final bottomY = baseY - h * 0.18;
    for (int i = 0; i < tiers; i++) {
      final t = i / (tiers - 1);
      final cy = bottomY + (topY - bottomY) * t;
      final tierW = w * 0.5 * (1 - t * 0.72);
      final tierH = h * 0.2;
      final shade = Color.lerp(_kLeafBack, _kLeafFront, t)!;
      final tier = Path()
        ..moveTo(baseX, cy - tierH)
        ..quadraticBezierTo(baseX - tierW * 0.5, cy - tierH * 0.2,
            baseX - tierW, cy + tierH * 0.2)
        ..quadraticBezierTo(baseX - tierW * 0.4, cy + tierH * 0.1, baseX, cy)
        ..quadraticBezierTo(baseX + tierW * 0.4, cy + tierH * 0.1,
            baseX + tierW, cy + tierH * 0.2)
        ..quadraticBezierTo(baseX + tierW * 0.5, cy - tierH * 0.2, baseX, cy - tierH)
        ..close();
      canvas.drawPath(tier, Paint()..color = shade);
      // Highlight on the sunny side.
      canvas.drawPath(
        Path()
          ..moveTo(baseX, cy - tierH)
          ..quadraticBezierTo(baseX + tierW * 0.5, cy - tierH * 0.2,
              baseX + tierW, cy + tierH * 0.2),
        Paint()
          ..color = _kLeafLight.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.01,
      );
    }
  }

  void _paintFlowering(
      Canvas canvas, double w, double h, double baseX, double baseY) {
    _paintTrunk(canvas, baseX, baseY, w, 0.4, h);
    // A few branches.
    final branchPaint = Paint()
      ..color = _kWood
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    final crownY = baseY - h * 0.45;
    canvas.drawLine(Offset(baseX, baseY - h * 0.3),
        Offset(baseX - w * 0.2, crownY), branchPaint);
    canvas.drawLine(Offset(baseX, baseY - h * 0.3),
        Offset(baseX + w * 0.2, crownY), branchPaint);

    // Soft rounded canopy (green base), then blossom clusters on top.
    final clusters = <Offset>[
      Offset(baseX, crownY - h * 0.16),
      Offset(baseX - w * 0.24, crownY - h * 0.02),
      Offset(baseX + w * 0.24, crownY - h * 0.04),
      Offset(baseX - w * 0.1, crownY - h * 0.2),
      Offset(baseX + w * 0.12, crownY - h * 0.19),
    ];
    for (final c in clusters) {
      canvas.drawCircle(c, w * 0.2, Paint()..color = _kLeafMid);
    }
    // Pink blossoms scattered over the canopy.
    final blossom = Paint()..color = const Color(0xFFE8749E);
    final blossomLight = Paint()..color = const Color(0xFFF4A9C2);
    final rnd = math.Random(7);
    for (int i = 0; i < 60; i++) {
      final c = clusters[i % clusters.length];
      final ang = rnd.nextDouble() * math.pi * 2;
      final rad = rnd.nextDouble() * w * 0.19;
      final px = c.dx + math.cos(ang) * rad;
      final py = c.dy + math.sin(ang) * rad * 0.9;
      canvas.drawCircle(
          Offset(px, py), w * 0.022, i.isEven ? blossom : blossomLight);
    }
  }

  void _paintBroadleaf(
      Canvas canvas, double w, double h, double baseX, double baseY) {
    _paintTrunk(canvas, baseX, baseY, w, 0.36, h);
    final crownCy = baseY - h * 0.6;
    // Big irregular round canopy from overlapping blobs, layered for depth.
    final blobs = <_Blob>[
      _Blob(-0.28, 0.12, 0.26, _kLeafBack),
      _Blob(0.3, 0.14, 0.26, _kLeafBack),
      _Blob(0.0, 0.28, 0.28, _kLeafBack),
      _Blob(-0.16, -0.04, 0.26, _kLeafMid),
      _Blob(0.18, -0.02, 0.26, _kLeafMid),
      _Blob(0.0, -0.18, 0.24, _kLeafFront),
      _Blob(-0.22, -0.14, 0.18, _kLeafFront),
      _Blob(0.12, -0.2, 0.16, _kLeafLight),
    ];
    for (final b in blobs) {
      canvas.drawCircle(
        Offset(baseX + b.dx * w, crownCy + b.dy * h),
        w * b.r,
        Paint()..color = b.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Blob {
  const _Blob(this.dx, this.dy, this.r, this.color);
  final double dx;
  final double dy;
  final double r;
  final Color color;
}

/// ===========================================================================
/// 6) Villager — simple standing Nepali figure (~46px).
///    variant: 0 = woman (sari/pharia + red), 1 = man (dhaka-topi),
///             2 = child.  Gentle idle sway + soft shadow.
/// ===========================================================================
class Villager extends StatelessWidget {
  const Villager({super.key, this.variant = 0, this.size = 46});

  final int variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final w = size * 0.52;
    return SizedBox(
      width: w,
      height: size,
      child: CustomPaint(painter: _VillagerPainter(variant % 3)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.01,
          end: 0.01,
          duration: 2600.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        )
        .moveY(begin: 0, end: -0.6, duration: 2600.ms, curve: Curves.easeInOut);
  }
}

class _VillagerPainter extends CustomPainter {
  const _VillagerPainter(this.variant);
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(cx, baseY - 1), w * 0.8, h * 0.05);

    switch (variant) {
      case 0:
        _paintWoman(canvas, w, h, cx, baseY);
        break;
      case 1:
        _paintMan(canvas, w, h, cx, baseY);
        break;
      default:
        _paintChild(canvas, w, h, cx, baseY);
    }
  }

  void _head(Canvas canvas, double cx, double cy, double r, {Color? hair}) {
    if (hair != null) {
      canvas.drawCircle(Offset(cx, cy - r * 0.2), r * 1.15, Paint()..color = hair);
    }
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = _kSkinTone);
  }

  void _paintWoman(Canvas canvas, double w, double h, double cx, double baseY) {
    final headR = w * 0.2;
    final headY = baseY - h * 0.82;

    // Long skirt/pharia (flared A-line) in red with a lighter shawl.
    final skirt = Path()
      ..moveTo(cx - w * 0.12, baseY - h * 0.55)
      ..lineTo(cx - w * 0.34, baseY - h * 0.02)
      ..quadraticBezierTo(cx, baseY + h * 0.02, cx + w * 0.34, baseY - h * 0.02)
      ..lineTo(cx + w * 0.12, baseY - h * 0.55)
      ..close();
    canvas.drawPath(skirt, Paint()..color = _kClothRed);
    // Skirt shading fold lines.
    final foldPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawLine(Offset(cx, baseY - h * 0.5), Offset(cx, baseY - h * 0.04),
        foldPaint);
    canvas.drawLine(Offset(cx - w * 0.1, baseY - h * 0.45),
        Offset(cx - w * 0.18, baseY - h * 0.05), foldPaint);

    // Torso / blouse (cholo).
    final torso = Path()
      ..moveTo(cx - w * 0.16, baseY - h * 0.55)
      ..lineTo(cx - w * 0.13, baseY - h * 0.72)
      ..lineTo(cx + w * 0.13, baseY - h * 0.72)
      ..lineTo(cx + w * 0.16, baseY - h * 0.55)
      ..close();
    canvas.drawPath(torso, Paint()..color = _kClothBlue);
    // Shawl (patuka) accent across the waist.
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.17, baseY - h * 0.58, w * 0.34, h * 0.04),
      Paint()..color = _kMarigold,
    );

    // Head with dark hair bun.
    _head(canvas, cx, headY, headR, hair: _kHair);
    canvas.drawCircle(
        Offset(cx + headR * 0.7, headY - headR * 0.2), headR * 0.4,
        Paint()..color = _kHair);
    // Bindi.
    canvas.drawCircle(Offset(cx, headY - headR * 0.1), headR * 0.12,
        Paint()..color = _kClothRed);
  }

  void _paintMan(Canvas canvas, double w, double h, double cx, double baseY) {
    final headR = w * 0.19;
    final headY = baseY - h * 0.82;

    // Legs (daura-suruwal trousers, cream).
    final legPaint = Paint()..color = _kTopiCream;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.14, baseY - h * 0.42, w * 0.11, h * 0.42),
          Radius.circular(w * 0.04)),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + w * 0.03, baseY - h * 0.42, w * 0.11, h * 0.42),
          Radius.circular(w * 0.04)),
      legPaint,
    );

    // Tunic (daura) — off-white overlapping wrap with a colored belt.
    final tunic = Path()
      ..moveTo(cx - w * 0.2, baseY - h * 0.4)
      ..lineTo(cx - w * 0.16, baseY - h * 0.72)
      ..lineTo(cx + w * 0.16, baseY - h * 0.72)
      ..lineTo(cx + w * 0.2, baseY - h * 0.4)
      ..close();
    canvas.drawPath(tunic, Paint()..color = const Color(0xFFEDE3C6));
    // Wrap diagonal.
    canvas.drawLine(Offset(cx - w * 0.16, baseY - h * 0.7),
        Offset(cx + w * 0.14, baseY - h * 0.45),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.02);
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.2, baseY - h * 0.44, w * 0.4, h * 0.05),
      Paint()..color = _kClothRed,
    );

    // Head + dhaka-topi (angled cap).
    _head(canvas, cx, headY, headR, hair: _kHair);
    final topi = Path()
      ..moveTo(cx - headR, headY - headR * 0.5)
      ..quadraticBezierTo(cx - headR * 0.3, headY - headR * 1.5,
          cx + headR * 1.05, headY - headR * 0.9)
      ..quadraticBezierTo(
          cx + headR, headY - headR * 0.3, cx - headR, headY - headR * 0.5)
      ..close();
    canvas.drawPath(topi, Paint()..color = _kTopiCream);
    // Topi pattern flecks.
    final fleck = Paint()..color = _kClothRed.withValues(alpha: 0.5);
    canvas.drawCircle(
        Offset(cx, headY - headR * 0.8), headR * 0.1, fleck);
    canvas.drawCircle(
        Offset(cx + headR * 0.5, headY - headR * 0.75), headR * 0.08, fleck);
  }

  void _paintChild(Canvas canvas, double w, double h, double cx, double baseY) {
    final headR = w * 0.24;
    final headY = baseY - h * 0.66;

    // Short body — bright shirt + little shorts.
    final body = Path()
      ..moveTo(cx - w * 0.14, baseY - h * 0.42)
      ..lineTo(cx - w * 0.11, baseY - h * 0.12)
      ..lineTo(cx + w * 0.11, baseY - h * 0.12)
      ..lineTo(cx + w * 0.14, baseY - h * 0.42)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF4E9E5A));
    // Little legs.
    final legPaint = Paint()..color = _kSkinTone;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.1, baseY - h * 0.14, w * 0.08, h * 0.14),
          Radius.circular(w * 0.03)),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + w * 0.02, baseY - h * 0.14, w * 0.08, h * 0.14),
          Radius.circular(w * 0.03)),
      legPaint,
    );

    _head(canvas, cx, headY, headR, hair: _kHair);
    // Rosy cheeks + smile.
    final cheek = Paint()..color = const Color(0x33E8749E);
    canvas.drawCircle(Offset(cx - headR * 0.5, headY + headR * 0.15),
        headR * 0.2, cheek);
    canvas.drawCircle(Offset(cx + headR * 0.5, headY + headR * 0.15),
        headR * 0.2, cheek);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// 7a) Rooster — small farm bird (~22px) with tiny idle motion.
/// ===========================================================================
class Rooster extends StatelessWidget {
  const Rooster({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.1,
      height: size,
      child: CustomPaint(painter: const _RoosterPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.03,
          end: 0.03,
          duration: 1400.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _RoosterPainter extends CustomPainter {
  const _RoosterPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(w * 0.5, baseY - 0.5), w * 0.7, h * 0.08);

    // Body.
    final bodyColor = const Color(0xFFEFE6D6);
    final body = Path()
      ..moveTo(w * 0.28, baseY - h * 0.2)
      ..quadraticBezierTo(w * 0.05, baseY - h * 0.5, w * 0.35, baseY - h * 0.7)
      ..quadraticBezierTo(w * 0.62, baseY - h * 0.85, w * 0.7, baseY - h * 0.55)
      ..quadraticBezierTo(w * 0.75, baseY - h * 0.25, w * 0.5, baseY - h * 0.2)
      ..close();
    canvas.drawPath(body, Paint()..color = bodyColor);
    // Wing patch.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.3, baseY - h * 0.4)
        ..quadraticBezierTo(w * 0.45, baseY - h * 0.55, w * 0.6, baseY - h * 0.4)
        ..quadraticBezierTo(w * 0.45, baseY - h * 0.32, w * 0.3, baseY - h * 0.4)
        ..close(),
      Paint()..color = const Color(0xFFC98B5A),
    );

    // Tail feathers (arched, dark).
    final tailPaint = Paint()
      ..color = const Color(0xFF5E4636)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.28, baseY - h * 0.5)
          ..quadraticBezierTo(w * (0.05 - i * 0.03), baseY - h * (0.8 + i * 0.1),
              w * (0.18 + i * 0.06), baseY - h * (0.95 + i * 0.05)),
        tailPaint,
      );
    }

    // Head + comb + wattle + beak.
    final headC = Offset(w * 0.66, baseY - h * 0.68);
    canvas.drawCircle(headC, h * 0.16, Paint()..color = bodyColor);
    final comb = Paint()..color = const Color(0xFFD2483B);
    canvas.drawCircle(Offset(headC.dx - h * 0.05, headC.dy - h * 0.18),
        h * 0.06, comb);
    canvas.drawCircle(Offset(headC.dx + h * 0.03, headC.dy - h * 0.2),
        h * 0.05, comb);
    canvas.drawCircle(
        Offset(headC.dx, headC.dy + h * 0.16), h * 0.05, comb); // wattle
    // Beak.
    canvas.drawPath(
      Path()
        ..moveTo(headC.dx + h * 0.14, headC.dy)
        ..lineTo(headC.dx + h * 0.28, headC.dy + h * 0.03)
        ..lineTo(headC.dx + h * 0.14, headC.dy + h * 0.08)
        ..close(),
      Paint()..color = const Color(0xFFE8A33C),
    );
    // Eye.
    canvas.drawCircle(Offset(headC.dx + h * 0.03, headC.dy - h * 0.02),
        h * 0.03, Paint()..color = _kWoodDark);

    // Legs.
    final legPaint = Paint()
      ..color = const Color(0xFFE8A33C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;
    canvas.drawLine(Offset(w * 0.42, baseY - h * 0.2),
        Offset(w * 0.4, baseY - 0.5), legPaint);
    canvas.drawLine(Offset(w * 0.52, baseY - h * 0.2),
        Offset(w * 0.54, baseY - 0.5), legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// 7b) Duck — small farm bird (~22px) with tiny idle motion.
/// ===========================================================================
class Duck extends StatelessWidget {
  const Duck({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.2,
      height: size,
      child: CustomPaint(painter: const _DuckPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -0.5, duration: 1600.ms, curve: Curves.easeInOut)
        .rotate(
          begin: -0.02,
          end: 0.02,
          duration: 1600.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _DuckPainter extends CustomPainter {
  const _DuckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseY = h;

    _paintGroundShadow(canvas, Offset(w * 0.5, baseY - 0.5), w * 0.7, h * 0.08);

    final bodyColor = const Color(0xFFF1EBD9);

    // Plump body.
    final body = Path()
      ..moveTo(w * 0.18, baseY - h * 0.28)
      ..quadraticBezierTo(w * 0.05, baseY - h * 0.6, w * 0.35, baseY - h * 0.65)
      ..quadraticBezierTo(w * 0.7, baseY - h * 0.72, w * 0.7, baseY - h * 0.4)
      ..quadraticBezierTo(w * 0.72, baseY - h * 0.24, w * 0.4, baseY - h * 0.25)
      ..close();
    canvas.drawPath(body, Paint()..color = bodyColor);
    // Upturned tail.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.18, baseY - h * 0.4)
        ..quadraticBezierTo(w * 0.02, baseY - h * 0.5, w * 0.14, baseY - h * 0.58)
        ..close(),
      Paint()..color = const Color(0xFFD8CFBB),
    );
    // Wing line.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, baseY - h * 0.45)
        ..quadraticBezierTo(
            w * 0.45, baseY - h * 0.35, w * 0.6, baseY - h * 0.42),
      Paint()
        ..color = const Color(0xFFCFC5AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round,
    );

    // Long neck + head.
    final neck = Path()
      ..moveTo(w * 0.55, baseY - h * 0.6)
      ..quadraticBezierTo(w * 0.78, baseY - h * 0.7, w * 0.8, baseY - h * 0.9)
      ..quadraticBezierTo(w * 0.68, baseY - h * 0.78, w * 0.62, baseY - h * 0.62)
      ..close();
    canvas.drawPath(neck, Paint()..color = bodyColor);
    final headC = Offset(w * 0.82, baseY - h * 0.9);
    canvas.drawCircle(headC, h * 0.13, Paint()..color = bodyColor);
    // Bill.
    canvas.drawPath(
      Path()
        ..moveTo(headC.dx + h * 0.08, headC.dy - h * 0.02)
        ..quadraticBezierTo(headC.dx + h * 0.32, headC.dy,
            headC.dx + h * 0.28, headC.dy + h * 0.08)
        ..quadraticBezierTo(
            headC.dx + h * 0.14, headC.dy + h * 0.1, headC.dx + h * 0.06,
            headC.dy + h * 0.05)
        ..close(),
      Paint()..color = const Color(0xFFE8A33C),
    );
    // Eye.
    canvas.drawCircle(Offset(headC.dx - h * 0.01, headC.dy - h * 0.02),
        h * 0.025, Paint()..color = _kWoodDark);

    // Little orange feet.
    final footPaint = Paint()
      ..color = const Color(0xFFE8843C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.35, baseY - h * 0.25),
        Offset(w * 0.33, baseY - 0.5), footPaint);
    canvas.drawLine(Offset(w * 0.5, baseY - h * 0.25),
        Offset(w * 0.52, baseY - 0.5), footPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}