import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/cover.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/states.dart';
import 'widgets/didi_pitch.dart';

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = familyMemberById(memberId);
    if (member == null) {
      return const Scaffold(body: ErrorStateView(title: 'Not found'));
    }
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final first = member.shortName;

    // A real connection, not a decorative one: memories whose own words name
    // this person. Matched on the first name against title, description and
    // tags, so it can only ever surface something that genuinely mentions
    // them. Empty for most people right now, and the section simply doesn't
    // appear — which is the truth about how much has been written down.
    final needle = first.toLowerCase();
    final memoriesPreview = ref
        .watch(recentMemoriesProvider)
        .where((m) =>
            m.title.toLowerCase().contains(needle) ||
            m.description.toLowerCase().contains(needle) ||
            m.tags.any((tag) => tag.toLowerCase().contains(needle)))
        .take(4)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.purpleMid),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'member-${member.id}',
                child: Container(
                  decoration:
                      BoxDecoration(gradient: CoverPalette.gradient(member.colorSeed)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The emoji is the base layer, so it shows through
                      // whenever there is no photo — or the named photo file
                      // hasn't been dropped into assets/images/family/ yet.
                      // Lifted when there's a memorial badge so the two never
                      // sit on top of each other.
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: member.inMemoriam ? 46 : 0),
                          child: Text(member.emoji,
                              style: const TextStyle(fontSize: 96)),
                        ),
                      ),
                      if (member.photo != null)
                        Image.asset(
                          member.photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      const Positioned.fill(
                          child: FloatingParticles(count: 10)),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (member.inMemoriam)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: AppDimens.brPill,
                                ),
                                child: const Text('🕊️  In Loving Memory',
                                    style: TextStyle(
                                        color: AppColors.purpleMid,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The name on a plate under the frame, the way a portrait is
                  // labelled — rather than a heading with a chip beside it.
                  _NamePlate(member: member, lang: lang),
                  const SizedBox(height: AppDimens.lg),
                  Text(trS(lang, member.bio),
                      style: t.bodyLarge?.copyWith(height: 1.6)),
                  const SizedBox(height: AppDimens.xl),

                  // The note, taped down on its own. The caption used to float
                  // beside it in open space, which read as a stray label rather
                  // than part of the note.
                  StickyNote(
                    text: trS(lang, member.funFact),
                    emoji: '💡',
                    rotation: -0.02,
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Didi's own corner. The rest of this home is about everyone
                  // else — this bit is just hers.
                  if (member.id == 'f_diksha') ...[
                    const _DidiCorner(),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  // Memories that genuinely name this person, found by looking
                  // for them in the title, the description and the tags.
                  //
                  // This replaces a "Favourite Memories" row that showed the
                  // four most *recent* memories on every single member's page —
                  // the same four for Kopa, for Meow, for everyone — captioned
                  // as if they were that person's favourites. A real link or
                  // nothing.
                  if (memoriesPreview.isNotEmpty) ...[
                    SectionHeader(
                        title: trS(lang, 'Memories that mention them'),
                        emoji: '💜'),
                    for (final m in memoriesPreview)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.sm),
                        child: _MemoryLink(memory: m, lang: lang),
                      ),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  if (member.inMemoriam) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.softGradient,
                        borderRadius: AppDimens.brLg,
                      ),
                      child: Column(
                        children: [
                          const Text('🌈', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text('Forever a part of our family',
                              style: t.titleMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(
                              'Some paw prints never fade. Run free and happy, '
                              'sweet ${member.shortName}. 💜',
                              style: t.bodyMedium,
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  // A "Gallery" of six gradient tiles used to sit here,
                  // presented as this person's photographs. There were no
                  // photographs. An empty shelf is better than a painted one,
                  // so it says what it's waiting for instead.
                  _StillToLink(name: first, lang: lang),
                  const SizedBox(height: 40),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}

/// The name on a plate beneath the portrait, the way a framed picture is
/// labelled. Brass for the people, since that is what a family hangs.
class _NamePlate extends StatelessWidget {
  const _NamePlate({required this.member, required this.lang});

  final FamilyMember member;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE6CE9A), Color(0xFFC0A263)],
        ),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A3418),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            trS(lang, member.relation),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B5334),
            ),
          ),
        ],
      ),
    );
  }
}

/// One memory that names this person, as a line you can follow.
class _MemoryLink extends StatelessWidget {
  const _MemoryLink({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${memory.title}, ${memory.date.prettyDate}. Opens this memory.',
      child: GestureDetector(
        onTap: () => context.push(Routes.memoryOf(memory.id)),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: AppDimens.brMd,
            border: Border(
              left: BorderSide(
                  color: CoverPalette.base(memory.colorSeed), width: 3),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trS(lang, memory.title), style: t.titleSmall),
                    Text(memory.date.prettyDate,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// What this page still can't show, said plainly.
///
/// The app has no data linking a person to their places, letters or voice —
/// so rather than draw four objects that would open nothing, this names the
/// gap. Same rule as the heritage record: an honest hole beats a painted one.
class _StillToLink extends StatelessWidget {
  const _StillToLink({required this.name, required this.lang});

  final String name;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.lavenderSoft.withValues(alpha: 0.5),
        borderRadius: AppDimens.brLg,
        border: Border.all(color: AppColors.lavender.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧵', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                trS(lang, 'Not yet threaded together'),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                  color: AppColors.purpleMid,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(lang,
                'Nothing yet connects $name to their places, their letters or '
                'their voice. When those are recorded they will show here.'),
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Diksha's own little corner — the things Didi loves, on the one page that is
/// about her. Shown only on `f_diksha`.
///
/// This used to show a scanned panel from the Blue Lock manga (© Muneyuki
/// Kaneshiro / Yusuke Nomura / Kodansha). It was the one asset in the project
/// that wasn't ours or openly licensed, and it has been replaced with
/// [DidiPitch], drawn in code. Naming the show she loves is hers to do and
/// always was — it was only the artwork that couldn't travel.
///
/// **Every asset in this project is now ours or openly licensed.** Keep it
/// that way: if something can't be drawn, check the licence before it lands
/// in assets/.
class _DidiCorner extends StatelessWidget {
  const _DidiCorner();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: "Didi's Corner", emoji: '💙'),
        const SizedBox(height: AppDimens.sm),
        Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDimens.brLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.lavender.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawn here rather than scanned from somebody else's book, so
              // this corner is safe to publish and still hers.
              ClipRRect(
                borderRadius: AppDimens.brMd,
                child: const DidiPitch(height: 190),
              ),
              const SizedBox(height: AppDimens.md),
              Text('Blue Lock ⚽', style: t.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Didi\'s favourite. When the code stops compiling and Kathmandu '
                'is loud and home is far away, this is where she goes. One day '
                'you\'ll be old enough to watch it with her, Dipu.',
                style: t.bodySmall
                    ?.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
