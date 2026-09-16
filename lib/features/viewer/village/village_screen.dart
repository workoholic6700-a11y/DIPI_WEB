import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/people.dart';
import '../../../data/providers/content_providers.dart';
import '../../../data/providers/heritage_providers.dart';
import 'day_night.dart';
import 'chautari_story_circle.dart';
import 'family_conversations.dart';
import 'family_diorama.dart';
import 'family_thread.dart';
import 'village_ambience.dart';
import 'village_discovery_book.dart';
import 'village_experiences.dart';
import 'village_festivals.dart';
import 'village_kindness.dart';
import 'village_map.dart';
import 'village_photography.dart';
import 'village_rhythm.dart';
import 'village_season.dart';
import 'village_weather.dart';
import 'yard_life.dart';
import 'nature/animal_sheds.dart';
import 'nature/farm_animals.dart';
import 'nature/ground_river_painter.dart';
import 'nature/homestead_yard.dart';
import 'nature/hill_country_painter.dart';
import 'nature/ilam_flora_widgets.dart';
import 'nature/ilam_village_widgets.dart';
import 'nature/nepali_farmers.dart';
import 'nature/our_house.dart';
import 'nature/sakela_than.dart';
import 'nature/sky_clouds_birds.dart';
import 'nature/sky_mountains.dart';
import 'nature/terrace_fields_painter.dart';
import 'nature/village_widgets.dart';

/// Rai Village — an optional, explorable landscape that *opens* the existing
/// screens. Drag to walk around, pinch to zoom, tap a building to visit it.
/// Nothing here duplicates data; every tap pushes a real route.
class VillageScreen extends ConsumerStatefulWidget {
  const VillageScreen({super.key});

  @override
  ConsumerState<VillageScreen> createState() => _VillageScreenState();
}

enum _VillageZone { memories, homestead, heart, fields, viewpoint }

