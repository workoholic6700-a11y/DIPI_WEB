import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ============================================================================
/// NEPALI FARMERS — three small, warm, stylized animated farmer widgets for a
/// Himalayan hill-village scene. Pure Flutter (CustomPainter + flutter_animate),
/// no assets. Each farmer is ~46px tall, has a soft ground shadow and a subtle
/// looping idle animation.
///
/// Public widgets:
///   • FarmerPlanting     — bent over, dipping an arm to plant rice/maize.
///   • FarmerCuttingGrass — squatting with a sickle (हँसिया), arm sweeps.
///   • FarmerCarrying     — standing, carrying a doko basket, gentle sway.
///
/// Shared palette (matches the rest of the village):
///   skin #E7B98F · dhaka-topi cream #EDE3C6 · kurta red #C0453E · blue #3E6E8C
///   wood #8A5A3C dark #5E3B26
/// ============================================================================

// ---- Shared colours --------------------------------------------------------
const Color _kSkin = Color(0xFFE7B98F);
const Color _kSkinShade = Color(0xFFD9A578);
const Color _kTopi = Color(0xFFEDE3C6);
const Color _kTopiShade = Color(0xFFD9CBA6);
const Color _kHair = Color(0xFF3A2A22);
const Color _kRed = Color(0xFFC0453E);
const Color _kRedDark = Color(0xFF9A362F);
const Color _kBlueDark = Color(0xFF2F566E);
const Color _kWood = Color(0xFF8A5A3C);
const Color _kWoodDark = Color(0xFF5E3B26);
const Color _kShadow = Color(0x33244018);

/// A soft, elliptical ground shadow used under every farmer.
class _GroundShadow extends StatelessWidget {
  const _GroundShadow({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[_kShadow, Color(0x00244018)],
          stops: <double>[0.35, 1.0],
        ),
      ),
    );
  }
}

// ============================================================================
// 1) FARMER PLANTING
// ============================================================================

/// A farmer bent over the soil, dipping one arm down repeatedly to plant
/// rice/maize seedlings. The whole torso bobs slightly and the planting arm
/// pulses down on a slow loop.
class FarmerPlanting extends StatelessWidget {
  const FarmerPlanting({super.key, this.size = 46});

  /// Height of the farmer in logical pixels (~46 by default).
  final double size;

  @override
  Widget build(BuildContext context) {
    final double w = size * 1.15;
    final double h = size * 1.15;

    final Widget shadow = Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: _GroundShadow(width: w * 0.62, height: h * 0.11)
            .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
            .scaleXY(
              begin: 1.0,
              end: 0.94,
              duration: 1600.ms,
              curve: Curves.easeInOut,
            ),
      ),
    );

    // Static: bent body, legs, head, dug soil, and the DOKO basket beside him.
    final Widget body = CustomPaint(
      size: Size(w, h),
      painter: const _DiggingBodyPainter(),
    );

    // Animated: both arms + the KODALO (hoe) swinging down to dig the bari.
    final Widget kodalo = Positioned.fill(
      child: CustomPaint(
        size: Size(w, h),
        painter: const _KodaloPainter(),
      )
          .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
          .rotate(
            begin: -0.34,
            end: 0.06,
            alignment: const Alignment(-0.32, -0.08), // pivot at the shoulder
            duration: 760.ms,
            curve: Curves.easeInOut,
          ),
    );

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[shadow, body, kodalo],
      ),
    );
  }
}

class _DiggingBodyPainter extends CustomPainter {
  const _DiggingBodyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;

