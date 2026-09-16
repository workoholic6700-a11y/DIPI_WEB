import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/utils/date_x.dart';
import '../../../core/utils/nepali_date.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/people.dart';
import '../../../shared/widgets/section_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AMBIENCE STATE
// ─────────────────────────────────────────────────────────────────────────────

enum DogMood { idle, sniffing, tailWag }

@immutable
class HallAmbience {
  final double glow;
  final DogMood dog;
  final bool toasting;

  const HallAmbience({
    this.glow = 0.5,
    this.dog = DogMood.idle,
    this.toasting = false,
  });

  HallAmbience copyWith({double? glow, DogMood? dog, bool? toasting}) =>
      HallAmbience(
        glow: glow ?? this.glow,
        dog: dog ?? this.dog,
        toasting: toasting ?? this.toasting,
      );
}

class HallAmbienceNotifier extends Notifier<HallAmbience> {
  @override
  HallAmbience build() => const HallAmbience();

  void set(HallAmbience next) => state = next;
}

final hallAmbienceProvider =
    NotifierProvider<HallAmbienceNotifier, HallAmbience>(
  HallAmbienceNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CelebrationHallScreen extends ConsumerWidget {
  const CelebrationHallScreen({super.key});

  static const _hall = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF241B18),
      Color(0xFF38241D),
      Color(0xFF513329),
      Color(0xFF654236),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);

    final members = MockData.family.where((m) => !m.isPet).toList();

    const order = [
      'f_grandpa',
      'f_father',
      'f_mother',
      'f_diksha',
      'f_diya',
      'f_dipisha',
    ];

    members.sort(
      (a, b) => order.indexOf(a.id).compareTo(order.indexOf(b.id)),
    );

    final dated = MockData.confirmedBirthdays.entries
        .map(
          (e) => (
            m: members.firstWhere((m) => m.id == e.key),
            d: e.value,
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.d
            .daysUntilNextAnniversary()
            .compareTo(b.d.daysUntilNextAnniversary()),
      );

    final next = dated.isEmpty ? null : dated.first;

    return SectionScaffold(
      title: 'Celebration Hall',
      subtitle: 'The long table · हाम्रो भोज',
      emoji: '🎂',
      gradient: _hall,
      onDark: true,
      particles: false,
      padding: const EdgeInsets.only(bottom: 48),
      child: _HallScene(
        members: members,
        next: next,
        lang: lang,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENE COMPOSER
// ─────────────────────────────────────────────────────────────────────────────

class _HallScene extends ConsumerWidget {
  const _HallScene({
    required this.members,
    required this.next,
    required this.lang,
  });

  final List<FamilyMember> members;
  final ({FamilyMember m, DateTime d})? next;
  final AppLang lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: _AmbientHall()),
            ),
            Column(
              children: [
                const _Entrance(),
                const SizedBox(height: 12),
                const _HallSign(),
                const SizedBox(height: 18),
                const _FoodTable(),
                const SizedBox(height: 18),
                if (next != null)
                  _CelebrationNotice(
                    next: next!,
                    lang: lang,
                  ),
                const SizedBox(height: 26),
                _FamilyTable(
                  members: members,
                  nextId: next?.m.id,
                  lang: lang,
                  width: width,
                ),
                const SizedBox(height: 18),
                const _DogUnderTable(),
                if (members.any(
                  (m) => MockData.isPlaceholderBirthday(m.id),
                )) ...[
                  const SizedBox(height: 24),
                  _Footnote(lang: lang),
                ],
              ],
            ),
            const Positioned.fill(
              child: IgnorePointer(child: _LightOverlay()),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMBIENT HALL
// ─────────────────────────────────────────────────────────────────────────────

class _AmbientHall extends StatefulWidget {
  const _AmbientHall();

  @override
  State<_AmbientHall> createState() => _AmbientHallState();
}

class _AmbientHallState extends State<_AmbientHall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) {
        final pulse = 0.88 + _breath.value * 0.24;
        return CustomPaint(
          painter: _HallAtmospherePainter(glowScale: pulse),
        );
      },
    );
  }
}

