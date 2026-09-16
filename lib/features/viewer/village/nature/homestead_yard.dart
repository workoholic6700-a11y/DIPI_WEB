import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ============================================================================
/// HOMESTEAD YARD — Eastern-Nepal (Ilam) hill-village compound features.
///
/// Four self-contained, const-constructible widgets rendered purely in Flutter:
///   • [OutsideToilet] — a small humble outhouse set apart from the house.
///   • [FishPond]      — a stone-rimmed pond with shimmer, lily pads & fish.
///   • [PottedGarden]  — a cluster of terracotta pots with bright flowers.
///   • [VegPatch]      — tidy rows of a Nepali kitchen garden.
///
/// No assets, no other packages. Animation only via flutter_animate.
/// ============================================================================

// ----------------------------- shared palette ------------------------------

class _Pal {
  // walls / stone / mud
  static const cream = Color(0xFFEDE3C6);
  static const stone = Color(0xFF9E8A72);
  static const stoneDark = Color(0xFF8A7862);
  static const mud = Color(0xFFB5794A);
  // cement / concrete
  static const cementGrey = Color(0xFFC7C0B4);
  // tin
  static const tinSilver = Color(0xFFAEB6BC);
  static const tinSilverDark = Color(0xFF949CA3);
  static const rustRed = Color(0xFF9A5B44);
  static const rustDark = Color(0xFF7A4636);
  // wood
  static const wood = Color(0xFF8A5A3C);
  static const woodDark = Color(0xFF5E3B26);
  static const frame = Color(0xFF6E4A2E);
  // water
  static const waterLight = Color(0xFF6FB4C4);
  static const waterDark = Color(0xFF3E8CA0);
  static const waterHi = Color(0xFFCDEDEF);
  static const lily = Color(0xFF4E9E5A);
  static const fishOrange = Color(0xFFF2953C);
  static const koiWhite = Color(0xFFF4EFE8);
  // clay / greens
  static const terracotta = Color(0xFFC06B4A);
  static const terracottaDark = Color(0xFFA9552F);
  static const leaf = Color(0xFF5EA05C);
  static const leafDark = Color(0xFF4C8C4C);
  // flowers
  static const marigold = Color(0xFFF2953C);
  static const pink = Color(0xFFE8749E);
  static const yellow = Color(0xFFF2C879);
  static const red = Color(0xFFD2483B);
  static const white = Color(0xFFFFFFFF);
  // vegetables
  static const tomato = Color(0xFFD9483B);
  static const cabbage = Color(0xFF7FB86A);
  static const chili = Color(0xFFC43A2E);
  static const pumpkin = Color(0xFFE7912F);

  static const shadow = Color(0x33000000);
}

