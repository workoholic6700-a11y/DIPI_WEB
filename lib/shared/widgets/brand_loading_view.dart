import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// A dreamy branded view with floating hearts & sparkles.
///
/// Used as the splash background and as a full-screen loading state. Kept
/// stateless & self-contained so any screen can drop it in.
class BrandLoadingView extends StatelessWidget {
  const BrandLoadingView({
    super.key,
    this.gradient = AppColors.dreamGradient,
    this.subtitle,
    this.showTitle = true,
  });

  final Gradient gradient;
  final String? subtitle;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          const _FloatingDecor(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeartMark()
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                        begin: 0.94,
                        end: 1.06,
                        duration: 1400.ms,
                        curve: Curves.easeInOut),
                if (showTitle) ...[
                  const SizedBox(height: 28),
                  Text('Dear', style: AppTypography.brandScript(fontSize: 34))
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .moveY(begin: 12, end: 0),
                  Text(AppConstants.viewerName,
                          style: AppTypography.brandScript(fontSize: 46))
                      .animate()
                      .fadeIn(delay: 380.ms, duration: 600.ms)
                      .moveY(begin: 12, end: 0),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15, height: 1.4),
                  ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
                ],
                const SizedBox(height: 28),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white70),
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.heartGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 52),
    );
  }
}

/// Softly drifting hearts & sparkles scattered behind the mark.
class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor();

  @override
  Widget build(BuildContext context) {
    const items = <_Decor>[
      _Decor(Icons.favorite, 0.12, 0.18, 18, 0),
      _Decor(Icons.auto_awesome, 0.82, 0.15, 16, 300),
      _Decor(Icons.favorite, 0.75, 0.72, 14, 600),
      _Decor(Icons.auto_awesome, 0.18, 0.68, 20, 900),
      _Decor(Icons.favorite, 0.5, 0.08, 12, 1200),
      _Decor(Icons.auto_awesome, 0.9, 0.5, 12, 1500),
      _Decor(Icons.favorite, 0.08, 0.42, 14, 1800),
    ];
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          for (final d in items)
            Positioned(
              left: d.x * c.maxWidth,
              top: d.y * c.maxHeight,
              child: Icon(d.icon, size: d.size, color: Colors.white24)
                  .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                  .moveY(
                      begin: 0,
                      end: -16,
                      duration: (1800 + d.delay).ms,
                      curve: Curves.easeInOut)
                  .fadeIn(delay: d.delay.ms),
            ),
        ],
      ),
    );
  }
}

class _Decor {
  const _Decor(this.icon, this.x, this.y, this.size, this.delay);
  final IconData icon;
  final double x;
  final double y;
  final double size;
  final int delay;
}
