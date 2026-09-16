import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/web/phone_frame.dart';

/// Forces one screen into landscape, the way a game does.
///
/// The scrapbook is portrait — set once in `bootstrap.dart`, and right for
/// reading. But a world you explore is a game, and games are played sideways:
/// you pick up the phone, the world turns, and you turn the phone to meet it.
/// Free Fire doesn't ask; it just goes landscape. So does this.
///
/// The lock is handed back on the way out, so no other screen inherits it.
class LandscapeScope extends StatefulWidget {
  const LandscapeScope({super.key, required this.child});

  final Widget child;

  @override
  State<LandscapeScope> createState() => _LandscapeScopeState();
}

class _LandscapeScopeState extends State<LandscapeScope> {
  // Web copy: a browser can't be rotated, so the page frame widens instead.
  final Object _shape = ScreenShape.enter(landscape: true);

  @override
  void initState() {
    super.initState();
    // Sideways, both ways up — so it works whichever way she turns it.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Full screen too: no status bar, no nav bar. It's a world, not a page.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Hand portrait and the system bars back, exactly as bootstrap had them.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    ScreenShape.leave(_shape);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