// small helper for a soft grounded shadow ellipse
class _GroundShadow extends StatelessWidget {
  const _GroundShadow({required this.width, this.height = 10, this.alpha = 0.2});
  final double width;
  final double height;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
        gradient: RadialGradient(
          colors: [
            Colors.black.withValues(alpha: alpha),
            Colors.black.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 1) OUTSIDE TOILET — a small separate outhouse (~58px wide).
/// ============================================================================
class OutsideToilet extends StatelessWidget {
  const OutsideToilet({super.key, this.size = 58});
  final double size;

  @override
  Widget build(BuildContext context) {
    // Outhouse is tall & narrow: box height ~ 1.5x width.
    final w = size;
    final h = size * 1.55;
    return SizedBox(
      width: w,
      height: h + 8,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: _GroundShadow(width: w * 0.9, height: 9, alpha: 0.22),
          ),
          Positioned(
            bottom: 4,
            child: CustomPaint(
              size: Size(w, h),
              painter: const _OuthousePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OuthousePainter extends CustomPainter {
  const _OuthousePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint();

    // ---- proportions ----
    final roofH = h * 0.16;
    final bodyTop = roofH * 0.72;
    final bodyLeft = w * 0.14;
    final bodyRight = w * 0.86;
    final bodyBottom = h * 0.97;

    // ---- side wall (slight 3/4 view for a corrugated tin look) ----
    final sideRect = Rect.fromLTRB(bodyRight - w * 0.03, bodyTop + h * 0.02,
        bodyRight + w * 0.10, bodyBottom - h * 0.01);
    p.color = _Pal.tinSilverDark;
    canvas.drawRect(sideRect, p);

    // ---- front body (corrugated tin) ----
    final bodyRect = Rect.fromLTRB(bodyLeft, bodyTop, bodyRight, bodyBottom);
    p.color = _Pal.tinSilver;
    canvas.drawRect(bodyRect, p);

    // corrugation vertical ridges on the front
    final ridge = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final ridgeCount = 7;
    for (int i = 1; i < ridgeCount; i++) {
      final x = bodyLeft + (bodyRect.width) * i / ridgeCount;
      ridge.color = _Pal.tinSilverDark.withValues(alpha: 0.55);
      canvas.drawLine(Offset(x, bodyTop + 1), Offset(x, bodyBottom - 1), ridge);
      ridge.color = _Pal.cream.withValues(alpha: 0.20);
      canvas.drawLine(
          Offset(x + 1.1, bodyTop + 1), Offset(x + 1.1, bodyBottom - 1), ridge);
    }
    // corrugation on the side wall too
    for (int i = 1; i < 3; i++) {
      final x = sideRect.left + sideRect.width * i / 3;
      ridge.color = Colors.black.withValues(alpha: 0.18);
      canvas.drawLine(
          Offset(x, sideRect.top + 2), Offset(x, sideRect.bottom - 2), ridge);
    }

    // subtle rust streaks (lived-in)
    final rust = Paint()..color = _Pal.rustRed.withValues(alpha: 0.16);
    canvas.drawRect(
        Rect.fromLTWH(bodyLeft + w * 0.30, bodyBottom - h * 0.20, 3, h * 0.18),
        rust);
    canvas.drawRect(
        Rect.fromLTWH(bodyRight - w * 0.22, bodyBottom - h * 0.14, 2.4, h * 0.13),
        rust..color = _Pal.rustDark.withValues(alpha: 0.14));

    // ---- door (wood plank) ----
    final doorRect = Rect.fromLTRB(
      bodyLeft + w * 0.16,
      bodyTop + h * 0.14,
      bodyRight - w * 0.16,
      bodyBottom - h * 0.01,
    );
    p.color = _Pal.frame;
    canvas.drawRect(doorRect.inflate(1.6), p);
    p.color = _Pal.wood;
    canvas.drawRect(doorRect, p);
    // plank seams
    final seam = Paint()
      ..color = _Pal.woodDark.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (int i = 1; i < 3; i++) {
      final x = doorRect.left + doorRect.width * i / 3;
      canvas.drawLine(
          Offset(x, doorRect.top + 1), Offset(x, doorRect.bottom - 1), seam);
    }
    // little ventilation gap at top of door
    p.color = _Pal.woodDark.withValues(alpha: 0.5);
    canvas.drawRect(
        Rect.fromLTWH(doorRect.left + 2, doorRect.top + 2,
            doorRect.width - 4, 2.4),
        p);
    // latch
    p.color = _Pal.woodDark;
    canvas.drawCircle(
        Offset(doorRect.right - 3, doorRect.center.dy), 1.6, p);

    // ---- roof (single-slope tin, slight overhang) ----
    final roof = Path()
      ..moveTo(bodyLeft - w * 0.06, bodyTop + roofH * 0.30)
      ..lineTo(bodyRight + w * 0.16, bodyTop - roofH * 0.30)
      ..lineTo(bodyRight + w * 0.16, bodyTop - roofH * 0.30 + roofH * 0.62)
      ..lineTo(bodyLeft - w * 0.06, bodyTop + roofH * 0.30 + roofH * 0.62)
      ..close();
    p.color = _Pal.tinSilverDark;
    canvas.drawPath(roof, p);
    // roof top highlight
    final roofTop = Path()
      ..moveTo(bodyLeft - w * 0.06, bodyTop + roofH * 0.30)
      ..lineTo(bodyRight + w * 0.16, bodyTop - roofH * 0.30)
      ..lineTo(bodyRight + w * 0.16, bodyTop - roofH * 0.30 + roofH * 0.28)
      ..lineTo(bodyLeft - w * 0.06, bodyTop + roofH * 0.30 + roofH * 0.28)
      ..close();
    p.color = _Pal.cementGrey.withValues(alpha: 0.7);
    canvas.drawPath(roofTop, p);

    // shading on the left of the body
    p.color = Colors.black.withValues(alpha: 0.06);
    canvas.drawRect(
        Rect.fromLTWH(bodyLeft, bodyTop, w * 0.10, bodyRect.height), p);

    // a bit of grass/dirt at base
    final grass = Paint()..color = _Pal.leafDark.withValues(alpha: 0.55);
    for (int i = 0; i < 5; i++) {
      final gx = bodyLeft - 2 + i * (bodyRect.width + 4) / 5;
      final path = Path()
        ..moveTo(gx, bodyBottom)
        ..quadraticBezierTo(gx + 1.4, bodyBottom - 5, gx + 0.4, bodyBottom - 7);
      canvas.drawPath(
          path,
          grass
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
      grass.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ============================================================================
/// 2) FISH POND — ~150px wide, stone rim, shimmer, lily pads & gliding fish.
/// ============================================================================
class FishPond extends StatelessWidget {
  const FishPond({super.key, this.width = 150});
  final double width;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * 0.64;
    return SizedBox(
      width: w,
      height: h + 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // static base: rim + water + lily pads
          Positioned.fill(
            child: CustomPaint(painter: const _PondBasePainter()),
          ),

          // animated shimmer overlay (soft breathing highlights)
          Positioned.fill(
            child: CustomPaint(painter: const _PondShimmerPainter())
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 1800.ms, curve: Curves.easeInOut)
                .then()
                .fade(begin: 1, end: 0.45, duration: 2400.ms),
          ),

          // ripple ring 1
          _Ripple(
            width: w,
            height: h,
            center: Alignment(-0.15, -0.1),
            maxR: w * 0.16,
            delay: 0.ms,
          ),
          // ripple ring 2
          _Ripple(
            width: w,
            height: h,
            center: Alignment(0.35, 0.25),
            maxR: w * 0.12,
            delay: 1400.ms,
          ),

          // gliding fish
          _GlidingFish(
            pondW: w,
            pondH: h,
            color: _Pal.fishOrange,
            y: h * 0.40,
            fromX: w * 0.24,
            toX: w * 0.70,
            period: 5200.ms,
            scale: 1.0,
          ),
          _GlidingFish(
            pondW: w,
            pondH: h,
            color: _Pal.koiWhite,
            y: h * 0.60,
            fromX: w * 0.68,
            toX: w * 0.30,
            period: 6400.ms,
            scale: 0.82,
          ),
          _GlidingFish(
            pondW: w,
            pondH: h,
            color: _Pal.fishOrange,
            y: h * 0.30,
            fromX: w * 0.60,
            toX: w * 0.42,
            period: 4600.ms,
            scale: 0.7,
          ),
        ],
      ),
    );
  }
}

class _PondBasePainter extends CustomPainter {
  const _PondBasePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint();

    // ground shadow beneath rim
    p.color = _Pal.shadow;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w / 2, h * 0.92), width: w * 0.9, height: h * 0.22),
        p);

    // --- earth / stone rim ---
    final rimRect = Rect.fromCenter(
        center: Offset(w / 2, h / 2), width: w * 0.96, height: h * 0.86);
    p.color = _Pal.stoneDark;
    canvas.drawOval(rimRect, p);
    p.color = _Pal.stone;
    canvas.drawOval(rimRect.deflate(2.2), p);

    // scattered rim stones
    final rng = math.Random(7);
    final rimStone = Paint();
    final cx = w / 2, cy = h / 2;
    final rx = rimRect.width / 2, ry = rimRect.height / 2;
    for (int i = 0; i < 22; i++) {
      final a = (i / 22) * math.pi * 2 + rng.nextDouble() * 0.2;
      final sx = cx + math.cos(a) * (rx - 3);
      final sy = cy + math.sin(a) * (ry - 3);
      final r = 2.4 + rng.nextDouble() * 2.4;
      rimStone.color =
          (i.isEven ? _Pal.stone : _Pal.stoneDark).withValues(alpha: 0.95);
      canvas.drawCircle(Offset(sx, sy), r, rimStone);
      rimStone.color = _Pal.cream.withValues(alpha: 0.30);
      canvas.drawCircle(Offset(sx - 0.7, sy - 0.7), r * 0.4, rimStone);
    }

    // --- water body ---
    final waterRect = rimRect.deflate(w * 0.055);
    final waterGrad = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        radius: 0.95,
        colors: [_Pal.waterLight, _Pal.waterDark],
      ).createShader(waterRect);
    canvas.drawOval(waterRect, waterGrad);

    // depth shading at the bottom of the pond
    p.color = const Color(0xFF2E7183).withValues(alpha: 0.35);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(waterRect.center.dx, waterRect.center.dy + h * 0.10),
            width: waterRect.width * 0.82,
            height: waterRect.height * 0.5),
        p);

    // --- lily pads ---
    _lilyPad(canvas, Offset(w * 0.30, h * 0.42), 12, flower: _Pal.pink);
    _lilyPad(canvas, Offset(w * 0.66, h * 0.55), 15, flower: _Pal.white);
    _lilyPad(canvas, Offset(w * 0.55, h * 0.34), 9, flower: null);
  }

  void _lilyPad(Canvas canvas, Offset c, double r, {Color? flower}) {
    final p = Paint();
    // shadow of pad on water
    p.color = Colors.black.withValues(alpha: 0.10);
    canvas.drawOval(
        Rect.fromCenter(
            center: c.translate(1.5, 1.8), width: r * 2, height: r * 1.5),
        p);
    // pad
    p.color = _Pal.lily;
    canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2, height: r * 1.55), p);
    p.color = _Pal.leafDark.withValues(alpha: 0.9);
    canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 1.5, height: r * 1.15), p);
    // notch (pac-man wedge)
    p.color = _Pal.waterDark;
    final wedge = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + r, c.dy - r * 0.42)
      ..lineTo(c.dx + r, c.dy + r * 0.42)
      ..close();
    canvas.drawPath(wedge, p);
    // pad vein highlight
    p
      ..color = _Pal.lily.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(c, c.translate(-r * 0.7, -r * 0.3), p);
    p.style = PaintingStyle.fill;

    // flower
    if (flower != null) {
      final fc = c.translate(-r * 0.15, -r * 0.35);
      for (int i = 0; i < 6; i++) {
        final a = i / 6 * math.pi * 2;
        final pos = fc.translate(math.cos(a) * r * 0.42, math.sin(a) * r * 0.30);
        p.color = flower;
        canvas.drawOval(
            Rect.fromCenter(center: pos, width: r * 0.42, height: r * 0.28), p);
      }
      p.color = _Pal.yellow;
      canvas.drawCircle(fc, r * 0.22, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PondShimmerPainter extends CustomPainter {
  const _PondShimmerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final waterRect = Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: w * 0.96 - w * 0.11,
        height: h * 0.86 - w * 0.11);
    canvas.save();
    canvas.clipPath(Path()..addOval(waterRect));
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // wavy horizontal highlight strokes
    final rng = math.Random(3);
    for (int i = 0; i < 6; i++) {
      final y = waterRect.top + waterRect.height * (0.15 + i * 0.13);
      final path = Path()..moveTo(waterRect.left, y);
      final segs = 5;
      for (int s = 1; s <= segs; s++) {
        final x = waterRect.left + waterRect.width * s / segs;
        final yy = y + math.sin(s * 1.3 + i) * 2.0;
        path.quadraticBezierTo(
            x - waterRect.width / segs * 0.5,
            yy + (rng.nextDouble() - 0.5) * 2,
            x,
            yy);
      }
      p
        ..color = _Pal.waterHi.withValues(alpha: 0.22 + (i.isEven ? 0.10 : 0))
        ..strokeWidth = 1.3;
      canvas.drawPath(path, p);
    }
    // a bright glint
    p
      ..color = _Pal.waterHi.withValues(alpha: 0.5)
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(waterRect.left + w * 0.16, waterRect.top + h * 0.20),
        Offset(waterRect.left + w * 0.30, waterRect.top + h * 0.20), p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Ripple extends StatelessWidget {
  const _Ripple({
    required this.width,
    required this.height,
    required this.center,
    required this.maxR,
    required this.delay,
  });
  final double width;
  final double height;
  final Alignment center;
  final double maxR;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: maxR * 2,
      height: maxR * 1.4,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.elliptical(maxR, maxR * 0.7)),
        border: Border.all(
            color: _Pal.waterHi.withValues(alpha: 0.7), width: 1.4),
      ),
    );
    return Align(
      alignment: center,
      child: dot
          .animate(onPlay: (c) => c.repeat())
          .scaleXY(
              begin: 0.2,
              end: 1.0,
              duration: 2600.ms,
              delay: delay,
              curve: Curves.easeOut)
          .fadeOut(duration: 2600.ms, delay: delay, curve: Curves.easeIn),
    );
  }
}

