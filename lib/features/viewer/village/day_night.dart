import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  Day & night over Ilam.
///
///  The village art is painted once, in daylight, by a dozen CustomPainters.
///  Rather than re-colour every one of them, this file lays a single tinted
///  sky-light *over* the whole world: a warm dawn, plain day, an orange dusk,
///  and a deep blue night with stars and lamp-lit windows.
///
///  Additive by design — delete this file and remove [DayNightLayer] +
///  [DayNightButton] from village_screen.dart and the village is untouched.
/// ─────────────────────────────────────────────────────────────────────────

enum VillagePhase { dawn, day, dusk, night }

/// What the sky is doing at a given hour in the village.
VillagePhase phaseForHour(int hour) {
  if (hour >= 5 && hour < 8) return VillagePhase.dawn;
  if (hour >= 8 && hour < 17) return VillagePhase.day;
  if (hour >= 17 && hour < 20) return VillagePhase.dusk;
  return VillagePhase.night;
}

/// The chosen time of day. `null` means **auto** — the village simply follows
/// the real clock, so if it is night where Dipisha is, it is night here too.
class VillageTimeNotifier extends Notifier<VillagePhase?> {
  @override
  VillagePhase? build() => null;

  /// auto → dawn → day → dusk → night → auto
  void cycle() {
    state = switch (state) {
      null => VillagePhase.dawn,
      VillagePhase.dawn => VillagePhase.day,
      VillagePhase.day => VillagePhase.dusk,
      VillagePhase.dusk => VillagePhase.night,
      VillagePhase.night => null,
    };
  }

  void select(VillagePhase? phase) => state = phase;
}

final villageTimeProvider =
    NotifierProvider<VillageTimeNotifier, VillagePhase?>(
      VillageTimeNotifier.new,
    );

/// The phase actually being shown: the manual choice, or the real clock.
final villagePhaseProvider = Provider<VillagePhase>((ref) {
  return ref.watch(villageTimeProvider) ?? phaseForHour(DateTime.now().hour);
});

// ─────────────────────────────────────────────────────────────────────────
//  Palette
// ─────────────────────────────────────────────────────────────────────────

class _SkyLight {
  const _SkyLight({
    required this.top,
    required this.horizon,
    required this.ground,
    required this.starOpacity,
    required this.lampOpacity,
    required this.bodyColor,
    required this.bodyGlow,
    required this.bodyPos,
    required this.isMoon,
  });

  /// Tint laid over the sky band, the horizon, and the ground.
  final Color top;
  final Color horizon;
  final Color ground;
  final double starOpacity;
  final double lampOpacity;

  /// The moon. The *sun* is already painted into the sky art at a fixed spot
  /// (SkyMountainsPainter, 0.735w × 0.185h) — the dawn/dusk tint washes over
  /// it and turns it low and orange all by itself, so adding one here would
  /// only put a second sun in the sky.
  final Color bodyColor;
  final Color bodyGlow;

  /// Where the moon sits. Kept well away from the painted sun.
  final Alignment bodyPos;
  final bool isMoon;
}

_SkyLight _lightFor(VillagePhase p) => switch (p) {
  // Early morning: soft peach, the hour Mummy lights the chulo.
  VillagePhase.dawn => const _SkyLight(
    top: Color(0x2E5B7BC4),
    horizon: Color(0x59FFB782),
    ground: Color(0x3DFFA463),
    starOpacity: 0.18,
    lampOpacity: 0.55,
    bodyColor: Color(0xFFFFF1CE),
    bodyGlow: Color(0xFFFFC078),
    bodyPos: Alignment(-0.72, 0.30),
    isMoon: false,
  ),
  // Daylight — the art as painted. No tint at all.
  VillagePhase.day => const _SkyLight(
    top: Color(0x00000000),
    horizon: Color(0x00000000),
    ground: Color(0x00000000),
    starOpacity: 0,
    lampOpacity: 0,
    bodyColor: Color(0xFFFFF8DC),
    bodyGlow: Color(0xFFFFE9A8),
    bodyPos: Alignment(0.10, -0.62),
    isMoon: false,
  ),
  // Evening: the sun going down behind the tea hills.
  VillagePhase.dusk => const _SkyLight(
    top: Color(0x6B3B3F8C),
    horizon: Color(0x82FF8A4A),
    ground: Color(0x5E7A3F6B),
    starOpacity: 0.42,
    lampOpacity: 0.85,
    bodyColor: Color(0xFFFFD9A0),
    bodyGlow: Color(0xFFFF7A3C),
    bodyPos: Alignment(0.74, 0.34),
    isMoon: false,
  ),
  // Night: deep hill-country blue, stars out, windows warm. The sky tint
  // runs nearly opaque up top so the painted sun is properly put out.
  VillagePhase.night => const _SkyLight(
    top: Color(0xF00A1636),
    horizon: Color(0xC4132A55),
    ground: Color(0x9E0B1B3D),
    starOpacity: 1,
    lampOpacity: 1,
    bodyColor: Color(0xFFF3F6FF),
    bodyGlow: Color(0xFFBFD4FF),
    bodyPos: Alignment(-0.46, -0.72),
    isMoon: true,
  ),
};

