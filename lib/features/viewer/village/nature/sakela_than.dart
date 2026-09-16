import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// SakelaThan — the Rai/Kirat sacred spot: a natural grove clearing (NOT a
/// temple). Nature-worship for **Sumnima** (earth mother) & **Paruhang** (sky
/// father): a low earthen/stone altar mound holding upright sacred stones (the
/// *chandi*), a leafy sacred branch behind, marigold & green-leaf offerings, a
/// ring of stones marking the Sakela *sili* dance circle, and two bamboo poles
/// with plain cloth streamers. Gentle sway on the streamers & leaves only.
///
/// Intrinsic size ~ [width] wide by (width * 0.82) tall; feet at the bottom.
class SakelaThan extends StatelessWidget {
  const SakelaThan({super.key, this.width = 200});

  final double width;

  @override
  Widget build(BuildContext context) {
    final double height = width * 0.82;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Static grove: mound, dance-ring stones, sacred stones, offerings.
          Positioned.fill(child: CustomPaint(painter: _SakelaPainter())),
          // Left bamboo streamer (soft flag sway).
          Positioned(
            left: width * 0.075,
            top: 0,
            width: width * 0.30,
            height: height * 0.60,
            child: const _ClothStreamer(color: Color(0xFFE8C15A), flip: false),
          ),
          // Right bamboo streamer.
          Positioned(
            right: width * 0.075,
            top: height * 0.03,
            width: width * 0.30,
            height: height * 0.58,
            child: const _ClothStreamer(color: Color(0xFFCF6B5C), flip: true),
          ),
          // Sacred leafy branch behind the stones — gentle breathing sway.
          Positioned(
            left: width * 0.30,
            top: -height * 0.10,
            width: width * 0.40,
            height: height * 0.55,
            child: const _SacredLeaves(),
          ),
        ],
      ),
    );
  }
}

/// A tall bamboo pole with a plain cloth streamer that sways in the breeze.
class _ClothStreamer extends StatelessWidget {
  const _ClothStreamer({required this.color, required this.flip});
  final Color color;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    // NOTE: this widget is placed inside a Positioned in SakelaThan's Stack, so
    // it must NOT itself return a Positioned — return the sized painter.
    return CustomPaint(
      painter: _StreamerPainter(color, flip),
      child: const SizedBox.expand(),
    )
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .moveX(
            begin: flip ? 1.4 : -1.4,
            end: flip ? -1.4 : 1.4,
            duration: 2400.ms,
            curve: Curves.easeInOut);
  }
}

class _StreamerPainter extends CustomPainter {
  _StreamerPainter(this.color, this.flip);
  final Color color;
  final bool flip;
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;
    // Bamboo pole on the outer side.
    final double poleX = flip ? w * 0.82 : w * 0.18;
    p
      ..color = const Color(0xFF8B6A3A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(poleX - w * 0.03, 0, w * 0.06, h), const Radius.circular(3)),
      p,
    );
    // Node rings on the bamboo.
    p
      ..color = const Color(0xFF6E5228)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int i = 1; i < 4; i++) {
      final double y = h * i / 4;
      canvas.drawLine(Offset(poleX - w * 0.03, y), Offset(poleX + w * 0.03, y), p);
    }
    p.style = PaintingStyle.fill;
    // Cloth streamers hanging from the top, drifting inward.
    final double dir = flip ? -1 : 1;
    for (int i = 0; i < 2; i++) {
      final double topY = h * (0.06 + i * 0.14);
      final Path cloth = Path()
        ..moveTo(poleX, topY)
        ..quadraticBezierTo(poleX + dir * w * 0.30, topY + h * 0.10,
            poleX + dir * w * 0.55, topY + h * 0.05)
        ..quadraticBezierTo(poleX + dir * w * 0.34, topY + h * 0.20,
            poleX + dir * w * 0.42, topY + h * 0.34)
        ..quadraticBezierTo(poleX + dir * w * 0.16, topY + h * 0.22,
            poleX, topY + h * 0.16)
        ..close();
      p.color = (i.isEven ? color : color.withValues(alpha: 0.85));
      canvas.drawPath(cloth, p);
      // subtle fold highlight
      p.color = Colors.white.withValues(alpha: 0.18);
      canvas.drawPath(cloth, p);
      p.color = color;
    }
  }

  @override
  bool shouldRepaint(covariant _StreamerPainter old) => false;
}