class _HallAtmospherePainter extends CustomPainter {
  _HallAtmospherePainter({required this.glowScale});
  final double glowScale;

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF30221D),
          Color(0xFF4A3026),
          Color(0xFF39251F),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, wall);

    final lights = [
      Offset(size.width * .18, 75),
      Offset(size.width * .50, 48),
      Offset(size.width * .82, 75),
    ];

    for (final center in lights) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD99A).withValues(alpha: .20 * glowScale),
            const Color(0xFFFFB55B).withValues(alpha: .06 * glowScale),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: 130 * glowScale),
        );

      canvas.drawCircle(center, 130 * glowScale, glow);
    }

    final floorY = size.height * .64;

    canvas.drawRect(
      Rect.fromLTWH(0, floorY, size.width, size.height - floorY),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF33231D),
            Color(0xFF241A17),
          ],
        ).createShader(
          Rect.fromLTWH(0, floorY, size.width, size.height - floorY),
        ),
    );
  }

  @override
  bool shouldRepaint(_HallAtmospherePainter old) =>
      old.glowScale != glowScale;
}

class _LightOverlay extends ConsumerWidget {
  const _LightOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glow = ref.watch(
      hallAmbienceProvider.select((a) => a.glow),
    );

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.55),
            radius: 0.95,
            colors: [
              const Color(0xFFFFD99A).withValues(alpha: 0.10 * glow),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRANCE + LAMP + MARIGOLDS
// ─────────────────────────────────────────────────────────────────────────────

class _Entrance extends StatelessWidget {
  const _Entrance();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            left: 26,
            right: 26,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFD99445).withValues(alpha: .32),
              ),
            ),
          ),
          const Positioned(top: 1, child: _WarmLamp()),
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _MarigoldCluster(),
                _MarigoldCluster(),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 700.ms)
        .moveY(begin: -10, end: 0, duration: 700.ms);
  }
}

class _WarmLamp extends ConsumerWidget {
  const _WarmLamp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glow = ref.watch(
      hallAmbienceProvider.select((a) => a.glow),
    );
    final scale = 0.9 + glow * 0.35;

    return Transform.scale(
      scale: scale,
      child: Column(
        children: [
          Container(
            width: 2,
            height: 16,
            color: const Color(0xFFD8B17A),
          ),
          Container(
            width: 48,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFD18C48),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC66D)
                      .withValues(alpha: .5 * glow),
                  blurRadius: 28 * scale,
                  spreadRadius: 7 * scale,
                ),
              ],
            ),
          ),
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE4A9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC76A)
                      .withValues(alpha: .8 * glow),
                  blurRadius: 15 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarigoldCluster extends StatefulWidget {
  const _MarigoldCluster();

  @override
  State<_MarigoldCluster> createState() => _MarigoldClusterState();
}

class _MarigoldClusterState extends State<_MarigoldCluster>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final angle = math.sin(_c.value * 2 * math.pi) * 0.045;
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: Row(
        children: List.generate(
          7,
          (i) => Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i.isEven
                  ? const Color(0xFFE9A143)
                  : const Color(0xFFD87932),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE9A143).withValues(alpha: .25),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HallSign extends StatelessWidget {
  const _HallSign();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211D).withValues(alpha: .82),
        border: Border.all(
          color: const Color(0xFFD8A15C).withValues(alpha: .38),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'THE FAMILY HALL',
            style: TextStyle(
              color: const Color(0xFFF1C982).withValues(alpha: .92),
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Come in. The table is ready.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .88),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 600.ms)
        .moveY(begin: 8, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOD TABLE
// ─────────────────────────────────────────────────────────────────────────────

class _FoodTable extends StatelessWidget {
  const _FoodTable();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 10,
              right: 10,
              bottom: 18,
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF9A6038),
                      Color(0xFF5D3625),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 34,
              top: 16,
              child: _ServingBowl(
                label: 'Chicken',
                steam: true,
                child: const _ChickenDish(),
              ),
            ),
            Positioned(
              right: 34,
              top: 24,
              child: _ServingBowl(
                label: 'Achar',
                child: const _AcharDish(),
              ),
            ),
            Positioned(
              top: 3,
              child: _ServingBowl(
                label: 'Sel roti',
                steam: true,
                child: const _SelRotiDish(),
              ),
            ),
            Positioned(
              left: 92,
              bottom: 28,
              child: const _Glass(),
            ),
            Positioned(
              right: 93,
              bottom: 30,
              child: const _Glass(),
            ),
            Positioned(
              bottom: 22,
              child: _ServingBowl(
                label: 'Snacks',
                small: true,
                child: const _SnackDish(),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 700.ms)
        .moveY(begin: 14, end: 0);
  }
}

