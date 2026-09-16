import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'day_night.dart';
import 'village_season.dart';

/// A deliberately lightweight weather layer. Rain is one static paint pass;
/// only a tapped puddle briefly animates, so the whole landscape never becomes
/// a permanent particle simulation.
class VillageWeatherLayer extends StatefulWidget {
  const VillageWeatherLayer({
    super.key,
    required this.width,
    required this.height,
    required this.season,
    required this.phase,
    required this.motion,
  });

  final double width;
  final double height;
  final VillageSeason season;
  final VillagePhase phase;
  final Animation<double> motion;

  @override
  State<VillageWeatherLayer> createState() => _VillageWeatherLayerState();
}

class _VillageWeatherLayerState extends State<VillageWeatherLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.season != VillageSeason.monsoon) {
      return const SizedBox.expand();
    }
    final night = widget.phase == VillagePhase.night;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: widget.motion,
                builder: (context, _) => CustomPaint(
                  painter: _SoftRainPainter(
                    night: night,
                    progress: widget.motion.value,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Umbrellas read as a changed family routine without moving figures.
        if (!night) ...[
          _emoji(0.108, 0.706, '☂️', 29),
          _emoji(0.432, 0.754, '🌂', 25),
        ],
        // Roof-edge drips.
        _emoji(0.294, 0.706, '💧', 12),
        _emoji(0.337, 0.707, '💧', 10),
        Positioned(
          left: widget.width * 0.535 - 52,
          top: widget.height * 0.885 - 28,
          width: 104,
          height: 56,
          child: Semantics(
            button: true,
            label: 'Rain puddle. Tap to make a ripple.',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                _ripple.forward(from: 0);
              },
              child: AnimatedBuilder(
                animation: _ripple,
                builder: (context, _) =>
                    CustomPaint(painter: _PuddleRipplePainter(_ripple.value)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emoji(double fx, double fy, String emoji, double size) => Positioned(
    left: widget.width * fx - size / 2,
    top: widget.height * fy - size,
    child: IgnorePointer(
      child: Text(emoji, style: TextStyle(fontSize: size)),
    ),
  );
}

class _SoftRainPainter extends CustomPainter {
  const _SoftRainPainter({required this.night, required this.progress});

  final bool night;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final wash = Paint()
      ..color = night ? const Color(0x123D5C82) : const Color(0x0D6B92A4);
    canvas.drawRect(Offset.zero & size, wash);

    final rain = Paint()
      ..color = night ? const Color(0x3DC5DCF2) : const Color(0x35EAF7FF)
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    final travel = progress * size.height;
    for (var i = 0; i < 120; i++) {
      final y = (i * 47.0 + math.sin(i * 1.7) * 31 + travel) % size.height;
      final x = (i * 83.0 + (i % 7) * 19) % size.width;
      canvas.drawLine(Offset(x, y), Offset(x - 8, y + 23), rain);
    }
  }

  @override
  bool shouldRepaint(covariant _SoftRainPainter oldDelegate) =>
      oldDelegate.night != night || oldDelegate.progress != progress;
}

class _PuddleRipplePainter extends CustomPainter {
  const _PuddleRipplePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0x357FB7C8);
    canvas.drawOval(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * 0.72,
        height: size.height * 0.38,
      ),
      base,
    );
    if (progress <= 0) return;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Color.fromRGBO(225, 248, 255, 1 - progress);
    for (var i = 0; i < 2; i++) {
      final p = (progress - i * 0.18).clamp(0.0, 1.0);
      if (p == 0) continue;
      canvas.drawOval(
        Rect.fromCenter(
          center: size.center(Offset.zero),
          width: 18 + size.width * 0.62 * p,
          height: 7 + size.height * 0.30 * p,
        ),
        ring,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PuddleRipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
