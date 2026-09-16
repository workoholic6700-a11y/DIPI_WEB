import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../data/providers/heritage_providers.dart';
import 'village_map.dart';
import 'village_season.dart';

class VillageExperiencePanel extends ConsumerWidget {
  const VillageExperiencePanel({
    super.key,
    required this.landmark,
    required this.onClose,
    required this.onRoute,
  });

  final Landmark landmark;
  final VoidCallback onClose;
  final ValueChanged<String> onRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 318),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF5E8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF896244), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 18,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5B3928),
                    Color(0xFFB27A4B),
                    Color(0xFF5B3928),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 7, 3),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: landmark.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: landmark.color),
                    ),
                    child: Text(
                      landmark.emoji,
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      landmark.label,
                      style: const TextStyle(
                        color: Color(0xFF3D2D2A),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 5, 14, 12),
                child: _experience(context, ref),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onRoute(landmark.route),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D7E52),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.door_front_door_rounded, size: 18),
                  label: Text(_visitLabel(landmark.label)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _visitLabel(String label) => switch (label) {
    'Memory Tree' => 'Open the family timeline',
    'Pet Park' => 'Visit all pet stories',
    'Family House' => 'Open the family albums',
    'Family' => 'Meet everyone',
    'Mailbox' => 'Open the mailbox',
    'Flower Garden' => 'Enter the garden',
    'Sakela Than' => 'Visit Sakela Than',
    'Library' => 'Open Our Story',
    'Celebration Hall' => 'Enter the hall',
    'Viewpoint' => 'Open all family places',
    _ => 'Step through the portal',
  };

  Widget _experience(BuildContext context, WidgetRef ref) =>
      switch (landmark.label) {
        'Memory Tree' => _memoryTree(ref),
        'Pet Park' => _petPark(ref),
        'Family House' => _familyHouse(),
        'Family' => _family(ref),
        'Mailbox' => _mailbox(ref),
        'Flower Garden' => _garden(ref),
        'Sakela Than' => _sakela(ref),
        'Library' => _library(ref),
        'Celebration Hall' => _celebration(ref),
        'Viewpoint' => _viewpoint(ref),
        _ => _portal(ref),
      };

  Widget _memoryTree(WidgetRef ref) {
    final events = [...ref.watch(timelineProvider)]
      ..sort((a, b) => b.date.compareTo(a.date));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro('${events.length} family moments are growing as leaves.'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final event in events.take(5))
                _object(
                  emoji: event.emoji,
                  title: '${event.year}',
                  subtitle: event.title,
                  onTap: () => onRoute(Routes.timeline),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _petPark(WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro('Each paw stone belongs to a real member of the family.'),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pet in pets)
              _personToken(pet, () => onRoute(Routes.pets)),
          ],
        ),
      ],
    );
  }

  Widget _familyHouse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro(
          'The door, kitchen window and family photograph lead to different parts of home.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _routeToken('🚪', 'Inside Home', Routes.home),
            _routeToken('🖼️', 'Our People', Routes.members),
            _routeToken('🍲', 'Recipe Book', Routes.heritageRecipes),
            _routeToken('📚', 'Albums', Routes.gallery),
          ],
        ),
      ],
    );
  }

  Widget _family(WidgetRef ref) {
    final people = ref.watch(familyProvider).where((m) => !m.isPet).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro('${people.length} people are kept on the family portrait wall.'),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final person in people)
                _personToken(person, () => onRoute(Routes.memberOf(person.id))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mailbox(WidgetRef ref) {
    final unopened = ref.watch(unopenedLettersProvider);
    if (unopened.isEmpty) {
      return _intro(
        'Every kept letter has been opened. They are still safe inside the mailbox.',
      );
    }
    final next = unopened.first;
    return InkWell(
      onTap: () => onRoute(Routes.letterOf(next.id)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1B4CB)),
        ),
        child: Row(
          children: [
            const Text('💌', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${unopened.length} sealed ${unopened.length == 1 ? 'letter' : 'letters'}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    next.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _garden(WidgetRef ref) {
    final family = ref.watch(familyProvider).where((m) => !m.isPet).take(6);
    const flowers = ['🌸', '🌼', '🌺', '🌻', '🪻', '🌷'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro('Each flower can lead back to someone in the family.'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final entry in family.indexed)
              _routeToken(
                flowers[entry.$1 % flowers.length],
                entry.$2.shortName,
                Routes.memberOf(entry.$2.id),
              ),
          ],
        ),
      ],
    );
  }

  Widget _sakela(WidgetRef ref) {
    final words = ref.watch(heritageWordsProvider).take(3).toList();
    final traditions = ref.watch(traditionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro(
          '${words.length} words are shown quietly here; ${traditions.length} traditions are kept in the archive.',
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final word in words)
              _routeToken(
                '🌿',
                '${word.word} · ${word.roman}',
                Routes.heritageWords,
              ),
            _routeToken('🪔', 'Traditions', Routes.heritageTraditions),
          ],
        ),
      ],
    );
  }

  Widget _library(WidgetRef ref) {
    final stories = ref.watch(storyProvider).length;
    final recipes = ref.watch(recipesProvider).length;
    final words = ref.watch(heritageWordsProvider).length;
    final roots = ref.watch(rootsProvider).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro('Take a real family book from the shelf.'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _book(
              'Our Story',
              '$stories chapters',
              Routes.ourStory,
              const Color(0xFFB98C6B),
            ),
            _book(
              'Recipes',
              '$recipes kept',
              Routes.heritageRecipes,
              const Color(0xFFD5A05D),
            ),
            _book(
              'Our Words',
              '$words kept',
              Routes.heritageWords,
              const Color(0xFF8A6DB2),
            ),
            _book(
              'Our Roots',
              '$roots places',
              Routes.heritageRoots,
              const Color(0xFF668D69),
            ),
          ],
        ),
      ],
    );
  }

  Widget _celebration(WidgetRef ref) {
    final next = _nextBirthday(ref.watch(familyProvider));
    if (next == null) {
      return _intro('The hall is ready for confirmed family celebrations.');
    }
    final when = next.$2 == 0
        ? 'today'
        : 'in ${next.$2} ${next.$2 == 1 ? 'day' : 'days'}';
    return Row(
      children: [
        const Text('🎂', style: TextStyle(fontSize: 38)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next at our table',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                '${next.$1} · $when',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _viewpoint(WidgetRef ref) {
    final roots = ref.watch(rootsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _intro('Real places are joined as one family journey.'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < roots.length; i++) ...[
                _object(
                  emoji: roots[i].emoji,
                  title: roots[i].place,
                  subtitle: roots[i].period,
                  onTap: () => onRoute(Routes.heritageRoots),
                ),
                if (i != roots.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _portal(WidgetRef ref) {
    final profile = ref.watch(dipishaProfileProvider);
    return _intro(
      '${profile.shortName}’s personal world waits beyond this gate. The portal stays still until she chooses it.',
    );
  }

  (String, int)? _nextBirthday(List<FamilyMember> members) {
    final dates = <(String, int)>[];
    for (final member in members) {
      final date = MockData.confirmedBirthdays[member.id];
      if (date != null) {
        dates.add((member.shortName, date.daysUntilNextAnniversary()));
      }
    }
    dates.sort((a, b) => a.$2.compareTo(b.$2));
    return dates.firstOrNull;
  }

  Widget _intro(String text) => Text(
    text,
    style: const TextStyle(
      color: AppColors.textSecondary,
      height: 1.4,
      fontSize: 12.5,
    ),
  );

  Widget _routeToken(String emoji, String label, String route) => ActionChip(
    avatar: Text(emoji),
    label: Text(label, overflow: TextOverflow.ellipsis),
    onPressed: () => onRoute(route),
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFFE2D0BC)),
  );

  Widget _personToken(FamilyMember person, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: ActionChip(
      avatar: Text(person.emoji),
      label: Text(person.shortName),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE2D0BC)),
    ),
  );

  Widget _object({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 91,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2D0BC)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            Text(
              title,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _book(String title, String count, String route, Color color) =>
      InkWell(
        onTap: () => onRoute(route),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 78,
          height: 82,
          padding: const EdgeInsets.fromLTRB(8, 10, 5, 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                count,
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ),
      );
}

class VillageNoticeBoard extends ConsumerWidget {
  const VillageNoticeBoard({super.key, required this.onRoute});

  final ValueChanged<String> onRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unopened = ref.watch(unopenedLettersProvider);
    final memory = ref.watch(memoryOfDayProvider);
    final family = ref.watch(familyProvider);
    final season = villageSeasonFor(DateTime.now());

    String title;
    String detail;
    String route;
    String emoji;
    if (unopened.isNotEmpty) {
      title = 'A sealed letter is waiting';
      detail = unopened.first.title;
      route = Routes.letterOf(unopened.first.id);
      emoji = '💌';
    } else {
      final birthday = _nextBirthday(family);
      if (birthday != null && birthday.$2 <= 14) {
        title = birthday.$2 == 0
            ? '${birthday.$1}’s birthday is today'
            : '${birthday.$1} · ${birthday.$2} days';
        detail = 'The Celebration Hall is preparing.';
        route = Routes.hall;
        emoji = '🎂';
      } else {
        title = 'Today’s family memory';
        detail = memory.title;
        route = Routes.memoryOf(memory.id);
        emoji = '💗';
      }
    }

    return Semantics(
      button: true,
      label: '$title. $detail',
      child: GestureDetector(
        onTap: () => onRoute(route),
        child: Container(
          width: 174,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB27A4B), Color(0xFF785039)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4D3024), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 7,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${season.emoji}  VILLAGE NOTICE',
                style: const TextStyle(
                  color: Color(0xFFFFE4A8),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$emoji $title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFEEDBCF), fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, int)? _nextBirthday(List<FamilyMember> members) {
    final result = <(String, int)>[];
    for (final member in members) {
      final date = MockData.confirmedBirthdays[member.id];
      if (date != null) {
        result.add((member.shortName, date.daysUntilNextAnniversary()));
      }
    }
    result.sort((a, b) => a.$2.compareTo(b.$2));
    return result.firstOrNull;
  }
}

class VillageStoryWalk {
  const VillageStoryWalk({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.stops,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<String> stops;
}

const villageStoryWalks = [
  VillageStoryWalk(
    title: 'Our Family Walk',
    subtitle: 'Home, our people, and the memories growing beside them.',
    emoji: '🏡',
    stops: ['Family House', 'Family', 'Memory Tree'],
  ),
  VillageStoryWalk(
    title: 'Roots & Stories',
    subtitle: 'What we carry, where it is kept, and where the journey leads.',
    emoji: '🌿',
    stops: ['Sakela Than', 'Library', 'Viewpoint'],
  ),
  VillageStoryWalk(
    title: 'Dipisha’s Trail',
    subtitle: 'A letter, a garden, and the gate to her own world.',
    emoji: '💜',
    stops: ['Mailbox', 'Flower Garden', "Dipisha's World"],
  ),
];

Future<VillageStoryWalk?> showVillageWalkChooser(BuildContext context) {
  return showDialog<VillageStoryWalk>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFFFF7EC),
      title: const Text('Take a family walk'),
      contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final walk in villageStoryWalks)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                onTap: () => Navigator.of(context).pop(walk),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0CCB6)),
                ),
                leading: Text(walk.emoji, style: const TextStyle(fontSize: 25)),
                title: Text(
                  walk.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  walk.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
        ],
      ),
    ),
  );
}

