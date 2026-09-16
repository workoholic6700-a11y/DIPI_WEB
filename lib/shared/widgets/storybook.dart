import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// Reusable visual language for the "handmade Nepali family storybook".
///
/// The pattern is deliberately quiet: it adds a sense of place without
/// competing with the family's photographs and writing.
class StorybookPanel extends StatelessWidget {
  const StorybookPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.lg),
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panel = Container(
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.darkCard : const Color(0xFFFFFCF7)),
        borderRadius: AppDimens.brLg,
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE9DACD)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3FA0).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _StorybookTexturePainter(isDark: isDark),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null) return panel;
    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, borderRadius: AppDimens.brLg, child: panel),
    );
  }
}

/// A small woven divider inspired by Dhaka diamonds.
class StorybookDivider extends StatelessWidget {
  const StorybookDivider({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: CustomPaint(
        size: const Size(double.infinity, 12),
        painter: _WovenLinePainter(),
      ),
    );
    return Row(
      children: [
        line,
        if (label != null) ...[
          const SizedBox(width: AppDimens.sm),
          Expanded(
            flex: 6,
            child: Text(
              label!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.purpleMid,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          line,
        ],
      ],
    );
  }
}

class _StorybookTexturePainter extends CustomPainter {
  const _StorybookTexturePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final fiber = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF8A6B52)).withValues(
        alpha: isDark ? 0.018 : 0.025,
      )
      ..strokeWidth = 0.7;
    for (double y = 9; y < size.height; y += 13) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 2), fiber);
    }

    final motif = Paint()
      ..color = AppColors.pinkDeep.withValues(alpha: isDark ? 0.12 : 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double x = 14; x < size.width; x += 28) {
      final path = Path()
        ..moveTo(x, 8)
        ..lineTo(x + 5, 3)
        ..lineTo(x + 10, 8)
        ..lineTo(x + 5, 13)
        ..close();
      canvas.drawPath(path, motif);
    }
  }

  @override
  bool shouldRepaint(covariant _StorybookTexturePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _WovenLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lavender.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double x = 0; x < size.width; x += 13) {
      final path = Path()
        ..moveTo(x, size.height / 2)
        ..lineTo(x + 4, 2)
        ..lineTo(x + 8, size.height / 2)
        ..lineTo(x + 4, size.height - 2)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
