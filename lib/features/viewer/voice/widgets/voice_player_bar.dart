import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// A beautiful (simulated) voice player with an animated waveform.
///
/// Phase 1 has no real audio — this fakes smooth playback so the UI feels
/// alive. In Phase 2 the play/seek hooks map onto `just_audio`.
class VoicePlayerBar extends StatefulWidget {
  const VoicePlayerBar({
    super.key,
    required this.title,
    required this.durationSeconds,
    this.gradient,
    this.compact = false,
  });

  final String title;
  final int durationSeconds;
  final List<Color>? gradient;
  final bool compact;

  @override
  State<VoicePlayerBar> createState() => _VoicePlayerBarState();
}

class _VoicePlayerBarState extends State<VoicePlayerBar> {
  Timer? _timer;
  double _progress = 0; // 0..1
  bool _playing = false;

  // Stable pseudo-random bar heights for the waveform.
  late final List<double> _bars = List.generate(
    40,
    (i) => 0.25 + 0.75 * (0.5 + 0.5 * math.sin(i * 0.9)) * ((i % 5) + 1) / 5,
  );

  void _toggle() {
    setState(() => _playing = !_playing);
    _timer?.cancel();
    if (_playing) {
      const tick = Duration(milliseconds: 100);
      final step = 0.1 / widget.durationSeconds;
      _timer = Timer.periodic(tick, (_) {
        setState(() {
          _progress += step;
          if (_progress >= 1) {
            _progress = 0;
            _playing = false;
            _timer?.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _time(double p) {
    final total = widget.durationSeconds;
    final s = (total * p).round();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final grad = widget.gradient ??
        const [Color(0xFFB79BE0), Color(0xFF9B72CF)];
    return Container(
      padding: EdgeInsets.all(widget.compact ? AppDimens.sm : AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.lavenderSoft.withValues(alpha: 0.5),
        borderRadius: AppDimens.brMd,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: widget.compact ? 40 : 48,
              height: widget.compact ? 40 : 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: grad),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: grad.last.withValues(alpha: 0.4),
                      blurRadius: 12),
                ],
              ),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: widget.compact ? 22 : 26,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.compact)
                  Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                if (!widget.compact) const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _bars.length; i++)
                        Expanded(
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1),
                            height: 30 * _bars[i],
                            decoration: BoxDecoration(
                              color: (i / _bars.length) <= _progress
                                  ? AppColors.lavender
                                  : AppColors.lavender
                                      .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          Text(_time(_progress),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