// ─────────────────────────────────────────────────────────────────────────
//  The layer itself
// ─────────────────────────────────────────────────────────────────────────

/// Lays the sky-light over the whole world. Sits above the scenery and below
/// the tappable landmarks, so labels stay readable at night.
class DayNightLayer extends ConsumerWidget {
  const DayNightLayer({
    super.key,
    required this.width,
    required this.height,
    this.lamps = const [],
  });

  final double width;
  final double height;

  /// Warm window/hearth lights, as fractions of the world, that come on in
  /// the evening: (fx, fy, radius).
  final List<({double fx, double fy, double r})> lamps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = _lightFor(ref.watch(villagePhaseProvider));
    const d = Duration(milliseconds: 1100);
    const curve = Curves.easeInOut;

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The tint goes down FIRST — the sky is coloured strongest, the
            // ground least, so the valley floor keeps a little of its green
            // even at night. Everything below is lit *through* it.
            Positioned.fill(
              child: AnimatedContainer(
                duration: d,
                curve: curve,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      light.top,
                      light.horizon,
                      light.ground,
                      light.ground,
                    ],
                    stops: const [0.0, 0.42, 0.62, 1.0],
                  ),
                ),
              ),
            ),
            // Stars, only in the sky band — above the tint, or they'd be
            // painted out by it.
            Positioned(
              left: 0,
              top: 0,
              width: width,
              height: height * 0.46,
              child: AnimatedOpacity(
                opacity: light.starOpacity,
                duration: d,
                curve: curve,
                child: RepaintBoundary(
                  child: CustomPaint(painter: _StarsPainter()),
                ),
              ),
            ),
            // The moon, only after dark.
            AnimatedAlign(
              alignment: light.bodyPos,
              duration: d,
              curve: curve,
              child: AnimatedOpacity(
                opacity: light.isMoon ? 1 : 0,
                duration: d,
                curve: curve,
                child: _CelestialBody(
                  color: light.bodyColor,
                  glow: light.bodyGlow,
                  duration: d,
                ),
              ),
            ),
            // Lamp light spilling out of the windows, over the tint.
            for (final l in lamps)
              Positioned(
                left: width * l.fx - l.r,
                top: height * l.fy - l.r,
                width: l.r * 2,
                height: l.r * 2,
                child: AnimatedOpacity(
                  opacity: light.lampOpacity,
                  duration: d,
                  curve: curve,
                  child: const _LampGlow(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The moon over the hills, with a soft shaded side so it doesn't read as a
/// second sun.
class _CelestialBody extends StatelessWidget {
  const _CelestialBody({
    required this.color,
    required this.glow,
    required this.duration,
  });

  final Color color;
  final Color glow;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.55),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Align(
        alignment: const Alignment(0.45, -0.25),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFDCE6FA).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _LampGlow extends StatelessWidget {
  const _LampGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFCF7A).withValues(alpha: 0.85),
            const Color(0xFFFFB347).withValues(alpha: 0.34),
            const Color(0x00FFB347),
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
      ),
    );
  }
}

/// A fixed field of stars — seeded, so they never jitter between rebuilds.
class _StarsPainter extends CustomPainter {
  static final List<({double x, double y, double r, double a})> _stars = () {
    final rnd = math.Random(7);
    return List.generate(150, (_) {
      final y = math.pow(rnd.nextDouble(), 1.6).toDouble();
      return (
        x: rnd.nextDouble(),
        y: y,
        r: 0.7 + rnd.nextDouble() * 1.5,
        // Stars thin out towards the hills.
        a: (0.35 + rnd.nextDouble() * 0.65) * (1 - y * 0.55),
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    for (final s in _stars) {
      p.color = Colors.white.withValues(alpha: s.a);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────
//  The button in the top bar
// ─────────────────────────────────────────────────────────────────────────

/// Tap to walk the village through dawn → day → dusk → night → back to the
/// real clock.
class DayNightButton extends ConsumerWidget {
  const DayNightButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final manual = ref.watch(villageTimeProvider);
    final phase = ref.watch(villagePhaseProvider);

    final (icon, en, ne) = switch (phase) {
      VillagePhase.dawn => ('🌄', 'Dawn', 'बिहान'),
      VillagePhase.day => ('☀️', 'Day', 'दिन'),
      VillagePhase.dusk => ('🌇', 'Dusk', 'साँझ'),
      VillagePhase.night => ('🌙', 'Night', 'रात'),
    };
    final label = lang == AppLang.ne ? ne : en;
    final auto = manual == null;

    final visibleLabel = auto
        ? '$label · ${lang == AppLang.ne ? 'अहिले' : 'now'}'
        : label;

    return Semantics(
      button: true,
      label: auto
          ? 'Village time is $label and follows the real clock. Tap to preview another time.'
          : 'Village time preview: $label. Tap to change it.',
      child: GestureDetector(
        onTap: () => ref.read(villageTimeProvider.notifier).cycle(),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(21),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                visibleLabel,
                style: const TextStyle(
                  color: Color(0xFF3A2E4D),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
