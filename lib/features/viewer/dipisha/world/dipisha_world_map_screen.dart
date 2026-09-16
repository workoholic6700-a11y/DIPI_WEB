import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/i18n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/landscape_scope.dart';
import 'place_view.dart';
import 'world_map.dart';
import 'world_rail.dart';

/// **Dipisha's World** — an explorable place, not a screen of cards.
///
/// Landscape and fullscreen, the way a game is. You drag across a valley that
/// is wider than the phone, and you touch things: a treehouse, a memory tree, a
/// garden, a chest. Each one opens a screen that already existed — the world
/// doesn't duplicate anything, it just gives her things a *location*, so
/// finding them feels like finding them.
class DipishaWorldMapScreen extends ConsumerStatefulWidget {
  const DipishaWorldMapScreen({super.key});

  @override
  ConsumerState<DipishaWorldMapScreen> createState() =>
      _DipishaWorldMapScreenState();
}

class _DipishaWorldMapScreenState extends ConsumerState<DipishaWorldMapScreen>
    with SingleTickerProviderStateMixin {
  final _tc = TransformationController();
  late final VideoPlayerController _worldVideo;
  bool _worldVideoReady = false;
  bool _worldVideoStarted = false;
  bool _landscapeArrived = false;

  /// The one-shot camera fly-in, and later the focus-on-a-place move.
  late final AnimationController _cam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Matrix4Tween _camTween = Matrix4Tween(
    begin: Matrix4.identity(),
    end: Matrix4.identity(),
  );

  Place? _focused;
  bool _flewIn = false;

  /// The viewport the camera was last set up for.
  ///
  /// This screen's first frame is still **portrait** — `LandscapeScope` asks
  /// for rotation in initState, but the new size only arrives a frame or two
  /// later. Camera maths done on that first frame is computed for 720x1600 and
  /// is nonsense once the phone is landscape, which parks the world off-screen.
  /// So we remember the size we solved for and re-solve whenever it changes.
  Size? _lastVp;

  @override
  void initState() {
    super.initState();
    _worldVideo = VideoPlayerController.asset(kWorldVideo);
    _prepareWorldVideo();
    _cam.addListener(() {
      _tc.value = _camTween.evaluate(_cam);
    });
  }

  Future<void> _prepareWorldVideo() async {
    try {
      await _worldVideo.initialize();
      await _worldVideo.setLooping(true);
      await _worldVideo.setVolume(0);
      if (!mounted) return;
      setState(() => _worldVideoReady = true);
      if (_landscapeArrived) _startWorldVideo();
    } catch (_) {
      // The PNG beneath the video is the deliberate offline/decoder fallback.
      // A decorative clip must never cost Dipisha the world itself.
    }
  }

  Future<void> _startWorldVideo() async {
    if (!_worldVideoReady || _worldVideoStarted) return;
    _worldVideoStarted = true;
    await _worldVideo.seekTo(Duration.zero);
    await _worldVideo.play();
  }

  @override
  void dispose() {
    _worldVideo.dispose();
    _cam.dispose();
    _tc.dispose();
    super.dispose();
  }

  /// Smallest scale at which the world still **covers** the viewport.
  ///
  /// Fitting (scale to height) leaves the Scaffold showing at the edges — on a
  /// 1600x720 screen a 2200x1000 world fitted to height is 1584 wide, so you
  /// get a strip of background down each side. Covering means the sky always
  /// reaches the bezel, whichever way the phone is turned.
  double _restScale(Size vp) =>
      math.max(vp.width / kWorldSize.width, vp.height / kWorldSize.height);

  /// The resting camera: as much of the valley as the screen can hold, centred.
  Matrix4 _restMatrix(Size vp) => _focusMatrix(
    vp,
    Offset(kWorldSize.width / 2, kWorldSize.height / 2),
    _restScale(vp),
  );

  /// Keep the camera inside the world, so you can never drag the sky off and
  /// find the void behind it.
  Matrix4 _clamp(Size vp, Matrix4 m) {
    final s = m.getMaxScaleOnAxis();
    final w = kWorldSize.width * s, h = kWorldSize.height * s;
    var dx = m.getTranslation().x, dy = m.getTranslation().y;
    dx = w <= vp.width ? (vp.width - w) / 2 : dx.clamp(vp.width - w, 0.0);
    dy = h <= vp.height ? (vp.height - h) / 2 : dy.clamp(vp.height - h, 0.0);
    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      // Scale z with x and y. `getMaxScaleOnAxis` returns the largest of the
      // three axes, so leaving z at 1 while x and y are ~0.25 makes it report
      // 1.0 — and this method then rebuilds the matrix at that, throwing the
      // zoom away. That is what parked the valley at 4x on its top-left
      // corner and showed the treehouse instead of the whole picture.
      ..scaleByDouble(s, s, s, 1);
  }

  /// Put [world] in the middle of the viewport at [scale].
  Matrix4 _focusMatrix(Size vp, Offset world, double scale) {
    final dx = vp.width / 2 - world.dx * scale;
    final dy = vp.height / 2 - world.dy * scale;
    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void _animateTo(
    Size vp,
    Matrix4 target, {
    Curve curve = Curves.easeInOutCubic,
    int ms = 900,
  }) {
    _camTween = Matrix4Tween(begin: _tc.value, end: _clamp(vp, target));
    _cam
      ..duration = Duration(milliseconds: ms)
      ..reset()
      ..animateTo(1, curve: curve);
  }

  Offset _worldPos(Place p) =>
      Offset(kWorldSize.width * p.fx, kWorldSize.height * p.fy);

  /// Tap a place: the camera goes to it and it introduces itself. Tap again —
  /// on the card — to actually go in. Two steps, because arriving somewhere
  /// should feel like arriving.
  void _tapPlace(Size vp, Place p) {
    setState(() => _focused = p);
    _animateTo(vp, _focusMatrix(vp, _worldPos(p), _restScale(vp) * 1.9));
  }

  void _dismiss(Size vp) {
    setState(() => _focused = null);
    _animateTo(vp, _restMatrix(vp));
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);

    return LandscapeScope(
      child: Scaffold(
        backgroundColor: const Color(0xFF2A1F45),
        body: LayoutBuilder(
          builder: (context, box) {
            final vp = Size(box.maxWidth, box.maxHeight);

            // Solve the camera once per viewport — but never during build.
            //
            // Writing to the TransformationController inside build() means
            // InteractiveViewer re-clamps it against a layout it hasn't done
            // yet, and quietly mangles the value; that is why the world kept
            // ending up parked at the wrong zoom. Everything here waits for
            // the frame to exist first.
            //
            // The first frame is also still portrait (LandscapeScope's
            // rotation lands a frame or two later), so we wait for a landscape
            // viewport before spending the fly-in on it.
            if (vp.width > 0 && vp != _lastVp) {
              _lastVp = vp;
              final isLandscape = vp.width > vp.height;
              final flyNow = isLandscape && !_flewIn;
              if (flyNow) {
                _flewIn = true;
                _landscapeArrived = true;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (flyNow) {
                  _startWorldVideo();
                  // Start close on her room, then pull back to the whole
                  // valley: you arrive somewhere that's yours, then see where
                  // you are.
                  final room = kPlaces.firstWhere(
                    (p) => p.kind == PlaceKind.room,
                  );
                  _tc.value = _clamp(
                    vp,
                    _focusMatrix(vp, _worldPos(room), _restScale(vp) * 2.4),
                  );
                  _animateTo(
                    vp,
                    _restMatrix(vp),
                    curve: Curves.easeOutCubic,
                    ms: 1700,
                  );
                } else {
                  // Rotated or resized: just sit the camera correctly for the
                  // size we actually have.
                  //
                  // Stop the camera first. A move started for the previous
                  // viewport keeps writing through its listener every frame,
                  // so it overwrites this assignment and finishes on the old
                  // size's maths — which is how the valley ended up parked at
                  // portrait zoom, showing a quarter of the picture.
                  _cam.stop();
                  _tc.value = _clamp(vp, _restMatrix(vp));
                }
              });
            }

            return Stack(
              children: [
                InteractiveViewer(
                  transformationController: _tc,
                  // Never below cover, so the sky always reaches the bezel.
                  minScale: _restScale(vp),
                  maxScale: _restScale(vp) * 3.2,
                  // No margin: you cannot drag the world off and find the void.
                  boundaryMargin: EdgeInsets.zero,
                  constrained: false,
                  child: SizedBox(
                    width: kWorldSize.width,
                    height: kWorldSize.height,
                    child: Stack(
                      children: [
                        // The world. This is Diksha's artwork, not a drawing
                        // of one — everything below is positioned against it.
                        Positioned.fill(
                          child: Image.asset(
                            kWorldImage,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.medium,
                            // The plate is large; if it ever goes missing the
                            // world should still open, not show a red box.
                            errorBuilder: (_, _, _) =>
                                const ColoredBox(color: Color(0xFF1B2A4A)),
                          ),
                        ),
                        if (_worldVideoReady)
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: VideoPlayer(_worldVideo),
                            ),
                          ),
                        for (final p in kPlaces)
                          Positioned(
                            left: kWorldSize.width * p.fx - 150 * p.scale,
                            top: kWorldSize.height * p.fy - 110 * p.scale,
                            width: 300 * p.scale,
                            height: 220 * p.scale,
                            // Labels live in world units — at rest the plate
                            // is drawn at ~0.48, so a 12px label would render
                            // at 6px and be unreadable. Counter-scaling by
                            // 1/camera keeps them a constant *screen* size at
                            // every zoom, the way map pins behave.
                            child: AnimatedBuilder(
                              animation: _tc,
                              builder: (context, child) => Transform.scale(
                                scale: 1 / _tc.value.getMaxScaleOnAxis(),
                                child: child,
                              ),
                              child: PlaceView(
                                place: p,
                                lang: lang,
                                dimmed: _focused != null && _focused != p,
                                onTap: () => _tapPlace(vp, p),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Tapping the sky lets go of whatever you were looking at.
                if (_focused != null)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _dismiss(vp),
                    ),
                  ),

                _TopBar(lang: lang, onBack: () => context.pop()),

                // The rail floats over the world, glass, never Material.
                if (_focused == null)
                  WorldRail(
                    lang: lang,
                    onGo: (route) {
                      if (route != Routes.dipishaWorld) context.push(route);
                    },
                  ),

                if (_focused != null)
                  _PlaceCard(
                    place: _focused!,
                    lang: lang,
                    onEnter: () => context.push(_focused!.route),
                    onClose: () => _dismiss(vp),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.lang, required this.onBack});
  final AppLang lang;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoundButton(icon: Icons.arrow_back_rounded, onTap: onBack),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trS(lang, 'Dipisha\'s World'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                  ),
                ),
                Text(
                  trS(lang, 'A world made just for her'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11.5,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 20, color: const Color(0xFF5B2B8A)),
          ),
        ),
      ),
    );
  }
}

/// The card that slides in when you touch a place. It says what's there in her
/// words, and then you decide to go in.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.lang,
    required this.onEnter,
    required this.onClose,
  });

  final Place place;
  final AppLang lang;
  final VoidCallback onEnter;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang == AppLang.ne ? place.ne : place.label,
                        style: const TextStyle(
                          color: Color(0xFF3A2E4D),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (place.blurb != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          trS(lang, place.blurb!),
                          style: const TextStyle(
                            color: Color(0xFF7A6E8A),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: onEnter,
                  style: FilledButton.styleFrom(
                    backgroundColor: place.color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  child: Text(trS(lang, 'Go in')),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFFA99FB5),
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
