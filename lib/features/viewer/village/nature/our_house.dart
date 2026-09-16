import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// OurHouse — a detailed, warm, traditional EASTERN-NEPAL RAI HILL HOUSE.
///
/// A two-storey mud-ochre / cream-plastered home on a stone base, with a
/// sloped corrugated tin roof, wooden windows + shutters, a wooden door, a
/// small open veranda (pidhi) with wooden posts, a stone-paved yard strip,
/// drying maize & chili under the eaves, a little wooden bench, a soft ground
/// shadow and gentle rising chimney smoke.
///
/// Intrinsic size ~ (height * 1.35) wide by [height] tall. Default 150px tall.
class OurHouse extends StatelessWidget {
  const OurHouse({super.key, this.height = 150});

  final double height;

  @override
  Widget build(BuildContext context) {
    final double width = height * 1.35;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Static house, roof, veranda, yard, details.
          Positioned.fill(
            child: CustomPaint(painter: _HousePainter()),
          ),
          // Soft rising smoke from the chimney (chimney sits near top-left roof).
          Positioned(
            left: width * 0.185,
            top: -height * 0.16,
            width: width * 0.24,
            height: height * 0.42,
            child: const _RisingSmoke(),
          ),
        ],
      ),
    );
  }
}

/// Three soft smoke puffs drifting up and fading — flutter_animate only.
class _RisingSmoke extends StatelessWidget {
  const _RisingSmoke();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _puff(14, 0, 0),
        _puff(11, 900, 8),
        _puff(9, 1800, -6),
      ],
    );
  }

  Widget _puff(double size, int delayMs, double dx) {
    final Widget dot = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEAF3F5).withValues(alpha: 0.55),
        ),
      ),
    );
    return Positioned.fill(
      child: dot
          .animate(
            onPlay: (AnimationController c) => c.repeat(),
            delay: Duration(milliseconds: delayMs),
          )
          .fadeIn(duration: 900.ms, curve: Curves.easeOut)
          .then()
          .moveY(begin: 0, end: -46, duration: 3200.ms, curve: Curves.easeOut)
          .moveX(begin: 0, end: dx, duration: 3200.ms, curve: Curves.easeInOut)
          .scaleXY(begin: 0.5, end: 1.6, duration: 3200.ms)
          .fadeOut(duration: 3200.ms, curve: Curves.easeIn),
    );
  }
}