    // Freshly-dug clods of soil at the lower-left (the bari being dug).
    p.color = const Color(0xFF8A5A3C);
    for (final Offset o in const <Offset>[
      Offset(0.13, 0.945),
      Offset(0.20, 0.965),
      Offset(0.07, 0.965)
    ]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(o.dx * w, o.dy * h),
              width: w * 0.06,
              height: h * 0.028),
          p);
    }

    // Legs (bent, forward stance) — blue.
    final Paint legPaint = Paint()
      ..color = _kBlueDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.085
      ..strokeCap = StrokeCap.round;
    final double hipX = w * 0.56;
    final double hipY = h * 0.60;
    Path leg = Path()
      ..moveTo(hipX, hipY)
      ..quadraticBezierTo(w * 0.60, h * 0.78, w * 0.66, h * 0.93);
    canvas.drawPath(leg, legPaint);
    leg = Path()
      ..moveTo(hipX, hipY)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.44, h * 0.93);
    canvas.drawPath(leg, legPaint);

    // Feet
    p.color = _kWoodDark;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.67, h * 0.94), width: w * 0.12, height: h * 0.05),
        p);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.42, h * 0.94), width: w * 0.12, height: h * 0.05),
        p);

    // Torso — bent forward, red kurta.
    final Path torso = Path()
      ..moveTo(hipX + w * 0.02, hipY)
      ..quadraticBezierTo(w * 0.40, hipY - h * 0.02, w * 0.30, hipY - h * 0.12)
      ..quadraticBezierTo(w * 0.24, hipY - h * 0.20, w * 0.30, hipY - h * 0.26)
      ..quadraticBezierTo(w * 0.42, hipY - h * 0.30, w * 0.52, hipY - h * 0.20)
      ..quadraticBezierTo(w * 0.62, hipY - h * 0.08, hipX + w * 0.02, hipY)
      ..close();
    p.color = _kRed;
    canvas.drawPath(torso, p);
    p.color = _kRedDark;
    canvas.drawPath(
      Path()
        ..moveTo(hipX + w * 0.02, hipY)
        ..quadraticBezierTo(w * 0.50, hipY - h * 0.04, w * 0.56, hipY - h * 0.14)
        ..quadraticBezierTo(w * 0.60, hipY - h * 0.06, hipX + w * 0.02, hipY)
        ..close(),
      p,
    );

    // Head + topi, bent low over the soil.
    final double headX = w * 0.30;
    final double headY = hipY - h * 0.22;
    p.color = _kSkin;
    canvas.drawCircle(Offset(headX, headY), h * 0.085, p);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(headX, headY), radius: h * 0.085),
      math.pi * 0.6,
      math.pi * 1.0,
      false,
      Paint()
        ..color = _kHair
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.03
        ..strokeCap = StrokeCap.round,
    );
    final Path topi = Path()
      ..moveTo(headX - h * 0.09, headY - h * 0.02)
      ..quadraticBezierTo(
          headX - h * 0.02, headY - h * 0.14, headX + h * 0.09, headY - h * 0.05)
      ..quadraticBezierTo(
          headX + h * 0.02, headY - h * 0.06, headX - h * 0.09, headY - h * 0.02)
      ..close();
    p.color = _kTopi;
    canvas.drawPath(topi, p);
    p.color = _kTopiShade;
    canvas.drawPath(
      Path()
        ..moveTo(headX - h * 0.09, headY - h * 0.02)
        ..quadraticBezierTo(headX, headY - h * 0.05, headX + h * 0.09, headY - h * 0.05)
        ..lineTo(headX + h * 0.06, headY - h * 0.02)
        ..close(),
      p,
    );

    // ── DOKO — a woven bamboo carrying basket, resting at his side. ──
    _drawDoko(canvas, w, h);
  }

  void _drawDoko(Canvas canvas, double w, double h) {
    final double cx = w * 0.85;
    final double topY = h * 0.64;
    final double botY = h * 0.93;
    final double topR = w * 0.13;
    final double botR = w * 0.045;
    final Paint p = Paint()..isAntiAlias = true;

    final Path basket = Path()
      ..moveTo(cx - topR, topY)
      ..lineTo(cx + topR, topY)
      ..lineTo(cx + botR, botY)
      ..lineTo(cx - botR, botY)
      ..close();
    p.color = const Color(0xFFC9A24E);
    canvas.drawPath(basket, p);
    // shaded side
    p.color = const Color(0xFF9C7A38);
    canvas.drawPath(
      Path()
        ..moveTo(cx + topR, topY)
        ..lineTo(cx + botR, botY)
        ..lineTo(cx + botR - w * 0.035, botY)
        ..lineTo(cx + topR - w * 0.05, topY)
        ..close(),
      p,
    );
    // woven texture
    final Paint weave = Paint()
      ..color = const Color(0xFF7A5A2E).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.011;
    for (int i = 1; i <= 3; i++) {
      final double t = i / 4.0;
      final double y = topY + (botY - topY) * t;
      final double rr = topR + (botR - topR) * t;
      canvas.drawLine(Offset(cx - rr, y), Offset(cx + rr, y), weave);
    }
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(cx + i * topR * 0.5, topY),
          Offset(cx + i * botR * 0.5, botY), weave);
    }
    // rim
    p.color = const Color(0xFF8A5A3C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - topR - w * 0.012, topY - h * 0.016,
              topR * 2 + w * 0.024, h * 0.032),
          Radius.circular(w * 0.02)),
      p,
    );
    // a little greenery poking out of the doko
    final Paint sprig = Paint()
      ..color = const Color(0xFF5EA05C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.015
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - w * 0.03, topY),
        Offset(cx - w * 0.05, topY - h * 0.08), sprig);
    canvas.drawLine(Offset(cx + w * 0.02, topY),
        Offset(cx + w * 0.045, topY - h * 0.06), sprig);
  }

  @override
  bool shouldRepaint(covariant _DiggingBodyPainter oldDelegate) => false;
}

