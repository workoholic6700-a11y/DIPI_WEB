import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'day_night.dart';
import 'village_season.dart';

/// A playful line performed inside the illustrated Village.
///
/// These are deliberately kept separate from archived family quotes: they are
/// small fictional scenes that make the characters feel present, not claims
/// that a family member said these exact words in real life.
class VillageConversationLine {
  const VillageConversationLine({
    required this.speaker,
    required this.text,
    required this.fx,
    required this.fy,
    required this.color,
    this.audio,
  });

  final String speaker;
  final String text;
  final double fx;
  final double fy;
  final Color color;
  final String? audio;
}

class VillageConversation {
  const VillageConversation({
    required this.title,
    required this.prompt,
    required this.fx,
    required this.fy,
    required this.lines,
  });

  final String title;
  final String prompt;
  final double fx;
  final double fy;
  final List<VillageConversationLine> lines;
}

const villageConversations = [
  VillageConversation(
    title: 'A water break',
    prompt: 'Mummy & Papa',
    fx: 0.145,
    fy: 0.685,
    lines: [
      VillageConversationLine(
        speaker: 'Mummy',
        text: 'Take a little water break.',
        fx: 0.105,
        fy: 0.754,
        color: Color(0xFFE8749E),
      ),
      VillageConversationLine(
        speaker: 'Papa',
        text: 'After this row. The seedlings are nearly settled.',
        fx: 0.185,
        fy: 0.756,
        color: Color(0xFFC0453E),
      ),
      VillageConversationLine(
        speaker: 'Mummy',
        text: 'The field can wait one minute. Drink first.',
        fx: 0.105,
        fy: 0.754,
        color: Color(0xFFE8749E),
      ),
      VillageConversationLine(
        speaker: 'Papa',
        text: 'You always remember before I do. Thank you.',
        fx: 0.185,
        fy: 0.756,
        color: Color(0xFFC0453E),
      ),
    ],
  ),
  VillageConversation(
    title: 'The youngest teacher',
    prompt: 'The three sisters',
    fx: 0.355,
    fy: 0.755,
    lines: [
      VillageConversationLine(
        speaker: 'Diksha',
        text: 'Dipisha, what did you learn today?',
        fx: 0.276,
        fy: 0.846,
        color: Color(0xFF9B72CF),
      ),
      VillageConversationLine(
        speaker: 'Dipisha',
        text: 'A new word! Can I teach both of you?',
        fx: 0.432,
        fy: 0.792,
        color: Color(0xFFF4A9C7),
      ),
      VillageConversationLine(
        speaker: 'Diya',
        text: 'Yes — but Diksha didi has to answer first.',
        fx: 0.360,
        fy: 0.842,
        color: Color(0xFFF2C879),
      ),
      VillageConversationLine(
        speaker: 'Diksha',
        text: 'Deal. Our youngest teacher goes first.',
        fx: 0.276,
        fy: 0.846,
        color: Color(0xFF9B72CF),
      ),
    ],
  ),
];

class _CharacterSpot {
  const _CharacterSpot(this.name, this.fx, this.fy, this.color);

  final String name;
  final double fx;
  final double fy;
  final Color color;
}

class _CharacterReaction {
  const _CharacterReaction({
    required this.speaker,
    required this.text,
    required this.fx,
    required this.fy,
    required this.color,
  });

  final String speaker;
  final String text;
  final double fx;
  final double fy;
  final Color color;
}

/// Two small, tap-to-start family scenes laid directly over the characters.
/// Only one short timer exists while a scene is active; there are no permanent
/// animation controllers or walking simulations.
class VillageFamilyMoments extends StatefulWidget {
  const VillageFamilyMoments({
    super.key,
    required this.width,
    required this.height,
    required this.enabled,
    required this.conversationsEnabled,
    required this.phase,
    required this.season,
  });

  final double width;
  final double height;
  final bool enabled;
  final bool conversationsEnabled;
  final VillagePhase phase;
  final VillageSeason season;

  @override
  State<VillageFamilyMoments> createState() => _VillageFamilyMomentsState();
}

