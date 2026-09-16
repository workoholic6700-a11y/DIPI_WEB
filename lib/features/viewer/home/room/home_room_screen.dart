import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/nepali_date.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/models/people.dart';
import '../../../../data/providers/content_providers.dart';
import '../../../../shared/widgets/language_toggle.dart';
import 'home_atmosphere.dart';
import 'widgets/family_cabinet.dart';
import 'widgets/family_mantel.dart';
import 'widgets/family_window.dart';
import 'widgets/front_door.dart';
import 'widgets/todays_table.dart';

/// **Inside Our Home.**
///
/// The old Home was a landing page: greeting, banner, cards, quote, promo
/// button, more cards. Every destination advertised at equal weight, which is
/// the structure of a website however soft the colours are.
///
/// This is a room instead. You look out of the window, you see what the family
/// left on the table, the people are on the shelf, the way outside is a door,
/// and the list of everywhere else is shut in a cabinet until you want it.
///
/// Family first, today second, features last.
///
/// Two rules held throughout:
/// * **Nothing loops.** The entrance plays once and stops. No particles, no
///   ambient animation — a room that never stops moving is a screensaver, and
///   it costs battery on this phone for nothing.
/// * **Nothing is claimed.** The greeting only mentions what actually exists
///   in the data, and no object implies a state the models don't store.
class HomeRoomScreen extends ConsumerWidget {
  const HomeRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final atmos = ref.watch(atmosphereProvider);
    final profile = ref.watch(dipishaProfileProvider);
    final memory = ref.watch(memoryOfDayProvider);
    final letters = ref.watch(lettersProvider);
    final unopenedLetters = ref.watch(unopenedLettersProvider);
    // The table offers the next letter she has not read. Once every letter
    // has been opened, the first kept letter remains on the table instead of
    // inventing a new one.
    final letter = unopenedLetters.firstOrNull ?? letters.first;
    final quote = ref.watch(quoteOfDayProvider);
    final family = ref.watch(familyProvider);
    final birthday = _nextBirthday(family);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: atmos.wall),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.md,
              AppDimens.lg,
              AppDimens.xxl,
            ),
            children: [
              _Header(
                lang: lang,
                atmos: atmos,
              ).animate().fadeIn(duration: 250.ms),
              const SizedBox(height: AppDimens.lg),

              // The window comes first: it is the only thing in the room that
              // is true right now, for both places at once.
              FamilyWindow(
                onTap: () => context.push(Routes.places),
              ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
              const SizedBox(height: AppDimens.lg),

              _Greeting(lang: lang, name: profile.shortName, atmos: atmos)
                  .animate()
                  .fadeIn(delay: 260.ms, duration: 300.ms)
                  .moveY(begin: 8, end: 0),
              const SizedBox(height: AppDimens.xl),

              TodaysTable(
                memory: memory,
                letter: letter,
                birthday: birthday,
                quote: quote,
                onMemory: () => context.push(Routes.memoryOf(memory.id)),
                // ⚠️ DELIBERATE — do not "fix" this to Routes.letterOf.
                //
                // Diksha's decision, confirmed twice on 2026-08-05: Nana's
                // letters are Dipisha's, and are reached ONLY through
                // Dipisha's World. The envelope on the family table says one
                // is waiting; it does not hand it over in the front room.
                //
                // It looks like a bug because the object names a letter and
                // opens a gate. It isn't. See DECISIONS.md.
                onLetter: () => context.push(Routes.dipishaGate),
                onBirthday: () => context.push(Routes.hall),
              ),
              const SizedBox(height: AppDimens.xxl),

              FamilyMantel(
                members: family,
                onEveryone: () => context.push(Routes.members),
                onMember: (m) => context.push(Routes.memberOf(m.id)),
              ).animate().fadeIn(delay: 700.ms, duration: 300.ms),
              const SizedBox(height: AppDimens.xxl),

              FrontDoor(onTap: () => context.push(Routes.village)),
              const SizedBox(height: AppDimens.md),

              const CabinetHandle(),
            ],
          ),
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
        name: member.shortName,
        days: date.daysUntilNextAnniversary(),
      ));
    }
    upcoming.sort((a, b) => a.days.compareTo(b.days));
    return upcoming.first;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lang, required this.atmos});

  final AppLang lang;
  final Atmosphere atmos;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // The family thinks in Bikram Sambat, so the BS date is the one that
    // stands beside the weekday.
    final date = '${now.weekdayLong} · ${bsDayMonth(now)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trS(lang, 'Our Home'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: atmos.ink,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                date,
                style: TextStyle(fontSize: 11.5, color: atmos.inkSoft),
              ),
            ],
          ),
        ),
        const LanguageToggle(),
      ],
    );
  }
}

/// A quiet line, assembled only from things that are actually here.
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.lang,
    required this.name,
    required this.atmos,
  });

  final AppLang lang;
  final String name;
  final Atmosphere atmos;

  @override
  Widget build(BuildContext context) {
    // Already the short form — the profile hands it over rather than this
    // screen guessing at where a name divides.
    final first = name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${trS(lang, greetingForNow())}, ${trS(lang, first)}.',
          style: TextStyle(
            fontSize: 22,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: atmos.ink,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          // Deliberately not "everyone left something today" — nothing in the
          // data says anyone did anything today.
          trS(lang, 'There are family stories waiting for you.'),
          style: TextStyle(fontSize: 13.5, height: 1.45, color: atmos.inkSoft),
        ),
      ],
    );
  }
}
