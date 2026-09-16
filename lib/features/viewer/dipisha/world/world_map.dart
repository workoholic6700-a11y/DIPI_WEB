import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';

/// What kind of thing you're looking at. Drives which widget paints it.
enum PlaceKind { house, room, tree, treehouse, garden, music, chest, trail }

/// One tappable place in Dipisha's World.
///
/// [fx]/[fy] are fractions of the world canvas (0–1). **These are traced from
/// the mockup**, so the composition matches even while the art is placeholder:
/// when a render replaces the painter, everything is already in the right spot.
class Place {
  const Place({
    required this.label,
    required this.ne,
    required this.kind,
    required this.fx,
    required this.fy,
    required this.route,
    required this.color,
    this.scale = 1.0,
    this.blurb,
  });

  final String label;
  final String ne;
  final PlaceKind kind;
  final double fx;
  final double fy;
  final String route;
  final Color color;

  /// Relative size, from the mockup. Our Home is the biggest thing in frame;
  /// the treasury hut is small. Hierarchy is composition, not decoration.
  final double scale;

  /// What she'd find there, in Nana's words.
  final String? blurb;
}

/// The painted world.
///
/// **This is the artwork, so the artwork sets the canvas.** `dipisha_world.png`
/// is 1672x941 (16:9); we work at 2x so it upscales cleanly on a 2400x1080
/// landscape screen. A phone is 2.22:1 and the art is 1.78:1, so covering the
/// screen would crop the treehouse off the left and her room off the right —
/// the two ends of the composition. Instead the camera rests fitted to WIDTH
/// (whole picture visible, a little sky-coloured margin top/bottom) and you can
/// zoom in from there.
const Size kWorldSize = Size(3344, 1882);

/// The world plate. Everything below is positioned as a fraction of it, traced
/// off this image — so if the art is ever re-rendered at a different size,
/// nothing here moves.
const String kWorldImage = 'assets/images/world/dipisha_world.png';

/// Eight seconds of the same locked composition coming gently to life.
/// This film is the one explicitly approved exception to the app's no-loop
/// rule. The PNG above stays underneath as the loading/decoder fallback.
const String kWorldVideo = 'assets/videos/dipisha_world.mp4';

/// Every place, positioned as in the mockup.
///
/// Left → right: Treehouse, Our Home (hero, centre-left), Garden (low left),
/// Treasury + Music Corner (centre, by the water), Memory Tree, Adventure Trail
/// (upper right, by the falls), Dipisha's Room (far right).
const List<Place> kPlaces = [
  Place(
    label: 'Treehouse',
    ne: 'रूख-घर',
    kind: PlaceKind.treehouse,
    fx: 0.153,
    fy: 0.282,
    scale: 1.0,
    route: Routes.letters,
    color: Color(0xFFE0A93E),
    blurb: 'Letters from Nana, for whenever you need them',
  ),
  Place(
    label: 'Our Home',
    ne: 'हाम्रो घर',
    kind: PlaceKind.house,
    fx: 0.383,
    fy: 0.383,
    scale: 1.5, // the hero of the frame
    route: Routes.gallery,
    color: Color(0xFFE8749E),
    blurb: 'Our family photos, kept together',
  ),
  Place(
    label: 'Garden',
    ne: 'फूलबारी',
    kind: PlaceKind.garden,
    fx: 0.299,
    fy: 0.579,
    scale: 1.0,
    route: Routes.garden,
    color: Color(0xFFF4A9C7),
    blurb: 'Our family garden, kept in one place',
  ),
  Place(
    label: 'Treasury',
    ne: 'खजाना',
    kind: PlaceKind.chest,
    fx: 0.752,
    fy: 0.606,
    scale: 0.8,
    route: Routes.surprise,
    color: Color(0xFFF2C879),
    blurb: 'Real messages, saved for the right day',
  ),
  Place(
    label: 'Music Corner',
    ne: 'संगीत कुना',
    kind: PlaceKind.music,
    fx: 0.643,
    fy: 0.595,
    scale: 0.9,
    route: Routes.voices,
    color: Color(0xFFA9D3F0),
    blurb: 'Voice messages kept by the family',
  ),
  Place(
    label: 'Memory Tree',
    ne: 'सम्झनाको रूख',
    kind: PlaceKind.tree,
    fx: 0.891,
    fy: 0.319,
    scale: 1.1,
    route: Routes.timeline,
    color: Color(0xFF4A8257),
    blurb: 'Our family story, year by year',
  ),
  Place(
    label: 'Adventure Trail',
    ne: 'यात्रा बाटो',
    kind: PlaceKind.trail,
    fx: 0.772,
    fy: 0.372,
    scale: 0.9,
    route: Routes.achievements,
    color: Color(0xFF6B3FA0),
    blurb: 'Still to add — Diksha will mark the trail',
  ),
  Place(
    label: 'Dipisha\'s Room',
    ne: 'दिपिशाको कोठा',
    kind: PlaceKind.room,
    fx: 0.879,
    fy: 0.659,
    scale: 1.0,
    route: Routes.dipishaRoom,
    color: Color(0xFF9B72CF),
    blurb: 'Still to add — Diksha will fill this room',
  ),
];

/// The rail down the left of the mockup. These are shortcuts *within* her
/// world, not the family app's menu.
const List<({String label, String ne, IconData icon, String route})> kRail = [
  (
    label: 'Home',
    ne: 'घर',
    icon: Icons.cottage_rounded,
    route: Routes.dipishaWorld,
  ),
  (
    label: 'Diary',
    ne: 'डायरी',
    icon: Icons.auto_stories_rounded,
    route: Routes.letters,
  ),
  (
    label: 'Treasures',
    ne: 'खजाना',
    icon: Icons.card_giftcard_rounded,
    route: Routes.surprise,
  ),
  (
    label: 'Memories',
    ne: 'सम्झना',
    icon: Icons.star_rounded,
    route: Routes.timeline,
  ),
];
