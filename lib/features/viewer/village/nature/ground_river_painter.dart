import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Foreground of the Nepali hill-village scene: green meadow ground with grass
/// texture, a winding perspective dirt path, a curving river with reflections
/// and ripples, a small arched wooden bridge, riverbank stones and tiny
/// scattered flowers. Covers roughly y 0.62–1.00.
///
/// Static CustomPainter — deterministic (seeded), no animation state.
class GroundRiverPainter extends CustomPainter {
  const GroundRiverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Deterministic pseudo-randomness so the scene is stable across repaints.
    final rnd = math.Random(20260713);

    _paintMeadow(canvas, size, w, h);
    _paintGrassTexture(canvas, size, w, h, rnd);
    _paintRiver(canvas, size, w, h, rnd);
    _paintPath(canvas, size, w, h);
    _paintBridge(canvas, size, w, h);
    _paintBankStones(canvas, size, w, h, rnd);
    _paintFlowers(canvas, size, w, h, rnd);
  }

  // ---------------------------------------------------------------------------
  // MEADOW — vertical green gradient ground filling the foreground band.
  // ---------------------------------------------------------------------------
  void _paintMeadow(Canvas canvas, Size size, double w, double h) {
    final top = h * 0.615;
    final ground = Rect.fromLTRB(0, top, w, h);

    // Soft undulating top edge so the meadow meets the mid-hills organically.
    final meadowPath = Path()..moveTo(0, top + h * 0.02);
    meadowPath.cubicTo(
      w * 0.18, top - h * 0.012,
      w * 0.34, top + h * 0.028,
      w * 0.50, top + h * 0.008,
    );
    meadowPath.cubicTo(
      w * 0.66, top - h * 0.014,
      w * 0.82, top + h * 0.03,
      w, top + h * 0.006,
    );
    meadowPath.lineTo(w, h);
    meadowPath.lineTo(0, h);
    meadowPath.close();

    final grad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF6BAF66),
        Color(0xFF5CA25A),
        Color(0xFF4F8C50),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(ground);

    canvas.drawPath(meadowPath, Paint()..shader = grad);

    // Broad soft light band across the mid-meadow (sunlit sweep).
    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF8CC77E).withValues(alpha: 0.0),
          const Color(0xFF8CC77E).withValues(alpha: 0.28),
          const Color(0xFF8CC77E).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, top, w, top + h * 0.14));
    final lightBand = Path()
      ..moveTo(0, top + h * 0.03)
      ..quadraticBezierTo(w * 0.5, top - h * 0.01, w, top + h * 0.03)
      ..lineTo(w, top + h * 0.13)
      ..quadraticBezierTo(w * 0.5, top + h * 0.09, 0, top + h * 0.13)
      ..close();
    canvas.drawPath(lightBand, lightPaint);

    // Gentle darker shadow pooling near the very bottom foreground corners.
    final cornerShade = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3F7742).withValues(alpha: 0.32),
          const Color(0xFF3F7742).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(w * 0.04, h * 1.02), radius: w * 0.30));
    canvas.drawRect(ground, cornerShade);
    final cornerShade2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3F7742).withValues(alpha: 0.30),
          const Color(0xFF3F7742).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(w * 0.97, h * 1.03), radius: w * 0.28));
    canvas.drawRect(ground, cornerShade2);
  }

  // ---------------------------------------------------------------------------
  // GRASS TEXTURE — scattered tufts / darker blades / light highlights.
  // Denser and larger toward the foreground (perspective), low alpha.
  // ---------------------------------------------------------------------------
  void _paintGrassTexture(
      Canvas canvas, Size size, double w, double h, math.Random rnd) {
    final top = h * 0.63;

    // Many short blades. Scale + density grow toward the bottom.
    for (int i = 0; i < 620; i++) {
      final ty = rnd.nextDouble(); // 0 = far/top, 1 = near/bottom
      // Bias distribution toward the foreground.
      final biased = ty * ty;
      final y = top + biased * (h - top);
      final x = rnd.nextDouble() * w;

      // Perspective scale.
      final scale = 0.28 + biased * 1.0;
      final bladeH = (h * 0.010) * scale * (0.6 + rnd.nextDouble() * 0.9);
      final lean = (rnd.nextDouble() - 0.5) * bladeH * 0.7;

      // Color: mostly darker green blades, some lighter highlights.
      final isLight = rnd.nextDouble() < 0.30;
      final Color c = isLight
          ? const Color(0xFF9AD07F)
          : const Color(0xFF3E7A43);
      final alpha = (isLight ? 0.14 : 0.20) * (0.5 + biased * 0.7);

      final p = Paint()
        ..color = c.withValues(alpha: alpha.clamp(0.05, 0.34))
        ..strokeWidth = (0.8 + scale * 1.1)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x + lean * 0.5, y - bladeH * 0.6, x + lean, y - bladeH);
      canvas.drawPath(path, p);
    }

    // A few denser tuft clumps in the foreground for richness.
    for (int i = 0; i < 46; i++) {
      final biased = math.pow(rnd.nextDouble(), 0.6).toDouble();
      final y = top + (0.35 + biased * 0.65) * (h - top);
      final x = rnd.nextDouble() * w;
      final scale = 0.5 + biased * 1.2;
      _grassTuft(canvas, Offset(x, y), scale, h, rnd);
    }
  }

  void _grassTuft(
      Canvas canvas, Offset base, double scale, double h, math.Random rnd) {
    final blades = 5 + rnd.nextInt(4);
    for (int b = 0; b < blades; b++) {
      final t = (b / (blades - 1)) - 0.5; // -0.5..0.5 spread
      final bh = h * 0.016 * scale * (0.7 + rnd.nextDouble() * 0.6);
      final dx = t * h * 0.010 * scale;
      final lean = dx * 1.6 + (rnd.nextDouble() - 0.5) * bh * 0.3;
      final isLight = rnd.nextDouble() < 0.35;
      final c = isLight ? const Color(0xFF9AD07F) : const Color(0xFF3B7440);
      final p = Paint()
        ..color = c.withValues(alpha: isLight ? 0.22 : 0.28)
        ..strokeWidth = 1.0 + scale * 0.9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(base.dx + dx, base.dy)
        ..quadraticBezierTo(
            base.dx + dx + lean * 0.4, base.dy - bh * 0.6,
            base.dx + dx + lean, base.dy - bh);
      canvas.drawPath(path, p);
    }
  }

  // ---------------------------------------------------------------------------
  // RIVER — gentle curving band low in the frame with reflections + ripples.
  // ---------------------------------------------------------------------------
  // River centreline as a function of x, so path + bridge can align to it.
  double _riverCenterY(double x, double w, double h) {
    final t = x / w;
    return h * (0.905
        + 0.028 * math.sin(t * math.pi * 1.7 + 0.6)
        - 0.010 * math.cos(t * math.pi * 3.1));
  }

  double _riverHalfWidth(double x, double w, double h) {
    // Slightly wider toward the right/foreground.
    final t = x / w;
    return h * (0.045 + 0.022 * t + 0.010 * math.sin(t * math.pi * 2.0));
  }

  void _paintRiver(
      Canvas canvas, Size size, double w, double h, math.Random rnd) {
    const steps = 48;

    Path buildBand() {
      final path = Path();
      path.moveTo(0, _riverCenterY(0, w, h) - _riverHalfWidth(0, w, h));
      for (int i = 1; i <= steps; i++) {
        final x = w * i / steps;
        path.lineTo(x, _riverCenterY(x, w, h) - _riverHalfWidth(x, w, h));
      }
      for (int i = steps; i >= 0; i--) {
        final x = w * i / steps;
        path.lineTo(x, _riverCenterY(x, w, h) + _riverHalfWidth(x, w, h));
      }
      path.close();
      return path;
    }

    final band = buildBand();

    // Damp grassy fringe / bank shadow just around the river.
    canvas.save();
    canvas.drawShadow(band, const Color(0xFF2E5E52), h * 0.006, false);
    canvas.restore();

    final riverRect = Rect.fromLTRB(0, h * 0.86, w, h);
    final riverPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF8FCAD3),
          Color(0xFF63AAB4),
          Color(0xFF4C94A3),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(riverRect);
    canvas.drawPath(band, riverPaint);

    // Clip subsequent water details to the band.
    canvas.save();
    canvas.clipPath(band);

    // Long horizontal reflection highlight bands (#CDEDEF), soft.
    for (int i = 0; i < 5; i++) {
      final frac = 0.15 + i * 0.16;
      final hp = Paint()
        ..color = const Color(0xFFCDEDEF)
            .withValues(alpha: 0.12 + rnd.nextDouble() * 0.14)
        ..strokeWidth = h * (0.004 + rnd.nextDouble() * 0.006)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      final baseOff = (rnd.nextDouble() - 0.5) * h * 0.02;
      for (int s = 0; s <= steps; s++) {
        final x = w * s / steps;
        final cy = _riverCenterY(x, w, h);
        final hw = _riverHalfWidth(x, w, h);
        final y = cy + (frac - 0.5) * 2 * hw * 0.8 + baseOff
            + math.sin(x / w * math.pi * 6 + i) * h * 0.004;
        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, hp);
    }

    // Short shimmering ripple dashes.
    for (int i = 0; i < 90; i++) {
      final x = rnd.nextDouble() * w;
      final cy = _riverCenterY(x, w, h);
      final hw = _riverHalfWidth(x, w, h);
      final y = cy + (rnd.nextDouble() - 0.5) * 1.7 * hw;
      final len = h * (0.008 + rnd.nextDouble() * 0.02);
      final light = rnd.nextBool();
      final p = Paint()
        ..color = (light
                ? const Color(0xFFCDEDEF)
                : const Color(0xFF3E8494))
            .withValues(alpha: 0.10 + rnd.nextDouble() * 0.16)
        ..strokeWidth = h * 0.0022
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x - len / 2, y), Offset(x + len / 2, y), p);
    }

    // Bright top-edge glint where the river meets the light.
    final glint = Paint()
      ..color = const Color(0xFFCDEDEF).withValues(alpha: 0.4)
      ..strokeWidth = h * 0.0035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final glintPath = Path();
    for (int s = 0; s <= steps; s++) {
      final x = w * s / steps;
      final y = _riverCenterY(x, w, h) - _riverHalfWidth(x, w, h) + h * 0.004;
      if (s == 0) {
        glintPath.moveTo(x, y);
      } else {
        glintPath.lineTo(x, y);
      }
    }
    canvas.drawPath(glintPath, glint);

    canvas.restore(); // end clip

    // Soft darker grass lip along the top bank edge for grounding.
    final lip = Paint()
      ..color = const Color(0xFF3D7A45).withValues(alpha: 0.5)
      ..strokeWidth = h * 0.010
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final lipPath = Path();
    for (int s = 0; s <= steps; s++) {
      final x = w * s / steps;
      final y = _riverCenterY(x, w, h) - _riverHalfWidth(x, w, h) - h * 0.002;
      if (s == 0) {
        lipPath.moveTo(x, y);
      } else {
        lipPath.lineTo(x, y);
      }
    }
    canvas.drawPath(lipPath, lip);
  }

  // ---------------------------------------------------------------------------
  // DIRT PATH — meanders from bottom foreground up toward the village,
  // narrowing with distance. Crosses the river at the bridge point.
  // ---------------------------------------------------------------------------
  // Path centre x as a function of vertical parameter t (0 far/top -> 1 near).
  double _pathCenterX(double t, double w) {
    // Village entry (far) around 0.42w, foreground exit around 0.60w, winding.
    return w * (0.44
        + 0.10 * math.sin(t * math.pi * 1.15)
        + 0.10 * t
        - 0.05 * math.cos(t * math.pi * 2.2));
  }

  void _paintPath(Canvas canvas, Size size, double w, double h) {
    final yFar = h * 0.635; // near village
    final yNear = h; // bottom of frame
    const steps = 40;

    // Half-width grows with t (perspective): thin far, wide near.
    double halfW(double t) => w * (0.006 + 0.052 * t * t);

    Offset pointAt(double t) {
      final y = yFar + (yNear - yFar) * t;
      return Offset(_pathCenterX(t, w), y);
    }

    // Build outline (left edge down then right edge up).
    final outline = Path();
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final c = pointAt(t);
      outline.lineTo(c.dx - halfW(t), c.dy);
      if (i == 0) {
        outline.moveTo(c.dx - halfW(t), c.dy);
        outline.lineTo(c.dx - halfW(t), c.dy);
      }
    }
    for (int i = steps; i >= 0; i--) {
      final t = i / steps;
      final c = pointAt(t);
      outline.lineTo(c.dx + halfW(t), c.dy);
    }
    outline.close();

    // Darker edge underlay (#C7A86F) slightly wider.
    final edgePath = Path();
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final c = pointAt(t);
      final hwd = halfW(t) + w * 0.006 * (0.4 + t);
      if (i == 0) {
        edgePath.moveTo(c.dx - hwd, c.dy);
      } else {
        edgePath.lineTo(c.dx - hwd, c.dy);
      }
    }
    for (int i = steps; i >= 0; i--) {
      final t = i / steps;
      final c = pointAt(t);
      final hwd = halfW(t) + w * 0.006 * (0.4 + t);
      edgePath.lineTo(c.dx + hwd, c.dy);
    }
    edgePath.close();

    canvas.drawPath(
        edgePath,
        Paint()
          ..color = const Color(0xFFC7A86F)
          ..style = PaintingStyle.fill);

    // Main dirt fill with a subtle vertical light gradient.
    canvas.drawPath(
        outline,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFEAD9AB), Color(0xFFE3CF9E), Color(0xFFD8C089)],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromLTRB(0, yFar, w, yNear)));

    // Center worn lighter streak + a few pebble specks for texture.
    final rnd = math.Random(77);
    final center = Paint()
      ..color = const Color(0xFFF0E2B8).withValues(alpha: 0.5)
      ..strokeWidth = w * 0.004
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final centerPath = Path();
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final c = pointAt(t);
      if (i == 0) {
        centerPath.moveTo(c.dx, c.dy);
      } else {
        centerPath.lineTo(c.dx, c.dy);
      }
    }
    canvas.drawPath(centerPath, center);

    for (int i = 0; i < 70; i++) {
      final t = math.pow(rnd.nextDouble(), 0.7).toDouble();
      final c = pointAt(t);
      final hw = halfW(t);
      final px = c.dx + (rnd.nextDouble() - 0.5) * 1.7 * hw;
      final py = c.dy + (rnd.nextDouble() - 0.5) * (yNear - yFar) / steps;
      final dark = rnd.nextBool();
      canvas.drawCircle(
          Offset(px, py),
          (0.6 + t * 1.8) * (0.6 + rnd.nextDouble()),
          Paint()
            ..color = (dark
                    ? const Color(0xFFB79763)
                    : const Color(0xFFF3E7BE))
                .withValues(alpha: 0.4));
    }
  }

  // ---------------------------------------------------------------------------
  // BRIDGE — small arched wooden bridge crossing the river near the path.
  // ---------------------------------------------------------------------------
  void _paintBridge(Canvas canvas, Size size, double w, double h) {
    // Anchor bridge to where the path meets the river band.
    final cx = _pathCenterX(0.72, w);
    final cy = _riverCenterY(cx, w, h);
    final span = w * 0.11; // half-span across river
    final deckThick = h * 0.014;
    final archRise = h * 0.045;

    final leftX = cx - span;
    final rightX = cx + span;
    final baseY = cy + h * 0.010;

    // Bridge shadow on the water.
    final shadow = Path()
      ..moveTo(leftX, baseY + h * 0.006)
      ..quadraticBezierTo(cx, baseY - archRise + h * 0.012,
          rightX, baseY + h * 0.006)
      ..quadraticBezierTo(cx, baseY + h * 0.020, leftX, baseY + h * 0.006)
      ..close();
    canvas.drawPath(
        shadow,
        Paint()
          ..color = const Color(0xFF33484F).withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Under-arch (dark wood) — the curved deck underside.
    final underTop = Path()
      ..moveTo(leftX, baseY)
      ..quadraticBezierTo(cx, baseY - archRise, rightX, baseY);

    // Deck body (mid wood) as a thick arched band.
    final deck = Path()
      ..moveTo(leftX, baseY)
      ..quadraticBezierTo(cx, baseY - archRise, rightX, baseY)
      ..lineTo(rightX, baseY - deckThick)
      ..quadraticBezierTo(
          cx, baseY - archRise - deckThick, leftX, baseY - deckThick)
      ..close();
    canvas.drawPath(deck, Paint()..color = const Color(0xFF8A5A3C));

    // Dark underside edge.
    canvas.drawPath(
        underTop,
        Paint()
          ..color = const Color(0xFF5E3B26)
          ..strokeWidth = h * 0.004
          ..style = PaintingStyle.stroke);

    // Deck planks (vertical-ish short lines across the arch, dark grooves).
    const planks = 13;
    for (int i = 1; i < planks; i++) {
      final t = i / planks;
      final px = leftX + (rightX - leftX) * t;
      // y on the top arch curve (quadratic bezier interpolation).
      final topY = _quadY(baseY, baseY - archRise - deckThick, baseY, t);
      final botY = _quadY(baseY, baseY - archRise, baseY, t);
      canvas.drawLine(
          Offset(px, topY),
          Offset(px, botY),
          Paint()
            ..color = const Color(0xFF5E3B26).withValues(alpha: 0.55)
            ..strokeWidth = h * 0.0016);
    }

    // Top highlight on the deck (sunlit plank tops).
    final deckTop = Path()
      ..moveTo(leftX, baseY - deckThick)
      ..quadraticBezierTo(
          cx, baseY - archRise - deckThick, rightX, baseY - deckThick);
    canvas.drawPath(
        deckTop,
        Paint()
          ..color = const Color(0xFFAE7A54).withValues(alpha: 0.8)
          ..strokeWidth = h * 0.003
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Railings — two arched rails with posts on each side.
    final railH = h * 0.05;
    for (final side in [1.0, 0.62]) {
      final rr = archRise * side;
      final lift = railH * side;
      final rail = Path()
        ..moveTo(leftX, baseY - deckThick - lift)
        ..quadraticBezierTo(cx, baseY - deckThick - rr - lift,
            rightX, baseY - deckThick - lift);
      canvas.drawPath(
          rail,
          Paint()
            ..color = const Color(0xFF6E4630)
            ..strokeWidth = h * 0.004
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
    // Vertical posts connecting deck to top rail.
    const posts = 7;
    for (int i = 0; i <= posts; i++) {
      final t = i / posts;
      final px = leftX + (rightX - leftX) * t;
      final deckY = _quadY(baseY - deckThick,
          baseY - archRise - deckThick, baseY - deckThick, t);
      final railY = _quadY(baseY - deckThick - railH,
          baseY - archRise - deckThick - railH, baseY - deckThick - railH, t);
      canvas.drawLine(
          Offset(px, deckY),
          Offset(px, railY),
          Paint()
            ..color = const Color(0xFF5E3B26)
            ..strokeWidth = h * 0.0028
            ..strokeCap = StrokeCap.round);
    }

    // Small support pilings at each bank end into the water.
    for (final bx in [leftX + span * 0.12, rightX - span * 0.12]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(bx - w * 0.006, baseY - h * 0.004,
                  w * 0.012, h * 0.028),
              Radius.circular(w * 0.003)),
          Paint()..color = const Color(0xFF5E3B26));
    }
  }

  // Quadratic bezier Y interpolation for control p1 between endpoints p0,p2.
  double _quadY(double p0, double p1, double p2, double t) {
    final mt = 1 - t;
    return mt * mt * p0 + 2 * mt * t * p1 + t * t * p2;
  }

  // ---------------------------------------------------------------------------
  // BANK STONES — clustered along the riverbank edges.
  // ---------------------------------------------------------------------------
  void _paintBankStones(
      Canvas canvas, Size size, double w, double h, math.Random rnd) {
    for (int i = 0; i < 70; i++) {
      final x = rnd.nextDouble() * w;
      final cy = _riverCenterY(x, w, h);
      final hw = _riverHalfWidth(x, w, h);
      // Place near top or bottom bank edge.
      final topBank = rnd.nextBool();
      final edge = topBank ? cy - hw : cy + hw;
      final jitter = (rnd.nextDouble()) * h * 0.02 * (topBank ? -1 : 1);
      final y = edge + jitter;

      final r = h * (0.006 + rnd.nextDouble() * 0.012);
      // Stone base with slight ellipse + top highlight + bottom shadow.
      final grey = 0.55 + rnd.nextDouble() * 0.25;
      final base = Color.fromARGB(255, (150 * grey + 60).round(),
          (150 * grey + 62).round(), (150 * grey + 66).round());

      // Shadow.
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y + r * 0.5),
              width: r * 2.3,
              height: r * 1.1),
          Paint()
            ..color = const Color(0xFF2E4148).withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      // Body.
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y), width: r * 2.1, height: r * 1.5),
          Paint()..color = base);
      // Highlight.
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x - r * 0.3, y - r * 0.35),
              width: r * 1.0,
              height: r * 0.6),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.22));
    }

    // A few larger stones near the bridge feet for grounding.
    final bcx = _pathCenterX(0.72, w);
    for (int i = 0; i < 6; i++) {
      final x = bcx + (rnd.nextDouble() - 0.5) * w * 0.22;
      final cy = _riverCenterY(x, w, h);
      final hw = _riverHalfWidth(x, w, h);
      final y = cy + hw * (0.6 + rnd.nextDouble() * 0.5);
      final r = h * (0.012 + rnd.nextDouble() * 0.014);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y + r * 0.4), width: r * 2.4, height: r * 1.1),
          Paint()
            ..color = const Color(0xFF2E4148).withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y), width: r * 2.2, height: r * 1.6),
          Paint()..color = const Color(0xFF8E9298));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x - r * 0.35, y - r * 0.4),
              width: r * 1.1,
              height: r * 0.6),
          Paint()..color = Colors.white.withValues(alpha: 0.20));
    }
  }

  // ---------------------------------------------------------------------------
  // FLOWERS — tiny scattered dots (pink/yellow/white) in the meadow grass.
  // ---------------------------------------------------------------------------
  void _paintFlowers(
      Canvas canvas, Size size, double w, double h, math.Random rnd) {
    final top = h * 0.65;
    const flowerColors = [
      Color(0xFFE8749E), // pink
      Color(0xFFF2C879), // yellow
      Color(0xFFFFFFFF), // white
      Color(0xFFB79BE0), // lavender
    ];

    for (int i = 0; i < 150; i++) {
      final biased = math.pow(rnd.nextDouble(), 0.85).toDouble();
      final y = top + biased * (h - top);
      // Avoid scattering flowers inside the river band.
      final x = rnd.nextDouble() * w;
      final cy = _riverCenterY(x, w, h);
      final hw = _riverHalfWidth(x, w, h);
      if ((y - cy).abs() < hw + h * 0.01) continue;

      final scale = 0.5 + biased * 1.2;
      final c = flowerColors[rnd.nextInt(flowerColors.length)];
      final r = h * 0.0038 * scale;

      // Small 5-petal dab: draw as a few tiny circles + center.
      final petals = 5;
      for (int p = 0; p < petals; p++) {
        final a = (p / petals) * math.pi * 2;
        final px = x + math.cos(a) * r;
        final py = y + math.sin(a) * r * 0.9;
        canvas.drawCircle(
            Offset(px, py),
            r * 0.7,
            Paint()..color = c.withValues(alpha: 0.85));
      }
      // Center dot.
      canvas.drawCircle(
          Offset(x, y),
          r * 0.6,
          Paint()
            ..color = (c == const Color(0xFFF2C879)
                    ? const Color(0xFFE79B3C)
                    : const Color(0xFFF2C879))
                .withValues(alpha: 0.9));
    }

    // A couple of small clustered flower patches for density.
    for (int cl = 0; cl < 5; cl++) {
      final biased = 0.4 + rnd.nextDouble() * 0.6;
      final baseY = top + biased * (h - top);
      final baseX = rnd.nextDouble() * w;
      final cy = _riverCenterY(baseX, w, h);
      final hw = _riverHalfWidth(baseX, w, h);
      if ((baseY - cy).abs() < hw + h * 0.02) continue;
      final c = flowerColors[rnd.nextInt(flowerColors.length)];
      for (int i = 0; i < 8; i++) {
        final x = baseX + (rnd.nextDouble() - 0.5) * w * 0.03;
        final y = baseY + (rnd.nextDouble() - 0.5) * h * 0.02;
        final r = h * 0.004 * (0.7 + rnd.nextDouble() * 0.8);
        for (int p = 0; p < 5; p++) {
          final a = (p / 5) * math.pi * 2;
          canvas.drawCircle(
              Offset(x + math.cos(a) * r, y + math.sin(a) * r * 0.9),
              r * 0.7,
              Paint()..color = c.withValues(alpha: 0.85));
        }
        canvas.drawCircle(Offset(x, y), r * 0.55,
            Paint()..color = const Color(0xFFF2C879).withValues(alpha: 0.9));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}