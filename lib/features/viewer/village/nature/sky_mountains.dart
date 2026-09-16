import 'dart:math' as math;
import 'package:flutter/material.dart';

/// SkyMountainsPainter
///
/// Static background for a Nepali Himalayan-foothill scene. Covers roughly the
/// top half of the canvas (y 0.00 - 0.55):
///   1. Soft vertical sky gradient (skyTop -> mid -> horizon).
///   2. A warm morning sun with a large soft radial glow.
///   3. Three layered mountain ranges with smooth rolling ridgelines and
///      atmospheric perspective (far = hazy/bluish/light, near = greener/darker).
///   4. Snow caps with blue-grey shadow on the far range.
///   5. Thin low-alpha mist bands where ranges overlap.
///
/// Fully resolution-independent: every coordinate is a fraction of
/// size.width / size.height. Draw this FIRST (bottom of the z-stack).
class SkyMountainsPainter extends CustomPainter {
  const SkyMountainsPainter();

  // ---- Shared palette -------------------------------------------------------
  static const Color _skyTop = Color(0xFF86C5E8);
  static const Color _skyMid = Color(0xFFB8E0EF);
  static const Color _skyHorizon = Color(0xFFE7F4EC);

  static const Color _sunCore = Color(0xFFFFF6D8);
  static const Color _sunGlow = Color(0xFFFFE9A8);

  static const Color _snow = Color(0xFFF4F8FB);
  static const Color _snowShadow = Color(0xFFCAD8E6);
  static const Color _mist = Color(0xFFEAF3F5);

