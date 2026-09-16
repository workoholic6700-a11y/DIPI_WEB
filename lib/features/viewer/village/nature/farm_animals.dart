import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Cozy farm animals for the Nepali hill village scene.
/// Three animated widgets — [Hen], [Cow], [Buffalo] — each self-contained,
/// with a fixed intrinsic size, a soft ground shadow, and a slow subtle
/// idle animation driven purely by flutter_animate (no manual controllers).

// ---------------------------------------------------------------------------
// Shared palette
// ---------------------------------------------------------------------------
class _Pal {
  static const cowBody = Color(0xFFEFE6D6);
  static const cowPatch = Color(0xFFA9764A);
  static const henBody = Color(0xFFF1EBD9);
  static const henBrown = Color(0xFFD9C39A);
  static const comb = Color(0xFFD2483B);
  static const buffalo = Color(0xFF4A4048);
  static const buffaloLight = Color(0xFF5C525A);
  static const horn = Color(0xFFEDE3C6);
  static const hornDark = Color(0xFFCBBE9C);
  static const hoof = Color(0xFF5E3B26);
  static const shadow = Color(0xFF2E3A2A);
  static const beak = Color(0xFFF2C879);
  static const eye = Color(0xFF3A2E28);
}

// ---------------------------------------------------------------------------
// HEN — ~22px tall, pecking (head bobs down/up)
// ---------------------------------------------------------------------------
class Hen extends StatelessWidget {
  final double size;
  const Hen({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final w = size * 1.15;
    final h = size;
    // The whole hen tilts forward and back to read as a peck.
    return SizedBox(
      width: w,
      height: h * 1.12,
      child: CustomPaint(painter: _HenPainter())
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(
            begin: -0.02,
            end: 0.10,
            duration: 900.ms,
            curve: Curves.easeInOut,
            alignment: const Alignment(0.35, 1.0),
          ),
    );
  }
}

class _HenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    // Ground shadow
    p.color = _Pal.shadow.withValues(alpha: 0.16);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.48, h * 0.96), width: w * 0.72, height: h * 0.13),
      p,
    );

    // Legs
    final leg = Paint()
      ..color = _Pal.beak
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.42, h * 0.74), Offset(w * 0.40, h * 0.92), leg);
    canvas.drawLine(
        Offset(w * 0.52, h * 0.74), Offset(w * 0.55, h * 0.92), leg);
    // tiny toes
    canvas.drawLine(
        Offset(w * 0.40, h * 0.92), Offset(w * 0.34, h * 0.93), leg);
    canvas.drawLine(
        Offset(w * 0.55, h * 0.92), Offset(w * 0.61, h * 0.93), leg);

    // Tail feathers (behind body)
    final tail = Path()
      ..moveTo(w * 0.14, h * 0.52)
      ..quadraticBezierTo(w * -0.06, h * 0.30, w * 0.10, h * 0.20)
      ..quadraticBezierTo(w * 0.18, h * 0.36, w * 0.30, h * 0.46)
      ..close();
    p.color = _Pal.henBrown;
    canvas.drawPath(tail, p);

    // Body
    p.color = _Pal.henBody;
    final body = Path()
      ..moveTo(w * 0.18, h * 0.58)
      ..quadraticBezierTo(w * 0.16, h * 0.28, w * 0.46, h * 0.28)
      ..quadraticBezierTo(w * 0.72, h * 0.30, w * 0.66, h * 0.66)
      ..quadraticBezierTo(w * 0.60, h * 0.80, w * 0.40, h * 0.78)
      ..quadraticBezierTo(w * 0.22, h * 0.76, w * 0.18, h * 0.58)
      ..close();
    canvas.drawPath(body, p);

    // Wing shading
    p.color = _Pal.henBrown.withValues(alpha: 0.7);
    final wing = Path()
      ..moveTo(w * 0.30, h * 0.44)
      ..quadraticBezierTo(w * 0.50, h * 0.40, w * 0.58, h * 0.56)
      ..quadraticBezierTo(w * 0.46, h * 0.66, w * 0.30, h * 0.60)
      ..close();
    canvas.drawPath(wing, p);

    // Head
    p.color = _Pal.henBody;
    canvas.drawCircle(Offset(w * 0.66, h * 0.34), w * 0.16, p);

    // Comb (red) on top of head
    p.color = _Pal.comb;
    final comb = Path()
      ..moveTo(w * 0.58, h * 0.22)
      ..quadraticBezierTo(w * 0.60, h * 0.10, w * 0.66, h * 0.16)
      ..quadraticBezierTo(w * 0.70, h * 0.08, w * 0.74, h * 0.18)
      ..quadraticBezierTo(w * 0.72, h * 0.24, w * 0.66, h * 0.24)
      ..close();
    canvas.drawPath(comb, p);

    // Wattle under beak
    final wattle = Path()
      ..moveTo(w * 0.78, h * 0.40)
      ..quadraticBezierTo(w * 0.82, h * 0.50, w * 0.76, h * 0.48)
      ..close();
    canvas.drawPath(wattle, p);

    // Beak
    p.color = _Pal.beak;
    final beak = Path()
      ..moveTo(w * 0.80, h * 0.34)
      ..lineTo(w * 0.94, h * 0.37)
      ..lineTo(w * 0.80, h * 0.42)
      ..close();
    canvas.drawPath(beak, p);

    // Eye
    p.color = _Pal.eye;
    canvas.drawCircle(Offset(w * 0.72, h * 0.32), w * 0.028, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// COW — ~64w x 44h, head-graze bob + occasional tail flick
// ---------------------------------------------------------------------------
class Cow extends StatelessWidget {
  final double width;
  const Cow({super.key, this.width = 64});

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * 0.72;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Static body + legs + shadow
          Positioned.fill(child: CustomPaint(painter: _CowBodyPainter())),
          // Animated head — gentle graze bob (down/up)
          Positioned(
            left: 0,
            top: 0,
            width: w,
            height: h,
            child: CustomPaint(painter: _CowHeadPainter())
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    begin: -h * 0.02,
                    end: h * 0.06,
                    duration: 2200.ms,
                    curve: Curves.easeInOut),
          ),
          // Animated tail — occasional flick
          Positioned(
            left: 0,
            top: 0,
            width: w,
            height: h,
            child: CustomPaint(painter: _CowTailPainter())
                .animate(onPlay: (c) => c.repeat())
                .rotate(
                  begin: -0.05,
                  end: 0.05,
                  duration: 700.ms,
                  curve: Curves.easeInOut,
                  // Pivot at the tail's attachment to the rump (~0.86w, 0.42h)
                  // so it swings from the base instead of tearing off the body.
                  alignment: const Alignment(0.72, -0.16),
                )
                .then(delay: 2600.ms),
          ),
        ],
      ),
    );
  }
}