class _VillageScreenState extends ConsumerState<VillageScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _tc = TransformationController();
  final _ambience = VillageAmbienceController();
  final _villageCaptureKey = GlobalKey();
  late final AnimationController _cam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..addListener(() => _tc.value = _camTween.evaluate(_camCurve));
  // One shared, slow clock drives the Village's ambient motion. Sharing this
  // controller keeps the scene alive without creating a ticker per object.
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();
  late final Animation<double> _camCurve = CurvedAnimation(
    parent: _cam,
    curve: Curves.easeInOutCubic,
  );
  Matrix4Tween _camTween = Matrix4Tween(
    begin: Matrix4.identity(),
    end: Matrix4.identity(),
  );
  bool _started = false;
  bool _interacting = false;
  bool _hasExplored = false;
  // The Village is first experienced as one complete place. From here the
  // family can pinch in or choose an area to see its smaller living moments.
  bool _overview = true;
  _VillageZone _zone = _VillageZone.homestead;
  Landmark? _selectedLandmark;
  VillageStoryWalk? _walk;
  int _walkStep = 0;
  VillageDiscovery? _discovery;
  bool _soundEnabled = true;
  bool _activitiesOpen = false;
  bool _kindnessMode = false;
  bool _storyCircleOpen = false;
  VillageFestival _festival = VillageFestival.auto;
  FamilyMember? _threadMember;
  bool _photoMode = false;
  bool _capturingPhoto = false;
  VillagePhase? _ambiencePhase;
  VillageSeason? _ambienceSeason;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ambience.dispose();
    _cam.dispose();
    _life.dispose();
    _tc.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_life.isAnimating) _life.repeat();
      _syncAmbience();
    } else {
      _life.stop();
      unawaited(_ambience.pause());
    }
  }

  // The close zone view crops the emptiest sky so the village fills the phone.
  // A separate fit scale allows a genuine whole-village overview.
  static const double _skyCrop = 0.38;

  double _restScale(Size vp) => vp.height / (kWorldHeight * (1 - _skyCrop));

  double _overviewScale(Size vp) =>
      math.min(vp.width / kWorldWidth, vp.height / kWorldHeight) * 0.96;

  double _zoneX(_VillageZone zone) => switch (zone) {
    _VillageZone.memories => 0.16,
    _VillageZone.homestead => 0.33,
    _VillageZone.heart => 0.52,
    _VillageZone.fields => 0.70,
    _VillageZone.viewpoint => 0.88,
  };

  String _zoneLabel(_VillageZone zone) => switch (zone) {
    _VillageZone.memories => 'Memory Hills',
    _VillageZone.homestead => 'Homestead',
    _VillageZone.heart => 'Village Heart',
    _VillageZone.fields => 'Fields & Library',
    _VillageZone.viewpoint => 'Viewpoint',
  };

  void _syncAmbience({_VillageZone? zone, bool? overview}) {
    if (!mounted) return;
    final showOverview = overview ?? _overview;
    unawaited(
      _ambience.update(
        area: showOverview ? 'overview' : (zone ?? _zone).name,
        season: _ambienceSeason ?? villageSeasonFor(DateTime.now()),
        phase: _ambiencePhase ?? ref.read(villagePhaseProvider),
        enabled: _soundEnabled,
      ),
    );
  }

  void _toggleSound() {
    HapticFeedback.selectionClick();
    setState(() => _soundEnabled = !_soundEnabled);
    _syncAmbience();
  }

  Future<void> _chooseFestival() async {
    final selected = await showVillageFestivalChooser(context, _festival);
    if (selected == null || !mounted) return;
    setState(() => _festival = selected);
  }

  Future<void> _chooseFamilyThread(Size vp) async {
    final member = await showFamilyThreadChooser(
      context,
      ref.read(familyProvider),
    );
    if (member == null || !mounted) return;
    setState(() {
      _threadMember = member;
      _activitiesOpen = false;
      _overview = true;
      _selectedLandmark = null;
      _discovery = null;
      _walk = null;
      _walkStep = 0;
      _kindnessMode = false;
      _storyCircleOpen = false;
    });
    _animateTo(_overviewMatrix(vp), d: const Duration(milliseconds: 520));
  }

  void _enterPhotographyMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _photoMode = true;
      _activitiesOpen = false;
      _capturingPhoto = false;
      _selectedLandmark = null;
      _discovery = null;
      _walk = null;
      _walkStep = 0;
      _kindnessMode = false;
      _storyCircleOpen = false;
      _threadMember = null;
    });
  }

  void _exitPhotographyMode() {
    if (_capturingPhoto) return;
    setState(() => _photoMode = false);
  }

  Future<void> _takeVillagePhoto() async {
    if (_capturingPhoto) return;
    setState(() => _capturingPhoto = true);
    try {
      final bytes = await captureVillageBoundary(_villageCaptureKey);
      if (!mounted) return;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The Village was not ready for a photo.'),
          ),
        );
        return;
      }
      await showVillagePostcardEditor(context, bytes);
    } finally {
      if (mounted) setState(() => _capturingPhoto = false);
    }
  }

  Matrix4 _zoneMatrix(Size vp, _VillageZone zone) {
    final s = _restScale(vp);
    final tx = vp.width / 2 - kWorldWidth * _zoneX(zone) * s;
    final ty = -kWorldHeight * _skyCrop * s;
    return Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(s, s, s, 1);
  }

  Matrix4 _overviewMatrix(Size vp) {
    final s = _overviewScale(vp);
    final tx = (vp.width - kWorldWidth * s) / 2;
    final ty = (vp.height - kWorldHeight * s) / 2;
    return Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(s, s, s, 1);
  }

  void _showOverview(Size vp) {
    HapticFeedback.selectionClick();
    setState(() {
      _overview = true;
      _activitiesOpen = false;
      _interacting = false;
      _hasExplored = true;
      _selectedLandmark = null;
      _discovery = null;
      _walk = null;
      _walkStep = 0;
      _kindnessMode = false;
      _storyCircleOpen = false;
    });
    _animateTo(_overviewMatrix(vp), d: const Duration(milliseconds: 520));
    _syncAmbience(overview: true);
  }

  _VillageZone _zoneFor(Landmark landmark) {
    if (landmark.fx < 0.245) return _VillageZone.memories;
    if (landmark.fx < 0.44) return _VillageZone.homestead;
    if (landmark.fx < 0.61) return _VillageZone.heart;
    if (landmark.fx < 0.79) return _VillageZone.fields;
    return _VillageZone.viewpoint;
  }

  void _goToZone(Size vp, _VillageZone zone) {
    if (_zone != zone ||
        _interacting ||
        _overview ||
        _storyCircleOpen ||
        _kindnessMode) {
      setState(() {
        _zone = zone;
        _overview = false;
        _activitiesOpen = false;
        _interacting = false;
        _hasExplored = true;
        _storyCircleOpen = false;
        _kindnessMode = false;
      });
    }
    _animateTo(_zoneMatrix(vp, zone), d: const Duration(milliseconds: 340));
    _syncAmbience(zone: zone);
  }

  void _finishExploring(Size vp) {
    final inverse = Matrix4.inverted(_tc.value);
    final worldCenter = MatrixUtils.transformPoint(
      inverse,
      Offset(vp.width / 2, vp.height / 2),
    );
    final zone = _VillageZone.values.reduce((a, b) {
      final ad = (worldCenter.dx / kWorldWidth - _zoneX(a)).abs();
      final bd = (worldCenter.dx / kWorldWidth - _zoneX(b)).abs();
      return ad <= bd ? a : b;
    });
    final overview = _tc.value.getMaxScaleOnAxis() <= _overviewScale(vp) * 1.14;
    // A free drag must remain where the person left it. We only update which
    // area's labels and ambience are active; the explicit bottom buttons are
    // the controls that intentionally recenter the camera.
    setState(() {
      _zone = zone;
      _overview = overview;
      if (overview) _activitiesOpen = false;
      _interacting = false;
      _hasExplored = true;
    });
    _syncAmbience(zone: zone, overview: overview);
  }

  Matrix4 _focusMatrix(Size vp, Offset world, double scale) {
    final tx = vp.width / 2 - world.dx * scale;
    final ty = vp.height / 2 - world.dy * scale;
    return Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void _animateTo(
    Matrix4 target, {
    Duration d = const Duration(milliseconds: 800),
  }) {
    _camTween = Matrix4Tween(begin: _tc.value, end: target);
    _cam.duration = d;
    _cam.forward(from: 0);
  }

  void _selectLandmark(Size vp, Landmark l) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLandmark = l;
      _activitiesOpen = false;
      _discovery = null;
      _kindnessMode = false;
      _storyCircleOpen = false;
      _threadMember = null;
      _overview = false;
      _zone = _zoneFor(l);
    });
    _animateTo(
      _focusMatrix(vp, l.worldPos, _restScale(vp) * 1.28),
      d: const Duration(milliseconds: 420),
    );
  }

  void _closeExperience(Size vp) {
    setState(() => _selectedLandmark = null);
    _animateTo(_zoneMatrix(vp, _zone), d: const Duration(milliseconds: 340));
  }

  Future<void> _openRoute(Size vp, String route) async {
    setState(() {
      _selectedLandmark = null;
      _discovery = null;
      _activitiesOpen = false;
    });
    await _ambience.pause();
    if (!mounted) return;
    if (route == Routes.home) {
      context.go(route);
      return;
    }
    await context.push(route);
    if (!mounted) return;
    _syncAmbience();
    _animateTo(_zoneMatrix(vp, _zone), d: const Duration(milliseconds: 620));
  }

  Future<void> _chooseWalk(Size vp) async {
    final walk = await showVillageWalkChooser(context);
    if (walk == null || !mounted) return;
    setState(() {
      _walk = walk;
      _activitiesOpen = false;
      _walkStep = 0;
      _selectedLandmark = null;
      _discovery = null;
      _hasExplored = true;
      _storyCircleOpen = false;
    });
    _focusWalkStop(vp);
  }

  void _focusWalkStop(Size vp) {
    final walk = _walk;
    if (walk == null) return;
    final label = walk.stops[_walkStep];
    final landmark = kLandmarks.firstWhere((l) => l.label == label);
    final zone = _zoneFor(landmark);
    setState(() {
      _zone = zone;
      _overview = false;
    });
    _syncAmbience(zone: zone);
    _animateTo(
      _focusMatrix(vp, landmark.worldPos, _restScale(vp) * 1.18),
      d: const Duration(milliseconds: 480),
    );
  }

  void _nextWalkStop(Size vp) {
    final walk = _walk;
    if (walk == null) return;
    if (_walkStep == walk.stops.length - 1) {
      _endWalk(vp);
      return;
    }
    setState(() => _walkStep++);
    _focusWalkStop(vp);
  }

  void _previousWalkStop(Size vp) {
    if (_walk == null || _walkStep == 0) return;
    setState(() => _walkStep--);
    _focusWalkStop(vp);
  }

  void _endWalk(Size vp) {
    setState(() {
      _walk = null;
      _walkStep = 0;
    });
    _animateTo(_zoneMatrix(vp, _zone), d: const Duration(milliseconds: 360));
  }

  void _revealDiscovery(VillageDiscovery discovery) {
    HapticFeedback.lightImpact();
    unawaited(
      ref.read(villageDiscoveriesProvider.notifier).discover(discovery.id),
    );
    setState(() {
      _discovery = discovery;
      _selectedLandmark = null;
      _storyCircleOpen = false;
    });
  }

  /// Place a decorative widget at a fractional (fx, fy) ground point; (w, h)
  /// are the widget's footprint, used only to anchor its bottom-centre there.
  Widget _withLife(
    Widget child, {
    required double phase,
    double dx = 0,
    double dy = 0,
    double turn = 0,
  }) => AnimatedBuilder(
    animation: _life,
    child: child,
    builder: (context, child) {
      final angle = _life.value * math.pi * 8 + phase * math.pi * 2;
      return Transform.translate(
        offset: Offset(math.sin(angle * 0.5) * dx, -math.sin(angle) * dy),
        child: Transform.rotate(
          angle: math.sin(angle * 0.5) * turn,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
    },
  );

  Widget _at(
    double fx,
    double fy,
    double w,
    double h,
    Widget child, {
    double? lifePhase,
    double lifeDx = 0,
    double lifeDy = 0,
    double lifeTurn = 0,
    bool childAnimations = false,
  }) {
    Widget detail = IgnorePointer(
      child: TickerMode(enabled: childAnimations, child: child),
    );
    if (lifePhase != null) {
      detail = _withLife(
        detail,
        phase: lifePhase,
        dx: lifeDx,
        dy: lifeDy,
        turn: lifeTurn,
      );
    }
    return Positioned(
      left: kWorldWidth * fx - w / 2,
      top: kWorldHeight * fy - h,
      child: detail,
    );
  }

  /// Anchor a figure by its FEET at (fx, fy) — it grows upward (so speech
  /// bubbles float above). Used for the family, pets and their props.
  Widget _ground(
    double fx,
    double fy,
    double width,
    Widget child, {
    double? lifePhase,
  }) {
    Widget figure = IgnorePointer(
      child: TickerMode(enabled: false, child: child),
    );
    if (lifePhase != null) {
      figure = _withLife(
        figure,
        phase: lifePhase,
        dx: 0.7,
        dy: 1.8,
        turn: 0.008,
      );
    }
    return Positioned(
      left: kWorldWidth * fx - width / 2,
      bottom: kWorldHeight * (1 - fy),
      child: figure,
    );
  }

  /// The Rai family living in the village, near Our House. 💜
  List<Widget> _family(VillagePhase phase) => [
    _ground(0.205, 0.775, 220, const FieldPlot(width: 220)),
    _ground(0.352, 0.862, 320, const Aagan(width: 320)),
    _ground(0.520, 0.842, 70, const StubbyMemorial(size: 70)),
    ...switch (phase) {
      VillagePhase.dawn => [
        _ground(
          0.205,
          0.756,
          58,
          const FamilyCharacter(
            kind: PersonKind.boy,
            cloth: Color(0xFFC0453E),
            name: 'Papa',
            size: 58,
            holdEmoji: '🧺',
            bob: false,
          ),
          lifePhase: 0.08,
        ),
        _ground(
          0.345,
          0.842,
          58,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFFE8749E),
            name: 'Mummy',
            size: 58,
            holdEmoji: '🔥',
            facingLeft: true,
            bob: false,
          ),
          lifePhase: 0.42,
        ),
      ],
      VillagePhase.day => [
        _ground(
          0.250,
          0.752,
          52,
          const NamedFigure(name: 'Helper', child: FarmerPlanting(size: 52)),
          lifePhase: 0.74,
        ),
        _ground(
          0.185,
          0.756,
          58,
          const FamilyCharacter(
            kind: PersonKind.boy,
            cloth: Color(0xFFC0453E),
            name: 'Papa',
            size: 58,
            hair: Color(0xFF241812),
            facingLeft: true,
            bob: false,
          ),
          lifePhase: 0.12,
        ),
        _ground(
          0.105,
          0.754,
          58,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFFE8749E),
            name: 'Mummy',
            size: 58,
            hair: Color(0xFF241812),
            holdEmoji: '🫗',
            bob: false,
          ),
          lifePhase: 0.46,
        ),
        _ground(0.300, 0.848, 46, const StudyDesk(size: 46)),
        _ground(
          0.276,
          0.846,
          54,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFF9B72CF),
            name: 'Diksha',
            size: 54,
            holdEmoji: '📖',
            sitting: true,
            bob: false,
          ),
          lifePhase: 0.23,
        ),
        _ground(0.360, 0.848, 74, const StrawMat(width: 74)),
        _ground(
          0.360,
          0.842,
          54,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFFF2C879),
            name: 'Diya',
            size: 54,
            holdEmoji: '📖',
            bob: false,
          ),
          lifePhase: 0.68,
        ),
      ],
      VillagePhase.dusk => [
        _ground(0.345, 0.850, 122, const StrawMat(width: 122)),
        _ground(
          0.292,
          0.840,
          54,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFFE8749E),
            name: 'Mummy',
            size: 54,
            holdEmoji: '🍲',
            bob: false,
          ),
          lifePhase: 0.17,
        ),
        _ground(
          0.325,
          0.841,
          54,
          const FamilyCharacter(
            kind: PersonKind.boy,
            cloth: Color(0xFFC0453E),
            name: 'Papa',
            size: 54,
            bob: false,
          ),
          lifePhase: 0.43,
        ),
        _ground(
          0.362,
          0.842,
          52,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFF9B72CF),
            name: 'Diksha',
            size: 52,
            bob: false,
          ),
          lifePhase: 0.66,
        ),
        _ground(
          0.397,
          0.842,
          52,
          const FamilyCharacter(
            kind: PersonKind.girl,
            cloth: Color(0xFFF2C879),
            name: 'Diya',
            size: 52,
            bob: false,
          ),
          lifePhase: 0.89,
        ),
      ],
      VillagePhase.night => [
        _ground(0.347, 0.854, 118, const StrawMat(width: 118)),
      ],
    },
  ];

  /// The living details of the village — trees on the hills, a maize field
  /// being planted, rice paddies, haystacks, fences, a well, animals grazing
  /// and farmers at work. Ilam life. 🌿
  List<Widget> _scenery({required bool shelterAnimals}) => [
    // Trees on the hills
    _at(
      0.045,
      0.665,
      116,
      122,
      const VillageTree(height: 122, variant: 0),
      lifePhase: 0.10,
      lifeTurn: 0.006,
    ),
    _at(0.135, 0.635, 96, 100, const VillageTree(height: 100, variant: 1)),
    _at(
      0.820,
      0.600,
      124,
      130,
      const VillageTree(height: 130, variant: 2),
      lifePhase: 0.58,
      lifeTurn: 0.006,
    ),
    _at(0.955, 0.645, 104, 108, const VillageTree(height: 108, variant: 0)),
    // The sacred tree beside the Sakela Than grove.
    _at(0.450, 0.515, 92, 96, const VillageTree(height: 96, variant: 1)),
    // 🌿 Sakela Than — our Kirat sacred grove (Sumnima & Paruhang).
    _at(
      0.525,
      0.590,
      156,
      128,
      const SakelaThan(width: 156),
      lifePhase: 0.35,
      lifeTurn: 0.004,
    ),
    // Distant houses dotting the far ridges
    _at(0.340, 0.476, 34, 30, const DistantHouse(size: 34)),
    _at(0.440, 0.470, 30, 26, const DistantHouse(size: 30)),
    _at(0.700, 0.462, 34, 30, const DistantHouse(size: 34)),
    // Kirat prayer flags strung high over the hills
    _at(
      0.165,
      0.520,
      210,
      90,
      const PrayerFlags(width: 210),
      lifePhase: 0.18,
      lifeDy: 1.5,
      lifeTurn: 0.005,
    ),
    _at(
      0.665,
      0.500,
      180,
      80,
      const PrayerFlags(width: 180),
      lifePhase: 0.72,
      lifeDy: 1.5,
      lifeTurn: 0.005,
    ),
    // Pine & flowering trees + close tea-bush rows on the slopes
    _at(0.220, 0.600, 118, 118, const VillageTree2(size: 118, variant: 0)),
    _at(0.780, 0.585, 122, 122, const VillageTree2(size: 122, variant: 1)),
    _at(0.900, 0.635, 106, 106, const VillageTree2(size: 106, variant: 2)),
    _at(0.120, 0.700, 120, 44, const TeaBushRow(width: 120)),
    _at(0.860, 0.700, 120, 44, const TeaBushRow(width: 120)),
    // Chautari — sacred resting platform under a big tree
    _at(0.610, 0.725, 150, 150, const Chautari(size: 150)),
    // Banana plants
    _at(0.030, 0.748, 110, 116, const BananaTree(size: 110)),
    _at(0.955, 0.780, 110, 116, const BananaTree(size: 110)),
    // 🏡 Our family house + homestead buildings around it
    _at(
      0.315,
      0.792,
      150,
      156,
      const OurHouse(height: 156),
      childAnimations: true,
    ),
    _at(0.455, 0.820, 138, 154, const CowShed()), // the big goth
    _at(0.210, 0.800, 84, 80, const GoatShed()),
    _at(0.150, 0.852, 96, 72, const PigSty()),
    _at(0.400, 0.858, 58, 62, const OutsideToilet(size: 58)),
    // Haystacks (parali)
    _at(0.155, 0.850, 84, 72, const Haystack(height: 72)),
    _at(0.695, 0.830, 80, 68, const Haystack(height: 68)),
    // Maize field being planted
    _at(0.185, 0.860, 50, 60, const MaizeClump(height: 60)),
    _at(0.225, 0.885, 52, 64, const MaizeClump(height: 64)),
    _at(0.265, 0.860, 48, 58, const MaizeClump(height: 58)),
    _at(0.305, 0.885, 52, 64, const MaizeClump(height: 64)),
    _at(0.205, 0.905, 50, 60, const MaizeClump(height: 60)),
    _at(0.285, 0.915, 50, 60, const MaizeClump(height: 60)),
    // Rice paddies near the river
    _at(0.460, 0.855, 42, 40, const RicePaddyTuft(size: 42)),
    _at(0.515, 0.865, 44, 42, const RicePaddyTuft(size: 44)),
    _at(0.570, 0.855, 40, 38, const RicePaddyTuft(size: 40)),
    // Fences & a stone well
    _at(0.350, 0.905, 160, 46, const WoodenFence(width: 160, height: 46)),
    _at(0.620, 0.895, 140, 44, const WoodenFence(width: 140, height: 44)),
    _at(0.415, 0.860, 90, 110, const StoneWell(height: 110)),
    // Bushes & flowers
    _at(0.085, 0.905, 70, 50, const Bush(width: 70, seed: 1)),
    _at(0.660, 0.915, 70, 50, const Bush(width: 70, seed: 2)),
    _at(0.905, 0.900, 70, 50, const Bush(width: 70, seed: 3)),
    _at(0.130, 0.945, 60, 40, const FlowerCluster(width: 60, seed: 1)),
    _at(0.375, 0.950, 60, 40, const FlowerCluster(width: 60, seed: 2)),
    _at(0.520, 0.955, 60, 40, const FlowerCluster(width: 60, seed: 3)),
    _at(0.780, 0.940, 60, 40, const FlowerCluster(width: 60, seed: 4)),
    // Animals graze in dry weather and gather beside the sheds in monsoon.
    if (!shelterAnimals) ...[
      _at(
        0.245,
        0.925,
        64,
        50,
        const Cow(width: 64),
        lifePhase: 0.12,
        lifeDy: 1.4,
      ),
      _at(
        0.730,
        0.905,
        72,
        55,
        const Buffalo(width: 72),
        lifePhase: 0.47,
        lifeDy: 1.1,
      ),
      _at(
        0.340,
        0.950,
        22,
        22,
        const Hen(size: 22),
        lifePhase: 0.21,
        lifeDy: 2.2,
        lifeTurn: 0.018,
      ),
      _at(
        0.365,
        0.962,
        20,
        20,
        const Hen(size: 20),
        lifePhase: 0.56,
        lifeDy: 2.0,
        lifeTurn: 0.018,
      ),
      _at(
        0.560,
        0.935,
        22,
        22,
        const Hen(size: 22),
        lifePhase: 0.82,
        lifeDy: 2.1,
        lifeTurn: 0.018,
      ),
    ] else ...[
      _at(
        0.435,
        0.835,
        58,
        46,
        const Cow(width: 58),
        lifePhase: 0.12,
        lifeDy: 1.2,
      ),
      _at(
        0.470,
        0.836,
        65,
        50,
        const Buffalo(width: 65),
        lifePhase: 0.47,
        lifeDy: 1.0,
      ),
      _at(
        0.205,
        0.825,
        34,
        34,
        const Goat(size: 34),
        lifePhase: 0.27,
        lifeDy: 1.8,
        lifeTurn: 0.012,
      ),
      _at(
        0.228,
        0.830,
        31,
        31,
        const Goat(size: 31),
        lifePhase: 0.68,
        lifeDy: 1.7,
        lifeTurn: 0.012,
      ),
      _at(
        0.325,
        0.875,
        20,
        20,
        const Hen(size: 20),
        lifePhase: 0.35,
        lifeDy: 2.0,
        lifeTurn: 0.018,
      ),
      _at(
        0.342,
        0.880,
        18,
        18,
        const Hen(size: 18),
        lifePhase: 0.79,
        lifeDy: 1.8,
        lifeTurn: 0.018,
      ),
    ],
    // A couple of villagers up on the terraces (not in the water)
    _at(
      0.660,
      0.720,
      30,
      44,
      const FarmerCuttingGrass(size: 44),
      lifePhase: 0.63,
      lifeDy: 1.5,
    ),
    // Ilam crops, water spout, goats, marigolds, villagers & farm birds
    _at(0.075, 0.870, 70, 70, const Dhara(size: 70)),
    if (!shelterAnimals) ...[
      _at(
        0.700,
        0.905,
        40,
        40,
        const Goat(size: 40),
        lifePhase: 0.17,
        lifeDy: 1.8,
        lifeTurn: 0.012,
      ),
      _at(
        0.735,
        0.918,
        36,
        36,
        const Goat(size: 36),
        lifePhase: 0.61,
        lifeDy: 1.7,
        lifeTurn: 0.012,
      ),
    ],
    _at(
      0.055,
      0.800,
      70,
      74,
      const CardamomPlant(size: 70),
      lifePhase: 0.14,
      lifeTurn: 0.009,
    ),
    _at(0.095, 0.830, 64, 68, const CardamomPlant(size: 64)),
    _at(0.640, 0.860, 64, 68, const MilletStalk(size: 64)),
    _at(
      0.675,
      0.888,
      60,
      64,
      const MilletStalk(size: 60),
      lifePhase: 0.53,
      lifeTurn: 0.010,
    ),
    _at(0.400, 0.900, 90, 40, const MarigoldRow(width: 90)),
    _at(0.520, 0.925, 90, 40, const MarigoldRow(width: 90)),
    _at(0.640, 0.895, 32, 46, const Villager(size: 46, variant: 1)),
    _at(0.355, 0.945, 24, 24, const Rooster(size: 24)),
    _at(0.315, 0.956, 24, 22, const Duck(size: 24)),
    // Homestead yard: fish pond, potted flowers in the aagan, veg patch
    _at(0.540, 0.905, 150, 62, const FishPond(width: 150)),
    _at(0.360, 0.882, 130, 60, const PottedGarden(width: 130)),
    _at(0.630, 0.885, 120, 58, const VegPatch(width: 120)),
  ];

  Widget _discoveryAt({
    required double fx,
    required double fy,
    required String label,
    required VoidCallback onTap,
  }) {
    if (_photoMode) return const SizedBox.shrink();
    return Positioned(
      left: kWorldWidth * fx - 19,
      top: kWorldHeight * fy - 19,
      width: 38,
      height: 38,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFE8C76D),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 9,
                color: Color(0xFF5A3D28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnreadLetter = ref.watch(unopenedLettersProvider).isNotEmpty;
    final unopenedCount = ref.watch(unopenedLettersProvider).length;
    final timelineCount = ref.watch(timelineProvider).length;
    final petsCount = ref.watch(petsProvider).length;
    final family = ref.watch(familyProvider);
    final familyCount = family.length;
    final albumsCount = ref.watch(albumsProvider).length;
    final storyCount = ref.watch(storyProvider).length;
    final roots = ref.watch(rootsProvider);
    final tally = ref.watch(heritageTallyProvider);
    final heritageWords = ref.watch(heritageWordsProvider);
    final memory = ref.watch(memoryOfDayProvider);
    final memories = ref.watch(memoriesProvider);
    final quote = ref.watch(quoteOfDayProvider);
    final dipisha = family.firstWhere((m) => m.id == 'f_dipisha');
    final stubby = family.firstWhere((m) => m.id == 'f_stubby');
    final featuredWord = heritageWords.first;
    final phase = ref.watch(villagePhaseProvider);
    final season = villageSeasonFor(DateTime.now());
    if (_ambiencePhase != phase || _ambienceSeason != season) {
      _ambiencePhase = phase;
      _ambienceSeason = season;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncAmbience());
    }
    var nextBirthdayDays = 366;
    var festivalPersonName = 'Our family';
    var festivalPersonEmoji = '🎂';
    for (final date in MockData.confirmedBirthdays.values) {
      final days = date.daysUntilNextAnniversary();
      if (days < nextBirthdayDays) nextBirthdayDays = days;
    }
    for (final member in family) {
      final date = MockData.confirmedBirthdays[member.id];
      if (date == null) continue;
      final days = date.daysUntilNextAnniversary();
      if (days == nextBirthdayDays) {
        festivalPersonName = member.name.split(' ').first;
        festivalPersonEmoji = member.emoji;
        break;
      }
    }
    final resolvedFestival = resolveVillageFestival(
      selected: _festival,
      now: DateTime.now(),
      birthdays: MockData.confirmedBirthdays.values,
      memories: memories.map((m) => m.date),
    );

    int archiveCount(Landmark landmark) => switch (landmark.label) {
      'Memory Tree' => timelineCount,
      'Pet Park' => petsCount,
      'Family House' => albumsCount,
      'Family' => familyCount,
      'Mailbox' => unopenedCount,
      'Flower Garden' => familyCount - petsCount,
      'Sakela Than' => tally.traditions,
      'Library' => storyCount + tally.words + tally.recipes + tally.places,
      'Viewpoint' => roots.length,
      _ => 0,
    };

    return Scaffold(
      backgroundColor: const Color(0xFF86C5E8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final vp = Size(constraints.maxWidth, constraints.maxHeight);
          if (!_started) {
            _started = true;
            // Open on the complete world, so nowhere feels like the Village's
            // only starting point, then settle once into the homestead. This
            // phone is 720 wide and the world is 2200: held at fit-width the
            // whole village is a ~330px strip in a screenful of empty sky,
            // too small to read. The entrance plays once and stops; the
            // whole-map view stays one tap away on the "All" button.
            _tc.value = _overviewMatrix(vp);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _syncAmbience(overview: true);
            });
            Future.delayed(const Duration(milliseconds: 850), () {
              // A drag during the pause means they are already exploring —
              // never pull the camera out from under them.
              if (!mounted || _interacting || _hasExplored) return;
              setState(() {
                _overview = false;
                _zone = _VillageZone.homestead;
              });
              _animateTo(
                _zoneMatrix(vp, _VillageZone.homestead),
                d: const Duration(milliseconds: 1500),
              );
              _syncAmbience(zone: _VillageZone.homestead, overview: false);
            });
          }
          return Stack(
            children: [
              RepaintBoundary(
                key: _villageCaptureKey,
                child: InteractiveViewer(
                  transformationController: _tc,
                  constrained: false,
                  minScale: _overviewScale(vp),
                  maxScale: _restScale(vp) * 1.35,
                  boundaryMargin: EdgeInsets.zero,
                  onInteractionStart: (_) {
                    _cam.stop();
                    setState(() {
                      _interacting = true;
                      _hasExplored = true;
                      _overview = false;
                      _activitiesOpen = false;
                      _storyCircleOpen = false;
                      _kindnessMode = false;
                    });
                  },
                  onInteractionEnd: (_) => _finishExploring(vp),
                  child: SizedBox(
                    width: kWorldWidth,
                    height: kWorldHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Natural landscape, painted back → front ──
                        const Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(painter: SkyMountainsPainter()),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: DriftingClouds(
                            width: kWorldWidth,
                            height: kWorldHeight * 0.5,
                            motion: _life,
                          ),
                        ),
                        Positioned(
                          left: kWorldWidth * 0.27,
                          top: kWorldHeight * 0.11,
                          child: BirdFlock(
                            width: 240,
                            height: 96,
                            motion: _life,
                          ),
                        ),
                        Positioned(
                          left: kWorldWidth * 0.60,
                          top: kWorldHeight * 0.17,
                          child: BirdFlock(
                            width: 170,
                            height: 74,
                            motion: _life,
                          ),
                        ),
                        // Rolling Ilam hills + tea gardens (fills the mid band).
                        const Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(painter: HillCountryPainter()),
                          ),
                        ),
                        const Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(painter: TerraceFieldsPainter()),
                          ),
                        ),
                        const Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(painter: GroundRiverPainter()),
                          ),
                        ),
                        // ── Living details: trees, crops, animals, farmers ──
                        ..._scenery(
                          shelterAnimals: season == VillageSeason.monsoon,
                        ),
                        // ── The Rai family, living in the village ──
                        ..._family(phase),
                        VillageRhythmLayer(
                          width: kWorldWidth,
                          height: kWorldHeight,
                          phase: phase,
                        ),
                        // Static seasonal details derived from the local date.
                        const VillageSeasonLayer(
                          width: kWorldWidth,
                          height: kWorldHeight,
                        ),
                        VillageFestivalLayer(
                          width: kWorldWidth,
                          height: kWorldHeight,
                          festival: resolvedFestival,
                          personName: festivalPersonName,
                          personEmoji: festivalPersonEmoji,
                          memoryTitle: memory.title,
                        ),
                        // ── The living yard: Dipisha & the pets, simply alive ──
                        Positioned(
                          left: kWorldWidth * 0.335,
                          top: kWorldHeight * 0.665,
                          width: kWorldWidth * 0.225,
                          height: kWorldHeight * 0.135,
                          child: YardLife(
                            width: kWorldWidth * 0.225,
                            height: kWorldHeight * 0.135,
                            phase: phase,
                            motion: _life,
                          ),
                        ),
                        // ── Wooden welcome sign ──
                        Positioned(
                          left: kWorldWidth * 0.33 - 92,
                          top: kWorldHeight * 0.235,
                          child: const _WelcomeSign(),
                        ),
                        // ── Dawn / day / dusk / night over the valley ──
                        const DayNightLayer(
                          width: kWorldWidth,
                          height: kWorldHeight,
                          lamps: [
                            // Our House: two windows, warm at night.
                            (fx: 0.295, fy: 0.735, r: 34),
                            (fx: 0.338, fy: 0.735, r: 34),
                            // The chulo's glow, low in the aagan.
                            (fx: 0.352, fy: 0.845, r: 26),
                            // A lantern in the big goth.
                            (fx: 0.455, fy: 0.770, r: 30),
                          ],
                        ),
                        VillageWeatherLayer(
                          width: kWorldWidth,
                          height: kWorldHeight,
                          season: season,
                          phase: phase,
                          motion: _life,
                        ),
                        Positioned.fill(
                          child: VillageKindnessLayer(
                            width: kWorldWidth,
                            height: kWorldHeight,
                            active:
                                _kindnessMode &&
                                !_overview &&
                                !_interacting &&
                                _selectedLandmark == null &&
                                _walk == null &&
                                _discovery == null,
                            onRoute: (route) => _openRoute(vp, route),
                          ),
                        ),
                        Positioned.fill(
                          child: VillageFamilyMoments(
                            width: kWorldWidth,
                            height: kWorldHeight,
                            enabled:
                                !_photoMode &&
                                !_kindnessMode &&
                                !_overview &&
                                !_interacting &&
                                _selectedLandmark == null &&
                                _walk == null &&
                                _discovery == null,
                            conversationsEnabled: phase == VillagePhase.day,
                            phase: phase,
                            season: season,
                          ),
                        ),
                        // Discoveries appear only after entering an area, so
                        // the opening overview remains a clean village map.
                        if (!_overview && !_photoMode) ...[
                          _discoveryAt(
                            fx: 0.15,
                            fy: 0.70,
                            label: 'Listen to a deep sound from the old forest',
                            onTap: () {
                              if (_soundEnabled) {
                                unawaited(_ambience.playForestDiscovery());
                              }
                              _revealDiscovery(
                                VillageDiscovery(
                                  id: 'forest_echo',
                                  emoji: '🌲',
                                  title: 'An echo from the forest',
                                  body: _soundEnabled
                                      ? 'A deep forest sound is hidden beside the Memory Tree.'
                                      : 'Turn on Village sound to hear this forest discovery.',
                                  route: Routes.timeline,
                                ),
                              );
                            },
                          ),
                          _discoveryAt(
                            fx: 0.54,
                            fy: 0.90,
                            label: 'A family memory reflected in the pond',
                            onTap: () => _revealDiscovery(
                              VillageDiscovery(
                                id: 'pond_memory',
                                emoji: '💧',
                                title: 'A reflection from the family album',
                                body: memory.title,
                                route: Routes.memoryOf(memory.id),
                              ),
                            ),
                          ),
                          _discoveryAt(
                            fx: 0.66,
                            fy: 0.50,
                            label: 'A family saying tied to the prayer flags',
                            onTap: () => _revealDiscovery(
                              VillageDiscovery(
                                id: 'prayer_flag_saying',
                                emoji: '🎏',
                                title: 'A saying carried by the wind',
                                body: '“${quote.text}” — ${quote.author}',
                                route: Routes.quotes,
                              ),
                            ),
                          ),
                          _discoveryAt(
                            fx: 0.47,
                            fy: 0.95,
                            label: 'The bridge between family places',
                            onTap: () => _revealDiscovery(
                              VillageDiscovery(
                                id: 'family_bridge',
                                emoji: '🧭',
                                title: 'The road between our places',
                                body: roots.isEmpty
                                    ? 'The family journey is waiting to be kept.'
                                    : roots.map((r) => r.place).join(' → '),
                                route: Routes.heritageRoots,
                              ),
                            ),
                          ),
                          _discoveryAt(
                            fx: 0.580,
                            fy: 0.900,
                            label:
                                'A flower connected to someone in the family',
                            onTap: () => _revealDiscovery(
                              VillageDiscovery(
                                id: 'garden_flower',
                                emoji: '🌸',
                                title:
                                    'A flower for ${dipisha.name.split(' ').first}',
                                body:
                                    'The garden keeps a path back to her family page.',
                                route: Routes.memberOf(dipisha.id),
                              ),
                            ),
                          ),
                          _discoveryAt(
                            fx: 0.485,
                            fy: 0.565,
                            label: 'A Rai word resting near Sakela Than',
                            onTap: () => _revealDiscovery(
                              VillageDiscovery(
                                id: 'sakela_word',
                                emoji: '🌿',
                                title:
                                    '${featuredWord.word} · ${featuredWord.roman}',
                                body: featuredWord.meaning,
                                route: Routes.heritageWords,
                              ),
                            ),
                          ),
                          _discoveryAt(
                            fx: 0.520,
                            fy: 0.840,
                            label: 'Stubby’s paw mark beside the memorial',
                            onTap: () => _revealDiscovery(
                              VillageDiscovery(
                                id: 'stubby_paw',
                                emoji: '🐾',
                                title: 'Stubby’s paw mark',
                                body: stubby.bio,
                                route: Routes.memberOf(stubby.id),
                              ),
                            ),
                          ),
                        ],
                        // ── Tappable places (always on top) ──
                        for (final l in kLandmarks)
                          Positioned(
                            left: l.worldPos.dx - 62,
                            top: l.worldPos.dy - 116,
                            width: 124,
                            child: _LandmarkView(
                              landmark: l,
                              showLabel:
                                  !_photoMode &&
                                  !_interacting &&
                                  !_overview &&
                                  !_storyCircleOpen &&
                                  _threadMember == null &&
                                  _zoneFor(l) == _zone &&
                                  (_selectedLandmark == null ||
                                      _selectedLandmark == l),
                              hasUnreadLetter: hasUnreadLetter,
                              archiveCount: _photoMode || _overview
                                  ? 0
                                  : archiveCount(l),
                              celebrationSoon:
                                  !_photoMode &&
                                  !_overview &&
                                  l.label == 'Celebration Hall' &&
                                  nextBirthdayDays <= 14,
                              onTap: _photoMode
                                  ? () {}
                                  : () => _selectLandmark(vp, l),
                            ),
                          ),
                        if (_threadMember != null)
                          Positioned.fill(
                            child: FamilyThreadLayer(
                              member: _threadMember!,
                              onRoute: (route) => _openRoute(vp, route),
                            ),
                          ),
                        Positioned.fill(
                          child: ChautariStoryCircle(
                            width: kWorldWidth,
                            height: kWorldHeight,
                            enabled:
                                _storyCircleOpen ||
                                (!_photoMode &&
                                    !_overview &&
                                    !_interacting &&
                                    !_kindnessMode &&
                                    _threadMember == null &&
                                    _selectedLandmark == null &&
                                    _walk == null &&
                                    _discovery == null),
                            onOpenChanged: (open) {
                              setState(() {
                                _storyCircleOpen = open;
                                if (open) {
                                  _activitiesOpen = false;
                                  _kindnessMode = false;
                                }
                              });
                            },
                            onRoute: (route) => _openRoute(vp, route),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_photoMode)
                _TopBar(
                  showHint: !_hasExplored,
                  zoneLabel: _overview ? 'Whole Village' : _zoneLabel(_zone),
                  soundEnabled: _soundEnabled,
                  onSoundTap: _toggleSound,
                ),
              if (!_photoMode &&
                  _zone == _VillageZone.heart &&
                  !_overview &&
                  !_interacting &&
                  _selectedLandmark == null &&
                  _walk == null &&
                  _discovery == null &&
                  !_storyCircleOpen &&
                  _threadMember == null)
                Positioned(
                  right: 12,
                  top: MediaQuery.paddingOf(context).top + 70,
                  child: VillageNoticeBoard(
                    onRoute: (route) => _openRoute(vp, route),
                  ),
                ),
              if (!_photoMode &&
                  !_overview &&
                  !_interacting &&
                  _selectedLandmark == null &&
                  _walk == null &&
                  _discovery == null &&
                  !_storyCircleOpen &&
                  _threadMember == null)
                Positioned(
                  right: 12,
                  bottom: MediaQuery.paddingOf(context).bottom + 74,
                  child: _VillageActivitiesMenu(
                    expanded: _activitiesOpen,
                    kindnessActive: _kindnessMode,
                    festivalEmoji: resolvedFestival.emoji,
                    onToggle: () =>
                        setState(() => _activitiesOpen = !_activitiesOpen),
                    onWalk: () {
                      setState(() => _activitiesOpen = false);
                      unawaited(_chooseWalk(vp));
                    },
                    onKindness: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _activitiesOpen = false;
                        _kindnessMode = !_kindnessMode;
                      });
                    },
                    onThread: () {
                      setState(() => _activitiesOpen = false);
                      unawaited(_chooseFamilyThread(vp));
                    },
                    onFestival: () {
                      setState(() => _activitiesOpen = false);
                      unawaited(_chooseFestival());
                    },
                    onBook: () {
                      setState(() => _activitiesOpen = false);
                      unawaited(showVillageDiscoveryBook(context));
                    },
                    onCamera: _enterPhotographyMode,
                  ),
                ),
              if (!_photoMode)
                _ZoneGuide(
                  selected: _zone,
                  overview: _overview,
                  onOverview: () => _showOverview(vp),
                  onSelected: (zone) => _goToZone(vp, zone),
                ),
              if (_selectedLandmark != null)
                Positioned(
                  left: 9,
                  right: 9,
                  bottom: MediaQuery.paddingOf(context).bottom + 58,
                  child: VillageExperiencePanel(
                    landmark: _selectedLandmark!,
                    onClose: () => _closeExperience(vp),
                    onRoute: (route) => _openRoute(vp, route),
                  ).animate().fadeIn(duration: 220.ms).moveY(begin: 18, end: 0),
                )
              else if (_walk != null)
                Positioned(
                  left: 9,
                  right: 9,
                  bottom: MediaQuery.paddingOf(context).bottom + 58,
                  child: VillageStoryWalkBar(
                    walk: _walk!,
                    step: _walkStep,
                    onBack: _walkStep == 0 ? null : () => _previousWalkStop(vp),
                    onNext: () => _nextWalkStop(vp),
                    onClose: () => _endWalk(vp),
                  ).animate().fadeIn(duration: 200.ms).moveY(begin: 14, end: 0),
                )
              else if (_discovery != null)
                Positioned(
                  left: 9,
                  right: 9,
                  bottom: MediaQuery.paddingOf(context).bottom + 58,
                  child: VillageDiscoveryToast(
                    discovery: _discovery!,
                    onOpen: () => _openRoute(vp, _discovery!.route),
                    onClose: () => setState(() => _discovery = null),
                  ).animate().fadeIn(duration: 180.ms).moveY(begin: 12, end: 0),
                ),
              if (_threadMember != null)
                Positioned(
                  left: 9,
                  right: 9,
                  bottom: MediaQuery.paddingOf(context).bottom + 58,
                  child: FamilyThreadBar(
                    member: _threadMember!,
                    onChange: () => _chooseFamilyThread(vp),
                    onClose: () => setState(() => _threadMember = null),
                  ),
                ),
              if (_photoMode)
                VillagePhotographyOverlay(
                  phase: phase,
                  festivalLabel: resolvedFestival.label,
                  capturing: _capturingPhoto,
                  onPhase: (selectedPhase) => ref
                      .read(villageTimeProvider.notifier)
                      .select(selectedPhase),
                  onFestival: _chooseFestival,
                  onCapture: _takeVillagePhoto,
                  onClose: _exitPhotographyMode,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _VillageActivitiesMenu extends StatelessWidget {
  const _VillageActivitiesMenu({
    required this.expanded,
    required this.kindnessActive,
    required this.festivalEmoji,
    required this.onToggle,
    required this.onWalk,
    required this.onKindness,
    required this.onThread,
    required this.onFestival,
    required this.onBook,
    required this.onCamera,
  });

  final bool expanded;
  final bool kindnessActive;
  final String festivalEmoji;
  final VoidCallback onToggle;
  final VoidCallback onWalk;
  final VoidCallback onKindness;
  final VoidCallback onThread;
  final VoidCallback onFestival;
  final VoidCallback onBook;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: expanded ? 'Village activities menu' : 'Open Village activities',
    child: AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomRight,
      child: Material(
        color: const Color(0xF7FFF9EE),
        elevation: 7,
        shadowColor: const Color(0x550E2917),
        borderRadius: BorderRadius.circular(expanded ? 20 : 24),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: expanded ? 226 : 166,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onToggle,
                child: SizedBox(
                  height: 46,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Row(
                      children: [
                        const Text('🏡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Village activities',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF3F362C),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (kindnessActive && !expanded)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8F63C7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Icon(
                          expanded
                              ? Icons.close_rounded
                              : Icons.expand_less_rounded,
                          size: 19,
                          color: const Color(0xFF5D7E52),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (expanded) ...[
                const Divider(height: 1, color: Color(0x1F5D493B)),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _VillageActivityTile(
                        emoji: '🧵',
                        label: 'Walk',
                        onTap: onWalk,
                      ),
                      _VillageActivityTile(
                        emoji: kindnessActive ? '💜' : '🧺',
                        label: kindnessActive ? 'Helping' : 'Kindness',
                        active: kindnessActive,
                        onTap: onKindness,
                      ),
                      _VillageActivityTile(
                        emoji: '🪡',
                        label: 'Thread',
                        onTap: onThread,
                      ),
                      _VillageActivityTile(
                        emoji: festivalEmoji,
                        label: 'Festival',
                        onTap: onFestival,
                      ),
                      _VillageActivityTile(
                        emoji: '📔',
                        label: 'Book',
                        onTap: onBook,
                      ),
                      _VillageActivityTile(
                        emoji: '🌸',
                        label: 'Camera',
                        onTap: onCamera,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _VillageActivityTile extends StatelessWidget {
  const _VillageActivityTile({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: active,
    label: label,
    child: Material(
      color: active ? const Color(0xFFE9DDF7) : const Color(0xFFFFFDF8),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 102,
          height: 49,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4B3528),
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

// ─────────────────────────────────────────────────────────────────────────
//  Top bar: back + title + explore hint
// ─────────────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  const _TopBar({
    required this.showHint,
    required this.zoneLabel,
    required this.soundEnabled,
    required this.onSoundTap,
  });

  final bool showHint;
  final String zoneLabel;
  final bool soundEnabled;
  final VoidCallback onSoundTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final subtitle = showHint
        ? lang == AppLang.ne
              ? 'घुम्न तान्नुहोस् · ठाउँ छुनुहोस्'
              : 'Drag to explore · tap a place to visit'
        : zoneLabel;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            _RoundBtn(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang == AppLang.ne ? 'राई गाउँ' : 'Rai Village',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                    ),
                  ),
                ],
              ),
            ),
            _VillageSoundButton(enabled: soundEnabled, onTap: onSoundTap),
            const SizedBox(width: 7),
            const DayNightButton(),
          ],
        ),
      ),
    );
  }
}

