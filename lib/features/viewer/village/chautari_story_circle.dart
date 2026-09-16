import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/router/app_routes.dart';
import '../../../data/models/heritage_models.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../data/providers/heritage_providers.dart';

class _ArchivePiece {
  const _ArchivePiece({
    required this.emoji,
    required this.label,
    required this.title,
    required this.body,
    required this.route,
    this.audio,
  });

  final String emoji;
  final String label;
  final String title;
  final String body;
  final String route;
  final String? audio;
}

/// The existing chautari becomes a doorway into real elder records. Matching
/// is deliberately text-based and conservative: if the archive does not name
/// an elder, the card shows an honest question-to-ask instead of inventing a
/// connection.
class ChautariStoryCircle extends ConsumerStatefulWidget {
  const ChautariStoryCircle({
    super.key,
    required this.width,
    required this.height,
    required this.enabled,
    required this.onOpenChanged,
    required this.onRoute,
  });

  final double width;
  final double height;
  final bool enabled;
  final ValueChanged<bool> onOpenChanged;
  final ValueChanged<String> onRoute;

  @override
  ConsumerState<ChautariStoryCircle> createState() =>
      _ChautariStoryCircleState();
}

class _ChautariStoryCircleState extends ConsumerState<ChautariStoryCircle> {
  bool _open = false;
  String? _selectedId;

