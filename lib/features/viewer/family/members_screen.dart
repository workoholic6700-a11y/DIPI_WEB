import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/portrait_frame.dart';
import 'widgets/family_composite_frame.dart';

/// **Our People** — the family wall, not a contact list.
///
/// A grid of identical cards says "these are records". A wall says "this is a
/// family": the eldest hangs highest and largest, the parents below him, the
/// three sisters in a row under them, and the animals on their own low shelf.
/// [Generation] already encoded that order — it just wasn't being drawn.
///
/// The frames don't match and none of them hangs quite straight, because that
/// is true of every wall of family photographs there has ever been. Press one
/// and it straightens and lifts, the way you take a picture down to look at it
/// properly.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  /// Warm plaster.
  static const _wall = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4EDE3), Color(0xFFEFE6DA)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final byGen = ref.watch(familyByGenerationProvider);

    final elders = byGen[Generation.grandparents] ?? const [];
    final parents = byGen[Generation.parents] ?? const [];
    final children = byGen[Generation.children] ?? const [];
    final pets = byGen[Generation.pets] ?? const [];

    void open(FamilyMember m) => context.push(Routes.memberOf(m.id));

    return SectionScaffold(
      title: 'Our People',
      subtitle: 'Everyone who makes us, us',
      emoji: '🖼️',
      gradient: _wall,
      // A wall doesn't have sparkles drifting across it.
      particles: false,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.sm),
              const _PictureRail(),
              const SizedBox(height: AppDimens.xl),
              const FamilyCompositeFrame(),
              const SizedBox(height: AppDimens.xxl),

              // ── The eldest, highest and largest ──
              if (elders.isNotEmpty)
                Center(
                  child: PortraitFrame(
                    member: elders.first,
                    width: w * 0.44,
                    style: FrameStyle.gilt,
                    tilt: -0.012,
                    onTap: () => open(elders.first),
                  ),
                ).animate().fadeIn(duration: 340.ms).moveY(begin: -8, end: 0),

              if (parents.isNotEmpty) ...[
                const SizedBox(height: AppDimens.xxl),
                _Row(
                  members: parents,
                  width: w * 0.36,
                  // Both rectangular, at Diksha's request — different timbers
                  // so they still read as two separate frames on the wall.
                  styles: const [FrameStyle.wood, FrameStyle.plain],
                  onTap: open,
                  delayMs: 90,
                ),
              ],

              if (children.isNotEmpty) ...[
                const SizedBox(height: AppDimens.xxl),
                _Row(
                  members: children,
                  width: w * 0.27,
                  styles: const [
                    FrameStyle.plain,
                    FrameStyle.wood,
                    FrameStyle.plain,
                  ],
                  onTap: open,
                  delayMs: 180,
                ),
              ],

              if (pets.isNotEmpty) ...[
                const SizedBox(height: AppDimens.xxl),
                Text(
                  trS(lang, 'Our animals'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                _Row(
                  members: pets,
                  width: w * 0.24,
                  styles: const [
                    FrameStyle.oval,
                    FrameStyle.plain,
                    FrameStyle.oval,
                  ],
                  onTap: open,
                  delayMs: 260,
                  showRelation: false,
                ),
                const SizedBox(height: AppDimens.md),
                // The shelf they sit on.
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB08A63),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 9,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.xxl),
            ],
          );
        },
      ),
    );
  }
}

/// A row of frames, alternating their tilt so the wall never looks ruled.
class _Row extends StatelessWidget {
  const _Row({
    required this.members,
    required this.width,
    required this.styles,
    required this.onTap,
    required this.delayMs,
    this.showRelation = true,
  });

  final List<FamilyMember> members;
  final double width;
  final List<FrameStyle> styles;
  final void Function(FamilyMember) onTap;
  final int delayMs;
  final bool showRelation;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDimens.lg,
      runSpacing: AppDimens.lg,
      children: [
        for (var i = 0; i < members.length; i++)
          PortraitFrame(
            member: members[i],
            width: width,
            style: styles[i % styles.length],
            tilt: (i.isEven ? 1 : -1) * (0.011 + (i % 3) * 0.007),
            showRelation: showRelation,
            onTap: () => onTap(members[i]),
          )
              .animate()
              .fadeIn(delay: (delayMs + i * 70).ms, duration: 320.ms)
              .moveY(begin: 10, end: 0),
      ],
    );
  }
}

/// The rail the pictures hang from.
class _PictureRail extends StatelessWidget {
  const _PictureRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFFC9B79B),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
    );
  }
}
