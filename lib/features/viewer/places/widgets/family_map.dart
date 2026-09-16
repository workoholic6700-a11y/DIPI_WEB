import 'package:flutter/material.dart';

/// A hand-drawn family map of Nepal — paper, not cartography.
///
/// Deliberately **not** a real map and never claims to be one. The places are
/// placed by the part of the country they're in — the eastern hills, the
/// middle, the southern plain — which is true, rather than by coordinates
/// nobody in this family ever wrote down. The screen says so out loud.
class FamilyMapPainter extends CustomPainter {
  const FamilyMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Aged paper.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4EAD5),
    );

    // ── The snows along the north edge ──
    final snow = Path()..moveTo(0, h * 0.30);
    for (var i = 0; i <= 10; i++) {
      final x = w * i / 10;
      final peak = h * (0.30 - (i.isEven ? 0.11 : 0.06));
      ph(snow, x, peak, w / 20);
    }
    snow
      ..lineTo(w, h * 0.30)
      ..lineTo(w, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(snow, Paint()..color = const Color(0xFFE7EDF2));

    // Shadow under the peaks.
    canvas.drawPath(
      snow,
      Paint()
        ..color = const Color(0xFFBFCBD8).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── The hills: three bands, greener as they come south ──
    _band(canvas, w, h, 0.28, 0.50, const Color(0xFF9CB98A));
    _band(canvas, w, h, 0.46, 0.68, const Color(0xFF86AE72));
    _band(canvas, w, h, 0.62, 0.84, const Color(0xFF6F9E5E));

    // ── The terai along the south ──
    final terai = Path()
      ..moveTo(0, h * 0.80)
      ..quadraticBezierTo(w * 0.5, h * 0.75, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(terai, Paint()..color = const Color(0xFFCBC188));

    // ── A river, running south out of the hills ──
    final river = Path()
      ..moveTo(w * 0.70, h * 0.34)
      ..cubicTo(w * 0.62, h * 0.52, w * 0.58, h * 0.62, w * 0.44, h * 0.74)
      ..cubicTo(w * 0.36, h * 0.80, w * 0.30, h * 0.86, w * 0.22, h * 0.95);
    canvas.drawPath(
      river,
      Paint()
        ..color = const Color(0xFF8FB6CF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // ── The fold lines of a paper map ──
    final fold = Paint()
      ..color = const Color(0xFFB9A98A).withValues(alpha: 0.30)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), fold);
    canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), fold);
  }

  /// One rolling band of hills.
  void _band(Canvas canvas, double w, double h, double top, double bottom,
      Color color) {
    final p = Path()..moveTo(0, h * top);
    const steps = 7;
    for (var i = 0; i < steps; i++) {
      final x1 = w * (i + 0.5) / steps;
      final x2 = w * (i + 1) / steps;
      p.quadraticBezierTo(x1, h * (top - 0.045), x2, h * top);
    }
    p
      ..lineTo(w, h * bottom)
      ..lineTo(0, h * bottom)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  /// One snow peak.
  void ph(Path path, double x, double y, double halfWidth) {
    path
      ..lineTo(x - halfWidth, y + halfWidth * 0.8)
      ..lineTo(x, y)
      ..lineTo(x + halfWidth, y + halfWidth * 0.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