class _CowBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    // Shadow
    p.color = _Pal.shadow.withValues(alpha: 0.18);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.52, h * 0.94), width: w * 0.82, height: h * 0.12),
      p,
    );

    // Legs
    p.color = _Pal.cowBody;
    void legRect(double cx) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx, h * 0.60, w * 0.075, h * 0.32),
        Radius.circular(w * 0.02),
      );
      canvas.drawRRect(r, p);
    }

    legRect(w * 0.26);
    legRect(w * 0.40);
    legRect(w * 0.62);
    legRect(w * 0.76);

    // Hooves
    p.color = _Pal.hoof;
    void hoof(double cx) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx, h * 0.88, w * 0.075, h * 0.05),
          Radius.circular(w * 0.015),
        ),
        p,
      );
    }

    hoof(w * 0.26);
    hoof(w * 0.40);
    hoof(w * 0.62);
    hoof(w * 0.76);

    // Body
    p.color = _Pal.cowBody;
    final body = Path()
      ..moveTo(w * 0.20, h * 0.55)
      ..quadraticBezierTo(w * 0.18, h * 0.30, w * 0.45, h * 0.30)
      ..quadraticBezierTo(w * 0.80, h * 0.28, w * 0.86, h * 0.48)
      ..quadraticBezierTo(w * 0.90, h * 0.66, w * 0.70, h * 0.70)
      ..quadraticBezierTo(w * 0.45, h * 0.74, w * 0.26, h * 0.70)
      ..quadraticBezierTo(w * 0.19, h * 0.66, w * 0.20, h * 0.55)
      ..close();
    canvas.drawPath(body, p);

    // Brown patches
    p.color = _Pal.cowPatch;
    final patch1 = Path()
      ..moveTo(w * 0.30, h * 0.36)
      ..quadraticBezierTo(w * 0.44, h * 0.30, w * 0.50, h * 0.44)
      ..quadraticBezierTo(w * 0.42, h * 0.56, w * 0.28, h * 0.52)
      ..quadraticBezierTo(w * 0.24, h * 0.42, w * 0.30, h * 0.36)
      ..close();
    canvas.drawPath(patch1, p);

    final patch2 = Path()
      ..moveTo(w * 0.62, h * 0.34)
      ..quadraticBezierTo(w * 0.78, h * 0.34, w * 0.80, h * 0.50)
      ..quadraticBezierTo(w * 0.70, h * 0.60, w * 0.60, h * 0.52)
      ..quadraticBezierTo(w * 0.58, h * 0.40, w * 0.62, h * 0.34)
      ..close();
    canvas.drawPath(patch2, p);

    // Soft belly shadow
    p.color = _Pal.cowPatch.withValues(alpha: 0.15);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.66), width: w * 0.55, height: h * 0.14),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CowHeadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    // Neck join
    p.color = _Pal.cowBody;
    final neck = Path()
      ..moveTo(w * 0.20, h * 0.40)
      ..quadraticBezierTo(w * 0.08, h * 0.42, w * 0.06, h * 0.58)
      ..lineTo(w * 0.20, h * 0.60)
      ..close();
    canvas.drawPath(neck, p);

    // Horns
    final horn = Paint()
      ..color = _Pal.horn
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.12, h * 0.36), Offset(w * 0.07, h * 0.24), horn);
    canvas.drawLine(Offset(w * 0.18, h * 0.34), Offset(w * 0.20, h * 0.22), horn);

    // Ears
    p.color = _Pal.cowBody;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.04, h * 0.42), width: w * 0.10, height: h * 0.08),
        p);

    // Head
    final head = Path()
      ..moveTo(w * 0.16, h * 0.36)
      ..quadraticBezierTo(w * 0.02, h * 0.40, w * 0.03, h * 0.56)
      ..quadraticBezierTo(w * 0.05, h * 0.70, w * 0.16, h * 0.68)
      ..quadraticBezierTo(w * 0.24, h * 0.64, w * 0.22, h * 0.48)
      ..quadraticBezierTo(w * 0.22, h * 0.38, w * 0.16, h * 0.36)
      ..close();
    canvas.drawPath(head, p);

    // Muzzle
    p.color = _Pal.cowPatch.withValues(alpha: 0.55);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.07, h * 0.60), width: w * 0.12, height: h * 0.14),
        p);

    // Eye
    p.color = _Pal.eye;
    canvas.drawCircle(Offset(w * 0.12, h * 0.48), w * 0.018, p);

    // Nostril
    canvas.drawCircle(Offset(w * 0.055, h * 0.60), w * 0.012, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CowTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..isAntiAlias = true
      ..color = _Pal.cowBody
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final tail = Path()
      ..moveTo(w * 0.86, h * 0.42)
      ..quadraticBezierTo(w * 0.94, h * 0.58, w * 0.90, h * 0.74);
    canvas.drawPath(tail, p);

    // Tuft
    p.style = PaintingStyle.fill;
    p.color = _Pal.cowPatch;
    canvas.drawCircle(Offset(w * 0.90, h * 0.76), w * 0.03, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// BUFFALO — ~72w, slow idle breathing bob
// ---------------------------------------------------------------------------
class Buffalo extends StatelessWidget {
  final double width;
  const Buffalo({super.key, this.width = 72});

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * 0.66;
    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(painter: _BuffaloPainter())
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.018,
            duration: 2600.ms,
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
          ),
    );
  }
}

