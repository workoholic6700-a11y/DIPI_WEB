import 'package:flutter/material.dart';
import 'dart:math' as math;

/// HillCountryPainter — the HILLY heart of the Ilam (eastern-Nepal) scene.
///
/// Paints, in the mid band (y ~0.36–0.70):
///  • Several layered rolling hills with smooth curved ridgelines receding into
///    the distance (atmospheric perspective: far hills lighter/hazier/bluer-green,
///    near hills deeper green), with a valley folding between them.
///  • Dense Ilam TEA GARDENS on the nearer slopes — many neat, evenly-spaced
///    curved rows of little round tea bushes following the hill contours.
///  • Thin footpaths winding up the hills, faint mist in the folds, and a few
///    tiny distant houses dotting a far ridge.
///
/// Self-contained. Drop into a Stack behind foreground pieces.
class HillCountryPainter extends CustomPainter {
  const HillCountryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ---- Palette (shared, exact) -----------------------------------------
    const Color hillBack = Color(0xFF7CB874);
    const Color hillMid = Color(0xFF5EA05C);
    const Color hillFront = Color(0xFF4C8C4C);
    const Color hillDeep = Color(0xFF3E7A44);
    const Color teaRowA = Color(0xFF4E8B4A);
    const Color teaRowB = Color(0xFF3E7540);
    const Color mist = Color(0xFFEAF3F5);
    const Color pathFill = Color(0xFFE3CF9E);
    const Color pathEdge = Color(0xFFC7A86F);

    // Bluer/hazier tints for the most distant ridges (atmospheric perspective).
    const Color ridgeFar1 = Color(0xFF9FBFB0); // farthest, most washed-out
    const Color ridgeFar2 = Color(0xFF88B389);

    // ======================================================================
    // 1. LAYERED ROLLING HILLS — back to front, each a smooth ridgeline.
    // ======================================================================

    // -- Ridge 0: farthest, hazy blue-green, low rolling ------------------
    _rollingHill(
      canvas, w, h,
      baseY: 0.415,
      amp: 0.022,
      lift: 0.030,
      seed: 11,
      colorTop: ridgeFar1,
      colorBottom: ridgeFar2,
      bumps: 5,
    );

    // -- Ridge 1: far hills, light green ---------------------------------
    _rollingHill(
      canvas, w, h,
      baseY: 0.455,
      amp: 0.030,
      lift: 0.045,
      seed: 23,
      colorTop: hillBack,
      colorBottom: const Color(0xFF6FAE66),
      bumps: 4,
    );

    // Tiny distant houses dotting this far ridge.
    _distantHouses(canvas, w, h, baseY: 0.455, amp: 0.030, seed: 23, bumps: 4);

    // -- Ridge 2: mid hills ----------------------------------------------
    _rollingHill(
      canvas, w, h,
      baseY: 0.505,
      amp: 0.038,
      lift: 0.060,
      seed: 37,
      colorTop: hillMid,
      colorBottom: const Color(0xFF4F9250),
      bumps: 4,
    );

    // Mist settling in the fold behind the front-left hill.
    _mistBand(canvas, w, h, cy: 0.545, halfH: 0.028, xa: 0.02, xb: 0.55, mist: mist);

    // -- Ridge 3: front-left hill (TEA GARDEN slope) ---------------------
    // A big rounded shoulder on the left that falls into the central valley.
    final Path frontLeft = _shoulderPath(
      w, h,
      startX: -0.05, crestX: 0.30, crestY: 0.470, endX: 0.62, endY: 0.640,
      floorY: 0.70,
    );
    _paintHill(canvas, frontLeft, w, h,
        top: hillFront, bottom: hillDeep, cyTop: 0.47, cyBot: 0.70);
    // Tea rows hugging this slope's contours.
    _teaGarden(
      canvas, frontLeft, w, h,
      crestX: 0.30, crestY: 0.470, spanX0: 0.02, spanX1: 0.58,
      rowTopY: 0.500, rowBotY: 0.660, rows: 13, seed: 5,
      rowA: teaRowA, rowB: teaRowB,
    );
    // Winding footpath climbing the left shoulder.
    _footpath(canvas, w, h, pathFill, pathEdge, points: const [
      Offset(0.10, 0.700), Offset(0.16, 0.640), Offset(0.135, 0.585),
      Offset(0.20, 0.540), Offset(0.255, 0.505), Offset(0.30, 0.478),
    ]);

