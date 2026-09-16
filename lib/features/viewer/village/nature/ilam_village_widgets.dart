import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ============================================================================
/// ILAM VILLAGE — detailed animated widget set.
/// Each widget: fixed intrinsic size, const ctor, self-contained,
/// subtle flutter_animate motion. No assets, no controllers.
/// ============================================================================

// ----------------------------------------------------------------------------
// 1) TeaBushRow — a short curved row of round tea bushes, gentle sway.
// ----------------------------------------------------------------------------
class TeaBushRow extends StatelessWidget {
  final double width;
  const TeaBushRow({super.key, this.width = 120});

  @override
  Widget build(BuildContext context) {
    final h = width * 0.36;
    return SizedBox(
      width: width,
      height: h,
      child: CustomPaint(painter: const _TeaBushRowPainter()),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.004,
          end: 0.004,
          duration: 3400.ms,
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
        );
  }
}

class _TeaBushRowPainter extends CustomPainter {
  const _TeaBushRowPainter();

  static const Color _rowA = Color(0xFF4E8B4A);
  static const Color _rowB = Color(0xFF3E7540);
  static const Color _lit = Color(0xFF6FA95E);
  static const Color _soil = Color(0xFFC39A6B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Curved slope baseline for the row (bushes follow a gentle arc).
    final n = (w / 15).round().clamp(6, 12);
    final bushR = w * 0.062;

    // soil strip beneath the row
    final soilPath = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.52, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(soilPath, Paint()..color = _soil.withValues(alpha: 0.85));

    for (int i = 0; i < n; i++) {
      final t = n == 1 ? 0.5 : i / (n - 1);
      final cx = bushR + t * (w - 2 * bushR);
      // arc: high in middle-ish, dip toward ends -> hill row
      final arc = math.sin(t * math.pi);
      final cy = h * 0.66 - arc * h * 0.18;

      // shadow
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + bushR * 0.18, cy + bushR * 0.28),
            width: bushR * 2.0,
            height: bushR * 1.0),
        Paint()..color = const Color(0xFF2C5A32).withValues(alpha: 0.30),
      );

      final base = (i.isEven) ? _rowA : _rowB;
      // main bush mound
      canvas.drawCircle(Offset(cx, cy), bushR, Paint()..color = base);
      // lit crown (top-left highlight)
      canvas.drawCircle(
        Offset(cx - bushR * 0.28, cy - bushR * 0.34),
        bushR * 0.58,
        Paint()..color = _lit.withValues(alpha: 0.65),
      );
      // little leaf dabs for texture
      final dab = Paint()..color = _lit.withValues(alpha: 0.5);
      for (int d = 0; d < 4; d++) {
        final a = d * 1.7 + i;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * bushR * 0.45,
              cy + math.sin(a) * bushR * 0.4),
          bushR * 0.16,
          dab,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------------
// 2) PrayerFlags — lungta string between two poles, gentle flutter.
// ----------------------------------------------------------------------------
class PrayerFlags extends StatelessWidget {
  final double width;
  const PrayerFlags({super.key, this.width = 200});

  static const List<Color> _flagColors = [
    Color(0xFF3E7CC0), // blue
    Color(0xFFF4F4F0), // white
    Color(0xFFD2483B), // red
    Color(0xFF4E9E5A), // green
    Color(0xFFF2C33C), // yellow
  ];

  @override
  Widget build(BuildContext context) {
    final h = width * 0.5;
    final count = (width / 18).round().clamp(8, 16);

    final flags = <Widget>[];
    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      // droop curve for the string (catenary-ish)
      final sag = math.sin(t * math.pi) * h * 0.22;
      final x = width * 0.10 + t * width * 0.80;
      final y = h * 0.20 + sag;
      final color = _flagColors[i % _flagColors.length];
      flags.add(Positioned(
        left: x - 1,
        top: y,
        child: _SingleFlag(color: color, index: i, size: width * 0.075),
      ));
    }

    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
              size: Size(width, h), painter: const _FlagPolesPainter()),
          ...flags,
        ],
      ),
    );
  }
}

