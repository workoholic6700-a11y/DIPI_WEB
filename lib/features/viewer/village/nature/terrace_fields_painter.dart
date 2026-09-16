import 'package:flutter/material.dart';
import 'dart:math' as math;

/// TerraceFieldsPainter
///
/// Classic Nepali terraced hillside fields for the mid-ground of the
/// hill-village scene. Draws several rolling hill mounds (roughly y 0.46–0.68),
/// each carved into many gently-curved horizontal stepped terraces that follow
/// the hill's contour. Colors vary realistically: mostly fresh greens, a few
/// golden ripe/mustard bands, a couple of tilled-soil brown, and 1–2 shimmering
/// paddy-water terraces, plus 1–2 flatter paddy fields near the bottom.
///
/// Static painter (no animation state). Draw relative to size only.
class TerraceFieldsPainter extends CustomPainter {
  const TerraceFieldsPainter();

  // ---- Shared palette ------------------------------------------------------
  static const Color _green1 = Color(0xFF93C97A);
  static const Color _green2 = Color(0xFF7FBE6A);
  static const Color _green3 = Color(0xFFB7D98C);
  static const Color _gold = Color(0xFFE8C85F);
  static const Color _soil = Color(0xFFC39A6B);
  static const Color _paddy = Color(0xFFBFE0D8);

