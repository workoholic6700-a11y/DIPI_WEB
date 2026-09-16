import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/cover.dart';
import '../../../../data/models/people.dart';
import '../../../../shared/widgets/common.dart';

/// How a frame is made. Real walls don't have matching frames — they have
/// whatever was to hand the year the photograph was taken.
enum FrameStyle { gilt, wood, oval, plain }

/// One framed photograph on the family wall.
///
/// Pressing it straightens the frame and lifts it off the wall — the way you'd
/// take one down to look properly — and the navigation starts on the same tap,
/// so the motion never costs you a moment.
class PortraitFrame extends StatefulWidget {
  const PortraitFrame({
    super.key,
    required this.member,
    required this.width,
    required this.onTap,
    this.style = FrameStyle.wood,
    this.tilt = 0,
    this.showRelation = true,
  });

  final FamilyMember member;
  final double width;
  final VoidCallback onTap;
  final FrameStyle style;

  /// Radians. Nothing on a real wall hangs perfectly straight.
  final double tilt;

  final bool showRelation;

  @override
  State<PortraitFrame> createState() => _PortraitFrameState();
}

class _PortraitFrameState extends State<PortraitFrame> {
  bool _held = false;

  Color get _timber => switch (widget.style) {
        FrameStyle.gilt => const Color(0xFFC9A55F),
        FrameStyle.wood => const Color(0xFF9C7B4E),
        FrameStyle.oval => const Color(0xFFB08A63),
        FrameStyle.plain => const Color(0xFFCBB68A),
      };

  double get _radius => switch (widget.style) {
        FrameStyle.oval => widget.width,
        FrameStyle.gilt => 3,
        _ => 2,
      };

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final first = m.shortName;
    final photoH = widget.width * (widget.style == FrameStyle.oval ? 1.0 : 1.18);

    return Semantics(
      button: true,
      label: '$first, ${m.relation}. A framed photograph. Opens their page.',
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _held = true),
        onTapUp: (_) => setState(() => _held = false),
        onTapCancel: () => setState(() => _held = false),
        child: AnimatedRotation(
          // Straightens when you take hold of it.
          turns: _held ? 0 : widget.tilt / (2 * 3.1415926),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: _held ? 1.04 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.width,
                  padding: EdgeInsets.all(
                      widget.style == FrameStyle.gilt ? 7 : 5.5),
                  decoration: BoxDecoration(
                    color: _timber,
                    borderRadius: BorderRadius.circular(_radius),
                    // Gilt frames catch the light along their top edge.
                    gradient: widget.style == FrameStyle.gilt
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFE0C489),
                              _timber,
                              const Color(0xFFA8863F),
                            ],
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: _held ? 0.30 : 0.18),
                        blurRadius: _held ? 20 : 11,
                        offset: Offset(0, _held ? 10 : 5),
                      ),
                    ],
                  ),
                  child: Container(
                    // The mount board inside the frame.
                    padding: EdgeInsets.all(
                        widget.style == FrameStyle.oval ? 0 : 4),
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite,
                      borderRadius:
                          BorderRadius.circular(_radius > 3 ? _radius : 1),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(_radius > 3 ? _radius : 1),
                      child: Hero(
                        tag: 'member-${m.id}',
                        child: SizedBox(
                          height: photoH,
                          width: double.infinity,
                          // Their own colour sits behind the picture. When we
                          // have the photograph it covers this completely;
                          // when we don't, the emoji sits on a tinted mount
                          // instead of a stark blank sheet.
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: CoverPalette.gradient(m.colorSeed),
                            ),
                            child: MemberFace(
                              photo: m.photo,
                              emoji: m.emoji,
                              emojiSize: widget.width * 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // The little engraved plate under the frame.
                Text(
                  first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // The plate sits on the wall itself, not on a card, so it
                  // has to take the theme's ink. Hardcoding the light one left
                  // every name nearly invisible with the lamp off.
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
                if (widget.showRelation)
                  Text(
                    m.relation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                if (m.inMemoriam)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text('🌈', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