class _HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;

    // ---- Layout anchors (fractions of the widget box) -----------------------
    // House body occupies the lower-centre; roof overhangs above.
    final double bodyLeft = w * 0.16;
    final double bodyRight = w * 0.80;
    final double bodyBottom = h * 0.90; // yard strip sits below this
    final double bodyTop = h * 0.30; // wall top (roof eaves)
    final double stoneTop = h * 0.72; // stone base band top
    final double storeyLine = h * 0.56; // divider between two storeys

    // ============================ GROUND SHADOW =============================
    p
      ..color = const Color(0xFF3E7A44).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.10, h * 0.90, w * 0.82, h * 0.11),
      p,
    );

    // ============================ STONE YARD STRIP ==========================
    _stoneYard(canvas, p, w, h, bodyLeft, bodyRight, bodyBottom);

    // ============================ WALLS =====================================
    // Upper storey (cream plaster) + lower storey (mud-ochre) + stone base.
    final Rect wallRect =
        Rect.fromLTRB(bodyLeft, bodyTop, bodyRight, bodyBottom);

    // Mud-ochre lower storey base fill.
    p.color = const Color(0xFFC99A5B);
    canvas.drawRect(wallRect, p);

    // Cream-plastered upper storey.
    p.color = const Color(0xFFEDE3C6);
    canvas.drawRect(
      Rect.fromLTRB(bodyLeft, bodyTop, bodyRight, storeyLine),
      p,
    );

    // Subtle vertical light gradient on the cream (sun from left).
    final Rect creamRect =
        Rect.fromLTRB(bodyLeft, bodyTop, bodyRight, storeyLine);
    p.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        const Color(0xFFF6EFD8).withValues(alpha: 0.6),
        const Color(0xFFDFD2AE).withValues(alpha: 0.0),
      ],
    ).createShader(creamRect);
    canvas.drawRect(creamRect, p);
    p.shader = null;

    // Warm shading on the mud-ochre (right side a touch darker).
    final Rect ochreRect =
        Rect.fromLTRB(bodyLeft, storeyLine, bodyRight, stoneTop);
    p.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        const Color(0xFFD7A968).withValues(alpha: 0.5),
        const Color(0xFFB5854A).withValues(alpha: 0.35),
      ],
    ).createShader(ochreRect);
    canvas.drawRect(ochreRect, p);
    p.shader = null;

    // Storey divider line (a thin wooden band / plaster edge).
    p
      ..color = const Color(0xFF8A5A3C).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(bodyLeft, storeyLine - h * 0.012, bodyRight, storeyLine),
      p,
    );
    // cream plaster lip below the divider
    p.color = const Color(0xFFEDE3C6).withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTRB(bodyLeft, storeyLine, bodyRight, storeyLine + h * 0.01),
      p,
    );

    // ============================ STONE BASE ================================
    _stoneBase(canvas, p, bodyLeft, bodyRight, stoneTop, bodyBottom);

    // Wall corner shading for a little 3D volume (right edge in shade).
    p.color = const Color(0xFF5E3B26).withValues(alpha: 0.10);
    canvas.drawRect(
      Rect.fromLTRB(bodyRight - w * 0.03, bodyTop, bodyRight, bodyBottom),
      p,
    );

    // ============================ WINDOWS ===================================
    // Upper storey: two shuttered windows.
    final double uwW = w * 0.11;
    final double uwH = h * 0.15;
    final double uwY = bodyTop + h * 0.055;
    _window(canvas, p, bodyLeft + w * 0.075, uwY, uwW, uwH, shutters: true);
    _window(canvas, p, bodyRight - w * 0.075 - uwW, uwY, uwW, uwH,
        shutters: true);

    // Lower storey: one window on the right of the door.
    final double lwW = w * 0.10;
    final double lwH = h * 0.13;
    _window(canvas, p, bodyRight - w * 0.055 - lwW, storeyLine + h * 0.03, lwW,
        lwH,
        shutters: false);

    // ============================ DOOR + VERANDA ============================
    _door(canvas, p, w, h, bodyLeft, storeyLine, stoneTop);
    _veranda(canvas, p, w, h, bodyLeft, bodyRight, stoneTop, bodyBottom);

    // ============================ ROOF ======================================
    _roof(canvas, p, w, h, bodyLeft, bodyRight, bodyTop);

    // ============================ CHIMNEY ===================================
    _chimney(canvas, p, w, h, bodyLeft);

    // ============================ HANGING DETAILS ===========================
    _dryingCorn(canvas, p, w, h, bodyRight, bodyTop);
    _chiliString(canvas, p, w, h, bodyLeft, bodyTop);

    // ============================ WOODEN BENCH ==============================
    _bench(canvas, p, w, h, bodyRight, bodyBottom);
  }

  // -------------------------------------------------------------------------
  void _stoneYard(Canvas canvas, Paint p, double w, double h, double bodyLeft,
      double bodyRight, double bodyBottom) {
    final Rect yard = Rect.fromLTRB(
        bodyLeft - w * 0.06, bodyBottom, bodyRight + w * 0.10, h * 0.985);
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFB6A88E);
    canvas.drawRRect(
        RRect.fromRectAndRadius(yard, const Radius.circular(3)), p);
    // paving cracks
    p
      ..color = const Color(0xFF9E8A72).withValues(alpha: 0.6)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final double yTop = yard.top + (yard.height * 0.5);
    for (int i = 0; i < 6; i++) {
      final double x = yard.left + yard.width * (i + 0.5) / 6;
      canvas.drawLine(Offset(x, yard.top), Offset(x + 3, yard.bottom), p);
    }
    canvas.drawLine(
        Offset(yard.left, yTop), Offset(yard.right, yTop - 2), p);
    p.style = PaintingStyle.fill;
  }

  void _stoneBase(Canvas canvas, Paint p, double bodyLeft, double bodyRight,
      double stoneTop, double bodyBottom) {
    final Rect base = Rect.fromLTRB(bodyLeft, stoneTop, bodyRight, bodyBottom);
    p.color = const Color(0xFF9E8A72);
    canvas.drawRect(base, p);
    // individual stones (rounded rects in staggered rows)
    final double bw = bodyRight - bodyLeft;
    final double rowH = (bodyBottom - stoneTop) / 2;
    p.color = const Color(0xFF8B7860).withValues(alpha: 0.9);
    final math.Random rnd = math.Random(7);
    for (int row = 0; row < 2; row++) {
      final double y = stoneTop + row * rowH + rowH * 0.16;
      final double offset = row.isEven ? 0 : bw * 0.06;
      for (double x = bodyLeft + 2 + offset;
          x < bodyRight - bw * 0.09;
          x += bw * 0.11) {
        final double sw = bw * 0.09 * (0.8 + rnd.nextDouble() * 0.35);
        final Rect stone =
            Rect.fromLTWH(x, y, sw, rowH * 0.62);
        canvas.drawRRect(
            RRect.fromRectAndRadius(stone, const Radius.circular(3)), p);
      }
    }
    // mortar highlight top edge
    p.color = const Color(0xFFB7A78C).withValues(alpha: 0.5);
    canvas.drawRect(
        Rect.fromLTRB(bodyLeft, stoneTop, bodyRight, stoneTop + 2), p);
  }

  void _window(Canvas canvas, Paint p, double x, double y, double ww,
      double wh, {required bool shutters}) {
    // wooden frame
    final Rect frame = Rect.fromLTWH(x, y, ww, wh);
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF6E4A2E);
    canvas.drawRRect(
        RRect.fromRectAndRadius(frame, const Radius.circular(2)), p);
    // glass / dark interior
    final Rect glass = frame.deflate(ww * 0.08);
    p.color = const Color(0xFF3A4A50);
    canvas.drawRect(glass, p);
    // glass sky reflection
    p.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        const Color(0xFFB8E0EF).withValues(alpha: 0.7),
        const Color(0xFF3A4A50).withValues(alpha: 0.0),
      ],
    ).createShader(glass);
    canvas.drawRect(glass, p);
    p.shader = null;
    // muntins (cross bars)
    p
      ..color = const Color(0xFF6E4A2E)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(glass.center.dx, glass.top),
        Offset(glass.center.dx, glass.bottom), p);
    canvas.drawLine(Offset(glass.left, glass.center.dy),
        Offset(glass.right, glass.center.dy), p);
    p.style = PaintingStyle.fill;

    // little open shutters on the sides (upper windows)
    if (shutters) {
      p.color = const Color(0xFF5E3B26);
      final double shW = ww * 0.28;
      canvas.drawRect(Rect.fromLTWH(x - shW, y, shW, wh), p);
      canvas.drawRect(Rect.fromLTWH(x + ww, y, shW, wh), p);
      // shutter plank lines
      p
        ..color = const Color(0xFF4A2E1D)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      for (int i = 1; i < 3; i++) {
        final double sy = y + wh * i / 3;
        canvas.drawLine(Offset(x - shW, sy), Offset(x, sy), p);
        canvas.drawLine(Offset(x + ww, sy), Offset(x + ww + shW, sy), p);
      }
      p.style = PaintingStyle.fill;
    }
    // window sill
    p.color = const Color(0xFF5E3B26);
    canvas.drawRect(
        Rect.fromLTWH(x - ww * 0.06, y + wh, ww * 1.12, wh * 0.09), p);
  }

  void _door(Canvas canvas, Paint p, double w, double h, double bodyLeft,
      double storeyLine, double stoneTop) {
    final double dW = w * 0.13;
    final double dH = (stoneTop - storeyLine) + h * 0.02;
    final double dX = bodyLeft + w * 0.055;
    final double dY = storeyLine + h * 0.02;
    // door frame
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5E3B26);
    final RRect frame = RRect.fromRectAndCorners(
      Rect.fromLTWH(dX - 3, dY - 3, dW + 6, dH + 3),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
    );
    canvas.drawRRect(frame, p);
    // door leaf
    p.color = const Color(0xFF8A5A3C);
    final RRect leaf = RRect.fromRectAndCorners(
      Rect.fromLTWH(dX, dY, dW, dH),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(leaf, p);
    // plank lines
    p
      ..color = const Color(0xFF5E3B26)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int i = 1; i < 3; i++) {
      final double px = dX + dW * i / 3;
      canvas.drawLine(Offset(px, dY + 2), Offset(px, dY + dH - 2), p);
    }
    p.style = PaintingStyle.fill;
    // door handle
    p.color = const Color(0xFF3A2416);
    canvas.drawCircle(Offset(dX + dW * 0.82, dY + dH * 0.55), 2.4, p);
    // warm threshold glow
    p.color = const Color(0xFFF2C879).withValues(alpha: 0.25);
    canvas.drawRect(Rect.fromLTWH(dX, dY + dH - 4, dW, 4), p);
  }

  void _veranda(Canvas canvas, Paint p, double w, double h, double bodyLeft,
      double bodyRight, double stoneTop, double bodyBottom) {
    // A small open pidhi (raised wooden platform) in front of the door area,
    // with two posts holding a little shade lip.
    final double vTop = stoneTop + h * 0.02;
    final double vLeft = bodyLeft + w * 0.02;
    final double vRight = bodyLeft + w * 0.30;

    // platform
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF8A5A3C);
    canvas.drawRect(
        Rect.fromLTRB(vLeft, bodyBottom - h * 0.03, vRight, bodyBottom), p);
    p.color = const Color(0xFF6E4A2E);
    canvas.drawRect(
        Rect.fromLTRB(vLeft, bodyBottom - h * 0.03, vRight,
            bodyBottom - h * 0.02),
        p);

    // two wooden posts
    p.color = const Color(0xFF5E3B26);
    final double postW = w * 0.014;
    for (final double px in <double>[vLeft + w * 0.01, vRight - w * 0.03]) {
      canvas.drawRect(
          Rect.fromLTWH(px, vTop, postW, bodyBottom - h * 0.03 - vTop), p);
    }
    // top beam
    canvas.drawRect(
        Rect.fromLTRB(vLeft, vTop, vRight, vTop + h * 0.018), p);
  }

  void _roof(Canvas canvas, Paint p, double w, double h, double bodyLeft,
      double bodyRight, double bodyTop) {
    // Corrugated tin roof — a shallow gable with overhang on both sides.
    final double overhang = w * 0.055;
    final double eaveL = bodyLeft - overhang;
    final double eaveR = bodyRight + overhang;
    final double eaveY = bodyTop; // roof bottom edge sits at wall top
    final double ridgeY = bodyTop - h * 0.20;
    final double apexX = (eaveL + eaveR) / 2;

    // Roof underside / shadow eave
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5E3B26).withValues(alpha: 0.45);
    canvas.drawRect(
        Rect.fromLTRB(eaveL, eaveY, eaveR, eaveY + h * 0.02), p);

    // Left slope face (lighter, catches light)
    final Path left = Path()
      ..moveTo(eaveL, eaveY)
      ..lineTo(apexX, ridgeY)
      ..lineTo(apexX, eaveY)
      ..close();
    p.color = const Color(0xFF9A5B44);
    canvas.drawPath(left, p);

    // Right slope face (darker / in shade)
    final Path right = Path()
      ..moveTo(eaveR, eaveY)
      ..lineTo(apexX, ridgeY)
      ..lineTo(apexX, eaveY)
      ..close();
    p.color = const Color(0xFF7A4636);
    canvas.drawPath(right, p);

    // Corrugation ridges — thin diagonal lines following each slope.
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    // left slope ridges
    p.color = const Color(0xFF7A4636).withValues(alpha: 0.7);
    for (int i = 1; i < 16; i++) {
      final double t = i / 16.0;
      final double x = eaveL + (apexX - eaveL) * t;
      final double yTopSlope = eaveY + (ridgeY - eaveY) * t;
      canvas.drawLine(Offset(x, eaveY), Offset(x, yTopSlope), p);
    }
    // left slope highlight ridges
    p.color = const Color(0xFFB5705A).withValues(alpha: 0.55);
    for (int i = 1; i < 16; i++) {
      final double t = (i + 0.5) / 16.0;
      final double x = eaveL + (apexX - eaveL) * t;
      final double yTopSlope = eaveY + (ridgeY - eaveY) * t;
      canvas.drawLine(Offset(x, eaveY), Offset(x, yTopSlope), p);
    }
    // right slope ridges
    p.color = const Color(0xFF5E3B26).withValues(alpha: 0.7);
    for (int i = 1; i < 16; i++) {
      final double t = i / 16.0;
      final double x = apexX + (eaveR - apexX) * t;
      final double yTopSlope = ridgeY + (eaveY - ridgeY) * t;
      canvas.drawLine(Offset(x, yTopSlope), Offset(x, eaveY), p);
    }
    p.style = PaintingStyle.fill;

    // Ridge cap beam along the top
    p.color = const Color(0xFF5E3B26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(apexX - w * 0.012, ridgeY - h * 0.006, w * 0.024,
            h * 0.02),
        const Radius.circular(2),
      ),
      p,
    );

    // Fascia board along the eaves (front lip)
    p.color = const Color(0xFF6E4A2E);
    canvas.drawRect(
        Rect.fromLTRB(eaveL, eaveY - h * 0.012, eaveR, eaveY), p);
    // warm highlight on eave lip
    p.color = const Color(0xFF8A5A3C).withValues(alpha: 0.7);
    canvas.drawRect(
        Rect.fromLTRB(eaveL, eaveY - h * 0.012, eaveR, eaveY - h * 0.008), p);

    // exposed rafter tails under the left eave
    p
      ..color = const Color(0xFF5E3B26)
      ..style = PaintingStyle.fill;
    for (double x = bodyLeft; x < bodyRight; x += w * 0.09) {
      canvas.drawRect(
          Rect.fromLTWH(x, eaveY, w * 0.012, h * 0.016), p);
    }
  }

  void _chimney(Canvas canvas, Paint p, double w, double h, double bodyLeft) {
    // Simple stone/tin chimney poking through the left slope.
    final double cx = bodyLeft + w * 0.06;
    final double cTop = h * 0.075;
    final double cW = w * 0.05;
    final double cH = h * 0.10;
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF9E8A72);
    canvas.drawRect(Rect.fromLTWH(cx, cTop, cW, cH), p);
    // shade side
    p.color = const Color(0xFF7E6E58);
    canvas.drawRect(Rect.fromLTWH(cx + cW * 0.62, cTop, cW * 0.38, cH), p);
    // cap
    p.color = const Color(0xFF5E3B26);
    canvas.drawRect(
        Rect.fromLTWH(cx - cW * 0.12, cTop - h * 0.012, cW * 1.24, h * 0.016),
        p);
  }

  void _dryingCorn(Canvas canvas, Paint p, double w, double h,
      double bodyRight, double bodyTop) {
    // A tiny cluster of maize cobs hanging under the right eave.
    final double hx = bodyRight - w * 0.05;
    final double hy = bodyTop + h * 0.01;
    // hanging string
    p
      ..color = const Color(0xFF5E3B26)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(hx, hy), Offset(hx, hy + h * 0.05), p);
    p.style = PaintingStyle.fill;
    // three cobs
    for (int i = 0; i < 3; i++) {
      final double cx = hx + (i - 1) * w * 0.022;
      final double cy = hy + h * 0.05;
      // husk-leaf tip
      p
        ..color = const Color(0xFFB7D98C)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(hx, hy + h * 0.04), Offset(cx, cy), p);
      final RRect cob = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.012, cy, w * 0.024, h * 0.075),
        Radius.circular(w * 0.012),
      );
      p
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFE8C85F);
      canvas.drawRRect(cob, p);
      // kernel speckles
      p.color = const Color(0xFFC79A3D).withValues(alpha: 0.6);
      for (int k = 0; k < 4; k++) {
        canvas.drawCircle(
            Offset(cx, cy + h * 0.012 + k * h * 0.017), 0.9, p);
      }
    }
  }

  void _chiliString(Canvas canvas, Paint p, double w, double h,
      double bodyLeft, double bodyTop) {
    // A short string of drying red chilies under the left eave.
    final double sx = bodyLeft + w * 0.11;
    final double sy = bodyTop + h * 0.01;
    p
      ..color = const Color(0xFF5E3B26)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(sx, sy), Offset(sx, sy + h * 0.03), p);
    p.style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final double angle = -0.5 + i * 0.32;
      final double px = sx + math.sin(angle) * w * 0.02;
      final double py = sy + h * 0.03 + i * h * 0.012;
      p.color = const Color(0xFFD2483B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(px, py), width: w * 0.008, height: h * 0.03),
          Radius.circular(w * 0.006),
        ),
        p,
      );
    }
  }

  void _bench(Canvas canvas, Paint p, double w, double h, double bodyRight,
      double bodyBottom) {
    // Small wooden bench sitting on the yard to the right of the house.
    final double bx = bodyRight + w * 0.015;
    final double by = bodyBottom - h * 0.005;
    final double bw = w * 0.13;
    final double seatH = h * 0.02;
    p
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF8A5A3C);
    // seat
    canvas.drawRect(Rect.fromLTWH(bx, by, bw, seatH), p);
    // seat highlight
    p.color = const Color(0xFFA06A44).withValues(alpha: 0.8);
    canvas.drawRect(Rect.fromLTWH(bx, by, bw, seatH * 0.4), p);
    // legs
    p.color = const Color(0xFF5E3B26);
    final double legW = w * 0.012;
    final double legH = h * 0.05;
    canvas.drawRect(Rect.fromLTWH(bx + w * 0.006, by + seatH, legW, legH), p);
    canvas.drawRect(
        Rect.fromLTWH(bx + bw - w * 0.018, by + seatH, legW, legH), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}