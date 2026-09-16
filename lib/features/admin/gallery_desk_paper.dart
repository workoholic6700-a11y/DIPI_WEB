import 'package:flutter/material.dart';

class GalleryDeskPaper extends StatelessWidget {
  const GalleryDeskPaper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF302936) : const Color(0xFFFFFAEF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: dark ? const Color(0xFF57465D) : const Color(0xFFD4BDA2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .13),
            blurRadius: 18,
            offset: const Offset(3, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 7,
            top: 0,
            bottom: 0,
            width: 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.brown.withValues(alpha: .04),
                    Colors.brown.withValues(alpha: .2),
                    Colors.brown.withValues(alpha: .04),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 16, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

class GalleryDeskPrint extends StatelessWidget {
  const GalleryDeskPrint({super.key, required this.child, this.draft = false});
  final Widget child;
  final bool draft;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF403646) : Colors.white,
        border: Border.all(
          color: draft
              ? const Color(0xFFB08B58)
              : (dark ? const Color(0xFF645269) : const Color(0xFFE4D8C9)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: draft ? .16 : .07),
            blurRadius: draft ? 10 : 3,
            offset: Offset(draft ? 3 : 0, draft ? 5 : 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
