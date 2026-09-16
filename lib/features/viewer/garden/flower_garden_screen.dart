import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/lottie_art.dart';
import '../../../shared/widgets/section_scaffold.dart';

/// ===========================================================================
/// FLOWER GARDEN
/// ===========================================================================
///
/// An immersive family garden rather than a flower catalogue.
///
/// The user enters through a garden gate and scrolls through a long,
/// environmental scene:
///
///   Garden gate
///       ↓
///   Flower beds
///       ↓
///   Pots + insects
///       ↓
///   Orange tree
///       ↓
///   Pond
///       ↓
///   Dipisha watering plants
///       ↓
///   Family pets
///       ↓
///   Quiet garden corner
///       ↓
///   Final garden
///
/// All Lottie assets use String paths through the project's Anim class.
/// ===========================================================================

class FlowerGardenScreen extends ConsumerStatefulWidget {
  const FlowerGardenScreen({super.key});

  @override
  ConsumerState<FlowerGardenScreen> createState() =>
      _FlowerGardenScreenState();
}

class _FlowerGardenScreenState extends ConsumerState<FlowerGardenScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _ambientController;

  double _scroll = 0;

  static const double _sceneHeight = 3000;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _scroll = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    _ambientController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);

    return SectionScaffold(
      title: 'Flower Garden',
      subtitle: 'Our phulbari · फूलबारी',
      emoji: '🌿',
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9BCBB5),
          Color(0xFFD8E5C7),
          Color(0xFF8EA86D),
          Color(0xFF536C43),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  height: _sceneHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // =====================================================
                      // ENVIRONMENT
                      // =====================================================

                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GardenBackgroundPainter(
                            scroll: _scroll,
                            animation: _ambientController.value,
                          ),
                        ),
                      ),

                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: const _GardenPathPainter(),
                          ),
                        ),
                      ),

                      // =====================================================
                      // ENTRANCE
                      // =====================================================

                      const _GardenGate(),

                      if (_scroll < 180)
                        _WalkMessage(scroll: _scroll),

                      // =====================================================
                      // DISTANT TREES
                      // =====================================================

                      _Tree(
                        left: -55,
                        top: 430,
                        scale: .72,
                        scroll: _scroll,
                        depth: .15,
                        color: const Color(0xFF5B7B55),
                      ),

                      _Tree(
                        right: -55,
                        top: 470,
                        scale: .76,
                        scroll: _scroll,
                        depth: .17,
                        color: const Color(0xFF52734E),
                      ),

                      _Tree(
                        left: width * .02,
                        top: 760,
                        scale: .88,
                        scroll: _scroll,
                        depth: .23,
                        color: const Color(0xFF416541),
                      ),

                      _Tree(
                        right: width * .02,
                        top: 850,
                        scale: .94,
                        scroll: _scroll,
                        depth: .26,
                        color: const Color(0xFF496B43),
                      ),

                      // =====================================================
                      // LALI GURAS
                      // =====================================================

                      _WorldObject(
                        left: width * .01,
                        top: 620,
                        scroll: _scroll,
                        depth: .38,
                        child: _RealFlowerPlant(
                          photo: 'assets/images/flowers/guras.jpg',
                          name: 'लालीगुराँस',
                          english: 'Lali Guras · Rhododendron',
                          description:
                              "Nepal's national flower. In spring, the hills around Ilam turn red with it.",
                          accent: const Color(0xFFB83D47),
                        ),
                      ),

                      // =====================================================
                      // SAYAPATRI
                      // =====================================================

                      _WorldObject(
                        right: width * .01,
                        top: 770,
                        scroll: _scroll,
                        depth: .42,
                        child: _RealFlowerPlant(
                          photo: 'assets/images/flowers/sayapatri.jpg',
                          name: 'सयपत्री',
                          english: 'Sayapatri · Marigold',
                          description:
                              'The familiar Tihar flower, bright around the home and woven into malas.',
                          accent: const Color(0xFFE49A27),
                        ),
                      ),

                      // =====================================================
                      // POTS
                      // =====================================================

                      _WorldObject(
                        left: width * .015,
                        top: 910,
                        scroll: _scroll,
                        depth: .46,
                        child: const _ClayPotRow(count: 3),
                      ),

                      _WorldObject(
                        right: width * .015,
                        top: 1035,
                        scroll: _scroll,
                        depth: .48,
                        child: const _ClayPotRow(count: 2),
                      ),

                      // =====================================================
                      // MONEY PLANT
                      // =====================================================

                      _WorldObject(
                        left: width * .025,
                        top: 1080,
                        scroll: _scroll,
                        depth: .49,
                        child: _LottiePlant(
                          animation: Anim.walkingPothos,
                          name: 'मनी प्लान्ट',
                          english: 'Money plant',
                          description:
                              'A little clay-pot plant growing wherever it wants.',
                          width: 125,
                        ),
                      ),

                      // =====================================================
                      // ORANGE
                      // =====================================================

                      _WorldObject(
                        right: width * .01,
                        top: 1200,
                        scroll: _scroll,
                        depth: .53,
                        child: _LottiePlant(
                          animation: Anim.walkingOrange,
                          name: 'सुन्तला',
                          english: 'Suntala · Orange',
                          description:
                              'Ilam orange — sweet, cold and best eaten in the winter sun.',
                          width: 145,
                        ),
                      ),

                      // =====================================================
                      // BUTTERFLY
                      // =====================================================

                      _FlyingLottie(
                        left: width * .48,
                        top: 580,
                        scroll: _scroll,
                        depth: .30,
                        animation: _ambientController.value,
                        asset: Anim.butterfly,
                        width: 60,
                      ),

                      // =====================================================
                      // BEE
                      // =====================================================

                      _FlyingLottie(
                        left: width * .18,
                        top: 890,
                        scroll: _scroll,
                        depth: .40,
                        animation: _ambientController.value,
                        asset: Anim.honeyBee,
                        width: 52,
                      ),

                      // =====================================================
                      // BIRD
                      // =====================================================

                      _FlyingLottie(
                        left: width * .58,
                        top: 1010,
                        scroll: _scroll,
                        depth: .44,
                        animation: _ambientController.value,
                        asset: Anim.happyBird,
                        width: 62,
                      ),

                      // =====================================================
                      // PARROT
                      // =====================================================

                      _FlyingLottie(
                        left: width * .53,
                        top: 1140,
                        scroll: _scroll,
                        depth: .49,
                        animation: _ambientController.value + .25,
                        asset: Anim.parrot,
                        width: 68,
                      ),

                      // =====================================================
                      // LITTLE PIG
                      // =====================================================

                      _WorldObject(
                        right: width * .07,
                        top: 1300,
                        scroll: _scroll,
                        depth: .52,
                        child: GestureDetector(
                          onTap: () {
                            _showDiscovery(
                              context,
                              title: 'A little visitor',
                              message:
                                  'Sometimes the garden gets unexpected visitors too.',
                            );
                          },
                          child: SizedBox(
                            width: 95,
                            height: 100,
                            child: LottieArt(Anim.cutePig),
                          ),
                        ),
                      ),

                      // =====================================================
                      // POND
                      // =====================================================

                      _WorldObject(
                        left: width * .10,
                        top: 1390.0,
                        scroll: _scroll,
                        depth: .55,
                        child: _Pond(
                          width: width * .80,
                          animation: _ambientController.value,
                        ),
                      ),

                      // =====================================================
                      // STUBBY
                      // =====================================================

                      _WorldObject(
                        left: -15,
                        top: 1535,
                        scroll: _scroll,
                        depth: .61,
                        child: _PetDiscovery(
                          asset: Anim.dogPeeking,
                          name: 'Stubby',
                          description:
                              'Still watching the garden from behind the pots.',
                          width: 135,
                        ),
                      ),

                      // =====================================================
                      // DIPISHA
                      // =====================================================

                      _WorldObject(
                        left: width * .43,
                        top: 1570,
                        scroll: _scroll,
                        depth: .60,
                        child: GestureDetector(
                          onTap: () {
                            _showDiscovery(
                              context,
                              title:
                                  lang == AppLang.ne ? 'डिपिशा' : 'Dipisha',
                              message:
                                  'One pot at a time. The garden is cared for slowly, in ordinary moments.',
                            );
                          },
                          child: SizedBox(
                            width: 155,
                            height: 195,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                const Positioned(
                                  bottom: 0,
                                  child: _GardenGroundPatch(
                                    width: 130,
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  height: 180,
                                  child: LottieArt(
                                    Anim.girlWateringPlants,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // =====================================================
                      // FLOWER PATCH
                      // =====================================================

                      _WorldObject(
                        right: width * .01,
                        top: 1740,
                        scroll: _scroll,
                        depth: .65,
                        child: _FlowerPatch(
                          animation: _ambientController.value,
                        ),
                      ),

                      // =====================================================
                      // ARJUN
                      // =====================================================

                      _WorldObject(
                        right: -10,
                        top: 1810,
                        scroll: _scroll,
                        depth: .68,
                        child: _PetDiscovery(
                          asset: Anim.cuteDoggie,
                          name: 'Arjun',
                          description:
                              'Still taking his job as garden guard very seriously.',
                          width: 145,
                        ),
                      ),

                      // =====================================================
                      // SECOND BUTTERFLY
                      // =====================================================

                      _FlyingLottie(
                        left: width * .24,
                        top: 1880,
                        scroll: _scroll,
                        depth: .62,
                        animation: _ambientController.value + .35,
                        asset: Anim.butterflyOrange,
                        width: 58,
                      ),

                      // =====================================================
                      // MEOW
                      // =====================================================

                      _WorldObject(
                        right: width * .04,
                        top: 2000,
                        scroll: _scroll,
                        depth: .73,
                        child: _PetDiscovery(
                          asset: Anim.danceCat,
                          name: 'Meow',
                          description:
                              'Walking through the flowers as though the whole garden belongs to her.',
                          width: 130,
                        ),
                      ),

                      // =====================================================
                      // BIRD PAIR
                      // =====================================================

                      _WorldObject(
                        left: width * .20,
                        top: 2040,
                        scroll: _scroll,
                        depth: .70,
                        child: SizedBox(
                          width: 95,
                          height: 95,
                          child: LottieArt(Anim.birdPairLove),
                        ),
                      ),

                      // =====================================================
                      // BENCH
                      // =====================================================

                      _WorldObject(
                        left: width * .10,
                        top: 2180,
                        scroll: _scroll,
                        depth: .78,
                        child: GestureDetector(
                          onTap: () {
                            _showDiscovery(
                              context,
                              title: 'A quiet corner',
                              message:
                                  'Sit here for a while. Nothing in this garden needs to be rushed.',
                            );
                          },
                          child: const _GardenBench(),
                        ),
                      ),

                      // =====================================================
                      // FINAL FLOWERS
                      // =====================================================

                      _WorldObject(
                        right: width * .02,
                        top: 2250,
                        scroll: _scroll,
                        depth: .80,
                        child: _FinalFlowerCluster(
                          animation: _ambientController.value,
                        ),
                      ),

                      // =====================================================
                      // FINAL BIRDS
                      // =====================================================

                      _WorldObject(
                        left: width * .52,
                        top: 2290,
                        scroll: _scroll,
                        depth: .76,
                        child: SizedBox(
                          width: 110,
                          height: 100,
                          child: LottieArt(
                            Anim.heartValleyBirds,
                          ),
                        ),
                      ),

                      // =====================================================
                      // ENDING
                      // =====================================================

                      Positioned(
                        left: 0,
                        right: 0,
                        top: 2500,
                        child: _GardenEnding(
                          lang: lang,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ===========================================================================
/// WORLD OBJECT
/// ===========================================================================

class _WorldObject extends StatelessWidget {
  const _WorldObject({
    this.left,
    this.right,
    required this.top,
    required this.scroll,
    required this.depth,
    required this.child,
  });

  final double? left;
  final double? right;
  final double top;
  final double scroll;
  final double depth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top - scroll * depth,
      child: child,
    );
  }
}

/// ===========================================================================
/// BACKGROUND
/// ===========================================================================

class _GardenBackgroundPainter extends CustomPainter {
  const _GardenBackgroundPainter({
    required this.scroll,
    required this.animation,
  });

  final double scroll;
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF94C9B4),
          Color(0xFFDCE9CE),
          Color(0xFF9DBA7C),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        width,
        size.height,
      ),
      skyPaint,
    );

    // ---------------------------------------------------------------
    // SUNLIGHT
    // ---------------------------------------------------------------

    final sunY = 120 - scroll * .035;

    canvas.drawCircle(
      Offset(width * .82, sunY),
      180,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE8A0).withValues(alpha: .50),
            const Color(0xFFFFE8A0).withValues(alpha: .12),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              width * .82,
              sunY,
            ),
            radius: 180,
          ),
        ),
    );

    // ---------------------------------------------------------------
    // DISTANT HILLS
    // ---------------------------------------------------------------

    _drawHill(
      canvas,
      size,
      500 - scroll * .08,
      145,
      const Color(0xFF78966D),
      0,
    );

    _drawHill(
      canvas,
      size,
      545 - scroll * .11,
      130,
      const Color(0xFF64835C),
      1.5,
    );

    // ---------------------------------------------------------------
    // GROUND
    // ---------------------------------------------------------------

    final groundY = 570 - scroll * .19;

    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF7D9D5D),
          Color(0xFF658849),
          Color(0xFF4F6F40),
          Color(0xFF3D5936),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          groundY,
          width,
          math.max(size.height - groundY, 0),
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        groundY,
        width,
        math.max(size.height - groundY, 0),
      ),
      groundPaint,
    );

    // ---------------------------------------------------------------
    // GRASS
    // ---------------------------------------------------------------

    final grassPaint = Paint()
      ..color = const Color(0xFF294729).withValues(alpha: .42)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final safeWidth = math.max(width.toInt(), 1);

    for (var i = 0; i < 260; i++) {
      final x = ((i * 71) % safeWidth).toDouble();

      final y =
          groundY +
          18 +
          ((i * 53) % 2350).toDouble();

      final sway =
          math.sin(
                animation * math.pi * 2 + i * .63,
              ) *
              3.2;

      canvas.drawLine(
        Offset(x, y),
        Offset(
          x + sway,
          y - 7 - (i % 5),
        ),
        grassPaint,
      );
    }

    // ---------------------------------------------------------------
    // FLOATING LIGHT / POLLEN
    // ---------------------------------------------------------------

    final particlePaint = Paint()
      ..color = const Color(0xFFFFE7A5).withValues(alpha: .32);

    for (var i = 0; i < 50; i++) {
      final x = ((i * 97) % safeWidth).toDouble();

      final baseY = 180 + ((i * 119) % 1800);

      final y =
          baseY +
          math.sin(
                animation * math.pi * 2 + i,
              ) *
              7;

      canvas.drawCircle(
        Offset(x, y),
        1 + (i % 3) * .35,
        particlePaint,
      );
    }
  }

  void _drawHill(
    Canvas canvas,
    Size size,
    double baseY,
    double height,
    Color color,
    double seed,
  ) {
    final path = Path()
      ..moveTo(0, baseY);

    for (var i = 0; i <= 12; i++) {
      final x = size.width * i / 12;

      final variation =
          math.sin(i * 1.15 + seed) *
          height *
          .22;

      path.lineTo(
        x,
        baseY - height * .42 - variation,
      );
    }

    path
      ..lineTo(
        size.width,
        baseY + 240,
      )
      ..lineTo(
        0,
        baseY + 240,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(
    covariant _GardenBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.scroll != scroll ||
        oldDelegate.animation != animation;
  }
}

/// ===========================================================================
/// WALKING PATH
/// ===========================================================================

class _GardenPathPainter extends CustomPainter {
  const _GardenPathPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;

    final path = Path()
      ..moveTo(width * .45, 220)
      ..cubicTo(
        width * .56,
        460,
        width * .28,
        730,
        width * .52,
        980,
      )
      ..cubicTo(
        width * .78,
        1210,
        width * .24,
        1440,
        width * .50,
        1670,
      )
      ..cubicTo(
        width * .74,
        1900,
        width * .30,
        2140,
        width * .48,
        3000,
      )
      ..lineTo(
        width * .90,
        3000,
      )
      ..cubicTo(
        width * .68,
        2140,
        width * .94,
        1900,
        width * .68,
        1670,
      )
      ..cubicTo(
        width * .42,
        1440,
        width * .94,
        1210,
        width * .70,
        980,
      )
      ..cubicTo(
        width * .44,
        730,
        width * .77,
        460,
        width * .57,
        220,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFC5A674),
    );

    // Soft centre highlight.
    final highlight = Path()
      ..moveTo(
        width * .49,
        260,
      )
      ..cubicTo(
        width * .55,
        500,
        width * .38,
        720,
        width * .54,
        950,
      )
      ..cubicTo(
        width * .68,
        1180,
        width * .35,
        1410,
        width * .51,
        1640,
      )
      ..cubicTo(
        width * .65,
        1880,
        width * .39,
        2110,
        width * .50,
        2500,
      );

    canvas.drawPath(
      highlight,
      Paint()
        ..color = const Color(0xFFE7D3A4).withValues(alpha: .52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );

    // Small stones beside the path.
    final stonePaint = Paint()
      ..color = const Color(0xFF806F59).withValues(alpha: .60);

    for (var i = 0; i < 28; i++) {
      final y = 390 + i * 92.0;

      final side = i.isEven ? -.04 : .04;

      final x =
          width * (.50 + side) +
          math.sin(i * 1.7) * width * .17;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 12 + (i % 3) * 3,
          height: 7,
        ),
        stonePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _GardenPathPainter oldDelegate,
  ) {
    return false;
  }
}

