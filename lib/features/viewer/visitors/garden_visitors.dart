import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/i18n/l10n.dart';
import '../../../shared/widgets/lottie_art.dart';

/// A honey bee or the orange butterfly wandering over the family's screens
/// the way it would over a garden: it flies in, rests on a flower a while,
/// flies on, and leaves. Touch it and it says something small.
///
/// Diksha chose this on 2026-09-10 knowing the "nothing loops" rule. The
/// limits below are what keep her phone smooth, and DECISIONS.md holds them:
/// one visitor at a time, long rests between visits, the drawing runs at
/// 20 fps in its own layer, never on the album desk, and a switch in the
/// cabinet that is remembered.

/// Remembered on the phone, so the visitors can be sent to rest from the
/// cabinet if they ever make the phone stutter.
class VisitorsEnabledNotifier extends Notifier<bool> {
  static const _prefsKey = 'garden_visitors';

  @override
  bool build() {
    _restore();
    return true;
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_prefsKey) == false) state = false;
  }

  Future<void> _persist(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_prefsKey, value);
  }

  void toggle() {
    state = !state;
    _persist(state);
  }
}

final visitorsEnabledProvider = NotifierProvider<VisitorsEnabledNotifier, bool>(
  VisitorsEnabledNotifier.new,
);

/// Screens that must stay clear of visitors (the album desk) hold this while
/// they are open. It is a count, so a screen pushed on top of the desk does
/// not release it early.
class VisitorsHoldNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void hold() => state = state + 1;

  void release() => state = math.max(0, state - 1);
}

final visitorsHeldProvider = NotifierProvider<VisitorsHoldNotifier, int>(
  VisitorsHoldNotifier.new,
);

/// How the visitors pace themselves. Tests hand in a fast one.
class VisitorTiming {
  const VisitorTiming({
    required this.firstVisit,
    required this.betweenVisits,
    required this.flightLeg,
    required this.restOnFlower,
    required this.bubble,
  });

  /// Quiet after the app opens, before the first visitor.
  final Duration firstVisit;

  /// Quiet between one visitor leaving and the next arriving.
  final (Duration, Duration) betweenVisits;

  /// One flight from wherever it is to the next flower.
  final (Duration, Duration) flightLeg;

  /// Sitting still on a flower.
  final (Duration, Duration) restOnFlower;

  /// How long a spoken line stays up after a touch.
  final Duration bubble;

  static const natural = VisitorTiming(
    firstVisit: Duration(seconds: 7),
    betweenVisits: (Duration(seconds: 14), Duration(seconds: 36)),
    flightLeg: (Duration(milliseconds: 2800), Duration(milliseconds: 5200)),
    restOnFlower: (Duration(seconds: 3), Duration(seconds: 8)),
    bubble: Duration(milliseconds: 2600),
  );
}

final visitorTimingProvider = Provider<VisitorTiming>(
  (_) => VisitorTiming.natural,
);

final visitorRandomProvider = Provider<math.Random>((_) => math.Random());

enum Visitor { bee, butterfly }

extension VisitorArt on Visitor {
  String get asset => switch (this) {
    Visitor.bee => Anim.honeyBee,
    Visitor.butterfly => Anim.butterflyOrange,
  };

  double get size => switch (this) {
    Visitor.bee => 64,
    Visitor.butterfly => 78,
  };

  /// The bee is drawn facing right; the butterfly is seen from above.
  bool get flipsWhenHeadingLeft => this == Visitor.bee;

  double get wobble => this == Visitor.bee ? 6 : 12;

  String get label => switch (this) {
    Visitor.bee => 'A bee',
    Visitor.butterfly => 'A butterfly',
  };

  List<String> get lines => switch (this) {
    Visitor.bee => const [
      'Bzzz! Hello there! 🍯',
      'Busy busy, making honey for our home 💛',
      'You found me! Bzz bzz 🐝',
      'Is that a flower… oh, it is you! 🌼',
    ],
    Visitor.butterfly => const [
      'Flutter flutter~ 🦋',
      'The wind told me to come and see you 🌸',
      'Tap-tap! That tickles! 💗',
      'Shh… I am dancing with the breeze 🍃',
    ],
  };
}