  @override
  void didUpdateWidget(covariant ChautariStoryCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled && _open) _open = false;
  }

  void _show() {
    HapticFeedback.lightImpact();
    setState(() => _open = true);
    widget.onOpenChanged(true);
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    widget.onOpenChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled && !_open) return const SizedBox.expand();
    final elders = ref
        .watch(familyProvider)
        .where(
          (m) =>
              m.generation == Generation.grandparents ||
              m.generation == Generation.parents,
        )
        .toList();
    if (elders.isEmpty) return const SizedBox.expand();
    final selected = elders.firstWhere(
      (m) => m.id == _selectedId,
      orElse: () => elders.first,
    );

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!_open) _marker(),
          if (_open) _storyCard(elders, selected),
        ],
      ),
    );
  }

  Widget _marker() => Positioned(
    left: widget.width * 0.610 - 68,
    top: widget.height * 0.665 - 20,
    width: 136,
    height: 40,
    child: Semantics(
      button: true,
      label: 'Open the Chautari Story Circle',
      child: Material(
        color: const Color(0xF4F8EED8),
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _show,
          borderRadius: BorderRadius.circular(20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌳', style: TextStyle(fontSize: 17)),
              SizedBox(width: 5),
              Text(
                'Story Circle',
                style: TextStyle(
                  color: Color(0xFF4B4630),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _storyCard(List<FamilyMember> elders, FamilyMember selected) {
    final piece = _pieceFor(selected);
    return Positioned(
      left: widget.width * 0.610 - 142,
      top: widget.height * 0.455,
      width: 284,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 292),
          decoration: BoxDecoration(
            color: const Color(0xFFF8EED8),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFF795A38), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 12,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(11, 7, 5, 5),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C7749),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    const Text('🌳', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHAUTARI STORY CIRCLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Only records already kept by the family',
                            style: TextStyle(
                              color: Color(0xFFDDE6CB),
                              fontSize: 7.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Close Story Circle',
                      onPressed: _close,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(11, 8, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final elder in elders)
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                  selected: elder.id == selected.id,
                                  onSelected: (_) =>
                                      setState(() => _selectedId = elder.id),
                                  avatar: Text(elder.emoji),
                                  label: Text(
                                    _firstName(elder),
                                    style: const TextStyle(fontSize: 8.5),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${selected.emoji} ${selected.name}',
                        style: const TextStyle(
                          color: Color(0xFF3D2D2A),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        selected.bio,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF705F55),
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Divider(height: 1),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            piece.emoji,
                            style: const TextStyle(fontSize: 23),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  piece.label.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF8A6B4B),
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  piece.title,
                                  style: const TextStyle(
                                    color: Color(0xFF3D2D2A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  piece.body,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF705F55),
                                    fontSize: 8.5,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ArchiveVoiceButton(
                            audio: piece.audio,
                            speaker: _firstName(selected),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            _close();
                            widget.onRoute(piece.route);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6C7749),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 14),
                          label: const Text(
                            'Open this family record',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ArchivePiece _pieceFor(FamilyMember member) {
    final aliases = _aliases(member);
    bool matches(String? text) {
      final lower = text?.toLowerCase() ?? '';
      return aliases.any(lower.contains);
    }

    final words = ref.watch(heritageWordsProvider);
    for (final word in words) {
      if (matches(word.saidBy) || matches(word.note)) {
        return _ArchivePiece(
          emoji: word.kind.emoji,
          label: 'A word connected in the archive',
          title: '${word.word} · ${word.roman}',
          body: word.meaning,
          route: Routes.heritageWords,
          audio: word.audio,
        );
      }
    }

    for (final recipe in ref.watch(recipesProvider)) {
      if (matches(recipe.taughtBy) ||
          matches(recipe.learnedFrom) ||
          matches(recipe.story)) {
        return _ArchivePiece(
          emoji: recipe.emoji,
          label: 'A family recipe connection',
          title: recipe.name,
          body: recipe.story,
          route: Routes.heritageRecipes,
        );
      }
    }

    for (final memory in ref.watch(memoriesProvider)) {
      if (matches(memory.title) || matches(memory.description)) {
        return _ArchivePiece(
          emoji: '💗',
          label: 'A memory that names them',
          title: memory.title,
          body: memory.description,
          route: Routes.memoryOf(memory.id),
        );
      }
    }

    for (final root in ref.watch(rootsProvider)) {
      if (matches(root.who) || matches(root.story)) {
        return _ArchivePiece(
          emoji: root.emoji,
          label: 'A place that names them',
          title: root.place,
          body: root.story,
          route: Routes.heritageRoots,
        );
      }
    }

    final missing = ref
        .watch(toCollectProvider)
        .where((item) => matches(item.askWho))
        .firstOrNull;
    if (missing != null) {
      return _ArchivePiece(
        emoji: '📝',
        label: 'A story still to ask',
        title: missing.what,
        body:
            'Ask ${missing.askWho}. ${missing.why ?? 'This has not been recorded yet.'}',
        route: Routes.heritage,
      );
    }

    return _ArchivePiece(
      emoji: '🌱',
      label: 'An honest space in the archive',
      title: 'Their voice is still to be collected',
      body:
          'The app does not yet hold a story or recording that names ${_firstName(member)}.',
      route: Routes.memberOf(member.id),
    );
  }

  Set<String> _aliases(FamilyMember member) {
    final aliases = <String>{_firstName(member).toLowerCase()};
    if (member.id == 'f_grandpa') aliases.addAll(['kopa', 'grandpa']);
    if (member.id == 'f_father') aliases.addAll(['papa', 'father']);
    if (member.id == 'f_mother') aliases.addAll(['mummy', 'mother']);
    return aliases;
  }

  String _firstName(FamilyMember member) => member.name.split(' ').first;
}

class _ArchiveVoiceButton extends StatefulWidget {
  const _ArchiveVoiceButton({required this.audio, required this.speaker});

  final String? audio;
  final String speaker;

  @override
  State<_ArchiveVoiceButton> createState() => _ArchiveVoiceButtonState();
}

class _ArchiveVoiceButtonState extends State<_ArchiveVoiceButton> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _play() async {
    final audio = widget.audio;
    if (audio == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${widget.speaker}’s recording has not been collected yet.',
            ),
          ),
        );
      return;
    }
    try {
      setState(() => _playing = true);
      await _player.setAsset(audio);
      await _player.play();
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.audio == null
          ? 'No recording yet'
          : 'Play ${widget.speaker}’s voice',
      visualDensity: VisualDensity.compact,
      onPressed: _play,
      icon: Icon(
        _playing
            ? Icons.graphic_eq_rounded
            : widget.audio == null
            ? Icons.mic_none_rounded
            : Icons.volume_up_rounded,
        size: 18,
        color: widget.audio == null
            ? const Color(0xFFAA9A91)
            : const Color(0xFF6C7749),
      ),
    );
  }
}
