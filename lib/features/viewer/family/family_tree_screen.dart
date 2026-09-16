import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/cover.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';

/// **Our Family Tree** — a tree that shows you where you come from.
///
/// It was four rows of circles joined by three dots. A tree should do one
/// thing a chart can't: when you touch a person, the line they came down
/// should light up all the way to the root, and everything else should step
/// back so you can see it.
///
/// The branches grow once when the screen opens and then hold still. Nothing
/// loops.
class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  /// Who is being traced. Null = the whole tree, evenly lit.
  String? _traced;

  static const _order = [
    (Generation.grandparents, 'Our Roots'),
    (Generation.parents, 'Mum & Dad'),
    (Generation.children, 'The Three Stars'),
    (Generation.pets, 'Our Furry Family'),
  ];

  static const _grove = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFF3E6), Color(0xFFF8F3E9)],
  );

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final byGen = ref.watch(familyByGenerationProvider);

    // Which generation the traced person sits in. Everything above it is the
    // line they came down.
    int? tracedDepth;
    if (_traced != null) {
      for (var i = 0; i < _order.length; i++) {
        if ((byGen[_order[i].$1] ?? const [])
            .any((m) => m.id == _traced)) {
          tracedDepth = i;
        }
      }
    }

    return SectionScaffold(
      title: 'Our Family Tree',
      subtitle: 'Touch anyone to trace their line',
      emoji: '🌳',
      gradient: _grove,
      particles: false,
      child: Column(
        children: [
          for (var i = 0; i < _order.length; i++) ...[
            if (i > 0)
              _Branch(
                // On the line of descent above the traced person.
                lit: tracedDepth == null || i <= tracedDepth,
                depth: i,
              ),
            _Generation(
              label: trS(lang, _order[i].$2),
              members: byGen[_order[i].$1] ?? const [],
              depth: i,
              traced: _traced,
              // Generations at or above the traced person stay bright.
              dimmed: tracedDepth != null && i > tracedDepth,
              onTrace: (id) => setState(
                  () => _traced = _traced == id ? null : id),
              onOpen: (id) => context.push(Routes.memberOf(id)),
            ),
          ],
          const SizedBox(height: AppDimens.xl),
          Text(
            trS(lang,
                _traced == null
                    ? 'Touch a face to follow their branch.'
                    : 'Touch again to open their page.'),
            textAlign: TextAlign.center,
            style: handwriting(fontSize: 17, color: pageInk(context)),
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }
}

class _Generation extends StatelessWidget {
  const _Generation({
    required this.label,
    required this.members,
    required this.depth,
    required this.traced,
    required this.dimmed,
    required this.onTrace,
    required this.onOpen,
  });

  final String label;
  final List<FamilyMember> members;
  final int depth;
  final String? traced;
  final bool dimmed;
  final void Function(String) onTrace;
  final void Function(String) onOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.34 : 1,
      duration: const Duration(milliseconds: 260),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.lavenderSoft,
              borderRadius: AppDimens.brPill,
            ),
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.purpleMid,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimens.md,
            runSpacing: AppDimens.md,
            children: [
              for (var i = 0; i < members.length; i++)
                _MemberNode(
                  member: members[i],
                  isTraced: traced == members[i].id,
                  // Somebody else is being traced in this same row.
                  faded: traced != null &&
                      traced != members[i].id &&
                      members.any((m) => m.id == traced),
                  onTap: () => traced == members[i].id
                      ? onOpen(members[i].id)
                      : onTrace(members[i].id),
                )
                    .animate()
                    .fadeIn(
                        delay: (depth * 140 + i * 80).ms, duration: 340.ms)
                    .scale(
                        begin: const Offset(0.86, 0.86),
                        end: const Offset(1, 1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberNode extends StatelessWidget {
  const _MemberNode({
    required this.member,
    required this.isTraced,
    required this.faded,
    required this.onTap,
  });

  final FamilyMember member;
  final bool isTraced;
  final bool faded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = CoverPalette.base(member.colorSeed);
    final first = member.shortName;

    return Semantics(
      button: true,
      selected: isTraced,
      label: isTraced
          ? '$first, ${member.relation}. Traced. Touch again to open.'
          : '$first, ${member.relation}. Touch to trace their line.',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: faded ? 0.42 : 1,
          duration: const Duration(milliseconds: 240),
          child: SizedBox(
            width: 96,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedScale(
                      scale: isTraced ? 1.12 : 1,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                      child: Hero(
                        tag: 'member-${member.id}',
                        child: Container(
                          width: 72,
                          height: 72,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            gradient:
                                CoverPalette.gradient(member.colorSeed),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isTraced ? AppColors.gold : Colors.white,
                              width: isTraced ? 3.5 : 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: base.withValues(
                                    alpha: isTraced ? 0.60 : 0.34),
                                blurRadius: isTraced ? 20 : 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: MemberFace(
                            photo: member.photo,
                            emoji: member.emoji,
                            emojiSize: 34,
                          ),
                        ),
                      ),
                    ),
                    if (member.inMemoriam)
                      const Positioned(
                        top: -4,
                        right: -4,
                        child: Text('🌈', style: TextStyle(fontSize: 15)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  member.relation.split(' · ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A real branch between two generations. Grows once, then holds.
class _Branch extends StatelessWidget {
  const _Branch({required this.lit, required this.depth});

  final bool lit;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + depth * 120),
      curve: Curves.easeOutCubic,
      builder: (context, grow, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: 46,
        width: double.infinity,
        child: CustomPaint(
          painter: _BranchPainter(grow: grow, lit: lit),
        ),
      ),
    );
  }
}

class _BranchPainter extends CustomPainter {
  _BranchPainter({required this.grow, required this.lit});

  final double grow;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()
      ..color = lit
          ? const Color(0xFF7E9B62)
          : const Color(0xFF7E9B62).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lit ? 3 : 2
      ..strokeCap = StrokeCap.round;

    // A short trunk, forking into two limbs.
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w / 2, h * 0.42 * grow);
    canvas.drawPath(path, paint);

    if (grow > 0.42) {
      final t = ((grow - 0.42) / 0.58).clamp(0.0, 1.0);
      final limbs = Path()
        ..moveTo(w / 2, h * 0.42)
        ..quadraticBezierTo(
            w / 2 - w * 0.10 * t, h * 0.70, w / 2 - w * 0.16 * t, h)
        ..moveTo(w / 2, h * 0.42)
        ..quadraticBezierTo(
            w / 2 + w * 0.10 * t, h * 0.70, w / 2 + w * 0.16 * t, h);
      canvas.drawPath(limbs, paint);

      // A leaf on the fork, once it's grown.
      if (t > 0.8 && lit) {
        canvas.drawCircle(
          Offset(w / 2, h * 0.42),
          3.4,
          Paint()..color = const Color(0xFF8FB86B),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BranchPainter old) =>
      old.grow != grow || old.lit != lit;
}
