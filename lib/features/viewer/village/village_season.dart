import 'dart:math' as math;

import 'package:flutter/material.dart';

enum VillageSeason { spring, monsoon, autumn, winter }

VillageSeason villageSeasonFor(DateTime date) => switch (date.month) {
  3 || 4 || 5 => VillageSeason.spring,
  6 || 7 || 8 || 9 => VillageSeason.monsoon,
  10 || 11 => VillageSeason.autumn,
  _ => VillageSeason.winter,
};

extension VillageSeasonX on VillageSeason {
  String get label => switch (this) {
    VillageSeason.spring => 'Spring in the hills',
    VillageSeason.monsoon => 'Monsoon green',
    VillageSeason.autumn => 'Clear autumn',
    VillageSeason.winter => 'Winter mist',
  };

  String get emoji => switch (this) {
    VillageSeason.spring => '🌸',
    VillageSeason.monsoon => '🌿',
    VillageSeason.autumn => '🍂',
    VillageSeason.winter => '🌫️',
  };
}

/// A static seasonal layer. It changes with the calendar but never loops, so
/// the village can feel current without keeping the phone repainting.
class VillageSeasonLayer extends StatelessWidget {
  const VillageSeasonLayer({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width, height),
          painter: _SeasonPainter(villageSeasonFor(DateTime.now())),
        ),
      ),
    );
  }
}

class _SeasonPainter extends CustomPainter {
  const _SeasonPainter(this.season);

  final VillageSeason season;

  @override
  void paint(Canvas canvas, Size size) {
    switch (season) {
      case VillageSeason.spring:
        _spring(canvas, size);
        break;
      case VillageSeason.monsoon:
        _monsoon(canvas, size);
        break;
      case VillageSeason.autumn:
        _autumn(canvas, size);
        break;
      case VillageSeason.winter:
        _winter(canvas, size);
        break;
    }
  }

  void _spring(Canvas canvas, Size size) {
    final random = math.Random(21);
    final paint = Paint()..color = const Color(0x66F4A9C7);
    for (var i = 0; i < 54; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.55 + random.nextDouble() * 0.38);
      final r = 1.4 + random.nextDouble() * 2.1;
      canvas.drawCircle(Offset(x, y), r, paint);
      canvas.drawCircle(Offset(x + r * 1.5, y), r * 0.72, paint);
    }
  }

  void _monsoon(Canvas canvas, Size size) {
    final wash = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x001B7A55), Color(0x181B7A55)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);

    final random = math.Random(34);
    final ring = Paint()
      ..color = const Color(0x267DC9D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.82 + random.nextDouble() * 0.15);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 8 + random.nextDouble() * 12,
          height: 3 + random.nextDouble() * 4,
        ),
        ring,
      );
    }
  }

  void _autumn(Canvas canvas, Size size) {
    final random = math.Random(55);
    final colors = [
      const Color(0x55D89A3D),
      const Color(0x55B86C3C),
      const Color(0x55E3B75B),
    ];
    for (var i = 0; i < 34; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.48 + random.nextDouble() * 0.43);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble());
      canvas.drawOval(const Rect.fromLTWH(-3, -1.5, 6, 3), paint);
      canvas.restore();
    }
  }

  void _winter(Canvas canvas, Size size) {
    final mist = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00FFFFFF), Color(0x22FFFFFF), Color(0x0AFFFFFF)],
        stops: [0, 0.58, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, mist);
  }

  @override
  bool shouldRepaint(covariant _SeasonPainter oldDelegate) =>
      oldDelegate.season != season;
}
