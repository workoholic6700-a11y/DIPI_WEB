import 'package:flutter/material.dart';

import 'day_night.dart';

/// Small static props that make the selected time feel like a different part
/// of family life. Nothing in this layer owns a ticker.
class VillageRhythmLayer extends StatelessWidget {
  const VillageRhythmLayer({
    super.key,
    required this.width,
    required this.height,
    required this.phase,
  });

  final double width;
  final double height;
  final VillagePhase phase;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: switch (phase) {
          // The note sits on the terrace above the roof. Anchored over the
          // house it covered the roof, the aagan and whoever was standing in
          // it — the art is the point, the caption is not. Pushed off to the
          // side it left the visible band entirely, so it stays here, close
          // to the aagan it describes but clear of it.
          VillagePhase.dawn => [
            _prop(0.348, 0.795, '♨️', 25),
            _note(0.330, 0.642,'The chulo wakes first'),
            _prop(0.205, 0.735, '🧺', 22),
          ],
          VillagePhase.day => [
            _prop(0.118, 0.716, '💧', 18),
            _prop(0.132, 0.729, '💧', 14),
            _note(0.330, 0.642,'Study time in the aagan'),
          ],
          VillagePhase.dusk => [
            _prop(0.343, 0.824, '🧺', 20),
            _prop(0.366, 0.829, '🍽️', 19),
            _prop(0.389, 0.830, '🥣', 18),
            _note(0.330, 0.642,'Everyone comes back to the aagan'),
          ],
          VillagePhase.night => [
            _prop(0.295, 0.712, '💤', 17),
            _prop(0.338, 0.711, '💤', 14),
            _prop(0.448, 0.770, '💤', 14),
            _note(0.330, 0.642,'Books closed · the house is resting'),
          ],
        },
      ),
    );
  }

  Widget _prop(double fx, double fy, String emoji, double size) => Positioned(
    left: width * fx - size / 2,
    top: height * fy - size,
    child: Text(emoji, style: TextStyle(fontSize: size)),
  );

  Widget _note(double fx, double fy, String text) => Positioned(
    left: width * fx - 62,
    top: height * fy,
    width: 124,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xD6FFF7E8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0x44805B3C)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF5A4030),
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