class _ServingBowl extends StatelessWidget {
  const _ServingBowl({
    required this.label,
    required this.child,
    this.small = false,
    this.steam = false,
  });

  final String label;
  final Widget child;
  final bool small;
  final bool steam;

  @override
  Widget build(BuildContext context) {
    final w = small ? 70.0 : 82.0;
    final h = small ? 52.0 : 62.0;

    return Column(
      children: [
        SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              child,
              if (steam)
                Positioned(
                  top: -18,
                  child: SizedBox(
                    width: w * 0.7,
                    height: 30,
                    child: const _Steam(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .54),
            fontSize: 9,
            letterSpacing: .4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEAM
// ─────────────────────────────────────────────────────────────────────────────

class _Steam extends StatefulWidget {
  const _Steam();

  @override
  State<_Steam> createState() => _SteamState();
}

class _SteamState extends State<_Steam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _SteamPainter(t: _c.value),
        size: Size.infinite,
      ),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final y = size.height * (1 - phase);
      final x = size.width / 2 + math.sin(phase * 6 + i) * 6;
      final opacity = (1 - phase) * 0.30;

      canvas.drawCircle(
        Offset(x, y),
        7 + phase * 10,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
  }

  @override
  bool shouldRepaint(_SteamPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOD PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

class _ChickenDish extends StatelessWidget {
  const _ChickenDish();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ChickenPainter());
}

class _ChickenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plate = Paint()..color = const Color(0xFFE8E0D3);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * .88,
        height: size.height * .64,
      ),
      plate,
    );

    final food = Paint()..color = const Color(0xFF9C4929);

    final pieces = [
      Offset(size.width * .36, size.height * .45),
      Offset(size.width * .52, size.height * .38),
      Offset(size.width * .60, size.height * .52),
      Offset(size.width * .44, size.height * .57),
    ];

    for (final p in pieces) {
      canvas.drawCircle(p, 10, food);
    }

    final highlight = Paint()
      ..color = const Color(0xFFD98645).withValues(alpha: .7);

    for (final p in pieces) {
      canvas.drawCircle(p.translate(-2, -2), 3, highlight);
    }

    final herb = Paint()..color = const Color(0xFF587044);

    for (final p in [
      Offset(size.width * .30, size.height * .36),
      Offset(size.width * .67, size.height * .40),
      Offset(size.width * .48, size.height * .66),
    ]) {
      canvas.drawCircle(p, 2.2, herb);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AcharDish extends StatelessWidget {
  const _AcharDish();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _AcharPainter());
}

class _AcharPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * .78,
        height: size.height * .58,
      ),
      Paint()..color = const Color(0xFFD9D0C2),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * .62,
        height: size.height * .43,
      ),
      Paint()..color = const Color(0xFFA94826),
    );

    final bits = Paint()..color = const Color(0xFFD18B35);

    for (final p in [
      Offset(size.width * .38, size.height * .45),
      Offset(size.width * .55, size.height * .40),
      Offset(size.width * .61, size.height * .55),
      Offset(size.width * .47, size.height * .59),
    ]) {
      canvas.drawCircle(p, 3, bits);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SelRotiDish extends StatelessWidget {
  const _SelRotiDish();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SelRotiPainter());
}

