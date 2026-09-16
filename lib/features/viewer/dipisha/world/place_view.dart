import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n.dart';
import 'world_map.dart';

/// A tappable place on the world plate: a label, and the region it names.
///
/// It deliberately draws **no scenery**. The artwork already contains the
/// treehouse, the cottage, the gazebo — painting a flat cartoon house on top of
/// a painted one would wreck the very thing we're standing on. So this is a
/// label in the mockup's style plus an invisible hit area, and nothing else.
///
/// The label is a real widget rather than baked into the art, which is what
/// makes it tappable, translatable to Nepali, and sharp at any zoom.
class PlaceView extends StatefulWidget {
  const PlaceView({
    super.key,
    required this.place,
    required this.lang,
    required this.dimmed,
    required this.onTap,
  });

  final Place place;
  final AppLang lang;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  State<PlaceView> createState() => _PlaceViewState();
}

class _PlaceViewState extends State<PlaceView> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final text = widget.lang == AppLang.ne ? p.ne : p.label;

    return AnimatedOpacity(
      opacity: widget.dimmed ? 0.25 : 1,
      duration: const Duration(milliseconds: 260),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onTap();
        },
        child: Semantics(
          button: true,
          label: '$text. ${trS(widget.lang, 'Double tap to explore')}',
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The hit region — as big as the thing it names, invisible.
              const SizedBox.expand(),

              // A soft halo so a child can tell this bit is alive. Barely
              // there; the art has to stay the hero.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: p.color.withValues(alpha: 0.16),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),

              // The label, in the mockup's style: dark translucent pill.
              Align(
                alignment: Alignment.topCenter,
                child: AnimatedScale(
                  scale: _down ? 0.94 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A2A22).withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xFFF6EDE4),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