/// Both arms gripping the kodalo (Nepali hoe) + its wooden handle and metal
/// blade. Rotated by the widget around the shoulder so it swings into the soil.
class _KodaloPainter extends CustomPainter {
  const _KodaloPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double shX = w * 0.34;
    final double shY = h * 0.46; // shoulder
    final double handX = w * 0.30;
    final double handY = h * 0.70; // grip

    // Both arms from the shoulder down to the hands (skin).
    final Paint arm = Paint()
      ..color = _kSkin
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(shX, shY)
          ..quadraticBezierTo(w * 0.30, h * 0.58, handX, handY),
        arm);
    canvas.drawPath(
        Path()
          ..moveTo(shX + w * 0.035, shY + h * 0.02)
          ..quadraticBezierTo(w * 0.34, h * 0.60, handX + w * 0.035, handY),
        arm);

    // Kodalo wooden handle: from the hands down-left to the blade at the soil.
    final double bladeX = w * 0.16;
    final double bladeY = h * 0.90;
    canvas.drawLine(
      Offset(handX + w * 0.015, handY - h * 0.02),
      Offset(bladeX, bladeY),
      Paint()
        ..color = const Color(0xFF9A6B3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.028
        ..strokeCap = StrokeCap.round,
    );

    // Kodalo blade: a broad angled metal head biting into the soil.
    final Path blade = Path()
      ..moveTo(bladeX + w * 0.02, bladeY - h * 0.035)
      ..lineTo(bladeX - w * 0.10, bladeY + h * 0.03)
      ..lineTo(bladeX - w * 0.075, bladeY + h * 0.08)
      ..lineTo(bladeX + w * 0.035, bladeY + h * 0.015)
      ..close();
    canvas.drawPath(blade, Paint()..color = const Color(0xFF8A9096));
    canvas.drawPath(
        blade,
        Paint()
          ..color = const Color(0xFF5E6469)
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.008);
    canvas.drawLine(
      Offset(bladeX, bladeY - h * 0.01),
      Offset(bladeX - w * 0.07, bladeY + h * 0.04),
      Paint()
        ..color = const Color(0xFFBFC4C8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.01
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _KodaloPainter oldDelegate) => false;
}

// ============================================================================
// 2) FARMER CUTTING GRASS
// ============================================================================

/// A farmer squatting low with a sickle (हँसिया), the cutting arm sweeping in
/// a slow arc to cut grass for the cow. A small tuft of cut grass sits nearby.
class FarmerCuttingGrass extends StatelessWidget {
  const FarmerCuttingGrass({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double w = size * 1.05;
    final double h = size * 1.05;

    final Widget shadow = Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: _GroundShadow(width: w * 0.6, height: h * 0.1),
      ),
    );

    // Body (torso, head, legs, grass) — dips down and up in a cutting rhythm
    // so the farmer clearly reads as working, not slumped.
    final Widget body = CustomPaint(
      size: Size(w, h),
      painter: const _CuttingBodyPainter(),
    )
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .moveY(
          begin: -h * 0.015,
          end: h * 0.05,
          duration: 620.ms,
          curve: Curves.easeInOut,
        );

    // The sickle arm sweeps down as he cuts, synced with the body dip.
    final Widget arm = Positioned.fill(
      child: CustomPaint(
        size: Size(w, h),
        painter: const _SickleArmPainter(),
      )
          .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
          .rotate(
            begin: -0.26,
            end: 0.22,
            alignment: const Alignment(0.15, -0.05), // pivot near the shoulder
            duration: 620.ms,
            curve: Curves.easeInOut,
          ),
    );

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          shadow,
          body,
          arm,
        ],
      ),
    );
  }
}

