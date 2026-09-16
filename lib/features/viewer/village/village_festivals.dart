import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum VillageFestival {
  auto,
  none,
  tihar,
  dashain,
  sakela,
  birthday,
  anniversary,
}

extension VillageFestivalX on VillageFestival {
  String get label => switch (this) {
    VillageFestival.auto => 'Follow family dates',
    VillageFestival.none => 'Everyday village',
    VillageFestival.tihar => 'Tihar lights',
    VillageFestival.dashain => 'Dashain courtyard',
    VillageFestival.sakela => 'Sakela gathering',
    VillageFestival.birthday => 'Birthday at the Hall',
    VillageFestival.anniversary => 'Memory anniversary',
  };

  String get emoji => switch (this) {
    VillageFestival.auto => '📅',
    VillageFestival.none => '🏡',
    VillageFestival.tihar => '🪔',
    VillageFestival.dashain => '🌾',
    VillageFestival.sakela => '🌿',
    VillageFestival.birthday => '🎂',
    VillageFestival.anniversary => '🌸',
  };
}

VillageFestival resolveVillageFestival({
  required VillageFestival selected,
  required DateTime now,
  required Iterable<DateTime> birthdays,
  required Iterable<DateTime> memories,
}) {
  if (selected != VillageFestival.auto) return selected;
  final birthday = birthdays.any(
    (date) => date.month == now.month && date.day == now.day,
  );
  if (birthday) return VillageFestival.birthday;
  final anniversary = memories.any(
    (date) =>
        date.year < now.year && date.month == now.month && date.day == now.day,
  );
  if (anniversary) return VillageFestival.anniversary;
  // Dashain, Tihar and Sakela use moving calendars. Auto mode never guesses.
  return VillageFestival.none;
}

class VillageFestivalLayer extends StatelessWidget {
  const VillageFestivalLayer({
    super.key,
    required this.width,
    required this.height,
    required this.festival,
    required this.personName,
    required this.personEmoji,
    required this.memoryTitle,
  });

  final double width;
  final double height;
  final VillageFestival festival;
  final String personName;
  final String personEmoji;
  final String memoryTitle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: switch (festival) {
          VillageFestival.tihar => _tihar(),
          VillageFestival.dashain => _dashain(),
          VillageFestival.sakela => _sakela(),
          VillageFestival.birthday => _birthday(),
          VillageFestival.anniversary => _anniversary(),
          _ => const <Widget>[],
        },
      ),
    );
  }

  List<Widget> _tihar() => [
    for (final fx in const [0.275, 0.295, 0.315, 0.335, 0.355, 0.375])
      _emoji(fx, 0.790, '🪔', 16),
    for (final fx in const [0.705, 0.725, 0.745, 0.765, 0.785])
      _emoji(fx, 0.685, '🪔', 15),
    _emoji(0.350, 0.842, '🌸', 25),
    _emoji(0.365, 0.842, '🌼', 21),
    _banner(0.330, 0.468, 'Tihar · the village is lit'),
  ];

  List<Widget> _dashain() => [
    Positioned(
      left: width * 0.645,
      top: height * 0.645,
      width: 132,
      height: 150,
      child: const CustomPaint(painter: _BambooSwingPainter()),
    ),
    _emoji(0.335, 0.820, '🌾', 27),
    _emoji(0.358, 0.825, '🔴', 13),
    _banner(0.330, 0.468, 'Dashain · blessings in the aagan'),
  ];

  List<Widget> _sakela() => [
    for (var i = 0; i < 9; i++)
      _emoji(
        0.525 + math.cos(i * math.pi * 2 / 9) * 0.046,
        0.580 + math.sin(i * math.pi * 2 / 9) * 0.034,
        i.isEven ? '🕺' : '💃',
        20,
      ),
    _emoji(0.525, 0.565, '🥁', 25),
    _banner(0.525, 0.438, 'Sakela · the circle gathers'),
  ];

  List<Widget> _birthday() => [
    Positioned(
      left: width * 0.675,
      top: height * 0.505,
      width: 290,
      height: 92,
      child: const CustomPaint(painter: _BuntingPainter()),
    ),
    _emoji(0.740, 0.710, '🎂', 31),
    _portraitNote(
      0.740,
      0.485,
      '$personEmoji $personName',
      'The Celebration Hall is ready',
    ),
  ];

  List<Widget> _anniversary() => [
    _emoji(0.090, 0.555, '🎀', 22),
    _emoji(0.125, 0.570, '🌸', 24),
    _portraitNote(0.125, 0.455, 'On this day', memoryTitle),
  ];

  Widget _emoji(double fx, double fy, String emoji, double size) => Positioned(
    left: width * fx - size / 2,
    top: height * fy - size,
    child: Text(emoji, style: TextStyle(fontSize: size)),
  );

  // A painted wooden board on a post, matching the welcome sign at the top of
  // the village. A flat plate laid over the hillside read as a poster stuck to
  // a wall — a sign needs a post under it and a shadow beneath it to stand in
  // the ground like everything else here does.
  Widget _banner(double fx, double fy, String text) => Positioned(
    left: width * fx - 58,
    top: height * fy,
    width: 116,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC9915F), Color(0xFF8A5A3C)],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF5E3B26), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFF7EA),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(width: 5, height: 15, color: const Color(0xFF5E3B26)),
      ],
    ),
  );

  Widget _portraitNote(double fx, double fy, String title, String subtitle) =>
      Positioned(
        left: width * fx - 78,
        top: height * fy,
        width: 156,
        child: Transform.rotate(
          angle: -0.025,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF4),
              border: Border.all(color: const Color(0xFFD7BA88)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4B3528),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF806A5E), fontSize: 8),
                ),
              ],
            ),
          ),
        ),
      );
}