class _SelRotiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final plate = Paint()..color = const Color(0xFFE8E0D3);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * .63),
        width: size.width * .88,
        height: size.height * .48,
      ),
      plate,
    );

    final roti = Paint()..color = const Color(0xFFC47B39);

    for (var i = 0; i < 3; i++) {
      final x = size.width * (.35 + i * .15);

      canvas.drawCircle(
        Offset(x, size.height * (.49 - i * .025)),
        18,
        roti,
      );

      canvas.drawCircle(
        Offset(x, size.height * (.49 - i * .025)),
        11,
        Paint()..color = const Color(0xFFE2A65A),
      );

      canvas.drawCircle(
        Offset(x, size.height * (.49 - i * .025)),
        5,
        Paint()..color = const Color(0xFFB96631),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SnackDish extends StatelessWidget {
  const _SnackDish();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SnackPainter());
}

class _SnackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * .86,
        height: size.height * .62,
      ),
      Paint()..color = const Color(0xFFD9D0C2),
    );

    final food = Paint()..color = const Color(0xFFB97837);

    for (final p in [
      Offset(size.width * .35, size.height * .45),
      Offset(size.width * .50, size.height * .38),
      Offset(size.width * .64, size.height * .48),
      Offset(size.width * .46, size.height * .58),
    ]) {
      canvas.drawCircle(p, 8, food);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Glass extends StatelessWidget {
  const _Glass();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0E8).withValues(alpha: .30),
        border: Border.all(
          color: Colors.white.withValues(alpha: .32),
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(7),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFD7A05B).withValues(alpha: .55),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CELEBRATION NOTICE
// ─────────────────────────────────────────────────────────────────────────────

class _CelebrationNotice extends ConsumerStatefulWidget {
  const _CelebrationNotice({
    required this.next,
    required this.lang,
  });

  final ({FamilyMember m, DateTime d}) next;
  final AppLang lang;

  @override
  ConsumerState<_CelebrationNotice> createState() =>
      _CelebrationNoticeState();
}

class _CelebrationNoticeState extends ConsumerState<_CelebrationNotice> {
  final _player = AudioPlayer();
  final _confetti = ConfettiController(
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void dispose() {
    _player.dispose();
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _toast() async {
    ref.read(hallAmbienceProvider.notifier).set(
          const HallAmbience(
            glow: 1.0,
            dog: DogMood.tailWag,
            toasting: true,
          ),
        );

    _confetti.play();

    try {
      await _player.setAsset('assets/audio/applause.wav');
      await _player.play();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 6));

    if (!mounted) return;
    ref.read(hallAmbienceProvider.notifier).set(
          const HallAmbience(glow: 0.6, dog: DogMood.idle),
        );
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.next.d.daysUntilNextAnniversary();
    final today = days == 0;
    final name = widget.next.m.shortName;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 26),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF261C18).withValues(alpha: .88),
            border: Border.all(
              color: const Color(0xFFD6A35E).withValues(alpha: .46),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _toast,
                child: const _RealisticCake(),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today ? 'TODAY WE CELEBRATE' : 'NEXT CELEBRATION',
                      style: const TextStyle(
                        color: Color(0xFFE5B96F),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      today ? 'Happy birthday, $name!' : '$name is next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      today
                          ? 'The table is ready.'
                          : '${_turningText(widget.next.d)} · '
                              '${days == 1 ? 'tomorrow' : '$days days away'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .64),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 16,
            gravity: .32,
            colors: const [
              Color(0xFFE4B766),
              Color(0xFFD56C39),
              Color(0xFFF1D39B),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 650.ms, duration: 650.ms)
        .moveY(begin: 12, end: 0);
  }

  String _turningText(DateTime date) {
    final turning =
        date.ageOn() + (date.daysUntilNextAnniversary() == 0 ? 0 : 1);
    return 'Turning $turning';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLICKERING CAKE
// ─────────────────────────────────────────────────────────────────────────────

class _RealisticCake extends StatefulWidget {
  const _RealisticCake();

  @override
  State<_RealisticCake> createState() => _RealisticCakeState();
}

class _RealisticCakeState extends State<_RealisticCake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 66,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 58,
            height: 27,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE5A76C),
                  Color(0xFFB65E45),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(9),
                bottom: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .3),
                  blurRadius: 7,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            child: Container(
              width: 63,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFF3D6B4),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                return Row(
                  children: List.generate(3, (i) {
                    final t = _c.value * 2 * math.pi + i * 1.7;
                    final flicker = 0.85 +
                        0.15 * math.sin(t) +
                        0.06 * math.sin(3.3 * t + 1.2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Transform.scale(
                        scale: flicker,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            Container(
                              width: 3,
                              height: 13,
                              color: const Color(0xFFF6E8D0),
                            ),
                            Container(
                              width: 6,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD27C),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFC15C)
                                        .withValues(alpha: .75 * flicker),
                                    blurRadius: 8 * flicker,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAMILY TABLE
// ─────────────────────────────────────────────────────────────────────────────

class _FamilyTable extends StatelessWidget {
  const _FamilyTable({
    required this.members,
    required this.nextId,
    required this.lang,
    required this.width,
  });

  final List<FamilyMember> members;
  final String? nextId;
  final AppLang lang;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tableWidth = math.min(width * .48, 250.0);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: CustomPaint(painter: _LongTablePainter()),
          ),
        ),
        Column(
          children: [
            Text(
              'THE LONG TABLE',
              style: TextStyle(
                color: const Color(0xFFE3B66F).withValues(alpha: .82),
                fontSize: 9,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'There is always a place for family.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: tableWidth + 170,
              child: Column(
                children: [
                  for (var i = 0; i < members.length; i++)
                    _PerspectiveSeat(
                      index: i,
                      total: members.length,
                      child: _FamilySeat(
                        member: members[i],
                        date: MockData.birthdays[members[i].id],
                        isNext: members[i].id == nextId,
                        left: i.isEven,
                        lang: lang,
                        delayMs: 900 + i * 100,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PerspectiveSeat extends StatelessWidget {
  const _PerspectiveSeat({
    required this.index,
    required this.total,
    required this.child,
  });

  final int index;
  final int total;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final depth = total <= 1 ? 1.0 : index / (total - 1);
    final scale = 0.90 + 0.10 * depth;
    final opacity = 0.72 + 0.28 * depth;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

class _LongTablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final nearW = size.width * .42;
    final farW = size.width * .24;
    final cx = size.width / 2;

    final path = Path()
      ..moveTo(cx - farW / 2, size.height * 0.04)
      ..lineTo(cx + farW / 2, size.height * 0.04)
      ..lineTo(cx + nearW / 2, size.height * 0.96)
      ..lineTo(cx - nearW / 2, size.height * 0.96)
      ..close();

    final tablePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF5D3423),
          Color(0xFF9B6037),
          Color(0xFF6A3D27),
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx, size.height / 2),
          width: nearW,
          height: size.height,
        ),
      );

    canvas.drawPath(path, tablePaint);

    final grain = Paint()
      ..color = const Color(0xFFE2A06A).withValues(alpha: .10)
      ..strokeWidth = 1;

    for (var i = 0; i < 13; i++) {
      final t = i / 12;
      final y = size.height * (0.06 + 0.88 * t);
      final halfW = (farW + (nearW - farW) * t) / 2;
      canvas.drawLine(
        Offset(cx - halfW + 12, y),
        Offset(cx + halfW - 12, y + (i.isEven ? 3 : -2)),
        grain,
      );
    }

    final runnerPath = Path()
      ..moveTo(cx - farW * 0.22, size.height * 0.04)
      ..lineTo(cx + farW * 0.22, size.height * 0.04)
      ..lineTo(cx + nearW * 0.22, size.height * 0.96)
      ..lineTo(cx - nearW * 0.22, size.height * 0.96)
      ..close();

    canvas.drawPath(
      runnerPath,
      Paint()..color = const Color(0xFFD5B184).withValues(alpha: .30),
    );

    canvas.drawPath(
      path.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: .20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FamilySeat extends StatelessWidget {
  const _FamilySeat({
    required this.member,
    required this.date,
    required this.isNext,
    required this.left,
    required this.lang,
    required this.delayMs,
  });

  final FamilyMember member;
  final DateTime? date;
  final bool isNext;
  final bool left;
  final AppLang lang;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final known = date != null;
    final guessed = MockData.isPlaceholderBirthday(member.id);
    final gone = member.inMemoriam;

    final details = Column(
      crossAxisAlignment:
          left ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          member.shortName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (known) ...[
          const SizedBox(height: 2),
          Text(
            lang == AppLang.ne ? bsDayMonth(date!) : date!.dayMonth,
            style: TextStyle(
              color: guessed
                  ? Colors.white.withValues(alpha: .42)
                  : const Color(0xFFE0B56F),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (guessed)
            Text(
              '* ${trS(lang, 'not confirmed')}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .32),
                fontSize: 9,
              ),
            ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          if (left) ...[
            Expanded(child: details),
            const SizedBox(width: 9),
            _PlaceSetting(
              member: member,
              known: known && !guessed,
              next: isNext,
              gone: gone,
            ),
            const Expanded(child: SizedBox()),
          ] else ...[
            const Expanded(child: SizedBox()),
            _PlaceSetting(
              member: member,
              known: known && !guessed,
              next: isNext,
              gone: gone,
            ),
            const SizedBox(width: 9),
            Expanded(child: details),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 500.ms)
        .moveY(begin: 8, end: 0);
  }
}

class _PlaceSetting extends StatelessWidget {
  const _PlaceSetting({
    required this.member,
    required this.known,
    required this.next,
    required this.gone,
  });

  final FamilyMember member;
  final bool known;
  final bool next;
  final bool gone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1E9DC),
              border: Border.all(
                color: next
                    ? const Color(0xFFE7B969)
                    : const Color(0xFFBFAF9D),
                width: next ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .25),
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          if (gone)
            const _MemorialFlower()
          else if (next)
            const _MiniCake()
          else if (known)
            const _SmallFoodOnPlate(),
          Positioned(left: 2, child: const _Fork()),
          Positioned(right: 2, child: const _Knife()),
        ],
      ),
    );
  }
}

class _SmallFoodOnPlate extends StatelessWidget {
  const _SmallFoodOnPlate();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFC27637),
          ),
        ),
        const SizedBox(width: 3),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFA8522C),
          ),
        ),
      ],
    );
  }
}