class _CuttingBodyPainter extends CustomPainter {
  const _CuttingBodyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;

    // Grass tufts on the ground (some standing, being cut).
    final Paint grass = Paint()
      ..color = const Color(0xFF5EA05C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.022
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final double gx = w * (0.10 + i * 0.045);
      canvas.drawLine(Offset(gx, h * 0.96), Offset(gx - w * 0.01, h * 0.82), grass);
      canvas.drawLine(Offset(gx, h * 0.96), Offset(gx + w * 0.015, h * 0.84), grass);
    }
    // small pile of cut grass
    final Paint cut = Paint()
      ..color = const Color(0xFF7FBE6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.08, h * 0.95), Offset(w * 0.02, h * 0.90), cut);
    canvas.drawLine(Offset(w * 0.10, h * 0.96), Offset(w * 0.16, h * 0.91), cut);

    // Squatting legs — folded, low stance (blue).
    final Paint legPaint = Paint()
      ..color = _kBlueDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.085
      ..strokeCap = StrokeCap.round;
    final double hipX = w * 0.60;
    final double hipY = h * 0.66;
    // folded thigh + shin (front)
    canvas.drawPath(
      Path()
        ..moveTo(hipX, hipY)
        ..quadraticBezierTo(w * 0.50, h * 0.86, w * 0.44, h * 0.86)
        ..quadraticBezierTo(w * 0.42, h * 0.90, w * 0.46, h * 0.93),
      legPaint,
    );
    // back knee tucked
    canvas.drawPath(
      Path()
        ..moveTo(hipX, hipY)
        ..quadraticBezierTo(w * 0.66, h * 0.84, w * 0.62, h * 0.92),
      legPaint,
    );
    // foot
    p.color = _kWoodDark;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.47, h * 0.94), width: w * 0.12, height: h * 0.045), p);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.63, h * 0.93), width: w * 0.11, height: h * 0.045), p);

    // Torso leaning forward over the grass (red kurta).
    final double shX = w * 0.46;
    final double shY = hipY - h * 0.20;
    final Path torso = Path()
      ..moveTo(hipX + w * 0.03, hipY)
      ..quadraticBezierTo(w * 0.44, hipY - h * 0.04, shX - w * 0.02, shY)
      ..quadraticBezierTo(w * 0.40, shY - h * 0.04, shX + w * 0.06, shY - h * 0.02)
      ..quadraticBezierTo(w * 0.66, hipY - h * 0.06, hipX + w * 0.03, hipY)
      ..close();
    p.color = _kRed;
    canvas.drawPath(torso, p);
    p.color = _kRedDark;
    canvas.drawPath(
      Path()
        ..moveTo(hipX + w * 0.03, hipY)
        ..quadraticBezierTo(w * 0.62, hipY - h * 0.05, shX + w * 0.06, shY - h * 0.02)
        ..quadraticBezierTo(w * 0.60, hipY - h * 0.02, hipX + w * 0.03, hipY)
        ..close(),
      p,
    );

    // Head with topi.
    final double headX = shX - w * 0.02;
    final double headY = shY - h * 0.07;
    p.color = _kSkin;
    canvas.drawCircle(Offset(headX, headY), h * 0.082, p);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(headX, headY), radius: h * 0.082),
      math.pi * 0.5,
      math.pi * 1.1,
      false,
      Paint()
        ..color = _kHair
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.03
        ..strokeCap = StrokeCap.round,
    );
    // topi
    p.color = _kTopi;
    canvas.drawPath(
      Path()
        ..moveTo(headX - h * 0.085, headY - h * 0.02)
        ..quadraticBezierTo(headX, headY - h * 0.14, headX + h * 0.088, headY - h * 0.04)
        ..quadraticBezierTo(headX, headY - h * 0.05, headX - h * 0.085, headY - h * 0.02)
        ..close(),
      p,
    );
    p.color = _kTopiShade;
    canvas.drawPath(
      Path()
        ..moveTo(headX - h * 0.085, headY - h * 0.02)
        ..quadraticBezierTo(headX, headY - h * 0.045, headX + h * 0.088, headY - h * 0.04)
        ..lineTo(headX + h * 0.05, headY - h * 0.015)
        ..close(),
      p,
    );

    // Support arm bracing on knee (skin).
    canvas.drawPath(
      Path()
        ..moveTo(shX + w * 0.02, shY + h * 0.02)
        ..quadraticBezierTo(w * 0.56, hipY + h * 0.02, w * 0.50, h * 0.80),
      Paint()
        ..color = _kSkin
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.05
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CuttingBodyPainter oldDelegate) => false;
}