/// ===========================================================================
/// GARDEN GATE
/// ===========================================================================

class _GardenGate extends StatelessWidget {
  const _GardenGate();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Column(
        children: [
          SizedBox(
            width: 285,
            height: 245,
            child: CustomPaint(
              painter: _GatePainter(),
            ),
          ),
          Text(
            'OUR GARDEN',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFF7F0D7),
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'हाम्रो फूलबारी',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: .82),
                ),
          ),
        ],
      ),
    );
  }
}

class _GatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wood = Paint()
      ..color = const Color(0xFF5C4633)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final left = size.width * .25;
    final right = size.width * .75;

    canvas.drawLine(
      Offset(left, size.height),
      Offset(left, 72),
      wood,
    );

    canvas.drawLine(
      Offset(right, size.height),
      Offset(right, 72),
      wood,
    );

    final arch = Path()
      ..moveTo(left, 105)
      ..quadraticBezierTo(
        size.width * .50,
        5,
        right,
        105,
      );

    canvas.drawPath(
      arch,
      wood,
    );

    final gateWood = Paint()
      ..color = const Color(0xFF795A3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    for (var i = 0; i < 4; i++) {
      final y = 145.0 + i * 22.0;

      canvas.drawLine(
        Offset(left + 8, y),
        Offset(right - 8, y),
        gateWood,
      );
    }

    final vine = Paint()
      ..color = const Color(0xFF41633C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final vinePath = Path()
      ..moveTo(
        left + 5,
        150,
      )
      ..quadraticBezierTo(
        size.width * .38,
        70,
        size.width * .49,
        120,
      )
      ..quadraticBezierTo(
        size.width * .62,
        180,
        right - 4,
        105,
      );

    canvas.drawPath(
      vinePath,
      vine,
    );

    for (var i = 0; i < 11; i++) {
      final x = left + 12 + i * 18;
      final y = 105 + math.sin(i * 1.4) * 25;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 16,
          height: 9,
        ),
        Paint()..color = const Color(0xFF76934F),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _GatePainter oldDelegate,
  ) {
    return false;
  }
}

