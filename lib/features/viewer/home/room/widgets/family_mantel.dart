import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_photos.dart';
import '../../../../../core/i18n/l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../data/models/people.dart';
import '../../../../../shared/widgets/common.dart';
import '../home_atmosphere.dart';

/// **The family mantel** — photographs on a shelf.
///
/// Not a row of equal circular avatars: a real mantel has one picture everyone
/// looks at and a few smaller ones leaning around it, in frames that don't
/// match because they were acquired at different times.
///
/// The big frame opens Family Members; each small frame opens that person. One
/// tap either way — the frame lifts as the route is already pushing, so the
/// motion never delays the navigation.
class FamilyMantel extends ConsumerWidget {
  const FamilyMantel({
    super.key,
    required this.members,
    required this.onEveryone,
    required this.onMember,
  });

  final List<FamilyMember> members;
  final VoidCallback onEveryone;
  final void Function(FamilyMember) onMember;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final atmos = ref.watch(atmosphereProvider);
    final people = members.where((m) => !m.isPet).toList();
    if (people.isEmpty) return const SizedBox.shrink();

    // The big frame holds a picture of the family rather than of one person —
    // Mummy and Papa together. Pointing it at a member whose photo file is
    // missing made it read as an empty placeholder beside the real portraits.
    //
    // Everyone gets a frame. This used to `.take(4)`, which quietly left Diya
    // and Dipisha off the family mantel — the shelf scrolls instead.
    final others = people;
    final pets = members.where((m) => m.isPet).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          trS(lang, 'Our people'),
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
            color: atmos.inkSoft,
          ),
        ),
        const SizedBox(height: AppDimens.md),
        SizedBox(
          height: 132,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _BigFrame(
                atmos: atmos,
                onTap: onEveryone,
                label: trS(lang, 'Everyone we love'),
              ),
              const SizedBox(width: AppDimens.md),
              // The rest of the shelf slides, the way you'd nudge frames
              // along to see the ones at the far end. The last frame sits
              // half off the edge, which is what tells you it moves.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < others.length; i++) ...[
                        _SmallFrame(
                          member: others[i],
                          atmos: atmos,
                          // Frames don't match, and they aren't hung straight.
                          tilt: (i.isEven ? 1 : -1) * (0.014 + (i % 3) * 0.006),
                          oval: i % 3 == 1,
                          onTap: () => onMember(others[i]),
                        ),
                        if (i != others.length - 1)
                          const SizedBox(width: AppDimens.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // The shelf itself.
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: atmos.frameWood,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                  color: atmos.shelfShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
        ),
        // The animals sit under the shelf, where they actually are. They
        // don't need a caption telling you they're underneath — you can see
        // that they are.
        if (pets.isNotEmpty) ...[
          const SizedBox(height: AppDimens.sm),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Row(
              children: [
                for (final p in pets) ...[
                  _PetTag(member: p, onTap: () => onMember(p)),
                  const SizedBox(width: 9),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BigFrame extends StatelessWidget {
  const _BigFrame({
    required this.atmos,
    required this.onTap,
    required this.label,
  });

  final Atmosphere atmos;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Framed family photograph. Opens $label.',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 106,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: atmos.frameWood,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                  color: atmos.shelfShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: SizedBox(
                  height: 92,
                  width: double.infinity,
                  child: Image.asset(
                    AppPhotos.parents,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const DecoratedBox(
                      decoration:
                          BoxDecoration(gradient: AppColors.softGradient),
                      child: Center(
                        child: Text('👨‍👩‍👧‍👧',
                            style: TextStyle(fontSize: 34)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 8.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallFrame extends StatelessWidget {
  const _SmallFrame({
    required this.member,
    required this.atmos,
    required this.tilt,
    required this.oval,
    required this.onTap,
  });

  final FamilyMember member;
  final Atmosphere atmos;
  final double tilt;
  final bool oval;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final first = member.shortName;
    return Semantics(
      button: true,
      label: 'Photograph of $first, ${member.relation}. Opens their page.',
      child: GestureDetector(
        onTap: onTap,
        child: Transform.rotate(
          angle: tilt,
          child: Container(
            width: 52,
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: Color.lerp(atmos.frameWood, AppColors.cream, 0.35),
              borderRadius: BorderRadius.circular(oval ? 26 : 2),
              boxShadow: [
                BoxShadow(
                    color: atmos.shelfShadow,
                    blurRadius: 7,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(oval ? 24 : 1),
              child: SizedBox(
                height: 46,
                width: double.infinity,
                child: MemberFace(
                  photo: member.photo,
                  emoji: member.emoji,
                  emojiSize: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PetTag extends StatelessWidget {
  const _PetTag({required this.member, required this.onTap});

  final FamilyMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${member.shortName}, ${member.relation}. '
          'Opens their page.',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Text(member.emoji, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