class _BuffaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..isAntiAlias = true;

    // Shadow
    p.color = _Pal.shadow.withValues(alpha: 0.20);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.95), width: w * 0.86, height: h * 0.12),
      p,
    );

    // Legs
    p.color = _Pal.buffalo;
    void leg(double cx) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx, h * 0.58, w * 0.08, h * 0.36),
          Radius.circular(w * 0.02),
        ),
        p,
      );
    }

    leg(w * 0.24);
    leg(w * 0.38);
    leg(w * 0.60);
    leg(w * 0.74);

    // Hooves
    p.color = _Pal.hoof;
    void hoof(double cx) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx, h * 0.90, w * 0.08, h * 0.05),
          Radius.circular(w * 0.015),
        ),
        p,
      );
    }

    hoof(w * 0.24);
    hoof(w * 0.38);
    hoof(w * 0.60);
    hoof(w * 0.74);

    // Body — heavier, lower slung than the cow
    p.color = _Pal.buffalo;
    final body = Path()
      ..moveTo(w * 0.18, h * 0.56)
      ..quadraticBezierTo(w * 0.16, h * 0.30, w * 0.44, h * 0.30)
      ..quadraticBezierTo(w * 0.82, h * 0.28, w * 0.88, h * 0.50)
      ..quadraticBezierTo(w * 0.92, h * 0.68, w * 0.68, h * 0.72)
      ..quadraticBezierTo(w * 0.42, h * 0.76, w * 0.24, h * 0.72)
      ..quadraticBezierTo(w * 0.17, h * 0.66, w * 0.18, h * 0.56)
      ..close();
    canvas.drawPath(body, p);

    // Back highlight (ridge)
    p.color = _Pal.buffaloLight.withValues(alpha: 0.8);
    final ridge = Path()
      ..moveTo(w * 0.28, h * 0.34)
      ..quadraticBezierTo(w * 0.55, h * 0.28, w * 0.80, h * 0.36)
      ..quadraticBezierTo(w * 0.55, h * 0.34, w * 0.28, h * 0.40)
      ..close();
    canvas.drawPath(ridge, p);

    // Head
    p.color = _Pal.buffalo;
    final head = Path()
      ..moveTo(w * 0.18, h * 0.40)
      ..quadraticBezierTo(w * 0.02, h * 0.44, w * 0.03, h * 0.60)
      ..quadraticBezierTo(w * 0.05, h * 0.74, w * 0.18, h * 0.72)
      ..quadraticBezierTo(w * 0.26, h * 0.66, w * 0.24, h * 0.50)
      ..quadraticBezierTo(w * 0.24, h * 0.42, w * 0.18, h * 0.40)
      ..close();
    canvas.drawPath(head, p);

    // Large curved horns (sweeping back — signature buffalo)
    final horn = Paint()
      ..color = _Pal.horn
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final hornL = Path()
      ..moveTo(w * 0.14, h * 0.36)
      ..quadraticBezierTo(w * 0.02, h * 0.20, w * 0.14, h * 0.10)
      ..quadraticBezierTo(w * 0.20, h * 0.06, w * 0.22, h * 0.14);
    canvas.drawPath(hornL, horn);
    final hornR = Path()
      ..moveTo(w * 0.22, h * 0.34)
      ..quadraticBezierTo(w * 0.30, h * 0.18, w * 0.24, h * 0.08);
    canvas.drawPath(hornR, horn);

    // Horn shading
    horn.color = _Pal.hornDark;
    horn.strokeWidth = w * 0.018;
    final hornLsh = Path()
      ..moveTo(w * 0.14, h * 0.36)
      ..quadraticBezierTo(w * 0.03, h * 0.21, w * 0.14, h * 0.12);
    canvas.drawPath(hornLsh, horn);

    // Muzzle
    p.color = _Pal.buffaloLight;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.07, h * 0.62), width: w * 0.13, height: h * 0.15),
        p);

    // Eye
    p.color = const Color(0xFF1E1A1C);
    canvas.drawCircle(Offset(w * 0.13, h * 0.50), w * 0.02, p);
    // small catchlight
    p.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(w * 0.135, h * 0.485), w * 0.007, p);

    // Nostril
    p.color = const Color(0xFF2A2428);
    canvas.drawCircle(Offset(w * 0.055, h * 0.62), w * 0.014, p);

    // Tail
    final tail = Paint()
      ..color = _Pal.buffalo
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final t = Path()
      ..moveTo(w * 0.88, h * 0.46)
      ..quadraticBezierTo(w * 0.95, h * 0.62, w * 0.91, h * 0.76);
    canvas.drawPath(t, tail);
    p.color = const Color(0xFF2A2428);
    canvas.drawCircle(Offset(w * 0.91, h * 0.78), w * 0.028, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}