/// ===========================================================================
/// WALK MESSAGE
/// ===========================================================================

class _WalkMessage extends StatelessWidget {
  const _WalkMessage({
    required this.scroll,
  });

  final double scroll;

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - scroll / 180).clamp(0.0, 1.0);

    return Positioned(
      top: 300,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .23),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Walk into the garden',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Scroll slowly and explore',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .78),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// TREE
/// ===========================================================================

class _Tree extends StatelessWidget {
  const _Tree({
    this.left,
    this.right,
    required this.top,
    required this.scale,
    required this.scroll,
    required this.color,
    required this.depth,
  });

  final double? left;
  final double? right;
  final double top;
  final double scale;
  final double scroll;
  final Color color;
  final double depth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top - scroll * depth,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.bottomCenter,
        child: CustomPaint(
          size: const Size(160, 250),
          painter: _TreePainter(
            color: color,
          ),
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  const _TreePainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final trunk = Paint()
      ..color = const Color(0xFF624934)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(
        size.width * .50,
        size.height,
      ),
      Offset(
        size.width * .50,
        size.height * .46,
      ),
      trunk,
    );

    final leaves = Paint()..color = color;

    final centers = [
      Offset(
        size.width * .50,
        size.height * .25,
      ),
      Offset(
        size.width * .34,
        size.height * .35,
      ),
      Offset(
        size.width * .66,
        size.height * .35,
      ),
      Offset(
        size.width * .50,
        size.height * .42,
      ),
      Offset(
        size.width * .22,
        size.height * .45,
      ),
      Offset(
        size.width * .78,
        size.height * .45,
      ),
    ];