  static const Color _mtnFar = Color(0xFF9DB4C6);
  static const Color _mtnMid = Color(0xFF7F9DB0);
  static const Color _mtnNear = Color(0xFF6E8FA2);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _paintSky(canvas, size, w, h);
    _paintSun(canvas, w, h);
    _paintFarRange(canvas, w, h);
    _paintMistBand(canvas, w, h, 0.400, 0.055, 0.22);
    _paintMidRange(canvas, w, h);
    _paintMistBand(canvas, w, h, 0.470, 0.050, 0.28);
    _paintNearRange(canvas, w, h);
    _paintMistBand(canvas, w, h, 0.535, 0.045, 0.20);
  }

  // ---------------------------------------------------------------------------
  // 1. SKY
  // ---------------------------------------------------------------------------
  void _paintSky(Canvas canvas, Size size, double w, double h) {
    final Rect skyRect = Rect.fromLTWH(0, 0, w, h * 0.58);
    final Paint sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_skyTop, _skyMid, _skyHorizon],
        stops: [0.0, 0.62, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, sky);

    // Very soft high wispy cloud smears for atmosphere.
    final Paint wisp = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    _wisp(canvas, w, h, 0.16, 0.13, 0.30, 0.030, wisp);
    _wisp(canvas, w, h, 0.68, 0.09, 0.34, 0.026, wisp);
    _wisp(canvas, w, h, 0.44, 0.20, 0.24, 0.022, wisp);
  }

  void _wisp(Canvas canvas, double w, double h, double cx, double cy,
      double rw, double rh, Paint p) {
    final Rect r = Rect.fromCenter(
      center: Offset(w * cx, h * cy),
      width: w * rw,
      height: h * rh,
    );
    canvas.drawOval(r, p);
  }

  // ---------------------------------------------------------------------------
  // 2. SUN with soft radial glow
  // ---------------------------------------------------------------------------
  void _paintSun(Canvas canvas, double w, double h) {
    final Offset c = Offset(w * 0.735, h * 0.185);
    final double glowR = h * 0.34;

    // Large outer glow.
    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: [
          _sunGlow.withValues(alpha: 0.55),
          _sunGlow.withValues(alpha: 0.28),
          _sunGlow.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: glowR));
    canvas.drawCircle(c, glowR, glow);

    // Inner warm halo.
    final double haloR = h * 0.115;
    final Paint halo = Paint()
      ..shader = RadialGradient(
        colors: [
          _sunCore.withValues(alpha: 0.95),
          _sunGlow.withValues(alpha: 0.5),
          _sunGlow.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: haloR))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(c, haloR, halo);

    // Bright core.
    final double coreR = h * 0.052;
    final Paint core = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.98),
          _sunCore,
          _sunCore.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: coreR));
    canvas.drawCircle(c, coreR, core);
  }

  // ---------------------------------------------------------------------------
  // 3a. FAR RANGE (hazy, light, bluish) + snow caps
  // ---------------------------------------------------------------------------
  void _paintFarRange(Canvas canvas, double w, double h) {
    // Ridgeline control points as fractions. Varied summit heights.
    final List<Offset> peaks = [
      Offset(0.00, 0.300),
      Offset(0.10, 0.235),
      Offset(0.20, 0.285),
      Offset(0.31, 0.190), // tall peak
      Offset(0.42, 0.255),
      Offset(0.54, 0.215),
      Offset(0.66, 0.170), // tallest, near sun
      Offset(0.78, 0.245),
      Offset(0.89, 0.205),
      Offset(1.00, 0.275),
    ];

    final Path ridge = _ridgePath(peaks, w, h, baseY: 0.520);

    // Body gradient: lighter/bluer at top (hazy), settling toward mid.
    final Paint body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _mtnFar.withValues(alpha: 0.92),
          _mtnFar,
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.15, w, h * 0.40));
    canvas.drawPath(ridge, body);

    // Snow caps on the taller summits.
    _snowCap(canvas, w, h, peaks[3], 0.062, 0.055);
    _snowCap(canvas, w, h, peaks[6], 0.078, 0.070);
    _snowCap(canvas, w, h, peaks[8], 0.050, 0.044);
    _snowCap(canvas, w, h, peaks[1], 0.044, 0.038);

    // Haze veil over the whole far range base to push it back.
    final Paint veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _mist.withValues(alpha: 0.0),
          _mist.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.34, w, h * 0.20));
    canvas.drawPath(ridge, veil);
  }

  /// Draws a snow cap sitting on a peak: white top with a blue-grey shadow on
  /// the shaded flank.
  void _snowCap(Canvas canvas, double w, double h, Offset peak, double capW,
      double capH) {
    final double px = peak.dx * w;
    final double py = peak.dy * h;
    final double hw = w * capW * 0.5;
    final double ch = h * capH;

    // Snow field: a jagged-soft blob draping down from the summit.
    final Path snow = Path()..moveTo(px - hw, py + ch);
    snow.cubicTo(
      px - hw * 0.7, py + ch * 0.55,
      px - hw * 0.5, py + ch * 0.25,
      px - hw * 0.18, py + ch * 0.12,
    );
    snow.quadraticBezierTo(px - hw * 0.05, py - ch * 0.02, px, py);
    snow.quadraticBezierTo(px + hw * 0.05, py - ch * 0.02, px + hw * 0.2, py + ch * 0.14);
    snow.cubicTo(
      px + hw * 0.5, py + ch * 0.30,
      px + hw * 0.72, py + ch * 0.6,
      px + hw, py + ch,
    );
    snow.quadraticBezierTo(px + hw * 0.45, py + ch * 0.78, px + hw * 0.12, py + ch * 0.92);
    snow.quadraticBezierTo(px - hw * 0.2, py + ch * 1.02, px - hw * 0.55, py + ch * 0.86);
    snow.quadraticBezierTo(px - hw * 0.8, py + ch * 0.74, px - hw, py + ch);
    snow.close();

    canvas.drawPath(snow, Paint()..color = _snow);

    // Blue-grey shadow on the shaded flank.
    final Path shade = Path()..moveTo(px, py);
    shade.quadraticBezierTo(px + hw * 0.05, py - ch * 0.02, px + hw * 0.2, py + ch * 0.14);
    shade.cubicTo(
      px + hw * 0.5, py + ch * 0.30,
      px + hw * 0.72, py + ch * 0.6,
      px + hw, py + ch,
    );
    shade.quadraticBezierTo(px + hw * 0.55, py + ch * 0.7, px + hw * 0.28, py + ch * 0.5);
    shade.quadraticBezierTo(px + hw * 0.1, py + ch * 0.3, px, py);
    shade.close();
    canvas.drawPath(
      shade,
      Paint()..color = _snowShadow.withValues(alpha: 0.55),
    );

    // Tiny bright highlight ridge on the sunlit side.
    final Paint hl = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, h * 0.0022)
      ..strokeCap = StrokeCap.round;
    final Path ridgeLine = Path()
      ..moveTo(px - hw * 0.18, py + ch * 0.12)
      ..quadraticBezierTo(px - hw * 0.05, py - ch * 0.02, px, py);
    canvas.drawPath(ridgeLine, hl);
  }

  // ---------------------------------------------------------------------------
  // 3b. MID RANGE (greener, more defined)
  // ---------------------------------------------------------------------------
  void _paintMidRange(Canvas canvas, double w, double h) {
    final List<Offset> peaks = [
      Offset(0.00, 0.420),
      Offset(0.12, 0.360),
      Offset(0.24, 0.395),
      Offset(0.37, 0.325),
      Offset(0.49, 0.375),
      Offset(0.60, 0.330),
      Offset(0.72, 0.380),
      Offset(0.84, 0.340),
      Offset(1.00, 0.400),
    ];
    final Path ridge = _ridgePath(peaks, w, h, baseY: 0.560);

    final Paint body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _mtnMid.withValues(alpha: 0.96),
          _mtnMid,
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.30, w, h * 0.30));
    canvas.drawPath(ridge, body);

    // Soft ridge highlight on sunlit crests.
    _crestHighlight(canvas, peaks, w, h, Colors.white.withValues(alpha: 0.18));

    // Faint valley shading to give volume.
    final Paint valley = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF3E5A6B).withValues(alpha: 0.20),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.42, w, h * 0.14));
    canvas.drawPath(ridge, valley);
  }

  // ---------------------------------------------------------------------------
  // 3c. NEAR RANGE (darkest, most defined foreground hills base)
  // ---------------------------------------------------------------------------
  void _paintNearRange(Canvas canvas, double w, double h) {
    final List<Offset> peaks = [
      Offset(0.00, 0.500),
      Offset(0.14, 0.450),
      Offset(0.28, 0.490),
      Offset(0.41, 0.435),
      Offset(0.55, 0.475),
      Offset(0.69, 0.440),
      Offset(0.82, 0.485),
      Offset(1.00, 0.460),
    ];
    final Path ridge = _ridgePath(peaks, w, h, baseY: 0.600);

    final Paint body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _mtnNear,
          const Color(0xFF5E7E90),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.40, w, h * 0.22));
    canvas.drawPath(ridge, body);

    _crestHighlight(canvas, peaks, w, h, Colors.white.withValues(alpha: 0.14));

    // Subtle texture: faint tree-line stipples on the crests.
    final Paint tuft = Paint()
      ..color = const Color(0xFF4E6E80).withValues(alpha: 0.35);
    final math.Random rnd = math.Random(7);
    for (int i = 0; i < peaks.length - 1; i++) {
      final Offset a = peaks[i];
      final Offset b = peaks[i + 1];
      final int n = 10;
      for (int j = 0; j < n; j++) {
        final double t = j / n;
        final double x = (a.dx + (b.dx - a.dx) * t) * w;
        final double baseY =
            (a.dy + (b.dy - a.dy) * t) * h + h * 0.012 + rnd.nextDouble() * h * 0.02;
        final double th = h * (0.004 + rnd.nextDouble() * 0.006);
        canvas.drawCircle(Offset(x, baseY), th, tuft);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Builds a smooth closed mountain silhouette from a list of summit points
  /// (fractional coordinates), using quadratic beziers through mid-saddles so
  /// the ridgeline rolls organically. [baseY] is the fractional bottom edge.
  Path _ridgePath(List<Offset> peaks, double w, double h, {required double baseY}) {
    final Path p = Path();
    final double by = baseY * h;
    p.moveTo(0, by);
    p.lineTo(peaks.first.dx * w, peaks.first.dy * h);

    for (int i = 0; i < peaks.length - 1; i++) {
      final Offset cur = peaks[i];
      final Offset nxt = peaks[i + 1];
      final double cx = (cur.dx + nxt.dx) * 0.5 * w;
      final double dip = math.max(cur.dy, nxt.dy) + 0.028;
      final double cy = dip * h;
      p.quadraticBezierTo(cx, cy, nxt.dx * w, nxt.dy * h);
    }

    p.lineTo(w, by);
    p.close();
    return p;
  }

  /// Thin soft highlight strokes tracing the sunlit side of each crest.
  void _crestHighlight(
      Canvas canvas, List<Offset> peaks, double w, double h, Color color) {
    final Paint hl = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, h * 0.0028)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final Path line = Path()..moveTo(peaks.first.dx * w, peaks.first.dy * h);
    for (int i = 0; i < peaks.length - 1; i++) {
      final Offset cur = peaks[i];
      final Offset nxt = peaks[i + 1];
      final double cx = (cur.dx + nxt.dx) * 0.5 * w;
      final double cy = (math.max(cur.dy, nxt.dy) + 0.028) * h;
      line.quadraticBezierTo(cx, cy, nxt.dx * w, nxt.dy * h);
    }
    canvas.drawPath(line, hl);
  }

  /// A thin horizontal mist band (low-alpha white) where ranges overlap.
  void _paintMistBand(
      Canvas canvas, double w, double h, double cy, double band, double alpha) {
    final Rect r = Rect.fromLTWH(0, h * (cy - band * 0.5), w, h * band);
    final Paint mist = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _mist.withValues(alpha: 0.0),
          _mist.withValues(alpha: alpha),
          _mist.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(r)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.012);
    canvas.drawRect(r, mist);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}