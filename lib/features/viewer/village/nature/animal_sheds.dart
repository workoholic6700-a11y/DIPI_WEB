import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// EASTERN-NEPAL (Ilam) HILL-VILLAGE HOMESTEAD — ANIMAL SHEDS
/// CowShed (big two-storey cement/tin goth), PigSty (small mud/tin lean-to),
/// GoatShed (small raised wooden khor on stilts). Const ctors, fixed sizes,
/// soft shadows, subtle flutter_animate accents. Read clearly at ~60-140px.

const Color _cement = Color(0xFFC7C0B4);
const Color _cementShade = Color(0xFFA8A196);
const Color _concrete = Color(0xFFB4AC9E);
const Color _stone = Color(0xFF9E8A72);
const Color _stoneDark = Color(0xFF8A7862);
const Color _mud = Color(0xFFB5794A);
const Color _tinSilver = Color(0xFFAEB6BC);
const Color _tinSilverDark = Color(0xFF949CA3);
const Color _tinRust = Color(0xFF9A5B44);
const Color _tinRustDark = Color(0xFF7A4636);
const Color _wood = Color(0xFF8A5A3C);
const Color _woodDark = Color(0xFF5E3B26);
const Color _frame = Color(0xFF6E4A2E);
const Color _thatch = Color(0xFFC9A24E);
const Color _hay = Color(0xFFE8C85F);
const Color _pig = Color(0xFFE6A6A0);
const Color _goat = Color(0xFFD9CFC0);
const Color _dark = Color(0xFF241C15);

Paint _softShadow() => Paint()
  ..color = const Color(0x2E000000)
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

/// 1) COW SHED — the big one. ~140px tall, two storeys, tin roof.
class CowShed extends StatelessWidget {
  const CowShed({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 154,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _CowShedPainter()),
          ),
          Positioned(
            left: 58,
            top: 118,
            child: _Puff(
              color: const Color(0xFFFDF6E6),
              size: 9,
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 900.ms)
                .fadeOut(delay: 1100.ms, duration: 1400.ms)
                .moveY(begin: 2, end: -16, duration: 2400.ms, curve: Curves.easeOut)
                .moveX(begin: 0, end: 6, duration: 2400.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

class _CowShedPainter extends CustomPainter {
  const _CowShedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.53, h - 7), width: w * 0.88, height: 20),
      _softShadow(),
    );

    final wallL = w * 0.16;
    final wallR = w * 0.79;
    final wallTop = h * 0.31;
    final ground = h * 0.945;
    final floorY = h * 0.60;

    final plinthTop = ground - 10;
    p.color = _stoneDark;
    canvas.drawRect(Rect.fromLTRB(wallL - 3, plinthTop, wallR + 3, ground), p);
    p.color = _stone;
    canvas.drawRect(Rect.fromLTRB(wallL - 3, plinthTop, wallR + 3, plinthTop + 5), p);
    p.color = _stoneDark.withValues(alpha: 0.55);
    p.strokeWidth = 1;
    p.style = PaintingStyle.stroke;
    for (double sx = wallL + 4; sx < wallR; sx += 12) {
      canvas.drawLine(Offset(sx, plinthTop + 1), Offset(sx + 3, ground - 1), p);
    }
    p.style = PaintingStyle.fill;