    final radii = [
      55.0,
      43.0,
      43.0,
      48.0,
      32.0,
      32.0,
    ];

    for (var i = 0; i < centers.length; i++) {
      canvas.drawCircle(
        centers[i],
        radii[i],
        leaves,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _TreePainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

/// ===========================================================================
/// REAL FLOWER
/// ===========================================================================

class _RealFlowerPlant extends StatelessWidget {
  const _RealFlowerPlant({
    required this.photo,
    required this.name,
    required this.english,
    required this.description,
    required this.accent,
  });

  final String photo;
  final String name;
  final String english;
  final String description;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFlowerDiscovery(
          context,
          photo: photo,
          name: name,
          english: english,
          description: description,
          accent: accent,
        );
      },
      child: SizedBox(
        width: 150,
        height: 195,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Positioned(
              bottom: 0,
              child: _GardenGroundPatch(),
            ),
            Positioned(
              bottom: 20,
              child: CustomPaint(
                size: const Size(125, 125),
                painter: _FlowerStemPainter(
                  accent: accent,
                ),
              ),
            ),
            Positioned(
              bottom: 70,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(photo),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .92),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .17),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              child: Text(
                name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFF7F1D7),
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowerStemPainter extends CustomPainter {
  const _FlowerStemPainter({
    required this.accent,
  });

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF3E683A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 6; i++) {
      final x = size.width * (.22 + i * .11);

      final sway = math.sin(i * .8) * 8;

      canvas.drawLine(
        Offset(x, size.height),
        Offset(
          x + sway,
          size.height * .30,
        ),
        stem,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            x + sway,
            size.height * .28,
          ),
          width: 18,
          height: 13,
        ),
        Paint()..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _FlowerStemPainter oldDelegate,
  ) {
    return oldDelegate.accent != accent;
  }
}

/// ===========================================================================
/// LOTTIE PLANT
/// ===========================================================================

class _LottiePlant extends StatelessWidget {
  const _LottiePlant({
    required this.animation,
    required this.name,
    required this.english,
    required this.description,
    required this.width,
  });

