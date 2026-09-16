import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The Rai family living in the village — cute hand-drawn girl / boy / pet
/// characters (no photos), each with a name and, for some, a Nepali speech
/// bubble. All decorative (IgnorePointer) so taps pass to the landmarks below.

const Color _ink = Color(0xFF3A2E4D);
const Color _skinDefault = Color(0xFFE7B98F);
const Color _hairDefault = Color(0xFF322017);

// ── Speech bubble ──────────────────────────────────────────────────────────
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text, this.maxWidth = 170});
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x30000000), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _ink, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.22)),
          ),
          CustomPaint(size: const Size(16, 9), painter: _BubbleTail()),
        ],
      ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
          begin: 0, end: -3, duration: 1900.ms, curve: Curves.easeInOut),
    );
  }
}

class _BubbleTail extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.4, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── A person (girl or boy) ──────────────────────────────────────────────────
enum PersonKind { girl, boy }

class _PersonPainter extends CustomPainter {
  const _PersonPainter(this.kind, this.cloth, this.hair, this.skin,
      {this.sitting = false});
  final PersonKind kind;
  final Color cloth;
  final Color hair;
  final Color skin;
  final bool sitting;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w * 0.5;
    final Paint p = Paint()..isAntiAlias = true;

    // shadow
    p.color = const Color(0x22000000);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, h * 0.975), width: w * 0.6, height: h * 0.08), p);

    final double headR = h * 0.15;
    final double headY = h * 0.19;

    // long hair behind (girl)
    if (kind == PersonKind.girl) {
      p.color = hair;
      canvas.drawPath(
        Path()
          ..moveTo(cx - headR * 1.15, headY)
          ..quadraticBezierTo(cx - headR * 1.5, h * 0.5, cx - headR * 0.7, h * 0.62)
          ..lineTo(cx + headR * 0.7, h * 0.62)
          ..quadraticBezierTo(cx + headR * 1.5, h * 0.5, cx + headR * 1.15, headY)
          ..close(),
        p,
      );
    }

    // legs
    final Paint leg = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Color shoe = const Color(0xFF4A3524);
    final Color pants = kind == PersonKind.boy ? const Color(0xFF3B4A66) : skin;
    if (sitting) {
      // seated: thigh forward, shin down (facing right, toward the desk)
      leg
        ..color = pants
        ..strokeWidth = w * (kind == PersonKind.boy ? 0.10 : 0.08);
      canvas.drawLine(Offset(cx - w * 0.02, h * 0.60), Offset(cx + w * 0.24, h * 0.66), leg);
      canvas.drawLine(Offset(cx + w * 0.24, h * 0.66), Offset(cx + w * 0.22, h * 0.92), leg);
      p.color = shoe;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + w * 0.24, h * 0.945), width: w * 0.15, height: h * 0.045), p);
    } else if (kind == PersonKind.boy) {
      leg
        ..color = pants
        ..strokeWidth = w * 0.11;
      canvas.drawLine(Offset(cx - w * 0.11, h * 0.66), Offset(cx - w * 0.13, h * 0.95), leg);
      canvas.drawLine(Offset(cx + w * 0.11, h * 0.66), Offset(cx + w * 0.13, h * 0.95), leg);
      p.color = shoe;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.12, h * 0.965), width: w * 0.13, height: h * 0.045), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.12, h * 0.965), width: w * 0.13, height: h * 0.045), p);
    } else {
      leg
        ..color = pants
        ..strokeWidth = w * 0.07;
      canvas.drawLine(Offset(cx - w * 0.09, h * 0.86), Offset(cx - w * 0.10, h * 0.96), leg);
      canvas.drawLine(Offset(cx + w * 0.09, h * 0.86), Offset(cx + w * 0.10, h * 0.96), leg);
      p.color = shoe;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.12, h * 0.965), width: w * 0.13, height: h * 0.045), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.12, h * 0.965), width: w * 0.13, height: h * 0.045), p);
    }

    // body / clothes
    p.color = cloth;
    if (kind == PersonKind.girl) {
      // frock (A-line dress) — shorter when seated so the legs show
      final double hemY = sitting ? h * 0.60 : h * 0.87;
      final double hemW = sitting ? w * 0.24 : w * 0.30;
      canvas.drawPath(
        Path()
          ..moveTo(cx - w * 0.16, h * 0.36)
          ..lineTo(cx + w * 0.16, h * 0.36)
          ..lineTo(cx + hemW, hemY)
          ..quadraticBezierTo(cx, hemY + h * 0.05, cx - hemW, hemY)
          ..close(),
        p,
      );
    } else {
      // shirt
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - w * 0.18, h * 0.36, w * 0.36, h * 0.32),
            Radius.circular(w * 0.08)),
        p,
      );
    }

    // arms
    final Paint arm = Paint()
      ..color = skin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06;
    canvas.drawLine(Offset(cx - w * 0.15, h * 0.42), Offset(cx - w * 0.24, h * 0.60), arm);
    canvas.drawLine(Offset(cx + w * 0.15, h * 0.42), Offset(cx + w * 0.24, h * 0.60), arm);

    // head
    p.color = skin;
    canvas.drawCircle(Offset(cx, headY), headR, p);

    // hair top
    p.color = hair;
    if (kind == PersonKind.girl) {
      canvas.drawPath(
        Path()
          ..moveTo(cx - headR * 1.1, headY + headR * 0.2)
          ..quadraticBezierTo(cx - headR * 1.2, headY - headR * 1.2, cx, headY - headR * 1.1)
          ..quadraticBezierTo(cx + headR * 1.2, headY - headR * 1.2, cx + headR * 1.1, headY + headR * 0.2)
          ..quadraticBezierTo(cx + headR * 0.6, headY - headR * 0.35, cx, headY - headR * 0.25)
          ..quadraticBezierTo(cx - headR * 0.6, headY - headR * 0.35, cx - headR * 1.1, headY + headR * 0.2)
          ..close(),
        p,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(cx - headR * 1.05, headY)
          ..quadraticBezierTo(cx - headR, headY - headR * 1.25, cx, headY - headR * 1.15)
          ..quadraticBezierTo(cx + headR, headY - headR * 1.25, cx + headR * 1.05, headY)
          ..quadraticBezierTo(cx + headR * 0.5, headY - headR * 0.5, cx, headY - headR * 0.45)
          ..quadraticBezierTo(cx - headR * 0.5, headY - headR * 0.5, cx - headR * 1.05, headY)
          ..close(),
        p,
      );
    }

    // face
    p.color = _ink;
    canvas.drawCircle(Offset(cx - headR * 0.38, headY + headR * 0.1), headR * 0.11, p);
    canvas.drawCircle(Offset(cx + headR * 0.38, headY + headR * 0.1), headR * 0.11, p);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, headY + headR * 0.28), radius: headR * 0.34),
      0.15,
      2.84,
      false,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = headR * 0.11
        ..strokeCap = StrokeCap.round,
    );
    // rosy cheeks
    p.color = const Color(0x33E8749E);
    canvas.drawCircle(Offset(cx - headR * 0.62, headY + headR * 0.32), headR * 0.18, p);
    canvas.drawCircle(Offset(cx + headR * 0.62, headY + headR * 0.32), headR * 0.18, p);
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) => false;
}

