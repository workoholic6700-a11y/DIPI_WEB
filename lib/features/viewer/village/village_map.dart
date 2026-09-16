import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';

/// The explorable world is one big landscape canvas; the camera pans/zooms
/// across it. These are its logical dimensions (device-independent pixels).
const double kWorldWidth = 2200;
const double kWorldHeight = 1040;

/// The kind of stylized art drawn for a landmark.
enum LandmarkKind { house, tree, mailbox, portal, hall, library, marker }

/// A tappable place in Rai Village. Tapping it flies the camera over and then
/// opens the matching EXISTING screen — the village never stores its own data.
class Landmark {
  const Landmark({
    required this.label,
    required this.emoji,
    required this.kind,
    required this.fx,
    required this.fy,
    required this.route,
    required this.color,
  });

  final String label;
  final String emoji;
  final LandmarkKind kind;

  /// Position as a fraction (0..1) of the world width/height.
  final double fx;
  final double fy;

  final String route;
  final Color color;

  Offset get worldPos => Offset(fx * kWorldWidth, fy * kWorldHeight);
}

/// Every place in the village → the real screen it opens.
const List<Landmark> kLandmarks = [
  Landmark(
    label: 'Memory Tree',
    emoji: '🌳',
    kind: LandmarkKind.tree,
    fx: 0.11,
    fy: 0.60,
    route: Routes.timeline,
    color: Color(0xFF5C9A63),
  ),
  Landmark(
    label: 'Pet Park',
    emoji: '🐾',
    kind: LandmarkKind.marker,
    fx: 0.20,
    fy: 0.80,
    route: Routes.pets,
    color: Color(0xFFE79B84),
  ),
  Landmark(
    label: 'Family House',
    emoji: '🏡',
    kind: LandmarkKind.house,
    fx: 0.33,
    fy: 0.62,
    route: Routes.gallery,
    color: Color(0xFFC25B4E),
  ),
  Landmark(
    label: 'Family',
    emoji: '👪',
    kind: LandmarkKind.marker,
    fx: 0.40,
    fy: 0.80,
    route: Routes.members,
    color: Color(0xFF7FB8E6),
  ),
  Landmark(
    label: 'Mailbox',
    emoji: '📬',
    kind: LandmarkKind.mailbox,
    fx: 0.47,
    fy: 0.68,
    route: Routes.letters,
    color: Color(0xFFB56FC0),
  ),
  Landmark(
    label: 'Flower Garden',
    emoji: '🌸',
    kind: LandmarkKind.marker,
    fx: 0.55,
    fy: 0.82,
    route: Routes.garden,
    color: Color(0xFFE8749E),
  ),
  Landmark(
    label: 'Sakela Than',
    emoji: '🌿',
    kind: LandmarkKind.marker,
    fx: 0.525,
    fy: 0.515,
    route: Routes.sakela,
    color: Color(0xFF5C9A4E),
  ),
  Landmark(
    label: 'Library',
    emoji: '📖',
    kind: LandmarkKind.library,
    fx: 0.62,
    fy: 0.60,
    route: Routes.ourStory,
    color: Color(0xFF9B72CF),
  ),
  Landmark(
    label: 'Celebration Hall',
    emoji: '🎂',
    kind: LandmarkKind.hall,
    fx: 0.74,
    fy: 0.62,
    route: Routes.hall,
    color: Color(0xFFE0A93E),
  ),
  Landmark(
    label: 'Viewpoint',
    emoji: '🌄',
    kind: LandmarkKind.marker,
    fx: 0.85,
    fy: 0.46,
    route: Routes.places,
    color: Color(0xFF4FB0A8),
  ),
  Landmark(
    label: "Dipisha's World",
    emoji: '✨',
    kind: LandmarkKind.portal,
    fx: 0.91,
    fy: 0.66,
    route: Routes.dipishaGate,
    color: Color(0xFF9B5CC0),
  ),
];