/// Lives above the whole viewer (see `main_viewer.dart`). Everywhere it is
/// not drawing a visitor it lets touches through to the screen beneath.
class GardenVisitors extends ConsumerStatefulWidget {
  const GardenVisitors({super.key});

  @override
  ConsumerState<GardenVisitors> createState() => _GardenVisitorsState();
}

class _GardenVisitorsState extends ConsumerState<GardenVisitors>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Created in initState: a lazily made controller first touched in
  // dispose() would look up TickerMode on a widget already on its way out.
  late final AnimationController _wings;
  AnimationController? _leg;
  Timer? _timer;
  Timer? _bubbleTimer;

  Visitor? _visitor;
  int _visitId = 0;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  bool _resting = false;
  bool _leaving = false;
  int _stopsLeft = 0;
  String? _bubble;

  Size _screen = Size.zero;
  bool _reduceMotion = false;
  bool _inBackground = false;

  VisitorTiming get _timing => ref.read(visitorTimingProvider);
  math.Random get _random => ref.read(visitorRandomProvider);

  bool get _allowed =>
      ref.read(visitorsEnabledProvider) &&
      ref.read(visitorsHeldProvider) == 0 &&
      !_reduceMotion &&
      !_inBackground;

  @override
  void initState() {
    super.initState();
    _wings = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addObserver(this);
    _schedule(_timing.firstVisit);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _bubbleTimer?.cancel();
    _leg?.dispose();
    _wings.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inBackground = state != AppLifecycleState.resumed;
    _recheck();
  }

  Duration _between((Duration, Duration) range) {
    final span = range.$2.inMilliseconds - range.$1.inMilliseconds;
    final extra = span <= 0 ? 0 : _random.nextInt(span + 1);
    return range.$1 + Duration(milliseconds: extra);
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _arrive);
  }

  /// A setting or the screen changed: send the visitor away at once, or let
  /// one come if the way is clear and nobody is on the way.
  void _recheck() {
    if (!mounted) return;
    if (!_allowed) {
      _timer?.cancel();
      _timer = null;
      if (_visitor != null) _gone();
      return;
    }
    if (_visitor == null && _timer == null) {
      _schedule(_between(_timing.betweenVisits));
    }
  }

  void _arrive() {
    _timer = null;
    if (!mounted || !_allowed) return;
    if (_screen == Size.zero) {
      // Not laid out yet; look again shortly.
      _schedule(const Duration(seconds: 1));
      return;
    }
    final visitor = _random.nextInt(10) < 6 ? Visitor.bee : Visitor.butterfly;
    setState(() {
      _visitor = visitor;
      _visitId++;
      _resting = false;
      _leaving = false;
      _bubble = null;
      _stopsLeft = 1 + _random.nextInt(3);
      _from = _offscreen(visitor);
      _to = _from;
    });
    _wings.repeat();
    _flyTo(_flowerSpot());
  }

  Offset _offscreen(Visitor visitor) {
    final w = _screen.width, h = _screen.height, s = visitor.size;
    return switch (_random.nextInt(3)) {
      0 => Offset(-s, h * (0.2 + 0.5 * _random.nextDouble())),
      1 => Offset(w + s, h * (0.2 + 0.5 * _random.nextDouble())),
      _ => Offset(w * (0.15 + 0.7 * _random.nextDouble()), -s),
    };
  }

  /// Somewhere a flower might be: never the very top, never the far edges.
  Offset _flowerSpot() {
    final w = _screen.width, h = _screen.height;
    return Offset(
      w * (0.12 + 0.76 * _random.nextDouble()),
      h * (0.22 + 0.62 * _random.nextDouble()),
    );
  }

  void _flyTo(Offset target) {
    final start = _position();
    _leg?.dispose();
    _from = start;
    _to = target;
    final leg = AnimationController(
      vsync: this,
      duration: _between(_timing.flightLeg),
    );
    _leg = leg;
    leg.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      // Off the controller's own notification before touching it.
      scheduleMicrotask(() {
        if (mounted && _leg == leg) _arrived();
      });
    });
    leg.forward();
    setState(() {});
  }

  void _arrived() {
    if (_visitor == null) return;
    if (_leaving) {
      _gone();
      return;
    }
    setState(() => _resting = true);
    _wings.stop();
    _timer?.cancel();
    _timer = Timer(_between(_timing.restOnFlower), () {
      _timer = null;
      if (!mounted || _visitor == null) return;
      setState(() => _resting = false);
      _wings.repeat();
      _stopsLeft--;
      if (_stopsLeft <= 0 || !_allowed) {
        _leaving = true;
        _flyTo(_offscreen(_visitor!));
      } else {
        _flyTo(_flowerSpot());
      }
    });
  }

  void _gone() {
    _timer?.cancel();
    _timer = null;
    _bubbleTimer?.cancel();
    _leg?.dispose();
    _leg = null;
    _wings.stop();
    if (mounted) {
      setState(() {
        _visitor = null;
        _bubble = null;
        _resting = false;
        _leaving = false;
      });
      if (_allowed) _schedule(_between(_timing.betweenVisits));
    }
  }

  void _poke() {
    final visitor = _visitor;
    if (visitor == null) return;
    final line = visitor.lines[_random.nextInt(visitor.lines.length)];
    _bubbleTimer?.cancel();
    setState(() => _bubble = line);
    // A touched visitor hangs in the air a moment, listening.
    _leg?.stop();
    _bubbleTimer = Timer(_timing.bubble, () {
      if (!mounted) return;
      setState(() => _bubble = null);
      final leg = _leg;
      if (leg != null && !leg.isCompleted) leg.forward();
    });
  }

  Offset _position() {
    final leg = _leg;
    final visitor = _visitor;
    if (leg == null || visitor == null) return _to;
    final t = Curves.easeInOutSine.transform(leg.value);
    final base = Offset.lerp(_from, _to, t)!;
    // A little bob that settles as it lands.
    final bob =
        math.sin(leg.value * math.pi * 3) * visitor.wobble * (1 - t / 2);
    return base + Offset(0, bob);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(visitorsEnabledProvider, (_, _) => _recheck());
    ref.listen<int>(visitorsHeldProvider, (_, _) => _recheck());
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      WidgetsBinding.instance.addPostFrameCallback((_) => _recheck());
    }
    final lang = ref.watch(langProvider);
    final visitor = _visitor;
    return LayoutBuilder(
      builder: (context, constraints) {
        _screen = constraints.biggest;
        if (visitor == null) return const SizedBox.expand();
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _leg ?? const AlwaysStoppedAnimation<double>(0),
            builder: (context, _) {
              final p = _position();
              final flip = visitor.flipsWhenHeadingLeft && _to.dx < _from.dx;
              final size = visitor.size;
              return Stack(
                children: [
                  Positioned(
                    left: p.dx - size / 2,
                    top: p.dy - size / 2,
                    width: size,
                    height: size,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _poke,
                      child: Semantics(
                        button: true,
                        label: trS(lang, visitor.label),
                        child: Transform.flip(
                          flipX: flip,
                          child: Lottie.asset(
                            visitor.asset,
                            key: ValueKey(_visitId),
                            controller: _wings,
                            frameRate: const FrameRate(20),
                            fit: BoxFit.contain,
                            onLoaded: (composition) {
                              _wings.duration = composition.duration;
                              if (!_resting && _visitor != null) {
                                _wings.repeat();
                              }
                            },
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_bubble != null)
                    Positioned(
                      left: (p.dx - 110).clamp(
                        8.0,
                        math.max(8.0, _screen.width - 228),
                      ),
                      top: math.max(8.0, p.dy - size / 2 - 54),
                      width: 220,
                      child: IgnorePointer(
                        child: _SpeechBubble(
                          key: const Key('visitor-bubble'),
                          text: trS(lang, _bubble!),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // The overlay sits above the Navigator, outside any Material, and text
    // drawn there falls back to a bare font with yellow underlines.
    return Material(
      type: MaterialType.transparency,
      child: Align(
        child:
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9EC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE6CFA6)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4B3A33),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 160.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 220.ms,
                  curve: Curves.easeOutBack,
                ),
      ),
    );
  }
}
