import 'package:flutter/material.dart';

/// The pitch under floodlights — drawn, not borrowed.
///
/// Didi's Corner used to show a scanned manga panel. It was lovely and it was
/// somebody else's, which was fine on her own phone and would have been a
/// problem the day this app went anywhere. So this is the same feeling in the
/// app's own hand: an empty pitch at night with the lights on, which is where
/// the football stories she loves all happen, and which is roughly what
/// "somewhere else to go for a while" looks like.
///
/// Entirely code — no asset, nothing to license, nothing to remove later.
class DidiPitch extends StatelessWidget {
  const DidiPitch({super.key, this.height = 190});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _PitchPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // ── Night sky over the ground ──
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16213E), Color(0xFF2A3A63), Color(0xFF35507A)],
        ).createShader(Offset.zero & size),
    );

    // A few stars, seeded by hand so they never move.
    const stars = [
      [0.10, 0.14], [0.26, 0.09], [0.41, 0.19], [0.63, 0.11],
      [0.79, 0.17], [0.90, 0.08], [0.17, 0.25], [0.71, 0.24],
    ];
    for (final s in stars) {
      canvas.drawCircle(
        Offset(w * s[0], h * s[1]),
        1.1,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }

    // ── Floodlights, one each side ──
    for (final x in [w * 0.14, w * 0.86]) {
      // The beam, thrown down onto the grass.
      final beam = Path()
        ..moveTo(x, h * 0.30)
        ..lineTo(x - w * 0.30, h * 0.92)
        ..lineTo(x + w * 0.30, h * 0.92)
        ..close();
      canvas.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF3C4).withValues(alpha: 0.30),
              const Color(0xFFFFF3C4).withValues(alpha: 0.0),
            ],
          ).createShader(
              Rect.fromLTWH(x - w * 0.30, h * 0.30, w * 0.60, h * 0.62)),
      );

      // The mast.
      canvas.drawLine(
        Offset(x, h * 0.30),
        Offset(x, h * 0.66),
        Paint()
          ..color = const Color(0xFF101B33)
          ..strokeWidth = 2.5,
      );
      // The lamp head.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(x, h * 0.28), width: 26, height: 11),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF0C1428),
      );
      // Its glow.
      canvas.drawCircle(
        Offset(x, h * 0.28),
        16,
        Paint()
          ..color = const Color(0xFFFFF3C4).withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(x - 8 + i * 8, h * 0.28),
          2.6,
          Paint()..color = const Color(0xFFFFF8DC),
        );
      }
    }

    // ── The grass ──
    final grass = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.56, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(grass, Paint()..color = const Color(0xFF2F6B4F));

    // Mown stripes, the way a pitch is cut.
    for (var i = 0; i < 6; i++) {
      if (i.isEven) continue;
      final left = w * (i / 6);
      canvas.drawRect(
        Rect.fromLTWH(left, h * 0.58, w / 6, h * 0.44),
        Paint()..color = const Color(0xFF357C5A).withValues(alpha: 0.55),
      );
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // The halfway line and the centre circle, in perspective.
    canvas.drawLine(
        Offset(0, h * 0.78), Offset(w, h * 0.78), line);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w / 2, h * 0.78), width: w * 0.34, height: h * 0.15),
      line,
    );
    canvas.drawCircle(
      Offset(w / 2, h * 0.78),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    // ── The ball, waiting on the spot ──
    final ball = Offset(w * 0.5, h * 0.905);
    canvas.drawOval(
      Rect.fromCenter(center: ball.translate(1, 8), width: 22, height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );
    canvas.drawCircle(ball, 10, Paint()..color = const Color(0xFFFDFDFB));
    // Its panels — one pentagon and three seams is enough to read as a ball.
    final panel = Paint()..color = const Color(0xFF23314F);
    final pent = Path();
    for (var i = 0; i < 5; i++) {
      final a = -1.5708 + i * 1.2566;
      final p = Offset(ball.dx + 4.1 * _cos(a), ball.dy + 4.1 * _sin(a));
      i == 0 ? pent.moveTo(p.dx, p.dy) : pent.lineTo(p.dx, p.dy);
    }
    pent.close();
    canvas.drawPath(pent, panel);
    for (var i = 0; i < 5; i++) {
      final a = -1.5708 + i * 1.2566;
      canvas.drawLine(
        Offset(ball.dx + 4.1 * _cos(a), ball.dy + 4.1 * _sin(a)),
        Offset(ball.dx + 9.6 * _cos(a), ball.dy + 9.6 * _sin(a)),
        Paint()
          ..color = panel.color
          ..strokeWidth = 1.4,
      );
    }
  }

  // Tiny local trig so this file needs no import.
  double _cos(double a) => _series(a + 1.5707963268);
  double _sin(double a) => _series(a);
  double _series(double x) {
    // Normalise to [-pi, pi] then a 7th-order Taylor sine — plenty for a ball.
    const twoPi = 6.2831853072;
    var v = x % twoPi;
    if (v > 3.1415926536) v -= twoPi;
    if (v < -3.1415926536) v += twoPi;
    final x2 = v * v;
    return v * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
