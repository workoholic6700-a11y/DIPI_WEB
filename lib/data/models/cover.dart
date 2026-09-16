import 'package:flutter/material.dart';

/// Deterministic pastel cover gradients used as placeholders for photos/covers
/// during the UI phase (no real images yet). A [seed] maps to a stable, pretty
/// gradient so the same item always looks the same.
abstract final class CoverPalette {
  CoverPalette._();

  static const List<List<Color>> _gradients = [
    [Color(0xFFB79BE0), Color(0xFF9B72CF)], // lavender
    [Color(0xFFFAD3E1), Color(0xFFF4A9C7)], // pink
    [Color(0xFFA9D3F0), Color(0xFF7FB8E6)], // sky
    [Color(0xFFF7D89B), Color(0xFFE0A93E)], // gold
    [Color(0xFFC7E9C0), Color(0xFF8FD08A)], // mint
    [Color(0xFFF3C4B4), Color(0xFFE79B84)], // peach
    [Color(0xFFD9C7F0), Color(0xFFB79BE0)], // lilac
    [Color(0xFFB4E4E0), Color(0xFF7FCFC8)], // aqua
  ];

  static LinearGradient gradient(int seed) {
    final colors = _gradients[seed.abs() % _gradients.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  static Color base(int seed) =>
      _gradients[seed.abs() % _gradients.length].first;

  /// A decorative icon to float on a placeholder cover.
  static IconData icon(int seed) {
    const icons = [
      Icons.local_florist_rounded,
      Icons.favorite_rounded,
      Icons.auto_awesome_rounded,
      Icons.cake_rounded,
      Icons.park_rounded,
      Icons.beach_access_rounded,
      Icons.celebration_rounded,
      Icons.pets_rounded,
    ];
    return icons[seed.abs() % icons.length];
  }
}
