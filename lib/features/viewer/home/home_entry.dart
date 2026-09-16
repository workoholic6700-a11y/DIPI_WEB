import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_hub_screen.dart';
import 'room/home_atmosphere.dart';
import 'room/home_room_screen.dart';

/// Which Home `/home` actually shows.
///
/// "Inside Our Home" replaced a screen this family already knew by heart, so
/// the old hub is not deleted — it stays reachable from the bottom of the
/// family cabinet, and the choice is remembered. Nothing floats over the room
/// to advertise that: a debug-looking switch parked on top of the furniture is
/// exactly the kind of thing that makes an app feel like a prototype.
class HomeEntry extends ConsumerWidget {
  const HomeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(homeStyleProvider)) {
      HomeStyle.room => const HomeRoomScreen(),
      HomeStyle.classic => const HomeHubScreen(),
    };
  }
}
