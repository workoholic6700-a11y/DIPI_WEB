import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_photos.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../data/models/content_models.dart';
import '../../../../data/providers/content_providers.dart';
import '../../../../data/providers/memory_photos_provider.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/gradient_cover.dart';
import '../../../../shared/widgets/soft_card.dart';

/// A horizontal memory card used in the Memories timeline.
class MemoryCard extends ConsumerWidget {
  const MemoryCard({super.key, required this.memory});
  final Memory memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(
      isFavoriteProvider((kind: FavKind.memory, id: memory.id)),
    );
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final asset = AppPhotos.memoryCardCover(memory.id);
    final caption = AppPhotos.captionFor(asset);
    final photoCount = ref.watch(memoryPhotosProvider(memory.id)).value?.length;

    return SoftCard(
      padding: const EdgeInsets.all(AppDimens.md),
      onTap: () => context.push(Routes.memoryOf(memory.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'memory-${memory.id}',
            child: SizedBox(
              width: 96,
              height: 96,
              child: GradientCover(
                seed: memory.colorSeed,
                icon: memory.category.icon,
                borderRadius: AppDimens.brMd,
                showSparkle: false,
                asset: asset,
                fit: caption != null ? BoxFit.contain : BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trS(ref.watch(langProvider), memory.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium,
                      ),
                    ),
                    Text(
                      memory.mood.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  trS(ref.watch(langProvider), memory.description),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall,
                ),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    trS(lang, caption),
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      memory.category.icon,
                      size: 13,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memory.date.dayMonth,
                      style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    if (photoCount != null && photoCount > 0)
                      _Meta(Icons.photo_rounded, '$photoCount'),
                    if (memory.hasVoice) ...[
                      const SizedBox(width: 8),
                      const _Meta(Icons.graphic_eq_rounded, ''),
                    ],
                    const SizedBox(width: 6),
                    FavoriteButton(
                      isFavorite: fav,
                      background: false,
                      size: 18,
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(FavKind.memory, memory.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}