class _NameChip extends StatelessWidget {
  const _NameChip(this.name);
  final String name;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(20)),
        child: Text(name,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
      );
}

/// A named family member (girl/boy) with an optional speech bubble + held item.
class FamilyCharacter extends StatelessWidget {
  const FamilyCharacter({
    super.key,
    required this.kind,
    required this.cloth,
    required this.name,
    this.speech,
    this.size = 54,
    this.holdEmoji,
    this.hair = _hairDefault,
    this.skin = _skinDefault,
    this.bob = true,
    this.sitting = false,
    this.facingLeft = false,
    this.walk = false,
  });

  final PersonKind kind;
  final Color cloth;
  final String name;
  final String? speech;
  final double size;
  final String? holdEmoji;
  final Color hair;
  final Color skin;
  final bool bob;
  final bool sitting;

  /// Mirror the figure to face left (e.g. Mummy facing Papa).
  final bool facingLeft;

  /// A gentle side-to-side step, suggesting walking toward someone.
  final bool walk;

  @override
  Widget build(BuildContext context) {
    Widget figure = SizedBox(
      width: size * 0.7,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: _PersonPainter(kind, cloth, hair, skin, sitting: sitting))),
          if (holdEmoji != null)
            Positioned(
              right: -size * 0.06,
              top: size * 0.42,
              child: Text(holdEmoji!, style: TextStyle(fontSize: size * 0.24)),
            ),
        ],
      ),
    );
    if (facingLeft) {
      figure = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
        child: figure,
      );
    }
    if (walk) {
      figure = figure
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: 4, end: -4, duration: 900.ms, curve: Curves.easeInOut)
          .moveY(begin: 0, end: -1.5, duration: 450.ms, curve: Curves.easeInOut);
    } else if (bob) {
      figure = figure
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -2, duration: 2400.ms, curve: Curves.easeInOut);
    }
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (speech != null) ...[SpeechBubble(text: speech!), const SizedBox(height: 2)],
          figure,
          const SizedBox(height: 2),
          _NameChip(name),
        ],
      ),
    );
  }
}