/// The sweeping cutting arm + sickle, drawn in its own painter so the parent
/// can rotate it around the shoulder.
class _SickleArmPainter extends CustomPainter {
  const _SickleArmPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // shoulder anchor roughly matching the body painter
    final double shX = w * 0.50;
    final double shY = h * 0.42;

    // arm
    canvas.drawPath(
      Path()
        ..moveTo(shX, shY)
        ..quadraticBezierTo(w * 0.36, h * 0.60, w * 0.24, h * 0.72),
      Paint()
        ..color = _kSkin
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.05
        ..strokeCap = StrokeCap.round,
    );

    // hand/handle joint at wrist
    final double wx = w * 0.24;
    final double wy = h * 0.72;
    canvas.drawCircle(Offset(wx, wy), h * 0.03, Paint()..color = _kSkinShade);

    // wooden handle
    canvas.drawLine(
      Offset(wx, wy),
      Offset(wx - w * 0.05, wy + h * 0.03),
      Paint()
        ..color = _kWood
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.028
        ..strokeCap = StrokeCap.round,
    );

    // curved steel sickle blade (हँसिया)
    final Path blade = Path()
      ..moveTo(wx - w * 0.05, wy + h * 0.03)
      ..quadraticBezierTo(wx - w * 0.16, wy - h * 0.02, wx - w * 0.14, wy - h * 0.10)
      ..quadraticBezierTo(wx - w * 0.12, wy - h * 0.04, wx - w * 0.04, wy + h * 0.02);
    canvas.drawPath(
      blade,
      Paint()
        ..color = const Color(0xFFB9C4CC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.02
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SickleArmPainter oldDelegate) => false;
}

// ============================================================================
// 3) FARMER CARRYING (doko + namlo)
// ============================================================================

/// A farmer standing and carrying a doko (bamboo basket) on the back, held by
/// a namlo (headband strap). Gentle walking-in-place sway.
class FarmerCarrying extends StatelessWidget {
  const FarmerCarrying({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double w = size * 0.95;
    final double h = size * 1.2;

    final Widget shadow = Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: _GroundShadow(width: w * 0.62, height: h * 0.085)
            .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
            .moveX(begin: -size * 0.01, end: size * 0.01, duration: 1400.ms, curve: Curves.easeInOut),
      ),
    );