  // Category codes for per-terrace colouring.
  static const int _cGreen = 0;
  static const int _cGold = 1;
  static const int _cSoil = 2;
  static const int _cPaddy = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Soft haze wash behind the terraces so they sit into the misty mid-hills.
    final Paint haze = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFEAF3F5).withValues(alpha: 0.55),
          const Color(0xFFEAF3F5).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.44, w, h * 0.14));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.44, w, h * 0.16), haze);

    // ---- Rolling terraced mounds -------------------------------------------
    // Each entry: centerX frac, baseY frac, topY frac, halfWidth frac,
    // terrace count, seed. Overlapping mounds read as a continuous ridge.
    _drawMound(canvas, size,
        cx: w * 0.14, baseY: h * 0.635, topY: h * 0.485,
        maxHalf: w * 0.20, nTerraces: 11, seed: 3);
    _drawMound(canvas, size,
        cx: w * 0.44, baseY: h * 0.655, topY: h * 0.470,
        maxHalf: w * 0.24, nTerraces: 13, seed: 7);
    _drawMound(canvas, size,
        cx: w * 0.72, baseY: h * 0.645, topY: h * 0.490,
        maxHalf: w * 0.22, nTerraces: 12, seed: 11);
    _drawMound(canvas, size,
        cx: w * 0.93, baseY: h * 0.660, topY: h * 0.500,
        maxHalf: w * 0.18, nTerraces: 10, seed: 17);

    // ---- Flatter paddy fields near the bottom of the band ------------------
    _drawPaddyField(canvas, size,
        cx: w * 0.30, cy: h * 0.660, halfW: w * 0.17, halfH: h * 0.018, seed: 2);
    _drawPaddyField(canvas, size,
        cx: w * 0.63, cy: h * 0.672, halfW: w * 0.20, halfH: h * 0.020, seed: 9);
  }

  // Deterministic pseudo-random in [0,1) from an integer + seed.
  double _rand(int i, int seed) {
    final double v = math.sin((i + 1) * 12.9898 + seed * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  // Pick a terrace colour category with a realistic distribution.
  int _category(int i, int seed) {
    final double r = _rand(i * 3 + 1, seed);
    if (r < 0.66) return _cGreen; // majority fresh green
    if (r < 0.80) return _cGold; // ripe rice / mustard
    if (r < 0.90) return _cSoil; // tilled soil
    return _cPaddy; // paddy water shimmer
  }

  Color _colorFor(int cat, int i, int seed) {
    switch (cat) {
      case _cGold:
        return _gold;
      case _cSoil:
        return _soil;
      case _cPaddy:
        return _paddy;
      default:
        final double r = _rand(i * 5 + 2, seed);
        if (r < 0.4) return _green1;
        if (r < 0.75) return _green2;
        return _green3;
    }
  }

  // ---- One terraced mound --------------------------------------------------
  void _drawMound(Canvas canvas, Size size,
      {required double cx,
      required double baseY,
      required double topY,
      required double maxHalf,
      required int nTerraces,
      required int seed}) {
    final double totalH = baseY - topY;
    final double step = totalH / nTerraces;

    // Draw bottom terrace first so upper terraces overlap their lower edge,
    // giving the stacked-step read.
    for (int i = 0; i < nTerraces; i++) {
      final double tBottom = i / nTerraces; // 0 bottom .. up
      final double tTop = (i + 1) / nTerraces;

      final double yBottom = baseY - i * step;
      final double yTop = baseY - (i + 1) * step;

      // Rounded dome silhouette: half-width shrinks toward the top.
      final double halfB = maxHalf * _profile(tBottom);
      final double halfT = maxHalf * _profile(tTop);

      // Gentle horizontal drift of the summit so mounds aren't symmetric.
      final double drift = (_rand(99, seed) - 0.5) * maxHalf * 0.35;
      final double cxT = cx + drift * tBottom;

      // Contour sag: wider (lower) terraces bow down more.
      final double sagB = halfB * 0.14 + step * 0.4;
      final double sagT = halfT * 0.14 + step * 0.4;

      final int cat = _category(i, seed);
      final Color base = _colorFor(cat, i, seed);

      // Slight tonal lift toward the top of the mound (light catching).
      final Color fill = Color.lerp(base, Colors.white, tBottom * 0.12)!;

      // Terrace band fill.
      final Path band = _bandPath(cxT, halfB, yBottom, sagB, halfT, yTop, sagT);
      canvas.drawPath(band, Paint()..color = fill..style = PaintingStyle.fill);

      // Darker inner shadow just under the top edge to carve the step.
      final Path topEdge = _contour(cxT, halfT, yTop, sagT);
      canvas.drawPath(
          topEdge,
          Paint()
            ..color = const Color(0xFF3E6B3B).withValues(alpha: 0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.0, step * 0.16)
            ..strokeCap = StrokeCap.round);

      // Bright grassy retaining-wall lip on the front (bottom) edge.
      final Path bottomEdge = _contour(cxT, halfB, yBottom, sagB);
      canvas.drawPath(
          bottomEdge,
          Paint()
            ..color = const Color(0xFFDDEFC2).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(0.8, step * 0.10)
            ..strokeCap = StrokeCap.round);

      // Crop-row / water texture inside the band.
      _texture(canvas, cat, cxT, halfT, halfB, yTop, yBottom, sagT, sagB, seed, i);
    }

    // Soft cast shadow on the ground at the mound base.
    final Path baseShadow = _contour(cx, maxHalf * _profile(0.0), baseY + step * 0.2,
        maxHalf * 0.16 + step * 0.4);
    canvas.drawPath(
        baseShadow,
        Paint()
          ..color = const Color(0xFF2E5A34).withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = step * 0.7
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  // Dome profile: 1 at base, tapering smoothly to a rounded top.
  double _profile(double t) {
    final double x = t.clamp(0.0, 1.0);
    return math.sqrt(math.max(0.0, 1.0 - x * x * 0.82));
  }

  // A single downward-bowing contour curve, left -> right.
  Path _contour(double cx, double half, double y, double sag) {
    final Path p = Path();
    p.moveTo(cx - half, y);
    p.quadraticBezierTo(cx, y + sag, cx + half, y);
    return p;
  }

  // Filled band between a bottom contour and a top contour.
  Path _bandPath(double cx, double halfB, double yB, double sagB, double halfT,
      double yT, double sagT) {
    final Path p = Path();
    p.moveTo(cx - halfB, yB);
    p.quadraticBezierTo(cx, yB + sagB, cx + halfB, yB); // bottom edge L->R
    p.lineTo(cx + halfT, yT);
    p.quadraticBezierTo(cx, yT + sagT, cx - halfT, yT); // top edge R->L
    p.close();
    return p;
  }

  // Tiny texture strokes to read as crop rows (or shimmer for paddy).
  void _texture(Canvas canvas, int cat, double cx, double halfT, double halfB,
      double yT, double yB, double sagT, double sagB, int seed, int idx) {
    final double midY = (yT + yB) / 2;
    final double midHalf = (halfT + halfB) / 2;
    final double midSag = (sagT + sagB) / 2;
    final double bandH = (yB - yT).abs();

    if (cat == _cPaddy) {
      // Horizontal shimmer highlights on water.
      final Paint sh = Paint()
        ..color = const Color(0xFFCDEDEF).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.7, bandH * 0.12)
        ..strokeCap = StrokeCap.round;
      for (int k = 0; k < 3; k++) {
        final double frac = 0.3 + k * 0.22;
        final double y = yB - bandH * frac;
        final double hw = midHalf * (0.55 + _rand(idx * 7 + k, seed) * 0.3);
        final double ox = (_rand(idx * 11 + k, seed) - 0.5) * midHalf * 0.4;
        final Path p = Path()
          ..moveTo(cx + ox - hw, y)
          ..quadraticBezierTo(cx + ox, y + midSag * 0.6, cx + ox + hw, y);
        canvas.drawPath(p, sh);
      }
      return;
    }

    // Crop rows: short vertical ticks marching along the terrace.
    final Color rowColor = (cat == _cSoil)
        ? const Color(0xFF9B7748).withValues(alpha: 0.45)
        : (cat == _cGold)
            ? const Color(0xFFC9A63E).withValues(alpha: 0.4)
            : const Color(0xFF5E9E52).withValues(alpha: 0.4);
    final Paint rows = Paint()
      ..color = rowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.5, bandH * 0.10)
      ..strokeCap = StrokeCap.round;

    final int n = (midHalf / 12).clamp(4, 26).toInt();
    final double tick = bandH * 0.42;
    for (int k = 0; k < n; k++) {
      final double fx = (n <= 1) ? 0.5 : k / (n - 1);
      final double x = cx - midHalf + fx * midHalf * 2;
      // Follow the contour sag so ticks sit on the curved surface.
      final double curve = midSag * (1 - math.pow((fx - 0.5) * 2, 2)).toDouble();
      final double y = midY + curve - tick * 0.5;
      final double jitter = (_rand(idx * 13 + k, seed) - 0.5) * bandH * 0.2;
      canvas.drawLine(
          Offset(x, y + jitter), Offset(x, y + tick + jitter), rows);
    }
  }

  // ---- Flatter paddy field (bottom of band) --------------------------------
  void _drawPaddyField(Canvas canvas, Size size,
      {required double cx,
      required double cy,
      required double halfW,
      required double halfH,
      required int seed}) {
    // Elliptical flooded paddy with a soft mud rim.
    final Rect r = Rect.fromCenter(
        center: Offset(cx, cy), width: halfW * 2, height: halfH * 2);

    // Mud embankment rim.
    canvas.drawOval(
        r.inflate(halfH * 0.6),
        Paint()..color = const Color(0xFFC7A86F).withValues(alpha: 0.55));

    // Water body with a subtle vertical sheen.
    final Paint water = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFD6EEE8),
          Color(0xFFBFE0D8),
          Color(0xFFA9D4CB),
        ],
      ).createShader(r);
    canvas.drawOval(r, water);

    // Bright shimmer streaks.
    final Paint streak = Paint()
      ..color = const Color(0xFFCDEDEF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, halfH * 0.16)
      ..strokeCap = StrokeCap.round;
    for (int k = 0; k < 4; k++) {
      final double fy = 0.28 + k * 0.16;
      final double y = r.top + r.height * fy;
      final double hw = halfW * (0.5 + _rand(k, seed) * 0.35);
      final double ox = (_rand(k + 5, seed) - 0.5) * halfW * 0.35;
      canvas.drawLine(Offset(cx + ox - hw, y), Offset(cx + ox + hw, y), streak);
    }

    // A few young rice tufts poking through the water near the far edge.
    final Paint tuft = Paint()
      ..color = const Color(0xFF7FBE6A).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, halfH * 0.14)
      ..strokeCap = StrokeCap.round;
    final int nt = (halfW / 22).clamp(5, 18).toInt();
    for (int k = 0; k < nt; k++) {
      final double fx = _rand(k * 2, seed);
      final double x = cx - halfW * 0.85 + fx * halfW * 1.7;
      final double fy = _rand(k * 2 + 1, seed);
      final double y = r.top + r.height * (0.2 + fy * 0.5);
      canvas.drawLine(Offset(x, y), Offset(x, y - halfH * 0.5), tuft);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}