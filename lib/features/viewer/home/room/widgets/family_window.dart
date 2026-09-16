import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/i18n/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../widgets/two_skies.dart';
import '../home_atmosphere.dart';

/// **The family window** — the same Two Skies, but as a thing in the wall.
///
/// It was a rounded card with a shadow, which is why it read as a component on
/// a page. A window is not a card: it has a timber frame, a sill it sits on, a
/// bar across the middle, and the light coming through it belongs to the room.
///
/// Nothing about the sky logic changed — [TwoSkies] already runs on real local
/// time for Ilam and for Malaysia, and already lights one small pane when it
/// isn't night where Papa is. This only puts a frame around the truth.
class FamilyWindow extends ConsumerWidget {
  const FamilyWindow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final atmos = ref.watch(atmosphereProvider);
    final wood = atmos.frameWood;

    return Semantics(
      button: true,
      label: trS(lang, 'The window. Our sky, and Papa\'s.'),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── The frame ──
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: wood,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                  bottom: Radius.circular(3),
                ),
                boxShadow: [
                  // Warm light spilling in around the frame after dark.
                  if (atmos.warmth > 0.4)
                    BoxShadow(
                      color: const Color(0xFFF2C879)
                          .withValues(alpha: 0.30 * atmos.warmth),
                      blurRadius: 34,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    // The two skies are already stacked as two panes, and the
                    // seam between them reads as the glazing bar. A vertical
                    // bar on top of that just cuts the sky in half and leaves
                    // one side looking empty — so there isn't one.
                    const TwoSkies(),
                    // A soft sheen across the top corner, the way glass
                    // catches a room's light.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.42, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── The sill ──
            Container(
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Color.lerp(wood, Colors.black, 0.18),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: atmos.shelfShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.sm),
          ],
        ),
      ),
    );
  }
}
