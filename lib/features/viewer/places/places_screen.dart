import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_photos.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/cover.dart';
import '../../../data/models/story_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/family_map.dart';

/// **Places in Our Story** — a paper map on a table.
///
/// It was a stack of cards, which tells you the places exist but not that
/// three of them are within an hour of each other and one is on the other side
/// of the country. A map says that in one glance.
///
/// WHERE THE PINS ARE
/// Placed by the part of Nepal each place is actually in — the eastern hills,
/// the middle, the southern plain. That much is true. Exact positions are not
/// claimed and the screen says so: nobody in this family ever wrote down a
/// coordinate, and inventing one to look precise would be the same lie as an
/// invented birthday.
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  String? _selected;

  /// Roughly where in the country each place sits, as fractions of the map.
  /// Ilam's three cluster in the east because they genuinely do.
  static const _pins = <String, (double, double)>{
    'pl1': (0.82, 0.60), // Mangalbare, Ilam — home, eastern hills
    'pl2': (0.91, 0.46), // Shree Antu — the ridge above it
    'pl3': (0.72, 0.68), // Ranke — mamaghar, same district
    'pl5': (0.45, 0.53), // Kathmandu — the middle
    'pl4': (0.19, 0.79), // Lumbini — the southern plain
  };

  static const _table = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDE2D0), Color(0xFFE3D6C0)],
  );

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final places = ref.watch(placesProvider);
    final selected = places.where((p) => p.id == _selected).firstOrNull;

    return SectionScaffold(
      title: 'Places in Our Story',
      subtitle: 'Where our story travelled',
      emoji: '🗺️',
      gradient: _table,
      particles: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── The map ──
          Container(
            decoration: BoxDecoration(
              borderRadius: AppDimens.brMd,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 1.38,
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: FamilyMapPainter()),
                    ),
                    for (final p in places)
                      if (_pins[p.id] != null)
                        Positioned(
                          left: box.maxWidth * _pins[p.id]!.$1 - 22,
                          top: box.maxHeight * _pins[p.id]!.$2 - 30,
                          child: _Pin(
                            place: p,
                            selected: _selected == p.id,
                            onTap: () => setState(
                              () => _selected = _selected == p.id ? null : p.id,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 420.ms),

          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  trS(lang, 'Shown approximately, from family memory.'),
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),

          // ── The tray: whichever pin is up ──
          if (selected != null)
            _StoryCard(place: selected, lang: lang)
          else
            _Prompt(lang: lang),

          const SizedBox(height: AppDimens.lg),
          // Everything, listed, for anyone who'd rather read than poke.
          Text(
            trS(lang, 'All our places'),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: [
              for (final p in places)
                GestureDetector(
                  key: ValueKey('place-selector-${p.id}'),
                  onTap: () => setState(() => _selected = p.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selected == p.id
                          ? CoverPalette.base(
                              p.colorSeed,
                            ).withValues(alpha: 0.20)
                          : AppColors.warmWhite,
                      borderRadius: AppDimens.brPill,
                      border: Border.all(
                        color: CoverPalette.base(
                          p.colorSeed,
                        ).withValues(alpha: 0.40),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.xl),
        ],
      ),
    );
  }
}

/// A pin stuck in the map. Rises when it's the one you're looking at.
class _Pin extends StatelessWidget {
  const _Pin({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final Place place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = CoverPalette.base(place.colorSeed);
    return Semantics(
      button: true,
      selected: selected,
      label: '${place.name}, ${place.region}. Shows its story.',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedSlide(
          offset: Offset(0, selected ? -0.13 : 0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: base, width: selected ? 2.6 : 1.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.34 : 0.20,
                      ),
                      blurRadius: selected ? 12 : 6,
                      offset: Offset(0, selected ? 6 : 3),
                    ),
                  ],
                ),
                child: Text(place.emoji, style: const TextStyle(fontSize: 16)),
              ),
              // The spike into the paper.
              Container(width: 2, height: 9, color: base),
            ],
          ),
        ),
      ),
    );
  }
}

/// The story of whichever place is currently pinned up.
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.place, required this.lang});

  final Place place;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final base = CoverPalette.base(place.colorSeed);
    final photo = AppPhotos.place(place.id);
    final photoCaption = AppPhotos.captionFor(photo);

    return Container(
      key: ValueKey(place.id),
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: AppDimens.brLg,
        border: Border.all(color: base.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Center(
              child: Polaroid(
                key: ValueKey('place-photo-${place.id}'),
                seed: place.colorSeed,
                caption: place.name,
                assetPath: photo,
                provenance: photoCaption == null
                    ? null
                    : trS(lang, photoCaption),
                width: (constraints.maxWidth - 28).clamp(0, 250),
                rotation: -0.025,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            children: [
              Text(place.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(place.name, style: t.titleMedium, maxLines: 2),
              ),
            ],
          ),
          Text(
            '${trS(lang, place.region)} · ${place.year}',
            style: t.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(lang, place.story),
            style: t.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).moveY(begin: 8, end: 0);
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.lang});

  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
      alignment: Alignment.center,
      child: Text(
        trS(lang, 'Touch a pin to hear about that place.'),
        textAlign: TextAlign.center,
        style: handwriting(fontSize: 18, color: pageInk(context)),
      ),
    );
  }
}