class _BambooSwingPainter extends CustomPainter {
  const _BambooSwingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bamboo = Paint()
      ..color = const Color(0xFF6E8A3D)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(15, size.height), Offset(47, 8), bamboo);
    canvas.drawLine(
      Offset(size.width - 15, size.height),
      Offset(size.width - 47, 8),
      bamboo,
    );
    canvas.drawLine(const Offset(45, 9), Offset(size.width - 45, 9), bamboo);
    final rope = Paint()
      ..color = const Color(0xFF8C6947)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2 - 18, 10),
      Offset(size.width / 2 - 18, 96),
      rope,
    );
    canvas.drawLine(
      Offset(size.width / 2 + 18, 10),
      Offset(size.width / 2 + 18, 96),
      rope,
    );
    canvas.drawLine(
      Offset(size.width / 2 - 24, 98),
      Offset(size.width / 2 + 24, 98),
      Paint()
        ..color = const Color(0xFF80522E)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BuntingPainter extends CustomPainter {
  const _BuntingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFF6D4A37)
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(5, 17), Offset(size.width - 5, 28), line);
    const colors = [
      Color(0xFFE8749E),
      Color(0xFFF2C879),
      Color(0xFF7FB8E6),
      Color(0xFF7EA56E),
    ];
    for (var i = 0; i < 12; i++) {
      final x = 10.0 + i * (size.width - 20) / 11;
      final y = 17 + i * 11 / 11;
      final path = Path()
        ..moveTo(x - 7, y)
        ..lineTo(x + 7, y)
        ..lineTo(x, y + 18)
        ..close();
      canvas.drawPath(path, Paint()..color = colors[i % colors.length]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<VillageFestival?> showVillageFestivalChooser(
  BuildContext context,
  VillageFestival selected,
) {
  HapticFeedback.selectionClick();
  return showDialog<VillageFestival>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFFFDF5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF896244), width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dress the Village',
                style: TextStyle(
                  color: Color(0xFF3D2D2A),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Preview moving-calendar festivals manually. Auto mode only uses confirmed family dates.',
                style: TextStyle(
                  color: Color(0xFF806A5E),
                  fontSize: 10.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final festival in VillageFestival.values)
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          leading: Text(
                            festival.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            festival.label,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          trailing: selected == festival
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF5D7E52),
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(festival),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class VillageFestivalButton extends StatelessWidget {
  const VillageFestivalButton({
    super.key,
    required this.festival,
    required this.onTap,
  });

  final VillageFestival festival;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Festival preview: ${festival.label}',
      child: Material(
        color: const Color(0xF2FFF8EC),
        elevation: 4,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(festival.emoji),
                const SizedBox(width: 5),
                const Text(
                  'Festival',
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
}