  /// IMPORTANT:
  /// Your Anim class contains String asset paths.
  final String animation;

  final String name;
  final String english;
  final String description;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDiscovery(
          context,
          title: english,
          message: description,
        );
      },
      child: SizedBox(
        width: width,
        height: width * 1.35,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: _GardenGroundPatch(
                width: width * .82,
              ),
            ),
            Positioned(
              bottom: 14,
              child: SizedBox(
                width: width,
                height: width,
                child: LottieArt(animation),
              ),
            ),
            Positioned(
              bottom: 3,
              child: Text(
                name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// GROUND PATCH
/// ===========================================================================

class _GardenGroundPatch extends StatelessWidget {
  const _GardenGroundPatch({
    this.width = 110,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF304D2D).withValues(alpha: .44),
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}

/// ===========================================================================
/// CLAY POTS
/// ===========================================================================

class _ClayPotRow extends StatelessWidget {
  const _ClayPotRow({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          count,
          (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              child: CustomPaint(
                size: Size(
                  30 + index * 5.0,
                  60 + index * 5.0,
                ),
                painter: _PotPainter(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pot = Paint()
      ..color = const Color(0xFF9B6243);

    final soil = Paint()
      ..color = const Color(0xFF503723);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width / 2,
          13,
        ),
        width: size.width,
        height: 13,
      ),
      soil,
    );

    final body = Path()
      ..moveTo(
        size.width * .12,
        14,
      )
      ..lineTo(
        size.width * .88,
        14,
      )
      ..lineTo(
        size.width * .74,
        size.height,
      )
      ..lineTo(
        size.width * .26,
        size.height,
      )
      ..close();

    canvas.drawPath(
      body,
      pot,
    );

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(
        size.width * .30,
        24,
      ),
      Offset(
        size.width * .34,
        size.height - 8,
      ),
      highlight,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PotPainter oldDelegate,
  ) {
    return false;
  }
}

/// ===========================================================================
/// FLYING LOTTIE
/// ===========================================================================

class _FlyingLottie extends StatelessWidget {
  const _FlyingLottie({
    required this.left,
    required this.top,
    required this.scroll,
    required this.depth,
    required this.animation,
    required this.asset,
    required this.width,
  });

  final double left;
  final double top;
  final double scroll;
  final double depth;
  final double animation;

  /// IMPORTANT:
  /// Anim constants are Strings in this project.
  final String asset;

  final double width;

  @override
  Widget build(BuildContext context) {
    final phase = animation * math.pi * 2;

    final driftX = math.sin(phase) * 24;
    final driftY = math.cos(phase) * 8;

    return Positioned(
      left: left + driftX,
      top: top - scroll * depth + driftY,
      child: SizedBox(
        width: width,
        height: width,
        child: LottieArt(asset),
      ),
    );
  }
}

/// ===========================================================================
/// POND
/// ===========================================================================

class _Pond extends StatelessWidget {
  const _Pond({
    required this.width,
    required this.animation,
  });

  final double width;
  final double animation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDiscovery(
          context,
          title: 'A little pond',
          message:
              'A quiet place where the garden slows down and the water catches the light.',
        );
      },
      child: SizedBox(
        width: width,
        height: 180,
        child: CustomPaint(
          painter: _PondPainter(
            animation: animation,
          ),
        ),
      ),
    );
  }
}

class _PondPainter extends CustomPainter {
  const _PondPainter({
    required this.animation,
  });

  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final water = Path()
      ..moveTo(
        5,
        size.height * .50,
      )
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .10,
        size.width * .50,
        size.height * .42,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .82,
        size.width - 5,
        size.height * .45,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height,
        size.width * .50,
        size.height * .76,
      )
      ..quadraticBezierTo(
        size.width * .18,
        size.height * .67,
        5,
        size.height * .50,
      )
      ..close();

    canvas.drawPath(
      water,
      Paint()..color = const Color(0xFF68A49A),
    );

    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: .27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 6; i++) {
      final x = size.width * (.24 + i * .09);

      final y =
          size.height * .47 +
          math.sin(
                animation * math.pi * 2 + i,
              ) *
              4;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 24 + i * 5.0,
          height: 7,
        ),
        ripple,
      );
    }

    final stones = Paint()
      ..color = const Color(0xFF878575);

    for (var i = 0; i < 9; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            10 + i * (size.width - 20) / 8,
            size.height * (.66 + (i % 2) * .04),
          ),
          width: 22,
          height: 12,
        ),
        stones,
      );
    }

    final reed = Paint()
      ..color = const Color(0xFF4D733F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final x = i.isEven
          ? 22 + i * 4.0
          : size.width - 22 - i * 4.0;

      canvas.drawLine(
        Offset(
          x,
          size.height * .70,
        ),
        Offset(
          x + math.sin(i) * 5,
          size.height * .40,
        ),
        reed,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _PondPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}

/// ===========================================================================
/// FLOWER PATCH
/// ===========================================================================

class _FlowerPatch extends StatelessWidget {
  const _FlowerPatch({
    required this.animation,
  });

  final double animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      height: 130,
      child: CustomPaint(
        painter: _FlowerPatchPainter(
          animation: animation,
        ),
      ),
    );
  }
}

