import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n.dart';
import '../../../../core/theme/app_dimens.dart';

/// **The Two Skies** — Ilam's sky, and Papa's.
///
/// Papa works in Malaysia so his daughters could study. Malaysia is UTC+8;
/// Nepal is UTC+5:45. He is **2 hours 15 minutes ahead**, always, and about
/// 3,000 km east. This widget doesn't explain any of that. It just shows both
/// skies at once, on real local time, so the distance is simply visible.
///
/// Deliberately has no tap target and no copy about "missing" him. It is a
/// window, not a message.
class TwoSkies extends ConsumerStatefulWidget {
  const TwoSkies({super.key});

  @override
  ConsumerState<TwoSkies> createState() => _TwoSkiesState();
}

class _TwoSkiesState extends ConsumerState<TwoSkies> {
  /// Malaysia (UTC+8) minus Nepal (UTC+5:45).
  static const _papaOffset = Duration(hours: 2, minutes: 15);

  late DateTime _now;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // A minute is plenty — the sky moves slowly, and so does a shift.
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  /// 0.0 at midnight → 1.0 at the next midnight.
  static double _dayFraction(DateTime t) =>
      (t.hour * 60 + t.minute) / (24 * 60);

  /// The sky over a hill, at this hour. Night indigo → dawn → day → dusk ember.
  static List<Color> _sky(double f) {
    const night = [Color(0xFF141A2E), Color(0xFF1E2743)];
    const dawn = [Color(0xFF5B4A72), Color(0xFFE8A17A)];
    const day = [Color(0xFF8FC2E8), Color(0xFFDCEBF5)];
    const dusk = [Color(0xFF3E3A63), Color(0xFFE0793F)];

    // Rough Ilam hours: 5 dawn, 8 day, 17 dusk, 20 night.
    if (f < 5 / 24) return night;
    if (f < 8 / 24) return _mix(night, dawn, (f - 5 / 24) / (3 / 24));
    if (f < 17 / 24) return _mix(dawn, day, ((f - 8 / 24) / (9 / 24)).clamp(0, 1));
    if (f < 20 / 24) return _mix(day, dusk, (f - 17 / 24) / (3 / 24));
    return _mix(dusk, night, (f - 20 / 24) / (4 / 24));
  }

  static List<Color> _mix(List<Color> a, List<Color> b, double t) => [
        Color.lerp(a[0], b[0], t)!,
        Color.lerp(a[1], b[1], t)!,
      ];

  /// Is he awake? Not a guess about his shift — just: is it night where he is.
  static bool _awake(DateTime t) => t.hour >= 6 && t.hour < 23;

  String _clock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final papaNow = _now.add(_papaOffset);
    final hereSky = _sky(_dayFraction(_now));
    final papaSky = _sky(_dayFraction(papaNow));
    final papaAwake = _awake(papaNow);

    return Semantics(
      label: 'Two skies. Ilam ${_clock(_now)}. Papa in Malaysia '
          '${_clock(papaNow)}.',
      child: ClipRRect(
        borderRadius: AppDimens.brLg,
        child: SizedBox(
          height: 104,
          child: Column(
            children: [
              // ── Papa's sky: a narrow band along the top, 3,000 km east ──
              Expanded(
                flex: 34,
                child: _Band(
                  colors: papaSky,
                  label: trS(lang, 'Papa · Malaysia'),
                  time: _clock(papaNow),
                  // The one lit window: he's awake, over there, right now.
                  window: papaAwake,
                  compact: true,
                ),
              ),
              // The seam. The two skies never quite meet.
              Container(height: 1, color: Colors.white.withValues(alpha: 0.28)),
              // ── Our sky, over the house ──
              Expanded(
                flex: 66,
                child: _Band(
                  colors: hereSky,
                  label: trS(lang, 'Ilam · our sky'),
                  time: _clock(_now),
                  window: false,
                  compact: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Band extends StatelessWidget {
  const _Band({
    required this.colors,
    required this.label,
    required this.time,
    required this.window,
    required this.compact,
  });

  final List<Color> colors;
  final String label;
  final String time;
  final bool window;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Pick text colour off the sky's own brightness, so it stays readable at
    // every hour without a scrim over the gradient.
    final lum = colors[1].computeLuminance();
    final ink = lum > 0.5 ? Colors.black.withValues(alpha: 0.62) : Colors.white;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          if (window)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 9,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2C879),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF2C879).withValues(alpha: 0.7),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimens.md, vertical: compact ? 3 : 8),
            child: Align(
              alignment:
                  compact ? Alignment.centerLeft : Alignment.bottomLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: ink,
                          fontSize: compact ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2)),
                  const SizedBox(width: 8),
                  Text(time,
                      style: TextStyle(
                          color: ink.withValues(alpha: 0.75),
                          fontSize: compact ? 10 : 12,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
