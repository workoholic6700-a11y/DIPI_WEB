import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/i18n/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../home_atmosphere.dart';

/// **The front door** — the way out to Rai Village.
///
/// Deliberately does NOT redraw the village. Painting a miniature landscape
/// here would put two versions of the same world in the app and make the real
/// one feel like a copy. What you get is a door, standing ajar, with light and
/// a suggestion of green coming through the gap — enough to know there is
/// somewhere out there. The actual world is on the other side of the tap.
class FrontDoor extends ConsumerWidget {
  const FrontDoor({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final atmos = ref.watch(atmosphereProvider);
    final night = atmos.hour == HomeHour.night;

    return Semantics(
      button: true,
      label: trS(lang, 'The front door. Steps outside into Rai Village.'),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 108,
          decoration: BoxDecoration(
            color: atmos.frameWood,
            borderRadius: AppDimens.brMd,
            boxShadow: [
              BoxShadow(
                  color: atmos.shelfShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                children: [
                  // The gap: outside light, warm at night, green by day.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: night
                              ? const [
                                  Color(0xFF20301F),
                                  Color(0xFF4C5F3A),
                                  Color(0xFF8C7A46),
                                ]
                              : const [
                                  Color(0xFF4C7A44),
                                  Color(0xFF8FB86B),
                                  Color(0xFFE4E9C4),
                                ],
                        ),
                      ),
                    ),
                  ),
                  // The door itself, swung part-way open from the left —
                  // stiles, two recessed panels and a brass handle, so it
                  // reads as a door rather than a brown rectangle.
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 122,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.lerp(atmos.frameWood, Colors.black, 0.34)!,
                            Color.lerp(atmos.frameWood, Colors.black, 0.08)!,
                          ],
                        ),
                        border: Border(
                          right: BorderSide(
                            color: Color.lerp(
                                atmos.frameWood, Colors.black, 0.45)!,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // The two panels.
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(11, 11, 6, 11),
                              child: Column(
                                children: [
                                  for (var i = 0; i < 2; i++) ...[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.lerp(atmos.frameWood,
                                              Colors.black, 0.22),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: Border.all(
                                            color: Color.lerp(atmos.frameWood,
                                                Colors.black, 0.48)!,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (i == 0) const SizedBox(height: 7),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // The handle, on the opening edge.
                          Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8C87A),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFF7A5A20)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 3,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8B96A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // The words, out in the light.
                  Positioned(
                    right: 14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trS(lang, 'Rai Village'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 6),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trS(lang, 'Step outside  →'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(color: Colors.black38, blurRadius: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
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