class _FlowerPatchPainter extends CustomPainter {
  const _FlowerPatchPainter({
    required this.animation,
  });

  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = Paint()
      ..color = const Color(0xFF354F2F).withValues(alpha: .50);

    canvas.drawOval(
      Rect.fromLTWH(
        0,
        size.height * .72,
        size.width,
        30,
      ),
      ground,
    );

    final stem = Paint()
      ..color = const Color(0xFF3E6A3A)
      ..strokeWidth = 2.5;

    for (var i = 0; i < 9; i++) {
      final x = 10 + i * 15.0;

      final sway =
          math.sin(
                animation * math.pi * 2 + i,
              ) *
              3;

      canvas.drawLine(
        Offset(
          x,
          size.height * .78,
        ),
        Offset(
          x + sway,
          25 + (i % 3) * 7.0,
        ),
        stem,
      );

      canvas.drawCircle(
        Offset(
          x + sway,
          21 + (i % 3) * 7.0,
        ),
        7,
        Paint()
          ..color = i.isEven
              ? const Color(0xFFE6A33A)
              : const Color(0xFFD85B57),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _FlowerPatchPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}

/// ===========================================================================
/// PET DISCOVERY
/// ===========================================================================

class _PetDiscovery extends StatelessWidget {
  const _PetDiscovery({
    required this.asset,
    required this.name,
    required this.description,
    required this.width,
  });

  /// Anim constants are String paths.
  final String asset;

  final String name;
  final String description;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDiscovery(
          context,
          title: name,
          message: description,
        );
      },
      child: SizedBox(
        width: width,
        height: width * 1.15,
        child: LottieArt(asset),
      ),
    );
  }
}

