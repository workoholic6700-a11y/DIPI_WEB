import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_photos.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../core/utils/nepali_date.dart';
import '../../../data/models/content_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../data/providers/memory_photos_provider.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/gradient_cover.dart';
import '../../../shared/widgets/lottie_art.dart';
import '../../../shared/widgets/soft_card.dart';
import '../../../shared/widgets/states.dart';
import '../../../shared/widgets/storybook.dart';
import '../voice/widgets/voice_player_bar.dart';
import 'memory_story_mode.dart';

class MemoryDetailScreen extends ConsumerWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});
  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider);
    final memory = memories.where((m) => m.id == memoryId).firstOrNull;

    if (memory == null) {
      return const Scaffold(
        body: ErrorStateView(
          title: 'Memory not found',
          message: 'This memory may have been moved.',
        ),
      );
    }

    final fav = ref.watch(
      isFavoriteProvider((kind: FavKind.memory, id: memory.id)),
    );
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final related = _relatedMemories(memory, memories);
    final pictureState = ref.watch(memoryPhotosProvider(memory.id));
    final pictures = pictureState.value ?? const <MemoryPhoto>[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 410,
            pinned: true,
            backgroundColor: AppColors.card,
            leading: const _CircleBack(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppDimens.md),
                child: FavoriteButton(
                  isFavorite: fav,
                  onTap: () => ref
                      .read(favoritesProvider.notifier)
                      .toggle(FavKind.memory, memory.id),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _MemoryHero(memory: memory, lang: lang),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Pill(
                        label:
                            '${memory.mood.emoji} '
                            '${trS(lang, memory.mood.label)}',
                        color: memory.mood.color,
                      ),
                      Pill(
                        label: trS(lang, memory.category.label),
                        icon: memory.category.icon,
                      ),
                      if (memory.location != null)
                        Pill(
                          label: trS(lang, memory.location!),
                          icon: Icons.place_rounded,
                          color: AppColors.skyBlue,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Text(trS(lang, memory.title), style: t.displaySmall),
                  const SizedBox(height: AppDimens.sm),
                  _DateLine(memory: memory, lang: lang),
                  const SizedBox(height: AppDimens.lg),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        opaque: true,
                        transitionDuration: const Duration(milliseconds: 650),
                        reverseTransitionDuration: const Duration(
                          milliseconds: 420,
                        ),
                        pageBuilder: (_, animation, secondaryAnimation) =>
                            MemoryStoryMode(memory: memory, lang: lang),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: AppColors.purpleMid,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: Text(trS(lang, 'Experience this memory')),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  StorybookPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StorybookDivider(
                          label: trS(lang, 'THE STORY BEHIND THE MOMENT'),
                        ),
                        const SizedBox(height: AppDimens.lg),
                        Text(
                          trS(lang, memory.description),
                          style: t.bodyLarge?.copyWith(height: 1.75),
                        ),
                      ],
                    ),
                  ),
                  if (memory.animation != null) ...[
                    const SizedBox(height: AppDimens.md),
                    Center(
                      child: LottieArt(
                        memory.animation!,
                        height: 160,
                        semanticLabel: memory.title,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimens.xl),

                  if (pictureState.hasValue) ...[
                    SectionHeader(
                      title:
                          '${trS(lang, 'Pictures for this story')} · ${pictures.length}',
                    ),
                    if (pictures.isEmpty)
                      Text(
                        trS(lang, 'No pictures added yet. Diksha can add one.'),
                        style: t.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      )
                    else
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: pictures.length,
                          separatorBuilder: (_, i) =>
                              const SizedBox(width: AppDimens.sm),
                          itemBuilder: (context, i) => SizedBox(
                            width: 238,
                            child: _StoryPicture(
                              memory: memory,
                              picture: pictures[i],
                              lang: lang,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  // Voice note
                  if (memory.hasVoice) ...[
                    SectionHeader(
                      title: trS(lang, 'A voice kept with this day'),
                      emoji: '🎧',
                    ),
                    const VoicePlayerBar(
                      title: 'Diksha\'s voice on this day',
                      durationSeconds: 45,
                    ),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  // Tags
                  if (memory.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in memory.tags)
                          Pill(label: '#$tag', color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  if (related.isNotEmpty) ...[
                    SectionHeader(
                      title: trS(lang, 'The story continues'),
                      emoji: '✨',
                    ),
                    SizedBox(
                      height: 184,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(width: AppDimens.md),
                        itemBuilder: (context, i) =>
                            _RelatedMemoryCard(memory: related[i], lang: lang),
                      ),
                    ),
                    const SizedBox(height: AppDimens.xl),
                  ],

                  // Author card
                  _AuthorCard(),
                  const SizedBox(height: 40),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }

  List<Memory> _relatedMemories(Memory current, List<Memory> all) {
    final candidates = all.where((memory) => memory.id != current.id).toList();
    candidates.sort((a, b) {
      int score(Memory memory) {
        var value = memory.category == current.category ? 3 : 0;
        value += memory.tags.where(current.tags.contains).length * 2;
        if (memory.location == current.location) value += 1;
        return value;
      }

      final byConnection = score(b).compareTo(score(a));
      if (byConnection != 0) return byConnection;
      return b.date.compareTo(a.date);
    });
    return candidates.take(3).toList();
  }
}

class _StoryPicture extends StatelessWidget {
  const _StoryPicture({
    required this.memory,
    required this.picture,
    required this.lang,
  });

  final Memory memory;
  final MemoryPhoto picture;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final caption = picture.caption;
    final tag = 'memory-${memory.id}-picture-${picture.assetPath}';
    return Semantics(
      button: true,
      label: trS(lang, 'Opens the photograph.'),
      child: GestureDetector(
        key: ValueKey('story-picture-${picture.assetPath}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _MemoryPhotoViewer(
              memory: memory,
              picture: picture,
              lang: lang,
              heroTag: tag,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDimens.brMd,
            border: Border.all(color: AppColors.lavenderSoft),
          ),
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: tag,
                  child: GradientCover(
                    seed: memory.colorSeed,
                    icon: Icons.local_florist_rounded,
                    asset: picture.assetPath,
                    fit: BoxFit.contain,
                    showSparkle: false,
                  ),
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 8),
                Text(
                  trS(lang, caption),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryPhotoViewer extends StatelessWidget {
  const _MemoryPhotoViewer({
    required this.memory,
    required this.picture,
    required this.lang,
    required this.heroTag,
  });

  final Memory memory;
  final MemoryPhoto picture;
  final AppLang lang;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final caption = picture.caption;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(trS(lang, memory.title)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                maxScale: 5,
                child: Hero(
                  tag: heroTag,
                  child: GradientCover(
                    seed: memory.colorSeed,
                    icon: Icons.local_florist_rounded,
                    asset: picture.assetPath,
                    fit: BoxFit.contain,
                    showSparkle: false,
                  ),
                ),
              ),
            ),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: Text(
                  trS(lang, caption),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemoryHero extends StatelessWidget {
  const _MemoryHero({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final asset = AppPhotos.memoryCardCover(memory.id);
    final caption = AppPhotos.captionFor(asset);
    if (caption != null) {
      return ColoredBox(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'memory-${memory.id}',
                    child: GradientCover(
                      seed: memory.colorSeed,
                      icon: Icons.local_florist_rounded,
                      asset: asset,
                      fit: BoxFit.contain,
                      showSparkle: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  trS(lang, caption),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'memory-${memory.id}',
          child: GradientCover(
            seed: memory.colorSeed,
            icon: memory.category.icon,
            asset: asset,
            showSparkle: false,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xB81C1526)],
              stops: [0.54, 1],
            ),
          ),
        ),
        Positioned(
          left: AppDimens.lg,
          right: AppDimens.lg,
          bottom: AppDimens.lg,
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.gold,
                size: 17,
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text(
                  trS(lang, 'A moment worth keeping'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.sm,
      runSpacing: AppDimens.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          memory.date.prettyDate,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        Text('·', style: TextStyle(color: AppColors.textMuted)),
        Text(
          bsLongDate(memory.date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: lang == AppLang.ne
                ? AppColors.purpleMid
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _RelatedMemoryCard extends StatelessWidget {
  const _RelatedMemoryCard({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final asset = AppPhotos.memoryCardCover(memory.id);
    final caption = AppPhotos.captionFor(asset);
    return SizedBox(
      width: 156,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimens.brLg,
          onTap: () => context.push(Routes.memoryOf(memory.id)),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDimens.brLg,
              border: Border.all(color: AppColors.lavenderSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GradientCover(
                    seed: memory.colorSeed,
                    icon: memory.category.icon,
                    asset: asset,
                    fit: caption != null ? BoxFit.contain : BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimens.radiusLg),
                    ),
                    showSparkle: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trS(lang, memory.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        memory.date.year.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (caption != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          trS(lang, caption),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoftCard(
      gradient: AppColors.softGradient,
      child: Row(
        children: [
          const EmojiAvatar(emoji: '👩🏻‍💻', size: 48, ring: true),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kept by Diksha',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Text(
                  'With all my love, always 💜',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.purpleMid,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
