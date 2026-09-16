import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/web/phone_frame.dart';

/// Holds one screen in portrait, even when it was opened from a landscape one.
///
/// [LandscapeScope] locks Dipisha's World sideways and only hands portrait back
/// in `dispose`. But the screens you reach *from* the world are pushed on top
/// of it, so the world is still mounted, dispose hasn't run, and a letter ends
/// up being read sideways.
///
/// This wraps those screens: portrait on the way in, and — if we arrived from
/// a landscape screen — landscape handed back on the way out, so returning to
/// the world doesn't leave it stuck upright.
class PortraitScope extends StatefulWidget {
  const PortraitScope({super.key, required this.child});

  final Widget child;

  @override
  State<PortraitScope> createState() => _PortraitScopeState();
}

class _PortraitScopeState extends State<PortraitScope> {
  /// Whether the screen underneath us had locked itself sideways.
  bool _cameFromLandscape = false;

  // Web copy: back to the phone-width frame while this screen is on top.
  final Object _shape = ScreenShape.enter(landscape: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read once, on the first frame, before we change anything.
    _cameFromLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    if (_cameFromLandscape) {
      // Give the world its orientation back — its own LandscapeScope is still
      // mounted underneath and won't re-run initState when we pop.
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    ScreenShape.leave(_shape);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