/// A static (un-animated) person figure — its position and motion are driven
/// externally (e.g. by the yard-life simulation). [crouch] uses the seated
/// pose to read as crouching down to play with a pet.
class PersonBody extends StatelessWidget {
  const PersonBody({
    super.key,
    required this.kind,
    required this.cloth,
    this.hair = _hairDefault,
    this.skin = _skinDefault,
    this.size = 48,
    this.crouch = false,
  });
  final PersonKind kind;
  final Color cloth;
  final Color hair;
  final Color skin;
  final double size;
  final bool crouch;
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size * 0.7, size),
        painter: _PersonPainter(kind, cloth, hair, skin, sitting: crouch),
      );
}

/// A static pet figure — motion driven externally by the simulation.
class PetBody extends StatelessWidget {
  const PetBody({super.key, required this.kind, required this.color, this.size = 30});
  final PetKind kind;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size * 1.4, size), painter: _PetPainter(kind, color));
}

/// A small name chip (reusable by the simulation).
class NameTag extends StatelessWidget {
  const NameTag(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) => _NameChip(name);
}

/// Wraps any figure (e.g. the working farmer) with a name chip below it.
class NamedFigure extends StatelessWidget {
  const NamedFigure({super.key, required this.child, required this.name});
  final Widget child;
  final String name;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [child, const SizedBox(height: 2), _NameChip(name)],
        ),
      );
}

// ── Pets (drawn dog / cat) ──────────────────────────────────────────────────
enum PetKind { dog, cat }

class Pet extends StatelessWidget {
  const Pet({
    super.key,
    required this.kind,
    required this.color,
    required this.name,
    this.size = 34,
    this.hop = true,
  });
  final PetKind kind;
  final Color color;
  final String name;
  final double size;
  final bool hop;

  @override
  Widget build(BuildContext context) {
    Widget pet = SizedBox(
      width: size * 1.4,
      height: size,
      child: CustomPaint(painter: _PetPainter(kind, color)),
    );
    if (hop) {
      // Roam side to side while hopping, so the cat & dog really move about.
      pet = pet
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: -16, end: 16, duration: 2400.ms, curve: Curves.easeInOut)
          .moveY(begin: 0, end: -5, duration: 600.ms, curve: Curves.easeInOut);
    }
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [pet, const SizedBox(height: 1), _NameChip(name)],
      ),
    );
  }
}

