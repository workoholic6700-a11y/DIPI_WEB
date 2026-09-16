import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'family_diorama.dart';
import 'day_night.dart';

/// Dipisha and the pets in the family yard.
///
/// The previous version ran a full-time random movement simulation. On a small
/// phone that meant the entire village could stay busy even when nobody was
/// touching it. These figures are calm instead: tap one for a single reaction,
/// and only the selected name/reaction is shown.
class YardLife extends StatefulWidget {
  const YardLife({
    super.key,
    required this.width,
    required this.height,
    required this.phase,
    required this.motion,
  });

  final double width;
  final double height;
  final VillagePhase phase;
  final Animation<double> motion;

  @override
  State<YardLife> createState() => _YardLifeState();
}

enum _YardFriend { dipisha, arjun, meow }

class _YardLifeState extends State<YardLife> {
  _YardFriend? _selected;

  void _select(_YardFriend friend) {
    setState(() => _selected = _selected == friend ? null : friend);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _friend(
              friend: _YardFriend.arjun,
              left: widget.width * 0.16,
              bottom: widget.height * 0.08,
            ),
            _friend(
              friend: _YardFriend.dipisha,
              left: widget.width * 0.43,
              bottom: widget.height * 0.06,
            ),
            _friend(
              friend: _YardFriend.meow,
              left: widget.width * 0.72,
              bottom: widget.height * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _friend({
    required _YardFriend friend,
    required double left,
    required double bottom,
  }) {
    final selected = _selected == friend;
    final (name, dayReaction, figure, width) = switch (friend) {
      _YardFriend.dipisha => (
        'Dipisha',
        '👋',
        const PersonBody(
          kind: PersonKind.girl,
          cloth: Color(0xFFF4A9C7),
          size: 46,
        ),
        58.0,
      ),
      _YardFriend.arjun => (
        'Arjun',
        '❤️',
        const PetBody(kind: PetKind.dog, color: Color(0xFFE6C9A0), size: 32),
        58.0,
      ),
      _YardFriend.meow => (
        'Meow',
        '😸',
        const PetBody(kind: PetKind.cat, color: Color(0xFFE79A45), size: 29),
        54.0,
      ),
    };
    final reaction = switch (widget.phase) {
      VillagePhase.dawn => friend == _YardFriend.dipisha ? '🥱' : '🌄',
      VillagePhase.day => dayReaction,
      VillagePhase.dusk => friend == _YardFriend.dipisha ? '🍽️' : '🏡',
      VillagePhase.night => '💤',
    };

    return Positioned(
      left: left - width / 2,
      bottom: bottom,
      width: width,
      child: Semantics(
        button: true,
        selected: selected,
        label: selected
            ? '$name is saying hello. Tap to close the reaction.'
            : '$name in the family yard. Tap for a reaction.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _select(friend),
          child: AnimatedBuilder(
            animation: widget.motion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? Container(
                            key: ValueKey(friend),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              reaction,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )
                        : const SizedBox(key: ValueKey('quiet'), height: 18),
                  ),
                  figure,
                  const SizedBox(height: 1),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: NameTag(name),
                  ),
                ],
              ),
            ),
            builder: (context, child) {
              final angle =
                  widget.motion.value * math.pi * 8 + friend.index * 1.9;
              return Transform.translate(
                offset: Offset(
                  math.sin(angle * 0.5) * 0.8,
                  -math.sin(angle) * 1.6,
                ),
                child: Transform.rotate(
                  angle: math.sin(angle * 0.5) * 0.012,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
