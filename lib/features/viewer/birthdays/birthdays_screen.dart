import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../core/utils/nepali_date.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/cover.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';

/// **Birthdays** — the calendar on the kitchen wall.
///
/// It was a gradient hero card over a list of rows. A family doesn't keep
/// birthdays in a list; it keeps them on the calendar by the door, with the
/// next one on the showing page and the rest of the year pencilled in below.
///
/// Only real, confirmed dates live here. The family thinks in Bikram Sambat,
/// so each date carries the BS one it was converted from. Mummy, Papa and
/// Kopa's are not recorded, and are shown as missing rather than guessed — a
/// wrong birthday in a family album is worse than an absent one.
class BirthdaysScreen extends ConsumerWidget {
  const BirthdaysScreen({super.key});

  /// **Confirmed dates only.**
  ///
  /// This used to read `MockData.birthdays`, which also holds three stand-ins
  /// for Mummy, Papa and Kopa — so the page was showing invented dates as
  /// fact, and a pencilled one could reach the top of the calendar as "next".
  /// mock_data says it plainly: no countdown may ever point at a placeholder.
  /// The three of them belong on the pinned note instead, and that is where
  /// `awaiting` now puts them.
  static Map<String, DateTime> get _birthdays => MockData.confirmedBirthdays;

  static const _wall = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4EEF6), Color(0xFFF8F2E9)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final members = ref.watch(familyProvider).where((m) => !m.isPet).toList();

    final withDays = members
        .where((m) => _birthdays.containsKey(m.id))
        .map((m) => (
              member: m,
              birthday: _birthdays[m.id]!,
              days: _birthdays[m.id]!.daysUntilNextAnniversary(),
            ))
        .toList()
      ..sort((a, b) => a.days.compareTo(b.days));

    final awaiting =
        members.where((m) => !_birthdays.containsKey(m.id)).toList();

    return SectionScaffold(
      title: 'Birthdays',
      subtitle: 'The calendar by the door',
      emoji: '🎂',
      gradient: _wall,
      particles: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (withDays.isNotEmpty) ...[
            _CalendarPage(next: withDays.first, lang: lang)
                .animate()
                .fadeIn(duration: 400.ms)
                .moveY(begin: -8, end: 0),
            const SizedBox(height: AppDimens.xl),
            Text(
              trS(lang, 'The rest of the year'),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppDimens.md),
            for (var i = 1; i < withDays.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: _DaySlip(
                  member: withDays[i].member,
                  birthday: withDays[i].birthday,
                  days: withDays[i].days,
                  lang: lang,
                  onTap: () =>
                      context.push(Routes.memberOf(withDays[i].member.id)),
                )
                    .animate()
                    .fadeIn(delay: (i * 70).ms, duration: 300.ms)
                    .moveX(begin: 10, end: 0),
              ),
          ],
          if (awaiting.isNotEmpty) ...[
            const SizedBox(height: AppDimens.lg),
            _PinnedNote(awaiting: awaiting, lang: lang),
          ],
          const SizedBox(height: AppDimens.xl),
        ],
      ),
    );
  }
}

/// The page currently showing on the calendar: whoever is next.
class _CalendarPage extends StatelessWidget {
  const _CalendarPage({required this.next, required this.lang});

  final ({FamilyMember member, DateTime birthday, int days}) next;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final when = next.birthday.nextAnniversary();
    final today = next.days == 0;
    final first = next.member.shortName;

    return Column(
      children: [
        // The spiral binding it hangs by.
        SizedBox(
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 9; i++)
                Container(
                  width: 7,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9AFA0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppDimens.xl),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10), top: Radius.circular(3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              Text(
                trS(lang, today ? 'Today' : 'Next on the calendar'),
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pinkDeep,
                ),
              ),
              const SizedBox(height: AppDimens.md),
              // The date, the way a calendar shows it.
              Text(
                when.day.toString(),
                style: const TextStyle(
                  fontSize: 74,
                  height: 0.95,
                  fontWeight: FontWeight.w300,
                  color: AppColors.purpleMid,
                ),
              ),
              Text(
                when.dayMonth.split(' ').last.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purpleMid,
                ),
              ),
              const SizedBox(height: 2),
              // The family keeps these in BS, so it's written underneath.
              Text(
                bsDayMonth(next.birthday),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppDimens.lg),
              Container(
                width: 46,
                height: 1.5,
                color: AppColors.lavenderLight,
              ),
              const SizedBox(height: AppDimens.lg),
              Container(
                width: 74,
                height: 74,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: CoverPalette.gradient(next.member.colorSeed),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2.5),
                ),
                child: MemberFace(
                  photo: next.member.photo,
                  emoji: next.member.emoji,
                  emojiSize: 36,
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                today
                    ? '${trS(lang, 'Happy birthday')}, $first 🎂'
                    : first,
                style: handwriting(fontSize: 26, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                today
                    ? '${trS(lang, 'Turning')} ${next.birthday.ageOn() + 1} '
                        '${trS(lang, 'today')}'
                    : '${trS(lang, 'Turning')} ${next.birthday.ageOn() + 1} · '
                        '${next.days} ${trS(lang, next.days == 1 ? 'day away' : 'days away')}',
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One of the year's other days, pencilled onto a slip.
class _DaySlip extends StatelessWidget {
  const _DaySlip({
    required this.member,
    required this.birthday,
    required this.days,
    required this.lang,
    required this.onTap,
  });

  final FamilyMember member;
  final DateTime birthday;
  final int days;
  final AppLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final first = member.shortName;

    return Semantics(
      button: true,
      label: '$first, ${birthday.dayMonth}, $days days away. '
          'Opens their page.',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(3),
            border: Border(
              left: BorderSide(
                  color: CoverPalette.base(member.colorSeed), width: 4),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    Text(
                      '${birthday.day}',
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1,
                        fontWeight: FontWeight.w300,
                        color: AppColors.purpleMid,
                      ),
                    ),
                    Text(
                      birthday.dayMonth.split(' ').last.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Container(
                width: 38,
                height: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: CoverPalette.gradient(member.colorSeed),
                  shape: BoxShape.circle,
                ),
                child: MemberFace(
                  photo: member.photo,
                  emoji: member.emoji,
                  emojiSize: 19,
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(first, style: t.titleSmall),
                    Text(
                      bsDayMonth(birthday),
                      style: t.bodySmall
                          ?.copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                '$days',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lavender,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                trS(lang, days == 1 ? 'day' : 'days'),
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The note pinned beside the calendar for the dates nobody has told us.
class _PinnedNote extends StatelessWidget {
  const _PinnedNote({required this.awaiting, required this.lang});

  final List<FamilyMember> awaiting;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final names = awaiting.map((m) => m.shortName).join(', ');
    // Reads correctly whether one date is missing or several.
    final tail = awaiting.length == 1
        ? trS(lang, 'we haven\'t written this one down yet. Nobody guesses it.')
        : trS(lang, 'we haven\'t written these down yet. Nobody guesses one.');

    return StickyNote(
      emoji: '💌',
      width: double.infinity,
      rotation: -0.014,
      text: '${trS(lang, 'Still to add')}\n$names — $tail',
    );
  }
}