    final body = Rect.fromLTRB(wallL, wallTop, wallR, plinthTop);
    p.color = _cement;
    canvas.drawRect(body, p);
    p.color = _cementShade;
    canvas.drawRect(Rect.fromLTRB(wallR - (wallR - wallL) * 0.30, wallTop, wallR, plinthTop), p);
    p.color = const Color(0xFFDCD6CA).withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTRB(wallL, wallTop, wallL + 6, plinthTop), p);

    p.color = _concrete;
    canvas.drawRect(Rect.fromLTRB(wallL - 2, floorY - 3, wallR + 2, floorY + 2), p);
    p.color = _cementShade.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTRB(wallL - 2, floorY + 1, wallR + 2, floorY + 2), p);

    p.color = _mud.withValues(alpha: 0.28);
    canvas.drawCircle(Offset(wallL + 9, floorY + 20), 6, p);
    canvas.drawCircle(Offset(wallR - 8, wallTop + 16), 5, p);
    p.color = _stoneDark.withValues(alpha: 0.35);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 0.8;
    final crack = Path()
      ..moveTo(wallR - 14, wallTop + 4)
      ..lineTo(wallR - 17, floorY - 18)
      ..lineTo(wallR - 12, floorY - 6);
    canvas.drawPath(crack, p);
    p.style = PaintingStyle.fill;

    final rTopL = Offset(w * 0.05, h * 0.19);
    final rTopR = Offset(w * 0.92, h * 0.27);
    final rBotR = Offset(w * 0.92, h * 0.325);
    final rBotL = Offset(w * 0.05, h * 0.245);
    final roof = Path()
      ..moveTo(rTopL.dx, rTopL.dy)
      ..lineTo(rTopR.dx, rTopR.dy)
      ..lineTo(rBotR.dx, rBotR.dy)
      ..lineTo(rBotL.dx, rBotL.dy)
      ..close();
    p.color = _tinSilver;
    canvas.drawPath(roof, p);
    p.style = PaintingStyle.stroke;
    for (int i = 1; i < 26; i++) {
      final f = i / 26.0;
      final t = Offset.lerp(rTopL, rTopR, f)!;
      final b = Offset.lerp(rBotL, rBotR, f)!;
      p.color = (i.isEven ? _tinSilverDark : const Color(0xFFCED4D8))
          .withValues(alpha: 0.7);
      p.strokeWidth = 1;
      canvas.drawLine(t, b, p);
    }
    p.color = _tinSilverDark;
    p.strokeWidth = 2;
    canvas.drawLine(rBotL, rBotR, p);
    p.color = const Color(0x33000000);
    p.strokeWidth = 2.5;
    canvas.drawLine(
        Offset(rBotL.dx + 4, rBotL.dy + 2), Offset(rBotR.dx - 4, rBotR.dy + 2), p);
    p.style = PaintingStyle.fill;

    final winL = w * 0.40, winR = w * 0.58, winT = h * 0.40, winB = h * 0.54;
    p.color = _frame;
    canvas.drawRect(Rect.fromLTRB(winL - 2, winT - 2, winR + 2, winB + 2), p);
    p.color = _dark;
    canvas.drawRect(Rect.fromLTRB(winL, winT, winR, winB), p);
    p.color = _hay;
    final hayLump = Path()
      ..moveTo(winL, winB)
      ..quadraticBezierTo((winL + winR) / 2, winB + 9, winR, winB)
      ..lineTo(winR, winB - 6)
      ..quadraticBezierTo((winL + winR) / 2, winB - 2, winL, winB - 6)
      ..close();
    canvas.drawPath(hayLump, p);
    p.color = _thatch;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 0.9;
    for (int i = 0; i < 9; i++) {
      final sx = winL + 2 + i * ((winR - winL - 4) / 8);
      canvas.drawLine(Offset(sx, winB + 2), Offset(sx + (i - 4) * 1.4, winB + 10), p);
    }
    p.style = PaintingStyle.fill;

    final doorL = w * 0.32, doorR = w * 0.55;
    final doorTop = floorY + 8, doorBot = plinthTop;
    p.color = _woodDark;
    final frame = Path()
      ..moveTo(doorL - 3, doorBot)
      ..lineTo(doorL - 3, doorTop + 8)
      ..quadraticBezierTo(doorL - 3, doorTop - 4, (doorL + doorR) / 2, doorTop - 4)
      ..quadraticBezierTo(doorR + 3, doorTop - 4, doorR + 3, doorTop + 8)
      ..lineTo(doorR + 3, doorBot)
      ..close();
    canvas.drawPath(frame, p);
    p.color = _dark;
    final door = Path()
      ..moveTo(doorL, doorBot)
      ..lineTo(doorL, doorTop + 8)
      ..quadraticBezierTo(doorL, doorTop, (doorL + doorR) / 2, doorTop)
      ..quadraticBezierTo(doorR, doorTop, doorR, doorTop + 8)
      ..lineTo(doorR, doorBot)
      ..close();
    canvas.drawPath(door, p);
    p.color = _thatch.withValues(alpha: 0.4);
    canvas.drawOval(
        Rect.fromCenter(center: Offset((doorL + doorR) / 2, doorBot - 1), width: 26, height: 5),
        p);

    _drawCowHead(canvas, Offset((doorL + doorR) / 2 + 4, doorBot - 14), p);

    final swL = w * 0.60, swR = w * 0.72, swT = floorY + 12, swB = floorY + 30;
    p.color = _frame;
    canvas.drawRect(Rect.fromLTRB(swL - 2, swT - 2, swR + 2, swB + 2), p);
    p.color = _dark;
    canvas.drawRect(Rect.fromLTRB(swL, swT, swR, swB), p);
    p.color = _wood;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.4;
    canvas.drawLine(Offset((swL + swR) / 2, swT), Offset((swL + swR) / 2, swB), p);
    canvas.drawLine(Offset(swL, (swT + swB) / 2), Offset(swR, (swT + swB) / 2), p);
    p.style = PaintingStyle.fill;

    final fY1 = ground - 4, fY2 = ground - 12;
    p.color = _wood;
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.02, fY2 - 2, w * 0.30, fY2 + 1, const Radius.circular(1.5)), p);
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.02, fY1 - 2, w * 0.30, fY1 + 1, const Radius.circular(1.5)), p);
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.70, fY2 - 2, w * 0.99, fY2 + 1, const Radius.circular(1.5)), p);
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.70, fY1 - 2, w * 0.99, fY1 + 1, const Radius.circular(1.5)), p);
    p.color = _woodDark;
    for (final px in [w * 0.03, w * 0.16, w * 0.29, w * 0.71, w * 0.85, w * 0.98]) {
      canvas.drawRect(Rect.fromLTRB(px - 1.5, fY2 - 4, px + 1.5, ground), p);
    }
  }

  void _drawCowHead(Canvas canvas, Offset c, Paint p) {
    p.color = _goat;
    final face = Path()
      ..moveTo(c.dx - 9, c.dy - 6)
      ..quadraticBezierTo(c.dx - 12, c.dy + 6, c.dx - 5, c.dy + 12)
      ..quadraticBezierTo(c.dx, c.dy + 16, c.dx + 5, c.dy + 12)
      ..quadraticBezierTo(c.dx + 12, c.dy + 6, c.dx + 9, c.dy - 6)
      ..quadraticBezierTo(c.dx, c.dy - 12, c.dx - 9, c.dy - 6)
      ..close();
    canvas.drawPath(face, p);
    p.color = const Color(0xFFCFC4B3);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx - 11, c.dy - 6), width: 7, height: 4), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx + 11, c.dy - 6), width: 7, height: 4), p);
    p.color = const Color(0xFFEDE6D6);
    canvas.drawCircle(Offset(c.dx - 5, c.dy - 10), 1.8, p);
    canvas.drawCircle(Offset(c.dx + 5, c.dy - 10), 1.8, p);
    p.color = const Color(0xFFC9AEA0);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + 9), width: 12, height: 8), p);
    p.color = _dark;
    canvas.drawCircle(Offset(c.dx - 2.5, c.dy + 9), 1.1, p);
    canvas.drawCircle(Offset(c.dx + 2.5, c.dy + 9), 1.1, p);
    canvas.drawCircle(Offset(c.dx - 4.5, c.dy + 1), 1.4, p);
    canvas.drawCircle(Offset(c.dx + 4.5, c.dy + 1), 1.4, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2) PIG STY — small (~64px). Low mud/stone + tin lean-to with a mud yard.