/// ===========================================================================
/// BENCH
/// ===========================================================================

class _GardenBench extends StatelessWidget {
  const _GardenBench();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 145,
      child: CustomPaint(
        painter: _BenchPainter(),
      ),
    );
  }
}

class _BenchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wood = Paint()
      ..color = const Color(0xFF755235);

    final dark = Paint()
      ..color = const Color(0xFF503A29);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          25,
          55,
          size.width - 50,
          25,
        ),
        const Radius.circular(5),
      ),
      wood,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          35,
          28,
          size.width - 70,
          22,
        ),
        const Radius.circular(5),
      ),
      wood,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        48,
        78,
        12,
        58,
      ),
      dark,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 60,
        78,
        12,
        58,
      ),
      dark,
    );

    canvas.drawLine(
      const Offset(18, 95),
      const Offset(18, 55),
      Paint()
        ..color = const Color(0xFF42663A)
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      const Offset(18, 50),
      8,
      Paint()..color = const Color(0xFFE7A143),
    );
  }

  @override
  bool shouldRepaint(
    covariant _BenchPainter oldDelegate,
  ) {
    return false;
  }
}

/// ===========================================================================
/// FINAL FLOWERS
/// ===========================================================================

class _FinalFlowerCluster extends StatelessWidget {
  const _FinalFlowerCluster({
    required this.animation,
  });