class _PetPainter extends CustomPainter {
  const _PetPainter(this.kind, this.color);
  final PetKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;

    // shadow
    p.color = const Color(0x22000000);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.94), width: w * 0.7, height: h * 0.12), p);

    p.color = color;
    // body
    canvas.drawOval(Rect.fromLTWH(w * 0.14, h * 0.42, w * 0.56, h * 0.4), p);
    // legs
    final Paint leg = Paint()
      ..color = color
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.26, h * 0.78), Offset(w * 0.26, h * 0.92), leg);
    canvas.drawLine(Offset(w * 0.56, h * 0.78), Offset(w * 0.56, h * 0.92), leg);
    // head
    canvas.drawCircle(Offset(w * 0.72, h * 0.46), h * 0.2, p);

    if (kind == PetKind.dog) {
      // floppy ear
      p.color = Color.lerp(color, Colors.black, 0.18)!;
      canvas.drawOval(Rect.fromLTWH(w * 0.62, h * 0.34, w * 0.1, h * 0.28), p);
      // tail up
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.16, h * 0.5)
          ..quadraticBezierTo(w * 0.02, h * 0.34, w * 0.1, h * 0.22),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // cat triangle ears
      p.color = color;
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.64, h * 0.34)..lineTo(w * 0.68, h * 0.16)..lineTo(w * 0.74, h * 0.32)..close(),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.74, h * 0.32)..lineTo(w * 0.80, h * 0.16)..lineTo(w * 0.83, h * 0.34)..close(),
        p,
      );
      // curled tail
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.18, h * 0.55)
          ..quadraticBezierTo(w * 0.0, h * 0.5, w * 0.06, h * 0.34),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round,
      );
    }

    // eyes + nose
    p.color = _ink;
    canvas.drawCircle(Offset(w * 0.70, h * 0.44), h * 0.03, p);
    canvas.drawCircle(Offset(w * 0.80, h * 0.44), h * 0.03, p);
    p.color = const Color(0xFFE8749E);
    canvas.drawCircle(Offset(w * 0.76, h * 0.52), h * 0.028, p);
  }

  @override
  bool shouldRepaint(covariant _PetPainter oldDelegate) => false;
}

// ── Stubby's memorial ───────────────────────────────────────────────────────
class StubbyMemorial extends StatelessWidget {
  const StubbyMemorial({super.key, this.size = 70});
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size * 1.4,
        height: size,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            for (final f in const [
              [0.12, 0.9, Color(0xFFE8749E)],
              [0.85, 0.9, Color(0xFFF2C879)],
              [0.26, 0.82, Color(0xFFB79BE0)],
              [0.76, 0.8, Color(0xFFFFFFFF)],
            ])
              Positioned(
                left: (f[0] as double) * size * 1.4,
                bottom: (1 - (f[1] as double)) * size,
                child: _flower(f[2] as Color, size * 0.13),
              ),
            Positioned(
              bottom: size * 0.14,
              child: Container(
                width: size * 0.46,
                height: size * 0.4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB9AFC2), Color(0xFF8E8497)],
                  ),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size * 0.22), bottom: Radius.circular(size * 0.05)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 5, offset: Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text('🐾', style: TextStyle(fontSize: size * 0.2))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1500.ms)
                    .then()
                    .fadeOut(duration: 1500.ms),
              ),
            ),
            Positioned(bottom: 0, child: _NameChip('Stubby 🌈')),
          ],
        ),
      ),
    );
  }

  Widget _flower(Color c, double s) => SizedBox(
        width: s,
        height: s * 1.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            Container(width: s * 0.16, height: s * 0.8, color: const Color(0xFF5EA05C)),
          ],
        ),
      );
}

// ── Props: study desk, straw mat, water gagri, field plot, aagan ────────────
class StudyDesk extends StatelessWidget {
  const StudyDesk({super.key, this.size = 46});
  final double size;
  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(size: Size(size, size * 0.8), painter: _DeskPainter()));
}