class PigSty extends StatelessWidget {
  const PigSty({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _PigStyPainter())),
          Positioned(
            left: 30,
            top: 44,
            child: const _Puff(color: Color(0xFF3A342C), size: 2.4)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: -6, end: 10, duration: 1300.ms, curve: Curves.easeInOut)
                .moveY(begin: 0, end: -5, duration: 900.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

class _PigStyPainter extends CustomPainter {
  const _PigStyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h - 5), width: w * 0.9, height: 13),
      _softShadow(),
    );

    final ground = h * 0.90;

    p.color = _mud.withValues(alpha: 0.55);
    final yard = Path()
      ..moveTo(w * 0.04, ground)
      ..quadraticBezierTo(w * 0.02, ground - 10, w * 0.20, ground - 11)
      ..lineTo(w * 0.62, ground - 11)
      ..quadraticBezierTo(w * 0.70, ground - 4, w * 0.66, ground + 1)
      ..close();
    canvas.drawPath(yard, p);
    p.color = const Color(0xFF7A5233).withValues(alpha: 0.6);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.30, ground - 3), width: 22, height: 7), p);

    final shL = w * 0.55, shR = w * 0.94;
    final shBot = ground;
    final shBackTop = h * 0.30;
    final shFrontTop = h * 0.44;

    p.color = _stoneDark;
    canvas.drawRect(Rect.fromLTRB(shR - 4, shBackTop, shR, shBot), p);
    p.color = _mud;
    final pbody = Path()
      ..moveTo(shL, shBot)
      ..lineTo(shL, shFrontTop + 4)
      ..lineTo(shR, shBackTop + 4)
      ..lineTo(shR, shBot)
      ..close();
    canvas.drawPath(pbody, p);
    p.color = const Color(0xFF9C6740);
    canvas.drawRect(Rect.fromLTRB(shL, shBot - 8, shR, shBot), p);
    p.color = _stone;
    for (double sx = shL + 2; sx < shR - 2; sx += 7) {
      canvas.drawCircle(Offset(sx, shBot - 3), 2, p);
    }
    p.color = _dark;
    canvas.drawRect(Rect.fromLTRB(shL + 3, shBot - 15, shL + 15, shBot), p);

    final tTopL = Offset(shL - 5, shFrontTop);
    final tTopR = Offset(shR + 4, shBackTop);
    final tBotR = Offset(shR + 4, shBackTop + 5);
    final tBotL = Offset(shL - 5, shFrontTop + 5);
    final roof = Path()
      ..moveTo(tTopL.dx, tTopL.dy)
      ..lineTo(tTopR.dx, tTopR.dy)
      ..lineTo(tBotR.dx, tBotR.dy)
      ..lineTo(tBotL.dx, tBotL.dy)
      ..close();
    p.color = _tinRust;
    canvas.drawPath(roof, p);
    p.style = PaintingStyle.stroke;
    for (int i = 1; i < 14; i++) {
      final f = i / 14.0;
      final t = Offset.lerp(tTopL, tTopR, f)!;
      final b = Offset.lerp(tBotL, tBotR, f)!;
      p.color = (i.isEven ? _tinRustDark : const Color(0xFFB06A50)).withValues(alpha: 0.7);
      p.strokeWidth = 0.9;
      canvas.drawLine(t, b, p);
    }
    p.color = _tinRustDark;
    p.strokeWidth = 1.4;
    canvas.drawLine(tBotL, tBotR, p);
    p.style = PaintingStyle.fill;
    p.color = _stoneDark;
    canvas.drawCircle(Offset(shR - 6, shBackTop + 1), 3, p);

    p.color = _wood;
    final railY1 = ground - 12, railY2 = ground - 4;
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.05, railY1, w * 0.56, railY1 + 2.5, const Radius.circular(1)), p);
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.05, railY2, w * 0.56, railY2 + 2.5, const Radius.circular(1)), p);
    p.color = _woodDark;
    for (final px in [w * 0.06, w * 0.22, w * 0.38, w * 0.54]) {
      canvas.drawRect(Rect.fromLTRB(px - 1.3, railY1 - 4, px + 1.3, ground), p);
    }

    _drawPig(canvas, Offset(w * 0.30, ground - 6), p);
  }

  void _drawPig(Canvas canvas, Offset c, Paint p) {
    p.color = _pig;
    canvas.drawOval(Rect.fromCenter(center: c, width: 22, height: 12), p);
    p.color = const Color(0xFFEEBAB4);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx - 4, c.dy - 2), width: 12, height: 7), p);
    p.color = _pig;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(c.dx + 10, c.dy + 1), width: 11, height: 9), p);
    p.color = const Color(0xFFD98F89);
    final ear = Path()
      ..moveTo(c.dx + 8, c.dy - 3)
      ..lineTo(c.dx + 12, c.dy - 6)
      ..lineTo(c.dx + 12, c.dy - 1)
      ..close();
    canvas.drawPath(ear, p);
    p.color = const Color(0xFFD98F89);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(c.dx + 15, c.dy + 2), width: 5, height: 4), p);
    p.color = _woodDark;
    canvas.drawCircle(Offset(c.dx + 14.2, c.dy + 2), 0.7, p);
    canvas.drawCircle(Offset(c.dx + 15.8, c.dy + 2), 0.7, p);
    canvas.drawCircle(Offset(c.dx + 10, c.dy - 1), 0.9, p);
    p.color = _pig;
    canvas.drawRect(Rect.fromLTRB(c.dx - 6, c.dy + 4, c.dx - 3, c.dy + 8), p);
    canvas.drawRect(Rect.fromLTRB(c.dx + 3, c.dy + 4, c.dx + 6, c.dy + 8), p);
    p.color = const Color(0xFFD98F89);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.4;
    final tail = Path()
      ..moveTo(c.dx - 11, c.dy - 1)
      ..quadraticBezierTo(c.dx - 15, c.dy - 3, c.dx - 13, c.dy - 5)
      ..quadraticBezierTo(c.dx - 11, c.dy - 6, c.dx - 12, c.dy - 3);
    canvas.drawPath(tail, p);
    p.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3) GOAT SHED — small (~66px). Raised wooden khor on stilts + ramp.