class _GlidingFish extends StatelessWidget {
  const _GlidingFish({
    required this.pondW,
    required this.pondH,
    required this.color,
    required this.y,
    required this.fromX,
    required this.toX,
    required this.period,
    required this.scale,
  });
  final double pondW;
  final double pondH;
  final Color color;
  final double y;
  final double fromX;
  final double toX;
  final Duration period;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final facingRight = toX > fromX;
    final fish = SizedBox(
      width: 22 * scale,
      height: 12 * scale,
      child: CustomPaint(
        painter: _FishPainter(color: color, facingRight: facingRight),
      ),
    );
    // position with Align by converting to alignment fractions
    Alignment alignAt(double x) => Alignment(
          (x / pondW) * 2 - 1,
          (y / pondH) * 2 - 1,
        );
    return Align(
      alignment: alignAt(fromX),
      child: fish
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(
              begin: 0,
              end: toX - fromX,
              duration: period,
              curve: Curves.easeInOut)
          .moveY(begin: 0, end: pondH * 0.05, duration: period, curve: Curves.easeInOut),
    );
  }
}

class _FishPainter extends CustomPainter {
  const _FishPainter({required this.color, required this.facingRight});
  final Color color;
  final bool facingRight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (!facingRight) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }
    final p = Paint();
    // soft shadow under fish (in water)
    p.color = Colors.black.withValues(alpha: 0.10);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.45, h * 0.62),
            width: w * 0.7,
            height: h * 0.5),
        p);
    // tail
    p.color = color.withValues(alpha: 0.9);
    final tail = Path()
      ..moveTo(w * 0.06, h * 0.5)
      ..lineTo(w * 0.02, h * 0.20)
      ..lineTo(w * 0.30, h * 0.5)
      ..lineTo(w * 0.02, h * 0.80)
      ..close();
    canvas.drawPath(tail, p);
    // body
    p.color = color;
    canvas.drawOval(
        Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.72, h * 0.64), p);
    // belly highlight
    p.color = _Pal.white.withValues(alpha: 0.28);
    canvas.drawOval(
        Rect.fromLTWH(w * 0.30, h * 0.22, w * 0.5, h * 0.28), p);
    // eye
    p.color = _Pal.woodDark;
    canvas.drawCircle(Offset(w * 0.80, h * 0.44), 1.1, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ============================================================================
/// 3) POTTED GARDEN — ~130px wide cluster of terracotta pots with flowers.
/// ============================================================================
class PottedGarden extends StatelessWidget {
  const PottedGarden({super.key, this.width = 130});
  final double width;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * 0.92;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 2,
            child: _GroundShadow(width: w * 0.92, height: 12, alpha: 0.20),
          ),
          // back-left pot (tall, marigolds)
          Positioned(
            left: w * 0.02,
            bottom: 6,
            child: _FlowerPot(
              potW: w * 0.34,
              potH: h * 0.34,
              flower: _Pal.marigold,
              flower2: _Pal.yellow,
              blooms: 6,
              swayDeg: 1.6,
              swayMs: 3200,
            ),
          ),
          // back-right pot (pink)
          Positioned(
            right: w * 0.03,
            bottom: 10,
            child: _FlowerPot(
              potW: w * 0.30,
              potH: h * 0.30,
              flower: _Pal.pink,
              flower2: _Pal.white,
              blooms: 5,
              swayDeg: 2.0,
              swayMs: 3800,
            ),
          ),
          // front-center pot (big, red + white)
          Positioned(
            bottom: 0,
            child: _FlowerPot(
              potW: w * 0.40,
              potH: h * 0.40,
              flower: _Pal.red,
              flower2: _Pal.white,
              blooms: 7,
              swayDeg: 1.4,
              swayMs: 3000,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowerPot extends StatelessWidget {
  const _FlowerPot({
    required this.potW,
    required this.potH,
    required this.flower,
    required this.flower2,
    required this.blooms,
    required this.swayDeg,
    required this.swayMs,
  });
  final double potW;
  final double potH;
  final Color flower;
  final Color flower2;
  final int blooms;
  final double swayDeg;
  final int swayMs;

  @override
  Widget build(BuildContext context) {
    final foliageH = potH * 1.5;
    final total = potH + foliageH;
    final swaying = SizedBox(
      width: potW * 1.6,
      height: foliageH,
      child: CustomPaint(
        painter: _FoliagePainter(
          flower: flower,
          flower2: flower2,
          blooms: blooms,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -swayDeg / 360,
          end: swayDeg / 360,
          duration: swayMs.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );

    return SizedBox(
      width: potW * 1.6,
      height: total,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          swaying,
          SizedBox(
            width: potW,
            height: potH,
            child: CustomPaint(painter: const _PotPainter()),
          ),
        ],
      ),
    );
  }
}

class _PotPainter extends CustomPainter {
  const _PotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint();

    // pot body (tapered): rim wider than base
    final rimY = h * 0.22;
    final body = Path()
      ..moveTo(w * 0.06, rimY)
      ..lineTo(w * 0.94, rimY)
      ..lineTo(w * 0.82, h)
      ..lineTo(w * 0.18, h)
      ..close();
    p.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_Pal.terracotta, _Pal.terracottaDark],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(body, p);
    p.shader = null;

    // side shade
    p.color = Colors.black.withValues(alpha: 0.10);
    final shade = Path()
      ..moveTo(w * 0.60, rimY)
      ..lineTo(w * 0.94, rimY)
      ..lineTo(w * 0.82, h)
      ..lineTo(w * 0.58, h)
      ..close();
    canvas.drawPath(shade, p);

    // rim band
    p.color = _Pal.terracotta;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, rimY - h * 0.14, w, h * 0.20),
            const Radius.circular(3)),
        p);
    p.color = _Pal.terracottaDark;
    canvas.drawRect(
        Rect.fromLTWH(0, rimY + h * 0.02, w, 1.6), p);
    // rim top highlight
    p.color = _Pal.cream.withValues(alpha: 0.25);
    canvas.drawRect(Rect.fromLTWH(2, rimY - h * 0.12, w - 4, 1.6), p);

    // dark soil at top
    p.color = _Pal.woodDark.withValues(alpha: 0.9);
    canvas.drawOval(
        Rect.fromLTWH(w * 0.10, rimY - h * 0.10, w * 0.80, h * 0.18), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FoliagePainter extends CustomPainter {
  const _FoliagePainter({
    required this.flower,
    required this.flower2,
    required this.blooms,
  });
  final Color flower;
  final Color flower2;
  final int blooms;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseX = w / 2;
    final baseY = h;
    final rng = math.Random(blooms * 13 + 1);
    final p = Paint();

    // stems + leaves
    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    final tips = <Offset>[];
    for (int i = 0; i < blooms; i++) {
      final t = blooms == 1 ? 0.5 : i / (blooms - 1);
      final spread = (t - 0.5) * w * 0.7;
      final topY = h * (0.10 + rng.nextDouble() * 0.30);
      final tip = Offset(baseX + spread, topY);
      tips.add(tip);
      final ctrl = Offset(baseX + spread * 0.4, h * 0.55);
      final path = Path()
        ..moveTo(baseX + spread * 0.15, baseY)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
      stem.color = _Pal.leafDark;
      canvas.drawPath(path, stem);

      // a couple of leaves along stem
      p.color = _Pal.leaf;
      final ly = h * (0.45 + rng.nextDouble() * 0.2);
      final lx = baseX + spread * 0.5;
      _leaf(canvas, p, Offset(lx, ly), 6, (spread > 0 ? 0.6 : -0.6));
      p.color = _Pal.leafDark;
      _leaf(canvas, p, Offset(lx - spread * 0.15, ly + 6), 5,
          (spread > 0 ? -0.4 : 0.4));
    }

    // blooms
    for (int i = 0; i < tips.length; i++) {
      final tip = tips[i];
      final r = 4.5 + rng.nextDouble() * 2.0;
      final petalColor = i.isEven ? flower : flower2;
      // shadow
      p.color = Colors.black.withValues(alpha: 0.08);
      canvas.drawCircle(tip.translate(0.8, 1.0), r + 1, p);
      // petals
      for (int k = 0; k < 7; k++) {
        final a = k / 7 * math.pi * 2 + i;
        final pos = tip.translate(math.cos(a) * r * 0.7, math.sin(a) * r * 0.7);
        p.color = petalColor;
        canvas.drawCircle(pos, r * 0.55, p);
      }
      // center
      p.color = petalColor == _Pal.white
          ? _Pal.yellow
          : (_Pal.woodDark.withValues(alpha: 0.6));
      canvas.drawCircle(tip, r * 0.5, p);
      p.color = _Pal.white.withValues(alpha: 0.35);
      canvas.drawCircle(tip.translate(-r * 0.2, -r * 0.2), r * 0.2, p);
    }
  }

  void _leaf(Canvas canvas, Paint p, Offset c, double len, double dir) {
    final path = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx + dir * len, c.dy - len * 0.5,
          c.dx + dir * len * 1.6, c.dy)
      ..quadraticBezierTo(
          c.dx + dir * len, c.dy + len * 0.5, c.dx, c.dy);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ============================================================================
/// 4) VEG PATCH — ~120px wide tidy rows of a Nepali kitchen garden.
/// ============================================================================
class VegPatch extends StatelessWidget {
  const VegPatch({super.key, this.width = 120});
  final double width;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * 0.86;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 2,
            child: _GroundShadow(width: w * 0.94, height: 12, alpha: 0.18),
          ),
          // soil bed (static)
          Positioned.fill(
            child: CustomPaint(painter: const _VegBedPainter()),
          ),
          // gently swaying plants overlay
          Positioned.fill(
            child: CustomPaint(painter: const _VegPlantsPainter())
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  begin: -0.004,
                  end: 0.004,
                  duration: 3400.ms,
                  curve: Curves.easeInOut,
                  alignment: Alignment.bottomCenter,
                ),
          ),
        ],
      ),
    );
  }
}