class _DeskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final wood = Paint()..color = const Color(0xFF9A6B3C);
    final woodDark = Paint()..color = const Color(0xFF6E4A2E);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.55, w * 0.22, h * 0.08), wood);
    canvas.drawRect(Rect.fromLTWH(w * 0.07, h * 0.62, w * 0.04, h * 0.35), woodDark);
    canvas.drawRect(Rect.fromLTWH(w * 0.21, h * 0.62, w * 0.04, h * 0.35), woodDark);
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.42, w * 0.6, h * 0.09), wood);
    canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.5, w * 0.05, h * 0.47), woodDark);
    canvas.drawRect(Rect.fromLTWH(w * 0.85, h * 0.5, w * 0.05, h * 0.47), woodDark);
    final book = Paint()..color = const Color(0xFFFBF4E6);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.44, h * 0.42)
        ..lineTo(w * 0.64, h * 0.38)
        ..lineTo(w * 0.86, h * 0.42)
        ..lineTo(w * 0.64, h * 0.44)
        ..close(),
      book,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StrawMat extends StatelessWidget {
  const StrawMat({super.key, this.width = 74});
  final double width;
  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(size: Size(width, width * 0.4), painter: _MatPainter()));
}

class _MatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final mat = Path()
      ..moveTo(w * 0.18, h * 0.1)
      ..lineTo(w * 0.95, h * 0.35)
      ..lineTo(w * 0.82, h * 0.95)
      ..lineTo(w * 0.05, h * 0.6)
      ..close();
    canvas.drawPath(mat, Paint()..color = const Color(0xFFE0C98A));
    final line = Paint()
      ..color = const Color(0xFFC7A86F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (int i = 1; i < 5; i++) {
      final t = i / 5;
      canvas.drawLine(Offset(w * (0.18 + 0.77 * t), h * (0.1 + 0.25 * t)),
          Offset(w * (0.05 + 0.77 * t), h * (0.6 + 0.35 * t)), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaterGagri extends StatelessWidget {
  const WaterGagri({super.key, this.size = 22});
  final double size;
  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(size: Size(size, size * 1.2), painter: _GagriPainter()));
}

class _GagriPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final brass = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8B84B), Color(0xFFB98A2E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.3, h * 0.35)
        ..quadraticBezierTo(w * -0.05, h * 0.6, w * 0.2, h * 0.9)
        ..quadraticBezierTo(w * 0.5, h * 1.05, w * 0.8, h * 0.9)
        ..quadraticBezierTo(w * 1.05, h * 0.6, w * 0.7, h * 0.35)
        ..close(),
      brass,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.2, w * 0.36, h * 0.18),
            Radius.circular(w * 0.06)),
        brass);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.12, w * 0.48, h * 0.1),
            Radius.circular(w * 0.06)),
        Paint()..color = const Color(0xFFCF9A34));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A ploughed field plot with rows of young crops (where Papa & Mummy work).
class FieldPlot extends StatelessWidget {
  const FieldPlot({super.key, this.width = 220});
  final double width;
  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(size: Size(width, width * 0.5), painter: _FieldPainter()));
}