class _VillageSoundButton extends StatelessWidget {
  const _VillageSoundButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = enabled ? 'Mute Village sounds' : 'Play Village sounds';
    return Semantics(
      button: true,
      toggled: enabled,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.white.withValues(alpha: 0.92),
          elevation: 3,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    enabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: const Color(0xFF3A2E4D),
                    size: 21,
                  ),
                  if (enabled)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 3.5,
                        backgroundColor: Color(0xFF5D7E52),
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
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to Our Home',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Icon(icon, color: const Color(0xFF3A2E4D), size: 22),
        ),
      ),
    );
  }
}

class _ZoneGuide extends StatelessWidget {
  const _ZoneGuide({
    required this.selected,
    required this.overview,
    required this.onOverview,
    required this.onSelected,
  });

  final _VillageZone selected;
  final bool overview;
  final VoidCallback onOverview;
  final ValueChanged<_VillageZone> onSelected;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Center(
          child: Material(
            color: const Color(0xEBFFF8EC),
            elevation: 5,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _overviewButton(),
                  _zoneButton(
                    zone: _VillageZone.memories,
                    icon: Icons.history_rounded,
                    label: 'Memories',
                  ),
                  _zoneButton(
                    zone: _VillageZone.homestead,
                    icon: Icons.home_rounded,
                    label: 'House',
                  ),
                  _zoneButton(
                    zone: _VillageZone.heart,
                    icon: Icons.park_rounded,
                    label: 'Than',
                  ),
                  _zoneButton(
                    zone: _VillageZone.fields,
                    icon: Icons.menu_book_rounded,
                    label: 'Fields',
                  ),
                  _zoneButton(
                    zone: _VillageZone.viewpoint,
                    icon: Icons.landscape_rounded,
                    label: 'View',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _zoneButton({
    required _VillageZone zone,
    required IconData icon,
    required String label,
  }) {
    final active = !overview && selected == zone;
    return Semantics(
      button: true,
      selected: active,
      label: '$label village area',
      child: InkWell(
        onTap: () => onSelected(zone),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: active ? 12 : 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF5D7E52) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : const Color(0xFF5D493B),
              ),
              if (active) ...[
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewButton() {
    return Semantics(
      button: true,
      selected: overview,
      label: 'Show the whole village',
      child: InkWell(
        onTap: onOverview,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: overview ? 12 : 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: overview ? const Color(0xFF5D7E52) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.travel_explore_rounded,
                size: 16,
                color: overview ? Colors.white : const Color(0xFF5D493B),
              ),
              if (overview) ...[
                const SizedBox(width: 5),
                const Text(
                  'All',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  Landmark = stylized building + label, tappable
// ─────────────────────────────────────────────────────────────────────────
class _LandmarkView extends StatelessWidget {
  const _LandmarkView({
    required this.landmark,
    required this.showLabel,
    required this.hasUnreadLetter,
    required this.archiveCount,
    required this.celebrationSoon,
    required this.onTap,
  });

  final Landmark landmark;
  final bool showLabel;
  final bool hasUnreadLetter;
  final int archiveCount;
  final bool celebrationSoon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${landmark.label}. Opens this place.',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Center(child: _art()),
                  if (archiveCount > 0)
                    Positioned(
                      top: 2,
                      right: 6,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8C76D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          '$archiveCount',
                          style: const TextStyle(
                            color: Color(0xFF4B3528),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  if (celebrationSoon)
                    const Positioned(
                      left: 5,
                      top: 3,
                      child: Text('🎀', style: TextStyle(fontSize: 20)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: showLabel
                  ? _label()
                  : const SizedBox(key: ValueKey('quiet-label'), height: 24),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 360.ms);
  }

  Widget _label() => Container(
    key: ValueKey(landmark.label),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xEEFFF5E5),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: const Color(0xFF7B5A3B), width: 1.2),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Text(
      '${landmark.emoji} ${landmark.label}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF4B3528),
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _art() {
    switch (landmark.kind) {
      case LandmarkKind.house:
        return _house(const Color(0xFFF0E4CE), landmark.color);
      case LandmarkKind.hall:
        return _hut(landmark.color, const Color(0xFFF6EAD2), bunting: true);
      case LandmarkKind.library:
        return _hut(landmark.color, const Color(0xFFEADFC8));
      case LandmarkKind.tree:
        return _tree();
      case LandmarkKind.mailbox:
        return _mailbox(landmark.color, hasUnreadLetter);
      case LandmarkKind.portal:
        return _portal(landmark.color);
      case LandmarkKind.marker:
        return _marker(landmark.color, landmark.emoji);
    }
  }

  // A little cottage: glowing windows + smoke.
  Widget _house(Color body, Color roof) {
    return SizedBox(
      width: 92,
      height: 84,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 68,
              height: 46,
              decoration: BoxDecoration(
                color: body,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
                border: Border.all(color: const Color(0xFF5E3B26), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_window(), _window()],
              ),
            ),
          ),
          Positioned(
            top: 6,
            child: CustomPaint(
              size: const Size(84, 34),
              painter: _RoofPainter(roof),
            ),
          ),
        ],
      ),
    );
  }

  Widget _window() => Container(
    width: 13,
    height: 15,
    decoration: BoxDecoration(
      color: const Color(0xFFFFE29A),
      borderRadius: BorderRadius.circular(2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFD98A).withValues(alpha: 0.8),
          blurRadius: 8,
        ),
      ],
    ),
  );

  // Generic building for Library / Celebration Hall.
  Widget _hut(Color roof, Color body, {bool bunting = false}) {
    return SizedBox(
      width: 96,
      height: 84,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 74,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: body,
                border: Border.all(color: const Color(0xFF5E3B26), width: 1.5),
              ),
              child: Text(landmark.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          Positioned(
            top: 8,
            child: CustomPaint(
              size: const Size(90, 32),
              painter: _RoofPainter(roof),
            ),
          ),
          if (bunting)
            Positioned(
              top: 2,
              child: Row(
                children: List.generate(
                  7,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 10,
                    color: [
                      const Color(0xFFE8749E),
                      const Color(0xFF9B72CF),
                      const Color(0xFFF2C879),
                    ][i % 3],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tree() {
    return SizedBox(
      width: 84,
      height: 96,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(width: 12, height: 34, color: const Color(0xFF7A5136)),
          Positioned(
            top: 0,
            child: Container(
              width: 78,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  colors: [Color(0xFF8FC98A), Color(0xFF4F8A57)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mailbox(Color color, bool hasUnread) {
    return SizedBox(
      width: 40,
      height: 60,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(width: 6, height: 34, color: const Color(0xFF5E3B26)),
          Positioned(
            top: 0,
            child: Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                  bottom: Radius.circular(3),
                ),
                border: Border.all(color: const Color(0xFF5E3B26), width: 1.5),
              ),
              child: const Icon(
                Icons.mail_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            top: hasUnread ? 0 : 12,
            right: 0,
            child: Container(
              width: 3,
              height: 19,
              color: const Color(0xFF7A3D32),
              alignment: Alignment.topRight,
              child: Container(
                width: 12,
                height: 8,
                color: hasUnread
                    ? const Color(0xFFE8749E)
                    : const Color(0xFF9A8178),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _portal(Color color) {
    return Container(
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
          bottom: Radius.circular(10),
        ),
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          colors: [
            Colors.white.withValues(alpha: 0.95),
            color,
            color.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.7),
            blurRadius: 26,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('✨', style: TextStyle(fontSize: 22)),
    );
  }

  Widget _marker(Color color, String emoji) {
    return SizedBox(
      width: 56,
      height: 72,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(width: 5, height: 30, color: const Color(0xFF5E3B26)),
          Positioned(
            top: 0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoofPainter extends CustomPainter {
  const _RoofPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF5E3B26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _RoofPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────
//  Ambient clouds + a wooden welcome sign
// ─────────────────────────────────────────────────────────────────────────
class _WelcomeSign extends StatelessWidget {
  const _WelcomeSign();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFC9915F), Color(0xFF8A5A3C)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF5E3B26), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              children: [
                Text(
                  'Welcome to Rai Village',
                  style: TextStyle(
                    color: Color(0xFFFFF7EA),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Our Home · Our Story · Our Forever',
                  style: TextStyle(color: Color(0xFFF3E3D3), fontSize: 9),
                ),
              ],
            ),
          ),
          Container(width: 8, height: 26, color: const Color(0xFF5E3B26)),
        ],
      ),
    );
  }
}
