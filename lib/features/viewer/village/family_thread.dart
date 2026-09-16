import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/heritage_models.dart';
import '../../../data/models/people.dart';
import '../../../data/models/story_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../data/providers/heritage_providers.dart';
import 'village_map.dart';

class FamilyThreadStop {
  const FamilyThreadStop({
    required this.landmark,
    required this.route,
    required this.reason,
  });

  final Landmark landmark;
  final String route;
  final String reason;
}

class FamilyThreadData {
  const FamilyThreadData({required this.member, required this.stops});

  final FamilyMember member;
  final List<FamilyThreadStop> stops;
}

FamilyThreadData buildFamilyThread({
  required FamilyMember member,
  required List<Memory> memories,
  required List<Letter> letters,
  required List<StoryChapter> stories,
  required List<TimelineEvent> timeline,
  required List<RootStep> roots,
}) {
  final aliases = _memberAliases(member);
  bool matches(String text) {
    final lower = text.toLowerCase();
    return aliases.any(lower.contains);
  }

  Landmark landmark(String label) =>
      kLandmarks.firstWhere((item) => item.label == label);

  final stops = <FamilyThreadStop>[
    FamilyThreadStop(
      landmark: landmark('Family House'),
      route: Routes.gallery,
      reason: 'Their place in the family home',
    ),
    FamilyThreadStop(
      landmark: landmark('Family'),
      route: Routes.memberOf(member.id),
      reason: member.relation,
    ),
  ];

  final namedMemory = memories
      .where((m) => matches('${m.title} ${m.description} ${m.tags.join(' ')}'))
      .firstOrNull;
  final namedTimeline = timeline
      .where((e) => matches('${e.title} ${e.description}'))
      .firstOrNull;
  if (namedMemory != null || namedTimeline != null) {
    stops.add(
      FamilyThreadStop(
        landmark: landmark('Memory Tree'),
        route: namedMemory == null
            ? Routes.timeline
            : Routes.memoryOf(namedMemory.id),
        reason: namedMemory?.title ?? namedTimeline!.title,
      ),
    );
  }

  final namedStory = stories
      .where((chapter) => matches('${chapter.title} ${chapter.body}'))
      .firstOrNull;
  if (namedStory != null) {
    stops.add(
      FamilyThreadStop(
        landmark: landmark('Library'),
        route: Routes.ourStory,
        reason: namedStory.title,
      ),
    );
  }

  final namedLetter = letters
      .where((letter) => matches('${letter.title} ${letter.body}'))
      .firstOrNull;
  if (namedLetter != null) {
    stops.add(
      FamilyThreadStop(
        landmark: landmark('Mailbox'),
        route: Routes.letterOf(namedLetter.id),
        reason: namedLetter.title,
      ),
    );
  }

  if (MockData.confirmedBirthdays.containsKey(member.id)) {
    stops.add(
      FamilyThreadStop(
        landmark: landmark('Celebration Hall'),
        route: Routes.birthdays,
        reason: 'A confirmed family birthday',
      ),
    );
  }

  final namedRoot = roots
      .where((root) => matches('${root.story} ${root.who ?? ''}'))
      .firstOrNull;
  if (namedRoot != null) {
    stops.add(
      FamilyThreadStop(
        landmark: landmark('Viewpoint'),
        route: Routes.heritageRoots,
        reason: namedRoot.place,
      ),
    );
  }

  if (member.id == 'f_dipisha') {
    stops.add(
      FamilyThreadStop(
        landmark: landmark("Dipisha's World"),
        route: Routes.dipishaGate,
        reason: 'Her own protected world',
      ),
    );
  }

  // Keep the path spatially readable from left to right. The reasons above
  // remain derived from content even though presentation order is geographic.
  stops.sort((a, b) => a.landmark.fx.compareTo(b.landmark.fx));
  return FamilyThreadData(member: member, stops: stops);
}

