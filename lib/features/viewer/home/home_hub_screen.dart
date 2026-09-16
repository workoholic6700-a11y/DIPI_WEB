import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_x.dart';
import '../../../core/utils/nepali_date.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/language_toggle.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/storybook.dart';
import 'widgets/section_card.dart';
import 'widgets/two_skies.dart';
import 'room/home_atmosphere.dart';

class HomeHubScreen extends ConsumerWidget {
  const HomeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteOfDayProvider);
    final memory = ref.watch(memoryOfDayProvider);
    final letter = ref.watch(lettersProvider).first;
    final profile = ref.watch(dipishaProfileProvider);
    final nextBirthday = _nextBirthday(ref.watch(familyProvider));
    final lang = ref.watch(langProvider);

    final sections = _sections(context, lang);

    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: FloatingParticles(count: 14)),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        AppDimens.xl,
                        AppDimens.lg,
                        0,
                      ),
                      child: _WelcomeHeader(lang: lang, name: profile.name),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.lg,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              ref.read(homeStyleProvider.notifier).toggle(),
                          icon: const Icon(Icons.chair_outlined),
                          label: Text(trS(lang, 'Switch to the new home')),
                        ),
                      ),
                    ),
                  ),
                  // The Two Skies — ours, and Papa's, 2h15m ahead in Malaysia.
                  // It sits under the welcome because it is the sky over this
                  // house, and it is the first true thing on the screen.
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        AppDimens.lg,
                        AppDimens.lg,
                        0,
                      ),
                      child: TwoSkies(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        AppDimens.lg,
                        AppDimens.lg,
                        0,
                      ),
                      child: _DailyTrail(
                        memory: memory,
                        letter: letter,
                        birthday: nextBirthday,
                        lang: lang,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.lg),
                      child: _TodayStrip(
                        quote: quote.text,
                        author: quote.author,
                        lang: lang,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        0,
                        AppDimens.lg,
                        AppDimens.sm,
                      ),
                      child: _VillageEntryCard(
                        lang: lang,
                        onTap: () => context.push(Routes.village),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        AppDimens.sm,
                        AppDimens.lg,
                        AppDimens.sm,
                      ),
                      child: Text(
                        trS(lang, 'Step inside our home'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.lg,
                      AppDimens.sm,
                      AppDimens.lg,
                      120,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: AppDimens.md,
                            crossAxisSpacing: AppDimens.md,
                            childAspectRatio: 1.22,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => sections[i],
                        childCount: sections.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({String name, int days}) _nextBirthday(List<FamilyMember> members) {
    final upcoming = <({String name, int days})>[];
    for (final member in members) {
      final date = MockData.confirmedBirthdays[member.id];
      if (date == null) continue;
      upcoming.add((
        name: member.name.toString().split(' ').first,
        days: date.daysUntilNextAnniversary(),
      ));
    }
    upcoming.sort((a, b) => a.days.compareTo(b.days));
    return upcoming.first;
  }

  List<Widget> _sections(BuildContext context, AppLang lang) {
    final data = <(String, String, IconData, List<Color>, String, bool)>[
      (
        'Family Tree',
        'Our roots & branches',
        Icons.account_tree_rounded,
        [const Color(0xFFB79BE0), const Color(0xFF9B72CF)],
        Routes.familyTree,
        false,
      ),
      (
        'Our Story',
        'Read it like a book',
        Icons.menu_book_rounded,
        [const Color(0xFFF7D89B), const Color(0xFFE0A93E)],
        Routes.ourStory,
        false,
      ),
      (
        'Family Members',
        'Everyone we love',
        Icons.groups_rounded,
        [const Color(0xFFA9D3F0), const Color(0xFF7FB8E6)],
        Routes.members,
        false,
      ),
      (
        'Gallery',
        'Photos & albums',
        Icons.photo_library_rounded,
        [const Color(0xFFF4A9C7), const Color(0xFFE8749E)],
        Routes.gallery,
        false,
      ),
      (
        'Timeline',
        'Year by year',
        Icons.timeline_rounded,
        [const Color(0xFF8FD08A), const Color(0xFF5FAE77)],
        Routes.timeline,
        false,
      ),
      (
        'Pets',
        'Our furry family',
        Icons.pets_rounded,
        [const Color(0xFFF3C4B4), const Color(0xFFE79B84)],
        Routes.pets,
        false,
      ),
      (
        'Birthdays',
        'Cakes & countdowns',
        Icons.cake_rounded,
        [const Color(0xFFD9A7E0), const Color(0xFFB56FC0)],
        Routes.birthdays,
        false,
      ),
      (
        'Places',
        'Where we\'ve been',
        Icons.map_rounded,
        [const Color(0xFF7FCFC8), const Color(0xFF4FB0A8)],
        Routes.places,
        false,
      ),
      (
        'Family Quotes',
        'Things we always say',
        Icons.format_quote_rounded,
        [const Color(0xFFC7B4E8), const Color(0xFF9B72CF)],
        Routes.quotes,
        false,
      ),
      // Earthen clay tones — this one is the archive, not a celebration.
      (
        'Our Roots',
        'Stories, words & traditions',
        Icons.history_edu_rounded,
        [const Color(0xFFCBB68A), const Color(0xFF9C7B4E)],
        Routes.heritage,
        false,
      ),
    ];

    final cards = <Widget>[
      for (var i = 0; i < data.length; i++)
        SectionCard(
          index: i,
          title: trS(lang, data[i].$1),
          subtitle: trS(lang, data[i].$2),
          icon: data[i].$3,
          gradient: data[i].$4,
          onTap: () => context.push(data[i].$5),
        ),
    ];

    // Dipisha's World — the special magical portal.
    cards.add(
      SectionCard(
        index: data.length,
        title: trS(lang, 'Dipisha\'s World'),
        subtitle: trS(lang, 'Made with love by Nana ✨'),
        icon: Icons.auto_awesome_rounded,
        gradient: const [Color(0xFF7B4FB5), Color(0xFFE8749E)],
        featured: true,
        onTap: () => context.push(Routes.dipishaGate),
      ),
    );
    return cards;
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.lang, required this.name});
  final AppLang lang;
  final String name;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'A quiet night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language switch, easy to reach for parents.
        Align(
          alignment: Alignment.centerRight,
          child: const LanguageToggle().animate().fadeIn(duration: 500.ms),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 5,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.heartGradient,
                borderRadius: AppDimens.brPill,
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Text(
                '${trS(lang, _greeting())}, $name',
                style: AppTypography.brandScript(
                  fontSize: 32,
                  color: AppColors.purpleMid,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).moveY(begin: 12, end: 0),
        const SizedBox(height: 4),
        Text(
          trS(lang, 'Here is what is waiting in our family today.'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 600.ms),
      ],
    );
  }
}