class GoatShed extends StatelessWidget {
  const GoatShed({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _GoatShedPainter())),
          Positioned(
            left: 20,
            top: 8,
            child: const _Straw()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(begin: -0.05, end: 0.05, duration: 2200.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

class _GoatShedPainter extends CustomPainter {
  const _GoatShedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.52, h - 4), width: w * 0.82, height: 12),
      _softShadow(),
    );

    final ground = h * 0.94;
    final boxL = w * 0.22, boxR = w * 0.82;
    final boxTop = h * 0.34, boxBot = h * 0.68;

    p.color = _woodDark;
    for (final sx in [boxL + 3, boxR - 3, (boxL + boxR) / 2]) {
      canvas.drawRect(Rect.fromLTRB(sx - 2, boxBot - 2, sx + 2, ground), p);
      p.color = _stone;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(sx, ground), width: 8, height: 4), p);
      p.color = _woodDark;
    }
    p.color = _wood;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.6;
    canvas.drawLine(
        Offset(boxL + 3, ground - 2), Offset(boxR - 3, boxBot + 3), p);
    p.style = PaintingStyle.fill;

    p.color = _wood;
    canvas.drawRect(Rect.fromLTRB(boxL, boxTop, boxR, boxBot), p);
    p.color = _woodDark.withValues(alpha: 0.5);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1;
    for (double py = boxTop + 5; py < boxBot; py += 6) {
      canvas.drawLine(Offset(boxL, py), Offset(boxR, py), p);
    }
    p.style = PaintingStyle.fill;
    p.color = _woodDark.withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTRB(boxR - 8, boxTop, boxR, boxBot), p);

    final dL = boxL + 6, dR = boxL + 22, dT = boxTop + 6, dB = boxBot - 4;
    p.color = _dark;
    canvas.drawRect(Rect.fromLTRB(dL, dT, dR, dB), p);
    p.color = _wood;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.2;
    for (double bx = dL + 3; bx < dR; bx += 4) {
      canvas.drawLine(Offset(bx, dT), Offset(bx, dB), p);
    }
    p.style = PaintingStyle.fill;

    final apex = Offset((boxL + boxR) / 2, h * 0.10);
    final eaveL = Offset(boxL - 8, boxTop + 3);
    final eaveR = Offset(boxR + 8, boxTop + 3);
    final roof = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(eaveR.dx, eaveR.dy)
      ..lineTo(eaveR.dx - 3, eaveR.dy + 5)
      ..lineTo(eaveL.dx + 3, eaveL.dy + 5)
      ..lineTo(eaveL.dx, eaveL.dy)
      ..close();
    p.color = _thatch;
    canvas.drawPath(roof, p);
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFFB68A3E).withValues(alpha: 0.8);
    for (int i = 1; i < 8; i++) {
      final f = i / 8.0;
      final t = Offset.lerp(apex, eaveL, f)!;
      canvas.drawLine(t, Offset(t.dx, t.dy + 4), p);
      final t2 = Offset.lerp(apex, eaveR, f)!;
      canvas.drawLine(t2, Offset(t2.dx, t2.dy + 4), p);
    }
    p.strokeWidth = 1;
    p.color = _thatch;
    for (double fx = eaveL.dx + 2; fx < eaveR.dx; fx += 3) {
      canvas.drawLine(Offset(fx, eaveL.dy + 5), Offset(fx - 0.5, eaveL.dy + 9), p);
    }
    p.style = PaintingStyle.fill;
    p.color = _woodDark;
    canvas.drawCircle(apex, 2, p);

    final rampTop = Offset(dR - 2, dB);
    final rampBot = Offset(w * 0.06, ground);
    p.color = _wood;
    final ramp = Path()
      ..moveTo(rampTop.dx, rampTop.dy - 2)
      ..lineTo(rampTop.dx, rampTop.dy + 3)
      ..lineTo(rampBot.dx, rampBot.dy)
      ..lineTo(rampBot.dx, rampBot.dy - 4)
      ..close();
    canvas.drawPath(ramp, p);
    p.color = _woodDark;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.2;
    for (int i = 1; i < 5; i++) {
      final f = i / 5.0;
      final a = Offset.lerp(rampTop, rampBot, f)!;
      canvas.drawLine(Offset(a.dx - 2, a.dy - 2), Offset(a.dx + 2, a.dy + 2), p);
    }
    p.style = PaintingStyle.fill;

    _drawGoat(canvas, Offset(dR + 6, boxTop + 16), p);
  }

  void _drawGoat(Canvas canvas, Offset c, Paint p) {
    p.color = _goat;
    final head = Path()
      ..moveTo(c.dx - 5, c.dy - 5)
      ..quadraticBezierTo(c.dx - 7, c.dy + 4, c.dx - 2, c.dy + 8)
      ..quadraticBezierTo(c.dx + 2, c.dy + 10, c.dx + 5, c.dy + 6)
      ..quadraticBezierTo(c.dx + 7, c.dy - 2, c.dx + 4, c.dy - 6)
      ..quadraticBezierTo(c.dx, c.dy - 9, c.dx - 5, c.dy - 5)
      ..close();
    canvas.drawPath(head, p);
    p.color = const Color(0xFFCFC4B3);
    final earL = Path()
      ..moveTo(c.dx - 5, c.dy - 3)
      ..lineTo(c.dx - 10, c.dy)
      ..lineTo(c.dx - 5, c.dy + 2)
      ..close();
    canvas.drawPath(earL, p);
    final earR = Path()
      ..moveTo(c.dx + 5, c.dy - 3)
      ..lineTo(c.dx + 9, c.dy)
      ..lineTo(c.dx + 5, c.dy + 2)
      ..close();
    canvas.drawPath(earR, p);
    p.color = const Color(0xFFEDE6D6);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.6;
    canvas.drawArc(
        Rect.fromCenter(center: Offset(c.dx - 2, c.dy - 8), width: 6, height: 6),
        -0.4, 2.0, false, p);
    canvas.drawArc(
        Rect.fromCenter(center: Offset(c.dx + 2, c.dy - 8), width: 6, height: 6),
        1.2, 2.0, false, p);
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFFEDE6DA);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + 6), width: 6, height: 5), p);
    p.color = _dark;
    canvas.drawCircle(Offset(c.dx - 2.5, c.dy + 1), 1.1, p);
    canvas.drawCircle(Offset(c.dx + 2.5, c.dy + 1), 1.1, p);
    canvas.drawCircle(Offset(c.dx, c.dy + 6.5), 0.8, p);
    p.color = _goat;
    final beard = Path()
      ..moveTo(c.dx - 1, c.dy + 8)
      ..lineTo(c.dx, c.dy + 13)
      ..lineTo(c.dx + 1, c.dy + 8)
      ..close();
    canvas.drawPath(beard, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Puff extends StatelessWidget {
  const _Puff({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Straw extends StatelessWidget {
  const _Straw();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 10,
      height: 12,
      child: CustomPaint(painter: _StrawPainter()),
    );
  }
}

class _StrawPainter extends CustomPainter {
  const _StrawPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _thatch
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final base = Offset(size.width / 2, size.height);
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(base, Offset(base.dx + i * 1.8, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}