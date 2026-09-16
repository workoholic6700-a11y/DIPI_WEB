import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_routes.dart';
import '../../../data/providers/content_providers.dart';

class VillageKindnessTask {
  const VillageKindnessTask({
    required this.id,
    required this.label,
    required this.emoji,
    required this.doneEmoji,
    required this.response,
    required this.fx,
    required this.fy,
    this.route,
  });

  final String id;
  final String label;
  final String emoji;
  final String doneEmoji;
  final String response;
  final double fx;
  final double fy;
  final String? route;
}

const villageKindnessTasks = [
  VillageKindnessTask(
    id: 'water_papa',
    label: 'Give water to Papa',
    emoji: '🥤',
    doneEmoji: '💧',
    response: 'Papa: Thank you, Dipisha. I needed that. 💜',
    fx: 0.185,
    fy: 0.720,
  ),
  VillageKindnessTask(
    id: 'water_flowers',
    label: 'Help Mummy water flowers',
    emoji: '🫗',
    doneEmoji: '✨🌸',
    response: 'Mummy: Look how happy the flowers are!',
    fx: 0.115,
    fy: 0.885,
  ),
  VillageKindnessTask(
    id: 'feed_goats',
    label: 'Feed the goats',
    emoji: '🌾',
    doneEmoji: '🌿',
    response: 'The goats hurry over for their favourite leaves.',
    fx: 0.715,
    fy: 0.875,
  ),
  VillageKindnessTask(
    id: 'call_chickens',
    label: 'Call the chickens home',
    emoji: '🐔',
    doneEmoji: '🏡',
    response: 'The chickens wobble back toward the warm yard.',
    fx: 0.365,
    fy: 0.925,
  ),
  VillageKindnessTask(
    id: 'set_plates',
    label: 'Place plates on the evening mat',
    emoji: '🍽️',
    doneEmoji: '🍽️',
    response: 'Diya: Perfect. Now everybody has a place.',
    fx: 0.352,
    fy: 0.815,
  ),
  VillageKindnessTask(
    id: 'light_lamp',
    label: 'Light the outdoor lamp',
    emoji: '🪔',
    doneEmoji: '🪔',
    response: 'Mummy: That little light makes the whole aagan warm.',
    fx: 0.390,
    fy: 0.795,
  ),
  VillageKindnessTask(
    id: 'open_letter',
    label: 'Open the waiting letter',
    emoji: '💌',
    doneEmoji: '📭',
    response: 'Diksha: This one was waiting especially for you.',
    fx: 0.470,
    fy: 0.650,
    route: Routes.letters,
  ),
  VillageKindnessTask(
    id: 'stubby_flowers',
    label: 'Place flowers near Stubby',
    emoji: '🌼',
    doneEmoji: '🌼',
    response: 'A small flower stays beside Stubby’s paw mark. 💜',
    fx: 0.520,
    fy: 0.810,
  ),
];

class VillageKindnessNotifier extends Notifier<Set<String>> {
  static const _dateKey = 'village_kindness_date';
  static const _doneKey = 'village_kindness_done';

  @override
  Set<String> build() {
    _restore();
    return <String>{};
  }

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_dateKey) == _today) {
      state = prefs.getStringList(_doneKey)?.toSet() ?? <String>{};
    } else {
      await prefs.setString(_dateKey, _today);
      await prefs.setStringList(_doneKey, const []);
    }
  }

  Future<void> complete(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, _today);
    await prefs.setStringList(_doneKey, state.toList());
  }
}

final villageKindnessProvider =
    NotifierProvider<VillageKindnessNotifier, Set<String>>(
      VillageKindnessNotifier.new,
    );

class VillageKindnessLayer extends ConsumerStatefulWidget {
  const VillageKindnessLayer({
    super.key,
    required this.width,
    required this.height,
    required this.active,
    required this.onRoute,
  });

  final double width;
  final double height;
  final bool active;
  final ValueChanged<String> onRoute;

  @override
  ConsumerState<VillageKindnessLayer> createState() =>
      _VillageKindnessLayerState();
}

class _VillageKindnessLayerState extends ConsumerState<VillageKindnessLayer> {
  VillageKindnessTask? _thanks;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _complete(VillageKindnessTask task) async {
    if (task.id == 'open_letter' && ref.read(unopenedLettersProvider).isEmpty) {
      setState(() {
        _thanks = const VillageKindnessTask(
          id: 'letters_safe',
          label: 'Letters are safe',
          emoji: '📭',
          doneEmoji: '📭',
          response: 'Every kept letter has already been opened.',
          fx: 0.470,
          fy: 0.650,
        );
      });
      _hideThanksLater();
      return;
    }
    HapticFeedback.mediumImpact();
    await ref.read(villageKindnessProvider.notifier).complete(task.id);
    if (!mounted) return;
    setState(() => _thanks = task);
    _hideThanksLater();
    if (task.id == 'open_letter') {
      final letters = ref.read(unopenedLettersProvider);
      if (letters.isNotEmpty) widget.onRoute(Routes.letterOf(letters.first.id));
    } else if (task.route != null) {
      widget.onRoute(task.route!);
    }
  }

  void _hideThanksLater() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _thanks = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = ref.watch(villageKindnessProvider);
    final unopened = ref.watch(unopenedLettersProvider);
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final task in villageKindnessTasks)
            if (completed.contains(task.id)) _completedProp(task),
          if (widget.active)
            for (final task in villageKindnessTasks)
              if (!completed.contains(task.id) &&
                  (task.id != 'open_letter' || unopened.isNotEmpty))
                _taskMarker(task),
          if (_thanks != null) _thankYou(_thanks!),
        ],
      ),
    );
  }

  Widget _taskMarker(VillageKindnessTask task) => Positioned(
    left: widget.width * task.fx - 23,
    top: widget.height * task.fy - 46,
    width: 46,
    height: 46,
    child: Semantics(
      button: true,
      label: task.label,
      child: Material(
        color: const Color(0xF7FFF8E9),
        elevation: 4,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFE2B95E), width: 2),
        ),
        child: InkWell(
          onTap: () => _complete(task),
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(task.emoji, style: const TextStyle(fontSize: 21)),
          ),
        ),
      ),
    ),
  );

  Widget _completedProp(VillageKindnessTask task) => Positioned(
    left: widget.width * task.fx - 18,
    top: widget.height * task.fy - 32,
    child: IgnorePointer(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xB8FFF8E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(task.doneEmoji, style: const TextStyle(fontSize: 19)),
      ),
    ),
  );

  Widget _thankYou(VillageKindnessTask task) {
    const width = 198.0;
    final left = (widget.width * task.fx - width / 2)
        .clamp(8.0, widget.width - width - 8)
        .toDouble();
    final top = (widget.height * task.fy - 118)
        .clamp(8.0, widget.height - 94)
        .toDouble();
    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Semantics(
        liveRegion: true,
        label: task.response,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2B95E), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(
            task.response,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4B3528),
              fontSize: 10.5,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class VillageKindnessButton extends ConsumerWidget {
  const VillageKindnessButton({
    super.key,
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(villageKindnessProvider).length;
    return Semantics(
      button: true,
      toggled: active,
      label:
          'Family kindness activities. $done of ${villageKindnessTasks.length} complete today.',
      child: Material(
        color: active ? const Color(0xFF5D7E52) : const Color(0xF2FFF8EC),
        elevation: 4,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(active ? '💜' : '🧺'),
                const SizedBox(width: 5),
                Text(
                  active
                      ? '$done/${villageKindnessTasks.length} · tap chores'
                      : 'Help today',
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF4B3528),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