  final double animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: _FinalFlowerPainter(
          animation: animation,
        ),
      ),
    );
  }
}

class _FinalFlowerPainter extends CustomPainter {
  const _FinalFlowerPainter({
    required this.animation,
  });

  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF3C6338)
      ..strokeWidth = 3;

    for (var i = 0; i < 7; i++) {
      final x = 15 + i * 20.0;

      final sway =
          math.sin(
                animation * math.pi * 2 + i,
              ) *
              2.5;

      canvas.drawLine(
        Offset(x, 130),
        Offset(
          x + sway,
          48 + (i % 3) * 8.0,
        ),
        stem,
      );

      canvas.drawCircle(
        Offset(
          x + sway,
          43 + (i % 3) * 8.0,
        ),
        9,
        Paint()
          ..color = i.isEven
              ? const Color(0xFFE2A03B)
              : const Color(0xFFE0605C),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _FinalFlowerPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}

/// ===========================================================================
/// ENDING
/// ===========================================================================

class _GardenEnding extends StatelessWidget {
  const _GardenEnding({
    required this.lang,
  });

  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final nepali = lang == AppLang.ne;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      padding: const EdgeInsets.fromLTRB(
        22,
        30,
        22,
        34,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EED8).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_florist_rounded,
            size: 42,
            color: Color(0xFF55744A),
          ),
          const SizedBox(height: 12),
          Text(
            'फूल जस्तै फक्रिनू, नानी।',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF48633E),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            nepali
                ? 'फूलबारीमा फेरि आउनू।'
                : 'Come back whenever you need a quiet place.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF68705E),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// FLOWER DISCOVERY
/// ===========================================================================

void _showFlowerDiscovery(
  BuildContext context, {
  required String photo,
  required String name,
  required String english,
  required String description,
  required Color accent,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          26,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F1DE),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(photo),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: .45),
                    width: 4,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                english,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF60675C),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// ===========================================================================
/// GENERAL DISCOVERY
/// ===========================================================================

void _showDiscovery(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(
          22,
          12,
          22,
          30,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F1DE),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.park_rounded,
                size: 42,
                color: Color(0xFF54714A),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF48643D),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF60675C),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      );
    },
  );
}