Set<String> _memberAliases(FamilyMember member) {
  final aliases = <String>{member.name.split(' ').first.toLowerCase()};
  switch (member.id) {
    case 'f_grandpa':
      aliases.addAll(['kopa', 'grandpa', 'grandfather']);
      break;
    case 'f_father':
      aliases.addAll(['papa', 'father']);
      break;
    case 'f_mother':
      aliases.addAll(['mummy', 'mother']);
      break;
    case 'f_diksha':
      aliases.add('didi');
      break;
    case 'f_diya':
      aliases.add('diya');
      break;
    case 'f_dipisha':
      aliases.addAll(['dipisha', 'little star']);
      break;
  }
  return aliases;
}

class FamilyThreadLayer extends ConsumerWidget {
  const FamilyThreadLayer({
    super.key,
    required this.member,
    required this.onRoute,
  });

  final FamilyMember member;
  final ValueChanged<String> onRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = buildFamilyThread(
      member: member,
      memories: ref.watch(memoriesProvider),
      letters: ref.watch(lettersProvider),
      stories: ref.watch(storyProvider),
      timeline: ref.watch(timelineProvider),
      roots: ref.watch(rootsProvider),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _FamilyThreadPainter(
                  points: data.stops.map((s) => s.landmark.worldPos).toList(),
                ),
              ),
            ),
          ),
        ),
        for (var i = 0; i < data.stops.length; i++) _stop(data.stops[i], i + 1),
      ],
    );
  }

  Widget _stop(FamilyThreadStop stop, int index) => Positioned(
    left: stop.landmark.worldPos.dx - 25,
    top: stop.landmark.worldPos.dy - 25,
    width: 50,
    height: 50,
    child: Semantics(
      button: true,
      label: '${member.name}: ${stop.landmark.label}. ${stop.reason}',
      child: Tooltip(
        message: stop.reason,
        child: Material(
          color: const Color(0xFFF7D77D),
          elevation: 7,
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 2.5),
          ),
          child: InkWell(
            onTap: () => onRoute(stop.route),
            customBorder: const CircleBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(stop.landmark.emoji, style: const TextStyle(fontSize: 20)),
                Positioned(
                  right: 1,
                  top: 1,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: const Color(0xFF5B3D2D),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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

class _FamilyThreadPainter extends CustomPainter {
  const _FamilyThreadPainter({required this.points});

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x5583572F)
        ..strokeWidth = 13
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF7D77D)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _FamilyThreadPainter oldDelegate) =>
      oldDelegate.points != points;
}

Future<FamilyMember?> showFamilyThreadChooser(
  BuildContext context,
  List<FamilyMember> people,
) {
  HapticFeedback.selectionClick();
  final family = people.where((m) => !m.isPet).toList();
  return showDialog<FamilyMember>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFFFDF5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF896244), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Follow a Family Thread',
              style: TextStyle(
                color: Color(0xFF3D2D2A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'Only places supported by records that actually name them are connected.',
              style: TextStyle(
                color: Color(0xFF806A5E),
                fontSize: 10,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 9),
            for (final member in family)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Text(
                  member.emoji,
                  style: const TextStyle(fontSize: 23),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  member.relation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.route_rounded),
                onTap: () => Navigator.of(context).pop(member),
              ),
          ],
        ),
      ),
    ),
  );
}

class FamilyThreadButton extends StatelessWidget {
  const FamilyThreadButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xF2FFF8EC),
    elevation: 4,
    borderRadius: BorderRadius.circular(21),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: const SizedBox(
        height: 42,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🧵'),
              SizedBox(width: 5),
              Text(
                'Family thread',
                style: TextStyle(
                  color: Color(0xFF4B3528),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class FamilyThreadBar extends StatelessWidget {
  const FamilyThreadBar({
    super.key,
    required this.member,
    required this.onChange,
    required this.onClose,
  });

  final FamilyMember member;
  final VoidCallback onChange;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFDF5E8),
    elevation: 8,
    borderRadius: BorderRadius.circular(17),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 5, 7),
      child: Row(
        children: [
          Text(member.emoji, style: const TextStyle(fontSize: 23)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${member.name.split(' ').first}’s family thread',
                  style: const TextStyle(
                    color: Color(0xFF3D2D2A),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Tap a glowing stop · every connection comes from a real record',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF806A5E), fontSize: 8),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Change')),
          IconButton(
            tooltip: 'Close family thread',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    ),
  );
}