/// A soft cluster of sacred leaves that breathes gently (a living branch).
class _SacredLeaves extends StatelessWidget {
  const _SacredLeaves();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LeavesPainter())
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .rotate(
            begin: -0.012,
            end: 0.012,
            alignment: Alignment.bottomCenter,
            duration: 3000.ms,
            curve: Curves.easeInOut);
  }
}

class _LeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;
    // A leafy sacred branch — soft green canopy on a slim stem.
    p.color = const Color(0xFF6E4A2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.47, h * 0.45, w * 0.06, h * 0.55),
          const Radius.circular(3)),
      p,
    );
    final math.Random rnd = math.Random(11);
    final List<Color> greens = <Color>[
      const Color(0xFF6FAF5C),
      const Color(0xFF5C9A4E),
      const Color(0xFF7FBE63),
      const Color(0xFF4F8A57),
    ];
    for (int i = 0; i < 22; i++) {
      final double a = -math.pi / 2 + (rnd.nextDouble() - 0.5) * 2.2;
      final double r = h * (0.16 + rnd.nextDouble() * 0.30);
      final double cx = w * 0.5 + math.cos(a) * r * 0.9;
      final double cy = h * 0.42 + math.sin(a) * r * 0.7;
      p.color = greens[rnd.nextInt(greens.length)].withValues(alpha: 0.95);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(a + math.pi / 2);
      final Rect leaf = Rect.fromCenter(
          center: Offset.zero, width: w * 0.10, height: w * 0.20);
      canvas.drawOval(leaf, p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeavesPainter old) => false;
}