class _SingleFlag extends StatelessWidget {
  final Color color;
  final int index;
  final double size;
  const _SingleFlag(
      {required this.color, required this.index, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(painter: _FlagPainter(color)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .rotate(
          begin: -0.012,
          end: 0.015,
          alignment: Alignment.topCenter,
          duration: (1500 + (index % 5) * 220).ms,
          curve: Curves.easeInOut,
        )
        .scaleX(
          begin: 0.94,
          end: 1.0,
          duration: (1500 + (index % 5) * 220).ms,
          curve: Curves.easeInOut,
        );
  }
}

class _FlagPainter extends CustomPainter {
  final Color color;
  const _FlagPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final hh = size.height;
    // gentle wavy flag hanging from top
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, hh * 0.82)
      ..quadraticBezierTo(w * 0.5, hh * 1.02, 0, hh * 0.82)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    // faint printed "mantra" lines
    final line = Paint()
      ..color = (color.computeLuminance() > 0.6
          ? const Color(0xFF6E4A2E)
          : Colors.white)
          .withValues(alpha: 0.45)
      ..strokeWidth = 0.8;
    for (int i = 1; i <= 3; i++) {
      final y = hh * (0.22 * i);
      canvas.drawLine(Offset(w * 0.15, y), Offset(w * 0.85, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlagPolesPainter extends CustomPainter {
  const _FlagPolesPainter();

  static const Color _wood = Color(0xFF8A5A3C);
  static const Color _woodDark = Color(0xFF5E3B26);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final polePaint = Paint()
      ..color = _wood
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    final tipPaint = Paint()..color = _woodDark;

    // two poles
    for (final px in [w * 0.10, w * 0.90]) {
      canvas.drawLine(Offset(px, h * 0.05), Offset(px, h), polePaint);
      canvas.drawCircle(Offset(px, h * 0.05), w * 0.014, tipPaint);
    }

    // the sagging string
    final string = Path()
      ..moveTo(w * 0.10, h * 0.16)
      ..quadraticBezierTo(w * 0.5, h * 0.42, w * 0.90, h * 0.16);
    canvas.drawPath(
      string,
      Paint()
        ..color = _woodDark.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------------
// 3) Chautari — stone resting platform around a big peepal/banyan; leaves sway.
// ----------------------------------------------------------------------------
class Chautari extends StatelessWidget {
  final double size;
  const Chautari({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // platform + trunk (static)
          CustomPaint(
            size: Size(size, size * 1.15),
            painter: const _ChautariBasePainter(),
          ),
          // swaying canopy
          Positioned(
            top: 0,
            child: SizedBox(
              width: size,
              height: size * 0.72,
              child: const CustomPaint(painter: _ChautariCanopyPainter()),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  begin: -0.010,
                  end: 0.010,
                  duration: 4200.ms,
                  curve: Curves.easeInOut,
                  alignment: Alignment.bottomCenter,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChautariBasePainter extends CustomPainter {
  const _ChautariBasePainter();

  static const Color _stone = Color(0xFF9E8A72);
  static const Color _stoneDark = Color(0xFF7C6A55);
  static const Color _stoneLit = Color(0xFFB9A88E);
  static const Color _wood = Color(0xFF8A5A3C);
  static const Color _woodDark = Color(0xFF5E3B26);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // ---- stone platform (rounded rectangular dais) ----
    final platTop = h * 0.72;
    final platBot = h * 0.96;
    final platRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.06, platTop, w * 0.94, platBot),
      Radius.circular(w * 0.05),
    );
    // shadow
    canvas.drawOval(
      Rect.fromLTRB(w * 0.04, platBot - h * 0.03, w * 0.96, platBot + h * 0.05),
      Paint()..color = const Color(0xFF2C5A32).withValues(alpha: 0.25),
    );
    canvas.drawRRect(platRect, Paint()..color = _stone);
    // top face (lighter)
    final topFace = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.06, platTop, w * 0.94, platTop + h * 0.06),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(topFace, Paint()..color = _stoneLit);

    // stone masonry seams
    final seam = Paint()
      ..color = _stoneDark.withValues(alpha: 0.55)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (int i = 1; i < 5; i++) {
      final x = w * 0.06 + i * (w * 0.88 / 5);
      canvas.drawLine(Offset(x, platTop + h * 0.06),
          Offset(x + (i.isEven ? 4 : -3), platBot), seam);
    }
    canvas.drawLine(Offset(w * 0.06, platTop + h * 0.15),
        Offset(w * 0.94, platTop + h * 0.15), seam);

    // ---- big buttressed trunk ----
    final trunk = Path()
      ..moveTo(cx - w * 0.10, platTop + h * 0.02)
      ..cubicTo(cx - w * 0.09, h * 0.5, cx - w * 0.05, h * 0.42,
          cx - w * 0.045, h * 0.30)
      ..lineTo(cx + w * 0.045, h * 0.30)
      ..cubicTo(cx + w * 0.05, h * 0.42, cx + w * 0.09, h * 0.5,
          cx + w * 0.10, platTop + h * 0.02)
      // root flare
      ..cubicTo(cx + w * 0.16, platTop, cx + w * 0.14, platTop + h * 0.02,
          cx + w * 0.12, platTop + h * 0.02)
      ..close();
    canvas.drawPath(trunk, Paint()..color = _wood);
    // bark shading
    final bark = Paint()
      ..color = _woodDark.withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final x = cx - w * 0.05 + i * w * 0.05;
      canvas.drawLine(
          Offset(x, h * 0.32), Offset(x - 3, platTop), bark);
    }
    // couple of exposed roots onto the platform
    canvas.drawLine(Offset(cx - w * 0.09, platTop + h * 0.03),
        Offset(cx - w * 0.18, platTop + h * 0.06), Paint()
          ..color = _woodDark
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + w * 0.09, platTop + h * 0.03),
        Offset(cx + w * 0.19, platTop + h * 0.05), Paint()
          ..color = _woodDark
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChautariCanopyPainter extends CustomPainter {
  const _ChautariCanopyPainter();

  static const Color _back = Color(0xFF3E7A44);
  static const Color _mid = Color(0xFF4C8C4C);
  static const Color _front = Color(0xFF5EA05C);
  static const Color _lit = Color(0xFF7CB874);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final rng = math.Random(7);

    // layered leafy blobs forming a broad peepal crown
    void cluster(double dx, double dy, double r, Color c) {
      canvas.drawCircle(Offset(cx + dx, h * 0.55 + dy), r, Paint()..color = c);
    }

    // back layer
    for (int i = 0; i < 7; i++) {
      final a = i / 7 * math.pi * 2;
      cluster(math.cos(a) * w * 0.30, math.sin(a) * h * 0.22 - h * 0.05,
          w * 0.18, _back);
    }
    // mid
    for (int i = 0; i < 8; i++) {
      final a = i / 8 * math.pi * 2 + 0.3;
      cluster(math.cos(a) * w * 0.24, math.sin(a) * h * 0.18 - h * 0.05,
          w * 0.16, _mid);
    }
    // front
    for (int i = 0; i < 9; i++) {
      final a = i / 9 * math.pi * 2 + 0.6;
      cluster(math.cos(a) * w * 0.18, math.sin(a) * h * 0.14 - h * 0.06,
          w * 0.14, _front);
    }
    // highlight dabs
    final litPaint = Paint()..color = _lit.withValues(alpha: 0.75);
    for (int i = 0; i < 14; i++) {
      final dx = (rng.nextDouble() - 0.5) * w * 0.6;
      final dy = (rng.nextDouble() - 0.6) * h * 0.4;
      canvas.drawCircle(Offset(cx + dx, h * 0.5 + dy), w * 0.045, litPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------------
// 4) Dhara — stone water spout with a thin animated stream into a basin.
// ----------------------------------------------------------------------------
class Dhara extends StatelessWidget {
  final double size;
  const Dhara({super.key, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size * 1.2),
            painter: const _DharaPainter(),
          ),
          // shimmering falling stream
          Positioned(
            left: size * 0.30,
            top: size * 0.52,
            child: SizedBox(
              width: size * 0.14,
              height: size * 0.42,
              child: const CustomPaint(painter: _DharaStreamPainter()),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 900.ms, color: const Color(0xFFCDEDEF))
                .scaleY(
                  begin: 0.92,
                  end: 1.0,
                  duration: 700.ms,
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                ),
          ),
        ],
      ),
    );
  }
}

class _DharaPainter extends CustomPainter {
  const _DharaPainter();

  static const Color _stone = Color(0xFF9E8A72);
  static const Color _stoneDark = Color(0xFF7C6A55);
  static const Color _stoneLit = Color(0xFFB9A88E);
  static const Color _brass = Color(0xFF9A5B44);
  static const Color _water = Color(0xFF8FCAD3);
  static const Color _waterDark = Color(0xFF4C94A3);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ---- back stone wall ----
    final wall = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.10, h * 0.05, w * 0.90, h * 0.62),
      topLeft: Radius.circular(w * 0.08),
      topRight: Radius.circular(w * 0.08),
    );
    canvas.drawRRect(wall, Paint()..color = _stone);
    // masonry seams
    final seam = Paint()
      ..color = _stoneDark.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(w * 0.10, h * 0.05 + i * h * 0.18),
          Offset(w * 0.90, h * 0.05 + i * h * 0.18), seam);
    }
    canvas.drawLine(Offset(w * 0.5, h * 0.05), Offset(w * 0.5, h * 0.23), seam);
    canvas.drawLine(Offset(w * 0.35, h * 0.23), Offset(w * 0.35, h * 0.41), seam);
    // lit top edge
    canvas.drawLine(Offset(w * 0.12, h * 0.06), Offset(w * 0.88, h * 0.06),
        Paint()
          ..color = _stoneLit
          ..strokeWidth = 2);

    // ---- carved brass/stone spout (makara-style) ----
    final spout = Path()
      ..moveTo(w * 0.44, h * 0.40)
      ..lineTo(w * 0.30, h * 0.40)
      ..quadraticBezierTo(w * 0.24, h * 0.44, w * 0.30, h * 0.50)
      ..lineTo(w * 0.42, h * 0.50)
      ..close();
    canvas.drawPath(spout, Paint()..color = _brass);
    canvas.drawCircle(
        Offset(w * 0.31, h * 0.45), w * 0.02, Paint()..color = _stoneDark);

    // ---- basin / pool at the bottom ----
    final basin = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.14, h * 0.78, w * 0.62, h * 0.96),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(basin, Paint()..color = _stoneDark);
    final pool = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.18, h * 0.80, w * 0.58, h * 0.90),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(pool, Paint()..color = _water);
    // water highlight
    canvas.drawLine(Offset(w * 0.22, h * 0.83), Offset(w * 0.40, h * 0.83),
        Paint()
          ..color = const Color(0xFFCDEDEF)
          ..strokeWidth = 1.5);
    // ripple rings where stream lands
    final ripple = Paint()
      ..color = _waterDark.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.37, h * 0.85),
            width: w * 0.14,
            height: h * 0.03),
        ripple);

    // a little brass water pot resting beside the basin
    final potPath = Path()
      ..moveTo(w * 0.66, h * 0.86)
      ..cubicTo(w * 0.60, h * 0.86, w * 0.60, h * 0.98, w * 0.70, h * 0.98)
      ..cubicTo(w * 0.80, h * 0.98, w * 0.80, h * 0.86, w * 0.74, h * 0.86)
      ..close();
    canvas.drawPath(potPath, Paint()..color = _brass);
    canvas.drawLine(Offset(w * 0.66, h * 0.86), Offset(w * 0.74, h * 0.86),
        Paint()
          ..color = _stoneDark
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DharaStreamPainter extends CustomPainter {
  const _DharaStreamPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stream = Path()
      ..moveTo(w * 0.2, 0)
      ..quadraticBezierTo(w * 0.9, h * 0.5, w * 0.55, h)
      ..lineTo(w * 0.35, h)
      ..quadraticBezierTo(w * 0.6, h * 0.5, w * 0.0, 0)
      ..close();
    canvas.drawPath(
        stream,
        Paint()
          ..color = const Color(0xFFCDEDEF).withValues(alpha: 0.9));
    canvas.drawPath(
        stream,
        Paint()
          ..color = const Color(0xFF8FCAD3).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------------
// 5) Goat — small white/grey goat, idle head bob.
// ----------------------------------------------------------------------------
class Goat extends StatelessWidget {
  final double size;
  const Goat({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.9,
      child: Stack(
        children: [
          // body (static)
          CustomPaint(
              size: Size(size, size * 0.9),
              painter: const _GoatBodyPainter()),
          // head (bobs)
          Positioned(
            left: size * 0.02,
            top: size * 0.08,
            child: SizedBox(
              width: size * 0.42,
              height: size * 0.5,
              child: const CustomPaint(painter: _GoatHeadPainter()),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  begin: -0.03,
                  end: 0.05,
                  duration: 2200.ms,
                  curve: Curves.easeInOut,
                  alignment: Alignment.bottomRight,
                ),
          ),
        ],
      ),
    );
  }
}

class _GoatBodyPainter extends CustomPainter {
  const _GoatBodyPainter();

  static const Color _coat = Color(0xFFD9CFC0);
  static const Color _shade = Color(0xFFB6AB99);
  static const Color _hoof = Color(0xFF5E3B26);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.55, h * 0.94),
          width: w * 0.7,
          height: h * 0.12),
      Paint()..color = const Color(0xFF2C5A32).withValues(alpha: 0.25),
    );

    // legs
    final legPaint = Paint()
      ..color = _shade
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    for (final lx in [w * 0.40, w * 0.52, w * 0.72, w * 0.84]) {
      canvas.drawLine(Offset(lx, h * 0.62), Offset(lx, h * 0.88), legPaint);
      canvas.drawCircle(Offset(lx, h * 0.89), w * 0.03, Paint()..color = _hoof);
    }

    // body
    final body = Path()
      ..moveTo(w * 0.30, h * 0.50)
      ..cubicTo(w * 0.25, h * 0.30, w * 0.55, h * 0.24, w * 0.72, h * 0.30)
      ..cubicTo(w * 0.92, h * 0.34, w * 0.98, h * 0.55, w * 0.88, h * 0.64)
      ..cubicTo(w * 0.70, h * 0.72, w * 0.42, h * 0.72, w * 0.30, h * 0.62)
      ..close();
    canvas.drawPath(body, Paint()..color = _coat);
    // belly shade
    canvas.drawPath(
        body,
        Paint()
          ..color = _shade.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    // little tail
    canvas.drawLine(Offset(w * 0.88, h * 0.36), Offset(w * 0.96, h * 0.30),
        Paint()
          ..color = _coat
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoatHeadPainter extends CustomPainter {
  const _GoatHeadPainter();

  static const Color _coat = Color(0xFFD9CFC0);
  static const Color _shade = Color(0xFFB6AB99);
  static const Color _horn = Color(0xFF8A5A3C);
  static const Color _eye = Color(0xFF3A2A1E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // horns
    final hornPaint = Paint()
      ..color = _horn
      ..strokeWidth = w * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.55, h * 0.30)
          ..quadraticBezierTo(w * 0.70, h * 0.05, w * 0.80, h * 0.18),
        hornPaint);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.45, h * 0.32)
          ..quadraticBezierTo(w * 0.58, h * 0.10, w * 0.66, h * 0.22),
        hornPaint);

    // head/muzzle
    final head = Path()
      ..moveTo(w * 0.10, h * 0.55)
      ..cubicTo(w * 0.05, h * 0.35, w * 0.35, h * 0.30, w * 0.60, h * 0.40)
      ..cubicTo(w * 0.78, h * 0.48, w * 0.72, h * 0.72, w * 0.50, h * 0.78)
      ..cubicTo(w * 0.30, h * 0.82, w * 0.12, h * 0.72, w * 0.10, h * 0.55)
      ..close();
    canvas.drawPath(head, Paint()..color = _coat);
    // muzzle shade
    canvas.drawOval(
        Rect.fromLTWH(w * 0.06, h * 0.55, w * 0.28, h * 0.22),
        Paint()..color = _shade.withValues(alpha: 0.4));
    // ear
    canvas.drawOval(
        Rect.fromLTWH(w * 0.55, h * 0.50, w * 0.30, h * 0.16),
        Paint()..color = _shade);
    // eye
    canvas.drawCircle(Offset(w * 0.34, h * 0.52), w * 0.05, Paint()..color = _eye);
    // beard
    canvas.drawLine(Offset(w * 0.18, h * 0.76), Offset(w * 0.20, h * 0.95),
        Paint()
          ..color = _coat
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------------------------------------------------------
// 6) DistantHouse — tiny simple hill house for far slopes. No animation.
// ----------------------------------------------------------------------------
class DistantHouse extends StatelessWidget {
  final double size;
  const DistantHouse({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: const _DistantHousePainter()),
    );
  }
}

class _DistantHousePainter extends CustomPainter {
  const _DistantHousePainter();

  static const Color _wall = Color(0xFFC99A5B);
  static const Color _wallLit = Color(0xFFEDE3C6);
  static const Color _stone = Color(0xFF9E8A72);
  static const Color _roof = Color(0xFF9A5B44);
  static const Color _roofDark = Color(0xFF7A4636);
  static const Color _window = Color(0xFF6E4A2E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.94),
          width: w * 0.8,
          height: h * 0.10),
      Paint()..color = const Color(0xFF2C5A32).withValues(alpha: 0.22),
    );

    // body
    final bodyRect = Rect.fromLTRB(w * 0.22, h * 0.42, w * 0.78, h * 0.90);
    canvas.drawRect(bodyRect, Paint()..color = _wall);
    // lit face
    canvas.drawRect(
        Rect.fromLTRB(w * 0.22, h * 0.42, w * 0.5, h * 0.90),
        Paint()..color = _wallLit.withValues(alpha: 0.55));
    // stone base
    canvas.drawRect(
        Rect.fromLTRB(w * 0.22, h * 0.80, w * 0.78, h * 0.90),
        Paint()..color = _stone);

    // corrugated tin roof (hip)
    final roof = Path()
      ..moveTo(w * 0.14, h * 0.44)
      ..lineTo(w * 0.5, h * 0.20)
      ..lineTo(w * 0.86, h * 0.44)
      ..close();
    canvas.drawPath(roof, Paint()..color = _roof);
    // roof ridge shade
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.20)
          ..lineTo(w * 0.86, h * 0.44)
          ..lineTo(w * 0.5, h * 0.44)
          ..close(),
        Paint()..color = _roofDark.withValues(alpha: 0.5));

    // window + door
    canvas.drawRect(
        Rect.fromLTRB(w * 0.30, h * 0.52, w * 0.42, h * 0.64),
        Paint()..color = _window);
    canvas.drawRect(
        Rect.fromLTRB(w * 0.56, h * 0.60, w * 0.68, h * 0.90),
        Paint()..color = _window);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