class _TodayStrip extends StatelessWidget {
  const _TodayStrip({
    required this.quote,
    required this.author,
    required this.lang,
  });
  final String quote;
  final String author;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = lang == AppLang.ne ? bsLongDate(now) : now.prettyDate;
    return StorybookPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: AppColors.purpleMid,
              ),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.purpleMid,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          StorybookDivider(label: trS(lang, 'WORDS FOR TODAY')),
          const SizedBox(height: AppDimens.md),
          Text(
            '“$quote”',
            style: handwriting(fontSize: 22, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            '— $author',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).moveY(begin: 14, end: 0);
  }
}

/// The magical doorway into Rai Village — a featured card on the Home hub.
class _VillageEntryCard extends StatelessWidget {
  const _VillageEntryCard({required this.onTap, required this.lang});
  final VoidCallback onTap;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5C9A63),
                  Color(0xFF3E6E8C),
                  Color(0xFF6B3FA0),
                ],
              ),
              borderRadius: AppDimens.brLg,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3E6E8C).withValues(alpha: 0.38),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: AppDimens.brMd,
                  ),
                  child: const Text('🏡', style: TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trS(lang, '✨ Enter Rai Village'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        trS(lang, 'Explore our memories in a living world'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppDimens.brPill,
                        ),
                        child: Text(
                          trS(lang, 'Enter  →'),
                          style: const TextStyle(
                            color: Color(0xFF3E6E8C),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 480.ms, duration: 500.ms)
        .moveY(begin: 16, end: 0, curve: Curves.easeOut);
  }
}

class _DailyTrail extends StatelessWidget {
  const _DailyTrail({
    required this.memory,
    required this.letter,
    required this.birthday,
    required this.lang,
  });

  final Memory memory;
  final Letter letter;
  final ({String name, int days}) birthday;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final birthdayLine = birthday.days == 0
        ? '${birthday.name}\'s celebration is today!'
        : '${birthday.name}\'s celebration in ${birthday.days} days';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trS(lang, 'Today in our family'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          trS(lang, 'Three little paths into our story'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimens.md),
        SizedBox(
          height: 146,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _TrailCard(
                eyebrow: trS(lang, 'REMEMBER'),
                title: trS(lang, memory.title),
                detail: lang == AppLang.ne
                    ? bsDayMonth(memory.date)
                    : memory.date.dayMonth,
                icon: Icons.auto_stories_rounded,
                colors: const [Color(0xFF8D6AC1), Color(0xFFB68ED7)],
                onTap: () => context.push(Routes.memoryOf(memory.id)),
              ),
              _TrailCard(
                eyebrow: trS(lang, 'UNFOLD'),
                title: trS(lang, letter.title),
                detail: trS(lang, 'A letter from Nana'),
                icon: Icons.mark_email_unread_rounded,
                colors: const [Color(0xFFE985AA), Color(0xFFF5B6CB)],
                onTap: () => context.push(Routes.letterOf(letter.id)),
              ),
              _TrailCard(
                eyebrow: trS(lang, 'CELEBRATE'),
                title: trS(lang, birthdayLine),
                detail: trS(lang, 'Visit the family table'),
                icon: Icons.cake_rounded,
                colors: const [Color(0xFFD3A33F), Color(0xFFF2CF82)],
                onTap: () => context.push(Routes.hall),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 330.ms).moveY(begin: 14, end: 0);
  }
}

class _TrailCard extends StatelessWidget {
  const _TrailCard({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.md),
      child: SizedBox(
        width: 174,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppDimens.brLg,
            child: Ink(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: AppDimens.brLg,
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 19),
                      const SizedBox(width: 7),
                      Text(
                        eyebrow,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