    // -- Ridge 4: front-right hill (TEA GARDEN slope) --------------------
    final Path frontRight = _shoulderPath(
      w, h,
      startX: 0.44, crestX: 0.82, crestY: 0.455, endX: 1.05, endY: 0.560,
      floorY: 0.72,
    );
    _paintHill(canvas, frontRight, w, h,
        top: const Color(0xFF56954F), bottom: hillDeep, cyTop: 0.455, cyBot: 0.72);
    _teaGarden(
      canvas, frontRight, w, h,
      crestX: 0.82, crestY: 0.455, spanX0: 0.50, spanX1: 1.02,
      rowTopY: 0.490, rowBotY: 0.690, rows: 15, seed: 9,
      rowA: teaRowA, rowB: teaRowB,
    );
    // Footpath winding up the right hill.
    _footpath(canvas, w, h, pathFill, pathEdge, points: const [
      Offset(0.72, 0.700), Offset(0.78, 0.640), Offset(0.755, 0.585),
      Offset(0.82, 0.535), Offset(0.87, 0.500), Offset(0.82, 0.468),
    ]);

    // Mist drifting through the central valley fold between the two hills.
    _mistBand(canvas, w, h, cy: 0.640, halfH: 0.030, xa: 0.30, xb: 0.72, mist: mist);
    _mistBand(canvas, w, h, cy: 0.600, halfH: 0.018, xa: 0.55, xb: 0.85, mist: mist);
  }

  // =====================================================================
  //  HILL BUILDERS
  // =====================================================================

  /// A broad rolling band spanning full width with several soft bumps,
  /// filled with a vertical gradient. Good for receding background ridges.
  static void _rollingHill(
    Canvas canvas,
    double w,
    double h, {
    required double baseY,
    required double amp,
    required double lift,
    required int seed,
    required Color colorTop,
    required Color colorBottom,
    required int bumps,
  }) {
    final rnd = math.Random(seed);
    final Path p = Path()..moveTo(-0.02 * w, baseY * h);

    final double step = 1.04 / bumps;
    double x = -0.02;
    for (int i = 0; i < bumps; i++) {
      final double nx = x + step;
      final double crestUp = lift * (0.6 + rnd.nextDouble() * 0.8);
      final double cx = (x + nx) / 2;
      final double cy = baseY - crestUp - amp * rnd.nextDouble();
      final double ny = baseY + amp * (rnd.nextDouble() - 0.5);
      p.quadraticBezierTo(cx * w, cy * h, nx * w, ny * h);
      x = nx;
    }
    p.lineTo(1.04 * w, h);
    p.lineTo(-0.02 * w, h);
    p.close();

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colorTop, colorBottom],
      ).createShader(Rect.fromLTWH(0, (baseY - lift) * h, w, (1.0 - baseY + lift) * h));
    canvas.drawPath(p, paint);
  }

  /// A single rounded hill "shoulder": rises to a crest then slopes down,
  /// closing to a floor line. Used for the two big foreground tea hills.
  static Path _shoulderPath(
    double w,
    double h, {
    required double startX,
    required double crestX,
    required double crestY,
    required double endX,
    required double endY,
    required double floorY,
  }) {
    final Path p = Path()..moveTo(startX * w, floorY * h);
    // rise to crest
    p.cubicTo(
      (startX + (crestX - startX) * 0.35) * w, (floorY - (floorY - crestY) * 0.15) * h,
      (crestX - (crestX - startX) * 0.30) * w, (crestY + (floorY - crestY) * 0.20) * h,
      crestX * w, crestY * h,
    );
    // fall to end
    p.cubicTo(
      (crestX + (endX - crestX) * 0.32) * w, (crestY + (endY - crestY) * 0.15) * h,
      (endX - (endX - crestX) * 0.28) * w, (endY - (endY - crestY) * 0.10) * h,
      endX * w, endY * h,
    );
    p.lineTo(endX * w, floorY * h + 0.30 * h);
    p.lineTo(startX * w, floorY * h + 0.30 * h);
    p.close();
    return p;
  }

  static void _paintHill(
    Canvas canvas,
    Path path,
    double w,
    double h, {
    required Color top,
    required Color bottom,
    required double cyTop,
    required double cyBot,
  }) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(Rect.fromLTWH(0, cyTop * h, w, (cyBot - cyTop + 0.15) * h));
    canvas.drawPath(path, paint);

    // Soft rim-light along the crest for form.
    final Paint rim = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.006
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, rim);
    canvas.restore();
  }

  // =====================================================================
  //  TEA GARDEN — neat curved rows of round bushes hugging the slope.
  // =====================================================================
  static void _teaGarden(
    Canvas canvas,
    Path hillClip,
    double w,
    double h, {
    required double crestX,
    required double crestY,
    required double spanX0,
    required double spanX1,
    required double rowTopY,
    required double rowBotY,
    required int rows,
    required int seed,
    required Color rowA,
    required Color rowB,
  }) {
    canvas.save();
    canvas.clipPath(hillClip);

    final rnd = math.Random(seed);

    for (int r = 0; r < rows; r++) {
      final double t = r / (rows - 1); // 0 top .. 1 bottom
      // Row sits lower as t grows; rows are denser/darker lower down.
      final double rowY = rowTopY + (rowBotY - rowTopY) * t;
      // Bush size grows toward the front (bottom) for depth.
      final double bush = h * (0.006 + 0.016 * t);
      // Row curvature follows the hill: sag away from the crest.
      final double curve = h * (0.020 + 0.030 * t);

      // Horizontal extent narrows a touch at the top of the slope.
      final double x0 = spanX0 + (crestX - spanX0) * (1 - t) * 0.18;
      final double x1 = spanX1 - (spanX1 - crestX) * (1 - t) * 0.14;

      final Color rowColor = (r.isEven ? rowA : rowB);
      // Slight per-row tonal drift for a hand-planted feel.
      final Color shade = Color.lerp(rowColor, rowB, rnd.nextDouble() * 0.4)!;

      final double spacing = bush * 1.35;
      final int n = ((x1 - x0) * w / spacing).floor();
      if (n <= 1) continue;

      final Paint bushPaint = Paint()..color = shade;
      final Paint hi = Paint()..color = Colors.white.withValues(alpha: 0.12);
      final Paint sh = Paint()..color = const Color(0xFF2F5E33).withValues(alpha: 0.22);

      for (int i = 0; i <= n; i++) {
        final double fx = i / n;
        final double x = (x0 + (x1 - x0) * fx) * w;
        // Contour sag: bushes dip toward the middle of the row.
        final double sag = math.sin(fx * math.pi) * curve;
        // gentle jitter so rows feel natural, not mechanical
        final double jitter = (rnd.nextDouble() - 0.5) * bush * 0.35;
        final double y = rowY * h + sag + jitter;

        // little shadow under each bush
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y + bush * 0.45),
            width: bush * 1.9,
            height: bush * 0.9,
          ),
          sh,
        );
        // the round tea bush
        canvas.drawCircle(Offset(x, y), bush, bushPaint);
        // top-left highlight
        canvas.drawCircle(
          Offset(x - bush * 0.30, y - bush * 0.30),
          bush * 0.45,
          hi,
        );
      }
    }

    // Faint darker seams (the walking gaps between tea blocks).
    final Paint seam = Paint()
      ..color = const Color(0xFF2F5E33).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.004;
    for (int s = 0; s < 3; s++) {
      final double sx = spanX0 + (spanX1 - spanX0) * (0.28 + 0.24 * s);
      final Path seamPath = Path()
        ..moveTo(sx * w, rowTopY * h)
        ..quadraticBezierTo(
          (sx + 0.02) * w, ((rowTopY + rowBotY) / 2) * h,
          (sx - 0.015) * w, rowBotY * h,
        );
      canvas.drawPath(seamPath, seam);
    }

    canvas.restore();
  }

  // =====================================================================
  //  FOOTPATH — a thin pale ribbon winding up a slope.
  // =====================================================================
  static void _footpath(
    Canvas canvas,
    double w,
    double h,
    Color fill,
    Color edge, {
    required List<Offset> points,
  }) {
    if (points.length < 2) return;
    final Path p = Path()..moveTo(points.first.dx * w, points.first.dy * h);
    for (int i = 1; i < points.length; i++) {
      final Offset prev = points[i - 1];
      final Offset cur = points[i];
      final double mx = (prev.dx + cur.dx) / 2;
      final double my = (prev.dy + cur.dy) / 2;
      p.quadraticBezierTo(prev.dx * w, prev.dy * h, mx * w, my * h);
    }
    p.lineTo(points.last.dx * w, points.last.dy * h);

    // Path narrows going uphill (perspective): draw as two strokes.
    final Paint edgePaint = Paint()
      ..color = edge.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = h * 0.016;
    final Paint fillPaint = Paint()
      ..color = fill.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = h * 0.010;
    canvas.drawPath(p, edgePaint);
    canvas.drawPath(p, fillPaint);
  }

  // =====================================================================
  //  MIST — a soft blurred band nestled in a hill fold.
  // =====================================================================
  static void _mistBand(
    Canvas canvas,
    double w,
    double h, {
    required double cy,
    required double halfH,
    required double xa,
    required double xb,
    required Color mist,
  }) {
    final Rect r = Rect.fromLTRB(xa * w, (cy - halfH) * h, xb * w, (cy + halfH) * h);
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [
          mist.withValues(alpha: 0.72),
          mist.withValues(alpha: 0.0),
        ],
      ).createShader(r)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.02);
    canvas.drawOval(r, paint);
  }

  // =====================================================================
  //  DISTANT HOUSES — tiny ochre roofs on a far ridge.
  // =====================================================================
  static void _distantHouses(
    Canvas canvas,
    double w,
    double h, {
    required double baseY,
    required double amp,
    required int seed,
    required int bumps,
  }) {
    final rnd = math.Random(seed * 7 + 1);
    const Color wall = Color(0xFFEDE3C6);
    const Color roof = Color(0xFF9A5B44);

    // Place a few houses near crest positions of this ridge.
    for (int i = 0; i < 3; i++) {
      final double fx = 0.22 + i * 0.24 + (rnd.nextDouble() - 0.5) * 0.05;
      final double x = fx * w;
      // Sit them just below the ridgeline.
      final double y = (baseY - amp * 0.2 + 0.010) * h + rnd.nextDouble() * h * 0.004;
      final double s = h * (0.010 + rnd.nextDouble() * 0.004);

      // wall
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y + s * 0.4), width: s * 1.6, height: s * 0.9),
        Paint()..color = wall.withValues(alpha: 0.92),
      );
      // roof (simple triangle)
      final Path roofPath = Path()
        ..moveTo(x - s * 1.0, y)
        ..lineTo(x + s * 1.0, y)
        ..lineTo(x, y - s * 0.7)
        ..close();
      canvas.drawPath(roofPath, Paint()..color = roof.withValues(alpha: 0.90));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}