class _VillageFamilyMomentsState extends State<VillageFamilyMoments> {
  final AudioPlayer _voicePlayer = AudioPlayer();
  int? _activeConversation;
  int _line = 0;
  Timer? _timer;
  StreamSubscription<PlayerState>? _voiceState;
  bool _voicePlaying = false;
  _CharacterReaction? _reaction;
  Timer? _reactionTimer;
  final Map<String, int> _reactionIndex = {};

  @override
  void initState() {
    super.initState();
    _voiceState = _voicePlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing =
          state.playing && state.processingState != ProcessingState.completed;
      if (_voicePlaying != playing) setState(() => _voicePlaying = playing);
      if (state.processingState == ProcessingState.completed &&
          _activeConversation != null) {
        _scheduleNext();
      }
    });
  }

  @override
  void didUpdateWidget(covariant VillageFamilyMoments oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) _close();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reactionTimer?.cancel();
    _voiceState?.cancel();
    unawaited(_voicePlayer.dispose());
    super.dispose();
  }

  void _start(int index) {
    _timer?.cancel();
    _reactionTimer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _activeConversation = index;
      _line = 0;
      _reaction = null;
    });
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 3800), _next);
  }

  void _next() {
    if (!mounted || _activeConversation == null) return;
    final conversation = villageConversations[_activeConversation!];
    if (_line == conversation.lines.length - 1) {
      _close();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _line++);
    _scheduleNext();
  }

  void _close() {
    _timer?.cancel();
    _reactionTimer?.cancel();
    _timer = null;
    unawaited(_voicePlayer.stop());
    if (!mounted || (_activeConversation == null && _reaction == null)) return;
    setState(() {
      _activeConversation = null;
      _line = 0;
      _reaction = null;
    });
  }

  void _showReaction(_CharacterSpot spot) {
    _timer?.cancel();
    _reactionTimer?.cancel();
    final lines = _reactionLines(spot.name);
    final index = _reactionIndex[spot.name] ?? 0;
    _reactionIndex[spot.name] = index + 1;
    HapticFeedback.lightImpact();
    setState(() {
      _activeConversation = null;
      _reaction = _CharacterReaction(
        speaker: spot.name,
        text: lines[index % lines.length],
        fx: spot.fx,
        fy: spot.fy,
        color: spot.color,
      );
    });
    _reactionTimer = Timer(const Duration(milliseconds: 3200), _close);
  }

  List<String> _reactionLines(String name) {
    if (widget.season == VillageSeason.monsoon) {
      return switch (name) {
        'Mummy' => const [
          'The rain is good for the garden. Keep your feet warm.',
          'Listen — the roof has its own monsoon song.',
        ],
        'Papa' => const [
          'The field drinks before any of us do.',
          'We will work again when the rain softens.',
        ],
        'Dipisha' => const [
          'Can I make one more puddle ripple?',
          'My umbrella needs a name!',
        ],
        _ => const [
          'A rainy day is a good day for stories.',
          'Let us keep the books away from the window.',
        ],
      };
    }
    return switch (widget.phase) {
      VillagePhase.dawn => switch (name) {
        'Mummy' => const [
          'The chulo is warm now.',
          'Morning begins before the sun reaches the yard.',
        ],
        'Papa' => const [
          'The field looks ready for us.',
          'One basket, then we can begin.',
        ],
        'Dipisha' => const ['Five more minutes… 🥱', 'Is breakfast ready?'],
        _ => const ['The village is only just waking up.'],
      },
      VillagePhase.day => switch (name) {
        'Mummy' => const [
          'The flowers need only a little water.',
          'I can hear Dipisha laughing from here.',
        ],
        'Papa' => const [
          'This row is nearly finished.',
          'A water break sounds good now.',
        ],
        'Diksha' => const [
          'Dipisha, save this story for me.',
          'One more page, then we can talk.',
        ],
        'Diya' => const [
          'I am definitely not copying Diksha’s answer.',
          'Dipisha should be the teacher today.',
        ],
        'Dipisha' => const [
          'Come play after your chapter!',
          'I learned something new today.',
        ],
        _ => const ['It is a busy day in the village.'],
      },
      VillagePhase.dusk => switch (name) {
        'Mummy' => const ['Let us set the evening mat.', 'Everybody is home.'],
        'Papa' => const ['The field can rest now.', 'Tea first, stories next.'],
        'Diksha' => const ['I brought a story for after dinner.'],
        'Diya' => const ['I will bring the plates.'],
        'Dipisha' => const ['Can we all sit outside tonight?'],
        _ => const ['The family is gathering in the aagan.'],
      },
      VillagePhase.night => switch (name) {
        'Dipisha' => const [
          'Good night, didis. 💜',
          'The lamps look like stars.',
        ],
        _ => const ['The house is resting now.'],
      },
    };
  }

  List<_CharacterSpot> _characterSpots() => switch (widget.phase) {
    VillagePhase.dawn => const [
      _CharacterSpot('Papa', 0.205, 0.756, Color(0xFFC0453E)),
      _CharacterSpot('Mummy', 0.345, 0.842, Color(0xFFE8749E)),
      _CharacterSpot('Dipisha', 0.432, 0.792, Color(0xFFF4A9C7)),
    ],
    VillagePhase.day => const [
      _CharacterSpot('Mummy', 0.105, 0.754, Color(0xFFE8749E)),
      _CharacterSpot('Papa', 0.185, 0.756, Color(0xFFC0453E)),
      _CharacterSpot('Diksha', 0.276, 0.846, Color(0xFF9B72CF)),
      _CharacterSpot('Diya', 0.360, 0.842, Color(0xFFF2C879)),
      _CharacterSpot('Dipisha', 0.432, 0.792, Color(0xFFF4A9C7)),
    ],
    VillagePhase.dusk => const [
      _CharacterSpot('Mummy', 0.292, 0.840, Color(0xFFE8749E)),
      _CharacterSpot('Papa', 0.325, 0.841, Color(0xFFC0453E)),
      _CharacterSpot('Diksha', 0.362, 0.842, Color(0xFF9B72CF)),
      _CharacterSpot('Diya', 0.397, 0.842, Color(0xFFF2C879)),
      _CharacterSpot('Dipisha', 0.432, 0.792, Color(0xFFF4A9C7)),
    ],
    VillagePhase.night => const [
      _CharacterSpot('Dipisha', 0.432, 0.792, Color(0xFFF4A9C7)),
    ],
  };

  Future<void> _playVoice(VillageConversationLine line) async {
    final audio = line.audio;
    if (audio == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${line.speaker}’s real voice has not been recorded yet.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }
    _timer?.cancel();
    try {
      await _voicePlayer.stop();
      await _voicePlayer.setAsset(audio);
      await _voicePlayer.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This recording could not be played.')),
      );
      _scheduleNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.expand();
    final active = _activeConversation;
    final reaction = _reaction;
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (active == null && reaction == null)
            for (final spot in _characterSpots()) _reactionTarget(spot),
          if (active == null && reaction == null && widget.conversationsEnabled)
            for (final entry in villageConversations.indexed)
              _starter(entry.$1, entry.$2)
          else if (active != null)
            _bubble(villageConversations[active]),
          if (reaction != null) _reactionBubble(reaction),
        ],
      ),
    );
  }

  Widget _reactionTarget(_CharacterSpot spot) => Positioned(
    left: widget.width * spot.fx - 27,
    top: widget.height * spot.fy - 67,
    width: 54,
    height: 67,
    child: Semantics(
      button: true,
      label: 'Tap ${spot.name} for a playful Village reaction',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showReaction(spot),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: spot.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 3),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _reactionBubble(_CharacterReaction reaction) {
    const bubbleWidth = 184.0;
    final left = (widget.width * reaction.fx - bubbleWidth / 2)
        .clamp(8.0, widget.width - bubbleWidth - 8)
        .toDouble();
    final top = (widget.height * reaction.fy - 140)
        .clamp(8.0, widget.height - 150)
        .toDouble();
    return Positioned(
      left: left,
      top: top,
      width: bubbleWidth,
      child: Semantics(
        liveRegion: true,
        button: true,
        label: '${reaction.speaker} says ${reaction.text}. Tap to close.',
        child: GestureDetector(
          onTap: _close,
          child: _FamilyBubble(
            conversationTitle: 'Playful Village reaction',
            line: VillageConversationLine(
              speaker: reaction.speaker,
              text: reaction.text,
              fx: reaction.fx,
              fy: reaction.fy,
              color: reaction.color,
            ),
            progress: '•',
            last: true,
            hasVoice: false,
            voicePlaying: false,
            onVoiceTap: () => _playVoice(
              VillageConversationLine(
                speaker: reaction.speaker,
                text: reaction.text,
                fx: reaction.fx,
                fy: reaction.fy,
                color: reaction.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _starter(int index, VillageConversation conversation) {
    return Positioned(
      left: widget.width * conversation.fx - 61,
      top: widget.height * conversation.fy - 19,
      width: 122,
      height: 38,
      child: Semantics(
        button: true,
        label:
            'Playful village scene: ${conversation.title}. ${conversation.prompt}.',
        child: Material(
          color: const Color(0xF5FFF7E9),
          elevation: 3,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
            onTap: () => _start(index),
            borderRadius: BorderRadius.circular(19),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.forum_rounded,
                    size: 15,
                    color: Color(0xFF6B4935),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      conversation.prompt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4B3528),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
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

  Widget _bubble(VillageConversation conversation) {
    final line = conversation.lines[_line];
    const bubbleWidth = 184.0;
    final left = (widget.width * line.fx - bubbleWidth / 2)
        .clamp(8.0, widget.width - bubbleWidth - 8)
        .toDouble();
    final top = (widget.height * line.fy - 142)
        .clamp(8.0, widget.height - 150)
        .toDouble();
    final last = _line == conversation.lines.length - 1;

    return Positioned(
      left: left,
      top: top,
      width: bubbleWidth,
      child: Semantics(
        liveRegion: true,
        button: true,
        label:
            '${line.speaker} says: ${line.text}. Tap to ${last ? 'finish' : 'continue'}.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          onLongPress: _close,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: _FamilyBubble(
              key: ValueKey('${conversation.title}-$_line'),
              conversationTitle: conversation.title,
              line: line,
              progress: '${_line + 1}/${conversation.lines.length}',
              last: last,
              hasVoice: line.audio != null,
              voicePlaying: _voicePlaying,
              onVoiceTap: () => _playVoice(line),
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyBubble extends StatelessWidget {
  const _FamilyBubble({
    super.key,
    required this.conversationTitle,
    required this.line,
    required this.progress,
    required this.last,
    required this.hasVoice,
    required this.voicePlaying,
    required this.onVoiceTap,
  });

  final String conversationTitle;
  final VillageConversationLine line;
  final String progress;
  final bool last;
  final bool hasVoice;
  final bool voicePlaying;
  final VoidCallback onVoiceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line.color, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x35000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: line.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      line.speaker,
                      style: const TextStyle(
                        color: Color(0xFF3D2D2A),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    progress,
                    style: const TextStyle(
                      color: Color(0xFF89766B),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Tooltip(
                    message: hasVoice
                        ? 'Play ${line.speaker}’s voice'
                        : '${line.speaker}’s voice is not recorded yet',
                    child: InkResponse(
                      onTap: onVoiceTap,
                      radius: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          voicePlaying
                              ? Icons.graphic_eq_rounded
                              : hasVoice
                              ? Icons.volume_up_rounded
                              : Icons.mic_none_rounded,
                          color: hasVoice
                              ? line.color
                              : const Color(0xFFAA9A91),
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                line.text,
                style: const TextStyle(
                  color: Color(0xFF4B3B35),
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${last ? 'Tap to finish' : 'Tap for next'} · playful village scene',
                style: const TextStyle(color: Color(0xFF9A8174), fontSize: 7.5),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(17, 9),
          painter: _ConversationTail(color: line.color),
        ),
      ],
    );
  }
}

class _ConversationTail extends CustomPainter {
  const _ConversationTail({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(1, 0)
      ..lineTo(size.width - 1, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFFCF7));
    canvas.drawLine(
      const Offset(1, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(size.width - 1, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ConversationTail oldDelegate) =>
      oldDelegate.color != color;
}