class VillageWalkButton extends StatelessWidget {
  const VillageWalkButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Choose a guided family walk',
    child: Material(
      color: const Color(0xEEFFF7EC),
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🧵', style: TextStyle(fontSize: 15)),
              SizedBox(width: 6),
              Text(
                'Family walk',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4B3528),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class VillageStoryWalkBar extends StatelessWidget {
  const VillageStoryWalkBar({
    super.key,
    required this.walk,
    required this.step,
    required this.onBack,
    required this.onNext,
    required this.onClose,
  });

  final VillageStoryWalk walk;
  final int step;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final last = step == walk.stops.length - 1;
    return Material(
      color: const Color(0xF5FFF7EC),
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 7, 7),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${walk.emoji} ${walk.title}',
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Stop ${step + 1} of ${walk.stops.length} · ${walk.stops[step]}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5D7E52),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(last ? 'Finish' : 'Next'),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class VillageDiscovery {
  const VillageDiscovery({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    required this.route,
  });
  final String id;
  final String emoji;
  final String title;
  final String body;
  final String route;
}

class VillageDiscoveryToast extends StatelessWidget {
  const VillageDiscoveryToast({
    super.key,
    required this.discovery,
    required this.onOpen,
    required this.onClose,
  });

  final VillageDiscovery discovery;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xF7FFF8EC),
    borderRadius: BorderRadius.circular(16),
    elevation: 7,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 5, 8),
      child: Row(
        children: [
          Text(discovery.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discovery.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                Text(
                  discovery.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onOpen, child: const Text('Open')),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    ),
  );
}
