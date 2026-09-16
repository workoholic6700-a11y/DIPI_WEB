import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Asset paths for the Lottie animations Diksha picked out for this home.
///
/// All are LottieFiles community animations under the Lottie Simple License
/// (free to use, attribution encouraged not required). Credits live in
/// `assets/lottie/CREDITS.md`.
abstract final class Anim {
  Anim._();

  static const _b = 'assets/lottie';

  // Nature & garden
  static const cherryBlossom = '$_b/cherry_blossom.json';
  static const bloomingFlowers = '$_b/blooming_flowers.json';
  static const flowerGrowing = '$_b/flower_growing.json';
  static const flowerPetals = '$_b/flower_petals.json';
  static const treeInWind = '$_b/tree_in_wind.json';
  static const walkingPothos = '$_b/walking_pothos.json';
  static const girlWateringPlants = '$_b/girl_watering_plants.json';
  static const walkingOrange = '$_b/walking_orange.json';

  // Little lives
  static const honeyBee = '$_b/honey_bee.json';
  static const butterfly = '$_b/butterfly.json';
  static const butterflyOrange = '$_b/butterfly_orange.json';
  static const cutePig = '$_b/cute_pig.json';
  static const happyBird = '$_b/happy_bird.json';
  static const parrot = '$_b/parrot.json';
  static const birdPairLove = '$_b/bird_pair_love.json';
  static const heartValleyBirds = '$_b/heart_valley_birds.json';

  // Our pets & family
  static const danceCat = '$_b/dance_cat.json';
  static const cuteDoggie = '$_b/cute_doggie.json';
  static const dogPeeking = '$_b/dog_peeking.json';
  static const bunniesCuddle = '$_b/bunnies_cuddle.json';
  static const catCrying = '$_b/cat_crying.json';
  static const momAndKids = '$_b/mom_and_kids.json';
  static const girlCycling = '$_b/girl_cycling.json';
}

/// A Lottie animation with the safety rails this app needs.
///
/// Lottie throws at *runtime* on a missing/!malformed asset, which would take a
/// whole screen down. Since these are decorative, a failure here must never
/// cost Dipisha a page — [errorBuilder] degrades to empty space instead.
class LottieArt extends StatelessWidget {
  const LottieArt(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  final String asset;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final art = Lottie.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      // Decorative only — never let a bad asset break the page.
      errorBuilder: (_, _, _) => SizedBox(width: width, height: height),
    );
    if (semanticLabel == null) {
      return ExcludeSemantics(child: art);
    }
    return Semantics(label: semanticLabel, image: true, child: art);
  }
}
