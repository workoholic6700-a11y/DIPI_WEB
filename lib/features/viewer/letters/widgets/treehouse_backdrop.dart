import 'package:flutter/material.dart';

/// The inside wall of Dipisha's World treehouse.
///
/// This is deliberately painted in code: it gives the letters a real place
/// without inventing a family photograph or adding another animated layer.
/// The grain is fixed, so this screen remains still after its entrance.
class TreehouseBackdrop extends StatelessWidget {
  const TreehouseBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF241A24), Color(0xFF38251F)]
              : const [Color(0xFFF4E4C9), Color(0xFFE8C899)],
        ),
      ),
      child: CustomPaint(
        painter: _TreehouseWallPainter(dark: dark),
        child: child,
      ),
    );
  }
}

class _TreehouseWallPainter extends CustomPainter {
  const _TreehouseWallPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final seam = Paint()
      ..color = (dark ? const Color(0xFF0E0908) : const Color(0xFF8B5A37))
          .withValues(alpha: dark ? 0.32 : 0.19)
      ..strokeWidth = 1.25;
    final lightEdge = Paint()
      ..color = Colors.white.withValues(alpha: dark ? 0.025 : 0.14)
      ..strokeWidth = 1;
    final grain = Paint()
      ..color = (dark ? const Color(0xFFB78255) : const Color(0xFF9B673E))
          .withValues(alpha: dark ? 0.08 : 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const plankWidth = 58.0;
    for (double x = plankWidth; x < size.width; x += plankWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), seam);
      canvas.drawLine(
        Offset(x + 1.5, 0),
        Offset(x + 1.5, size.height),
        lightEdge,
      );
    }

    // A few deterministic grain marks keep the wall tactile without looking
    // busy behind the envelopes.
    for (double y = 96; y < size.height; y += 148) {
      for (double x = 14; x < size.width; x += plankWidth) {
        final path = Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 16, y - 7, x + 34, y + 1)
          ..quadraticBezierTo(x + 43, y + 5, x + 50, y + 2);
        canvas.drawPath(path, grain);
      }
    }

    // The broad beam makes the wall read as a little room, not wallpaper.
    final beam = Paint()
      ..color = (dark ? const Color(0xFF1A100D) : const Color(0xFF744628))
          .withValues(alpha: dark ? 0.42 : 0.18);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 12), beam);
  }

  @override
  bool shouldRepaint(covariant _TreehouseWallPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