    final Widget body = CustomPaint(
      size: Size(w, h),
      painter: const _CarryingPainter(),
    )
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        // subtle walking-in-place sway: tiny lateral rock + micro bob
        .rotate(
          begin: -0.018,
          end: 0.018,
          alignment: Alignment.bottomCenter,
          duration: 1400.ms,
          curve: Curves.easeInOut,
        )
        .moveY(begin: 0, end: -size * 0.02, duration: 700.ms, curve: Curves.easeInOut);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          shadow,
          body,
        ],
      ),
    );
  }
}

class _CarryingPainter extends CustomPainter {
  const _CarryingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;

    final double cx = w * 0.5;

    // --- Doko (bamboo basket) on the back, drawn first (behind body). ---
    // Conical woven basket, wider at top.
    final Path doko = Path()
      ..moveTo(w * 0.30, h * 0.30)
      ..lineTo(w * 0.70, h * 0.30)
      ..quadraticBezierTo(w * 0.66, h * 0.62, cx, h * 0.66)
      ..quadraticBezierTo(w * 0.34, h * 0.62, w * 0.30, h * 0.30)
      ..close();
    p.color = _kWood;
    canvas.drawPath(doko, p);
    // basket rim
    p.color = _kWoodDark;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.30), width: w * 0.40, height: h * 0.055),
      p,
    );
    p.color = const Color(0xFFB07E52);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.295), width: w * 0.36, height: h * 0.04),
      p,
    );
    // woven texture lines
    final Paint weave = Paint()
      ..color = _kWoodDark.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.008;
    for (int i = 1; i <= 3; i++) {
      final double t = i / 4.0;
      final double yy = h * (0.34 + t * 0.26);
      final double halfW = (w * 0.20) * (1 - t * 0.45);
      canvas.drawLine(Offset(cx - halfW, yy), Offset(cx + halfW, yy), weave);
    }
    // diagonal weave
    for (int i = 0; i < 4; i++) {
      final double x0 = w * (0.34 + i * 0.09);
      canvas.drawLine(Offset(x0, h * 0.34), Offset(x0 - w * 0.03, h * 0.58), weave);
    }
    // greens poking out of the top (fodder/veg)
    final Paint leaf = Paint()
      ..color = const Color(0xFF5EA05C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.40, h * 0.30), Offset(w * 0.36, h * 0.18), leaf);
    canvas.drawLine(Offset(cx, h * 0.29), Offset(w * 0.52, h * 0.15), leaf);
    canvas.drawLine(Offset(w * 0.60, h * 0.30), Offset(w * 0.64, h * 0.19), leaf);

    // --- Legs (standing, slight stride), blue. ---
    final Paint legPaint = Paint()
      ..color = _kBlueDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.06
      ..strokeCap = StrokeCap.round;
    final double hipY = h * 0.72;
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.02, hipY)
        ..quadraticBezierTo(w * 0.42, h * 0.86, w * 0.40, h * 0.97),
      legPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.02, hipY)
        ..quadraticBezierTo(w * 0.58, h * 0.86, w * 0.60, h * 0.97),
      legPaint,
    );
    p.color = _kWoodDark;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.39, h * 0.98), width: w * 0.13, height: h * 0.03), p);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.61, h * 0.98), width: w * 0.13, height: h * 0.03), p);

    // --- Torso (upright, slight forward lean under the load), red kurta. ---
    final double shY = h * 0.40;
    final Path torso = Path()
      ..moveTo(cx - w * 0.11, hipY)
      ..quadraticBezierTo(w * 0.34, h * 0.55, w * 0.36, shY + h * 0.02)
      ..quadraticBezierTo(cx, shY - h * 0.03, w * 0.62, shY + h * 0.02)
      ..quadraticBezierTo(w * 0.66, h * 0.55, cx + w * 0.11, hipY)
      ..quadraticBezierTo(cx, hipY + h * 0.02, cx - w * 0.11, hipY)
      ..close();
    p.color = _kRed;
    canvas.drawPath(torso, p);
    // shading down the side
    p.color = _kRedDark;
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.11, hipY)
        ..quadraticBezierTo(w * 0.66, h * 0.55, w * 0.62, shY + h * 0.02)
        ..quadraticBezierTo(w * 0.60, h * 0.55, cx + w * 0.04, hipY)
        ..close(),
      p,
    );

    // --- Arms holding straps at the sides (skin). ---
    final Paint armPaint = Paint()
      ..color = _kSkin
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.042
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.38, shY + h * 0.03)
        ..quadraticBezierTo(w * 0.33, h * 0.52, w * 0.37, h * 0.62),
      armPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.62, shY + h * 0.03)
        ..quadraticBezierTo(w * 0.67, h * 0.52, w * 0.63, h * 0.62),
      armPaint,
    );

    // --- Head with topi. ---
    final double headY = shY - h * 0.055;
    p.color = _kSkin;
    canvas.drawCircle(Offset(cx, headY), h * 0.07, p);
    // face shading
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, headY), radius: h * 0.07),
      -math.pi * 0.15,
      math.pi * 0.6,
      false,
      Paint()
        ..color = _kSkinShade.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.02,
    );
    // hair
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, headY), radius: h * 0.07),
      math.pi * 0.55,
      math.pi * 1.0,
      false,
      Paint()
        ..color = _kHair
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.026
        ..strokeCap = StrokeCap.round,
    );
    // topi cap
    p.color = _kTopi;
    canvas.drawPath(
      Path()
        ..moveTo(cx - h * 0.072, headY - h * 0.015)
        ..quadraticBezierTo(cx, headY - h * 0.11, cx + h * 0.072, headY - h * 0.015)
        ..quadraticBezierTo(cx, headY - h * 0.035, cx - h * 0.072, headY - h * 0.015)
        ..close(),
      p,
    );
    p.color = _kTopiShade;
    canvas.drawPath(
      Path()
        ..moveTo(cx - h * 0.072, headY - h * 0.015)
        ..quadraticBezierTo(cx, headY - h * 0.035, cx + h * 0.072, headY - h * 0.015)
        ..quadraticBezierTo(cx, headY - h * 0.005, cx - h * 0.072, headY - h * 0.015)
        ..close(),
      p,
    );

    // --- Namlo (headband strap) from forehead over to the doko. ---
    final Paint namlo = Paint()
      ..color = const Color(0xFF6E4A30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.02
      ..strokeCap = StrokeCap.round;
    // across the forehead
    canvas.drawLine(
      Offset(cx - h * 0.07, headY - h * 0.005),
      Offset(cx + h * 0.07, headY - h * 0.005),
      namlo,
    );
    // strap running back to the basket rim on each side
    canvas.drawPath(
      Path()
        ..moveTo(cx - h * 0.06, headY)
        ..quadraticBezierTo(w * 0.34, h * 0.34, w * 0.33, h * 0.31),
      namlo,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + h * 0.06, headY)
        ..quadraticBezierTo(w * 0.66, h * 0.34, w * 0.67, h * 0.31),
      namlo,
    );
  }

  @override
  bool shouldRepaint(covariant _CarryingPainter oldDelegate) => false;
}