class _VegBedPainter extends CustomPainter {
  const _VegBedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint();

    // raised soil bed (rounded trapezoid seen at slight angle)
    final bedTop = h * 0.55;
    final bed = Path()
      ..moveTo(w * 0.08, bedTop)
      ..lineTo(w * 0.92, bedTop)
      ..lineTo(w * 0.99, h * 0.94)
      ..lineTo(w * 0.01, h * 0.94)
      ..close();
    p.color = _Pal.mud;
    canvas.drawPath(bed, p);
    // top face of the bed (lighter tilled soil)
    final topFace = Path()
      ..moveTo(w * 0.08, bedTop)
      ..lineTo(w * 0.92, bedTop)
      ..lineTo(w * 0.86, bedTop - h * 0.10)
      ..lineTo(w * 0.14, bedTop - h * 0.10)
      ..close();
    p.color = const Color(0xFF8A5A38);
    canvas.drawPath(topFace, p);

    // furrow rows on the top face
    final furrow = Paint()
      ..color = _Pal.woodDark.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (int i = 1; i < 3; i++) {
      final y = bedTop - h * 0.10 + (h * 0.10) * i / 3;
      canvas.drawLine(Offset(w * 0.15, y), Offset(w * 0.85, y), furrow);
    }

    // little scattered soil clumps / pebbles
    final rng = math.Random(9);
    for (int i = 0; i < 14; i++) {
      final x = w * (0.12 + rng.nextDouble() * 0.76);
      final y = h * (0.60 + rng.nextDouble() * 0.30);
      p.color = (rng.nextBool() ? _Pal.woodDark : _Pal.stoneDark)
          .withValues(alpha: 0.35);
      canvas.drawCircle(Offset(x, y), 1.0 + rng.nextDouble(), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VegPlantsPainter extends CustomPainter {
  const _VegPlantsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rowY = h * 0.52;

    // ----- Back row: staked tomato plants with red fruit -----
    _tomato(canvas, Offset(w * 0.22, rowY), 1.0);
    _tomato(canvas, Offset(w * 0.46, rowY - h * 0.02), 1.1);

    // chili plant (right back)
    _chili(canvas, Offset(w * 0.74, rowY));

    // ----- Front row: cabbages + pumpkin -----
    final frontY = h * 0.78;
    _cabbage(canvas, Offset(w * 0.20, frontY), 12);
    _cabbage(canvas, Offset(w * 0.44, frontY + 2), 11);
    _pumpkin(canvas, Offset(w * 0.72, frontY + 3));
  }

  // --- tomato plant with a wooden stake ---
  void _tomato(Canvas canvas, Offset base, double s) {
    final p = Paint();
    // stake
    p
      ..color = _Pal.wood
      ..strokeWidth = 2.0 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base.translate(1.5 * s, -26 * s), p);
    p.style = PaintingStyle.fill;

    // foliage clumps
    final leaves = [
      base.translate(-6 * s, -8 * s),
      base.translate(5 * s, -12 * s),
      base.translate(-3 * s, -18 * s),
      base.translate(3 * s, -22 * s),
      base.translate(-4 * s, -24 * s),
    ];
    for (int i = 0; i < leaves.length; i++) {
      p.color = i.isEven ? _Pal.leaf : _Pal.leafDark;
      canvas.drawCircle(leaves[i], (4.5 - i * 0.3) * s, p);
    }
    // tie strings
    p
      ..color = _Pal.cream.withValues(alpha: 0.7)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(base.translate(1.5 * s, -14 * s),
        base.translate(-4 * s, -14 * s), p);
    p.style = PaintingStyle.fill;

    // red tomatoes
    final tomatoes = [
      base.translate(-5 * s, -9 * s),
      base.translate(4 * s, -14 * s),
      base.translate(-2 * s, -19 * s),
    ];
    for (final t in tomatoes) {
      p.color = Colors.black.withValues(alpha: 0.10);
      canvas.drawCircle(t.translate(0.6, 0.8), 2.6 * s, p);
      p.color = _Pal.tomato;
      canvas.drawCircle(t, 2.6 * s, p);
      p.color = _Pal.white.withValues(alpha: 0.5);
      canvas.drawCircle(t.translate(-0.9 * s, -0.9 * s), 0.8 * s, p);
    }
  }

  // --- chili plant with small red chilies ---
  void _chili(Canvas canvas, Offset base) {
    final p = Paint();
    // bushy green
    for (int i = 0; i < 5; i++) {
      final a = i / 5 * math.pi * 2;
      final c = base.translate(math.cos(a) * 6, -10 + math.sin(a) * 6);
      p.color = i.isEven ? _Pal.leaf : _Pal.leafDark;
      canvas.drawCircle(c, 4.5, p);
    }
    p.color = _Pal.leafDark;
    canvas.drawCircle(base.translate(0, -12), 5, p);
    // hanging chilies
    final chilies = [
      base.translate(-4, -8),
      base.translate(3, -6),
      base.translate(5, -12),
    ];
    p
      ..color = _Pal.chili
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (final c in chilies) {
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(c.dx + 1, c.dy + 4, c.dx - 0.5, c.dy + 7);
      canvas.drawPath(path, p);
    }
    p.style = PaintingStyle.fill;
  }

  // --- leafy cabbage ---
  void _cabbage(Canvas canvas, Offset c, double r) {
    final p = Paint();
    // shadow
    p.color = Colors.black.withValues(alpha: 0.10);
    canvas.drawOval(
        Rect.fromCenter(
            center: c.translate(1, 1.5), width: r * 2.2, height: r * 1.2),
        p);
    // outer leaves
    for (int i = 0; i < 7; i++) {
      final a = i / 7 * math.pi * 2;
      final pos = c.translate(math.cos(a) * r * 0.6, math.sin(a) * r * 0.42);
      p.color = _Pal.leafDark;
      canvas.drawOval(
          Rect.fromCenter(center: pos, width: r * 1.1, height: r * 0.8), p);
    }
    // inner head
    p.color = _Pal.cabbage;
    canvas.drawCircle(c.translate(0, -1), r * 0.62, p);
    // vein swirls
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _Pal.leafDark.withValues(alpha: 0.6);
    canvas.drawCircle(c.translate(0, -1), r * 0.4, p);
    canvas.drawCircle(c.translate(0, -1), r * 0.22, p);
    p.style = PaintingStyle.fill;
    // highlight
    p.color = _Pal.white.withValues(alpha: 0.18);
    canvas.drawCircle(c.translate(-r * 0.2, -r * 0.3), r * 0.18, p);
  }

  // --- pumpkin on a vine ---
  void _pumpkin(Canvas canvas, Offset c) {
    final p = Paint();
    // vine
    p
      ..color = _Pal.leafDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final vine = Path()
      ..moveTo(c.dx - 12, c.dy - 2)
      ..quadraticBezierTo(c.dx - 6, c.dy - 8, c.dx, c.dy - 6);
    canvas.drawPath(vine, p);
    // vine leaf
    p
      ..style = PaintingStyle.fill
      ..color = _Pal.leaf;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(c.dx - 12, c.dy - 5), width: 8, height: 6),
        p);

    // pumpkin body shadow
    p.color = Colors.black.withValues(alpha: 0.12);
    canvas.drawOval(
        Rect.fromCenter(
            center: c.translate(1, 2), width: 18, height: 13),
        p);
    // ribbed body
    p.color = _Pal.pumpkin;
    canvas.drawOval(
        Rect.fromCenter(center: c, width: 18, height: 13), p);
    // rib shading
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFCF7A22).withValues(alpha: 0.7);
    for (int i = -1; i <= 1; i++) {
      final path = Path()
        ..moveTo(c.dx + i * 4.5, c.dy - 6)
        ..quadraticBezierTo(
            c.dx + i * 6.5, c.dy, c.dx + i * 4.5, c.dy + 6);
      canvas.drawPath(path, p);
    }
    p.style = PaintingStyle.fill;
    // stem
    p.color = _Pal.leafDark;
    canvas.drawRect(
        Rect.fromCenter(center: c.translate(0, -7), width: 2.4, height: 4), p);
    // highlight
    p.color = _Pal.white.withValues(alpha: 0.22);
    canvas.drawOval(
        Rect.fromCenter(
            center: c.translate(-4, -3), width: 5, height: 3),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}