class _MiniCake extends StatelessWidget {
  const _MiniCake();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            2,
            (_) => Container(
              width: 2,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              color: const Color(0xFFF5E4CA),
            ),
          ),
        ),
        Container(
          width: 29,
          height: 15,
          decoration: BoxDecoration(
            color: const Color(0xFFC46A50),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: 32,
          height: 3,
          color: const Color(0xFFEBC79A),
        ),
      ],
    );
  }
}

class _MemorialFlower extends StatelessWidget {
  const _MemorialFlower();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _FlowerPainter(),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final flower = Paint()..color = const Color(0xFFE39A32);
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 7; i++) {
      final angle = i * math.pi * 2 / 7;
      canvas.drawCircle(
        center +
            Offset(
              math.cos(angle) * 6,
              math.sin(angle) * 6,
            ),
        4,
        flower,
      );
    }

    canvas.drawCircle(
      center,
      3,
      Paint()..color = const Color(0xFFB86B24),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Fork extends StatelessWidget {
  const _Fork();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFC7B9A8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Knife extends StatelessWidget {
  const _Knife();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFBBAA98),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOG
// ─────────────────────────────────────────────────────────────────────────────

class _DogUnderTable extends ConsumerStatefulWidget {
  const _DogUnderTable();

  @override
  ConsumerState<_DogUnderTable> createState() => _DogUnderTableState();
}

class _DogUnderTableState extends ConsumerState<_DogUnderTable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(
      hallAmbienceProvider.select((a) => a.dog),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = math.sin(_controller.value * math.pi);

        double bob = phase * 2;
        double rot = 0;
        double scale = 1;

        switch (mood) {
          case DogMood.idle:
            bob = phase * 2;
            break;
          case DogMood.sniffing:
            bob = phase * 4;
            rot = phase * 0.06;
            break;
          case DogMood.tailWag:
            bob = phase * 3;
            rot = math.sin(_controller.value * math.pi * 8) * 0.14;
            scale = 1.05;
            break;
        }

        return Transform.translate(
          offset: Offset(bob, 0),
          child: Transform.rotate(
            angle: rot,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text(
                '🐕',
                style: TextStyle(
                  fontSize: 26,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .45),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              if (mood == DogMood.tailWag)
                Positioned(
                  top: -14,
                  right: -14,
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: const Color(0xFFFFD27C),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: .4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Someone is waiting for leftovers.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .45),
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTNOTE
// ─────────────────────────────────────────────────────────────────────────────

class _Footnote extends StatelessWidget {
  const _Footnote({required this.lang});

  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 26),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .16),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Text(
        trS(
          lang,
          '* A date marked like this is pencilled in until someone tells us '
          'the real one. Nothing counts down to a pencilled date.',
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .48),
          fontSize: 11,
          height: 1.45,
        ),
      ),
    );
  }
}