class _SakelaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;

    // ── Ground shadow ──
    p.color = const Color(0xFF3E7A44).withValues(alpha: 0.26);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.94),
            width: w * 0.86,
            height: h * 0.14),
        p);

    // ── Grassy clearing mound ──
    p.color = const Color(0xFF8FC06A);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.86),
            width: w * 0.80,
            height: h * 0.26),
        p);
    // lighter swept dance-ring inside
    p.color = const Color(0xFFB6D98A).withValues(alpha: 0.85);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.86),
            width: w * 0.62,
            height: h * 0.18),
        p);

    // ── Ring of small stones marking the Sakela dance circle ──
    p.color = const Color(0xFF9E8A72);
    for (int i = 0; i < 12; i++) {
      final double a = i / 12 * math.pi * 2;
      final double rx = w * 0.34, ry = h * 0.11;
      final Offset c = Offset(w * 0.5 + math.cos(a) * rx, h * 0.86 + math.sin(a) * ry);
      canvas.drawOval(
          Rect.fromCenter(center: c, width: w * 0.05, height: w * 0.035), p);
      p.color = const Color(0xFF8B7860);
      canvas.drawOval(
          Rect.fromCenter(
              center: c + Offset(0, w * 0.006), width: w * 0.05, height: w * 0.02),
          p);
      p.color = const Color(0xFF9E8A72);
    }

    // ── Earthen altar platform (the "than") ──
    final Rect platTop = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.70), width: w * 0.40, height: h * 0.10);
    // sides (mud)
    p.color = const Color(0xFF9C6B3E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTRB(platTop.left, platTop.center.dy, platTop.right, h * 0.80),
          const Radius.circular(4)),
      p,
    );
    // stone rim around the base
    p.color = const Color(0xFF8B7860);
    for (double x = platTop.left; x < platTop.right - 2; x += w * 0.055) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, h * 0.755, w * 0.05, h * 0.04),
            const Radius.circular(3)),
        p,
      );
    }
    // platform top (packed earth, lit)
    p.color = const Color(0xFFC08A54);
    canvas.drawOval(platTop, p);
    p.color = const Color(0xFFD8A96E).withValues(alpha: 0.8);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(platTop.center.dx, platTop.top + platTop.height * 0.42),
            width: platTop.width * 0.9,
            height: platTop.height * 0.7),
        p);

    // ── Sacred upright stones (the chandi) — three, weathered grey ──
    void stone(double cx, double baseY, double sw, double sh, Color col) {
      final Path st = Path()
        ..moveTo(cx - sw * 0.5, baseY)
        ..lineTo(cx - sw * 0.34, baseY - sh)
        ..quadraticBezierTo(cx, baseY - sh * 1.16, cx + sw * 0.34, baseY - sh)
        ..lineTo(cx + sw * 0.5, baseY)
        ..close();
      p.color = col;
      canvas.drawPath(st, p);
      // shaded right face
      p.color = Colors.black.withValues(alpha: 0.10);
      final Path sh2 = Path()
        ..moveTo(cx, baseY - sh * 1.02)
        ..lineTo(cx + sw * 0.34, baseY - sh)
        ..lineTo(cx + sw * 0.5, baseY)
        ..lineTo(cx, baseY)
        ..close();
      canvas.drawPath(sh2, p);
    }

    final double baseY = h * 0.70;
    stone(w * 0.38, baseY, w * 0.13, h * 0.22, const Color(0xFF9AA0A2));
    stone(w * 0.62, baseY, w * 0.13, h * 0.22, const Color(0xFF9AA0A2));
    // tallest central stone (Sumnima–Paruhang)
    stone(w * 0.50, baseY, w * 0.17, h * 0.34, const Color(0xFFAEB2B0));
    // a smear of sindoor-free ochre tika + a green leaf tucked on the central stone
    p.color = const Color(0xFFE0A93E).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(w * 0.50, baseY - h * 0.26), w * 0.018, p);

    // ── Offerings at the foot: marigolds + green leaves + a little brass pot ──
    // brass water pot (kalash)
    p.color = const Color(0xFFCB8E3C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(w * 0.585, baseY - h * 0.02),
              width: w * 0.07,
              height: h * 0.06),
          const Radius.circular(4)),
      p,
    );
    p.color = const Color(0xFFE3B860).withValues(alpha: 0.9);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.585, baseY - h * 0.045),
            width: w * 0.07,
            height: h * 0.016),
        p);
    // marigold cluster (left foot)
    void marigold(double cx, double cy, double r, Color col) {
      p.color = col;
      for (int k = 0; k < 8; k++) {
        final double a = k / 8 * math.pi * 2;
        canvas.drawCircle(
            Offset(cx + math.cos(a) * r * 0.6, cy + math.sin(a) * r * 0.6),
            r * 0.5, p);
      }
      p.color = const Color(0xFFE0A93E);
      canvas.drawCircle(Offset(cx, cy), r * 0.55, p);
    }

    marigold(w * 0.40, baseY - h * 0.01, w * 0.05, const Color(0xFFF2A93E));
    marigold(w * 0.45, baseY + h * 0.01, w * 0.045, const Color(0xFFF4B94F));
    marigold(w * 0.35, baseY + h * 0.015, w * 0.04, const Color(0xFFEF8F3A));
    // green leaf sprigs among the flowers
    p.color = const Color(0xFF5C9A4E);
    for (int i = 0; i < 5; i++) {
      final double lx = w * (0.33 + i * 0.03);
      canvas.save();
      canvas.translate(lx, baseY + h * 0.03);
      canvas.rotate(-0.4 + i * 0.2);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: w * 0.03, height: w * 0.075),
          p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SakelaPainter old) => false;
}