class _FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // soil plot (an angled patch)
    final plot = Path()
      ..moveTo(w * 0.14, h * 0.2)
      ..lineTo(w * 0.96, h * 0.32)
      ..lineTo(w * 0.84, h * 0.94)
      ..lineTo(w * 0.03, h * 0.78)
      ..close();
    canvas.drawPath(plot, Paint()..color = const Color(0xFF9C6B40));
    canvas.drawPath(plot, Paint()..color = const Color(0xFF7E5330).withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 2);
    // furrow rows + green sprouts
    final row = Paint()
      ..color = const Color(0xFF7E5330)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.02;
    final sprout = Paint()
      ..color = const Color(0xFF6FBE5C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.02
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i <= 4; i++) {
      final t = i / 5.0;
      final x1 = w * (0.10 + 0.83 * t), y1 = h * (0.22 + 0.10 * t);
      final x2 = w * (0.03 + 0.81 * t), y2 = h * (0.78 + 0.16 * (t - 0.5).abs());
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), row);
      for (double s = 0.15; s < 0.95; s += 0.22) {
        final px = x1 + (x2 - x1) * s, py = y1 + (y2 - y1) * s;
        canvas.drawLine(Offset(px, py), Offset(px - w * 0.006, py - h * 0.06), sprout);
        canvas.drawLine(Offset(px, py), Offset(px + w * 0.01, py - h * 0.05), sprout);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The clean, freshly-swept earthen courtyard (aagan) in front of the house,
/// ringed with little potted plants.
class Aagan extends StatelessWidget {
  const Aagan({super.key, this.width = 220});
  final double width;
  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(size: Size(width, width * 0.52), painter: _AaganPainter()));
}

class _AaganPainter extends CustomPainter {
  static const List<Color> _flowerCols = [
    Color(0xFFE8749E),
    Color(0xFFF2C879),
    Color(0xFFD2483B),
    Color(0xFFB79BE0),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Rect.fromLTWH(w * 0.06, h * 0.28, w * 0.88, h * 0.66);

    // Smooth, clean swept ochre courtyard (no dirt, no grass).
    canvas.drawOval(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.25),
          colors: [Color(0xFFF1E0B9), Color(0xFFDDC393)],
        ).createShader(rect),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = const Color(0xFFCBAE7E).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Faint concentric broom-sweep arcs (shows it's swept clean).
    final sweep = Paint()
      ..color = const Color(0xFFC9AC7A).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i < 5; i++) {
      canvas.drawArc(rect.deflate(w * 0.045 * i), 3.5, 2.3, false, sweep);
    }

    // Potted plants ringing the courtyard.
    _pot(canvas, w * 0.09, h * 0.62, w * 0.05, _flowerCols[0]);
    _pot(canvas, w * 0.91, h * 0.62, w * 0.05, _flowerCols[1]);
    _pot(canvas, w * 0.22, h * 0.92, w * 0.048, _flowerCols[2]);
    _pot(canvas, w * 0.78, h * 0.92, w * 0.048, _flowerCols[3]);
    _pot(canvas, w * 0.50, h * 0.965, w * 0.046, _flowerCols[4]);
  }

  void _pot(Canvas canvas, double cx, double cy, double s, Color flower) {
    final p = Paint()..isAntiAlias = true;
    // shadow
    p.color = const Color(0x18000000);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + s * 0.6), width: s * 1.8, height: s * 0.5), p);
    // terracotta pot
    p.color = const Color(0xFFC06B4A);
    canvas.drawPath(
      Path()
        ..moveTo(cx - s * 0.75, cy - s * 0.1)
        ..lineTo(cx + s * 0.75, cy - s * 0.1)
        ..lineTo(cx + s * 0.55, cy + s * 0.6)
        ..lineTo(cx - s * 0.55, cy + s * 0.6)
        ..close(),
      p,
    );
    p.color = const Color(0xFFA9552F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy - s * 0.12), width: s * 1.7, height: s * 0.3),
          Radius.circular(s * 0.1)),
      p,
    );
    // green plant
    final leaf = Paint()
      ..color = const Color(0xFF5EA05C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - s * 0.1), Offset(cx - s * 0.55, cy - s * 1.2), leaf);
    canvas.drawLine(Offset(cx, cy - s * 0.1), Offset(cx + s * 0.55, cy - s * 1.1), leaf);
    canvas.drawLine(Offset(cx, cy - s * 0.1), Offset(cx, cy - s * 1.45), leaf);
    // flower
    p.color = flower;
    canvas.drawCircle(Offset(cx, cy - s * 1.5), s * 0.32, p);
    p.color = const Color(0xFFF2C879);
    canvas.drawCircle(Offset(cx, cy - s * 1.5), s * 0.12, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
