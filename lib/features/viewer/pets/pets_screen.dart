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

/// **Our Animals** — their corner of the house.
///
/// Not three stacked cards: the corner they actually occupy. A rug on the
/// floor, their things on it, and each of them in their own spot with their
/// name on a collar tag.
///
/// Stubby is here too. She gets the same spot as the others with a quiet
/// rainbow rather than a black band, because that is how this family talks
/// about her — "forever in our hearts", not "deceased".
class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  static const _corner = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7EFE6), Color(0xFFEFE3D6)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final pets = ref.watch(petsProvider);

    return SectionScaffold(
      title: 'Our Animals',
      subtitle: 'Their corner of the house',
      emoji: '🐾',
      gradient: _corner,
      particles: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Rug(),
          const SizedBox(height: AppDimens.xl),
          for (var i = 0; i < pets.length; i++) ...[
            _PetSpot(pet: pets[i], flip: i.isOdd, lang: lang)
                .animate()
                .fadeIn(delay: (i * 90).ms, duration: 340.ms)
                .moveY(begin: 10, end: 0),
            const SizedBox(height: AppDimens.xl),
          ],
          Center(
            child: Text(
              trS(lang, 'Everybody who has ever slept on this floor.'),
              textAlign: TextAlign.center,
              style: handwriting(fontSize: 18, color: pageInk(context)),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }
}

/// The rug they all lie on, with their things left on it.
class _Rug extends StatelessWidget {
  const _Rug();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 74,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD9B7A2), Color(0xFFC79C86)],
              ),
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 6)),
              ],
            ),
          ),
          // The woven ring in the middle of it.
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 46),
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xFFEBD3C3).withValues(alpha: 0.75),
                  width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          // Their things.
          const Positioned(left: 34, bottom: 8, child: Text('🦴',
              style: TextStyle(fontSize: 19))),
          const Positioned(right: 40, top: 12, child: Text('🧶',
              style: TextStyle(fontSize: 18))),
          const Positioned(right: 96, bottom: 10, child: Text('🥣',
              style: TextStyle(fontSize: 17))),
        ],
      ),
    );
  }
}

/// One animal in their own spot, with a collar tag for a nameplate.
class _PetSpot extends StatefulWidget {
  const _PetSpot({
    required this.pet,
    required this.flip,
    required this.lang,
  });

  final FamilyMember pet;
  final bool flip;
  final AppLang lang;

  @override
  State<_PetSpot> createState() => _PetSpotState();
}

class _PetSpotState extends State<_PetSpot> {
  bool _held = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pet;
    final t = Theme.of(context).textTheme;
    final base = CoverPalette.base(p.colorSeed);
    final first = p.shortName;

    // Their basket / cushion, with them in it.
    final bed = AnimatedScale(
      scale: _held ? 1.05 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          gradient: CoverPalette.gradient(p.colorSeed),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: _held ? 0.42 : 0.26),
              blurRadius: _held ? 20 : 13,
              offset: Offset(0, _held ? 10 : 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Hero(
          tag: 'member-${p.id}',
          child: MemberFace(
            photo: p.photo,
            emoji: p.emoji,
            emojiSize: 56,
          ),
        ),
      ),
    );

    final text = Column(
      crossAxisAlignment:
          widget.flip ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // The collar tag.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: AppDimens.brPill,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 5,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 5),
              Text(
                first,
                style: const TextStyle(
                  color: Color(0xFF5A421A),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          trS(widget.lang, p.relation),
          style: t.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          trS(widget.lang, p.bio),
          textAlign: widget.flip ? TextAlign.right : TextAlign.left,
          style: t.bodySmall?.copyWith(height: 1.5),
        ),
        if (p.inMemoriam) ...[
          const SizedBox(height: AppDimens.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌈', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                trS(widget.lang, 'Forever in our hearts'),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purpleMid),
              ),
            ],
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      label: '$first, ${p.relation}. Opens their page.',
      child: GestureDetector(
        onTap: () => context.push(Routes.memberOf(p.id)),
        onTapDown: (_) => setState(() => _held = true),
        onTapUp: (_) => setState(() => _held = false),
        onTapCancel: () => setState(() => _held = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.flip
                  ? [Expanded(child: text), const SizedBox(width: 14), bed]
                  : [bed, const SizedBox(width: 14), Expanded(child: text)],
            ),
            const SizedBox(height: AppDimens.md),
            // Their one line, on a note by the bed.
            StickyNote(
              text: trS(widget.lang, p.funFact),
              emoji: '🐾',
              width: double.infinity,
              rotation: widget.flip ? 0.012 : -0.012,
            ),
          ],
        ),
      ),
    );
  }
}
