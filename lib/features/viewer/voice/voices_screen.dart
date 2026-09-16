import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/voice_player_bar.dart';

class VoicesScreen extends ConsumerWidget {
  const VoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voices = ref.watch(voicesProvider);

    return SectionScaffold(
      title: 'Voice Messages',
      subtitle: 'Nana\'s voice, whenever you miss it',
      emoji: '🎧',
      child: Column(
        children: [
          for (var i = 0; i < voices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: Container(
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimens.brLg,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.lavender.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(voices[i].category.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.pinkDeep)),
                              Text(voices[i].date.shortDate,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Consumer(builder: (context, ref, _) {
                          final fav = ref.watch(isFavoriteProvider(
                              (kind: FavKind.voice, id: voices[i].id)));
                          return FavoriteButton(
                            isFavorite: fav,
                            background: false,
                            size: 20,
                            onTap: () => ref
                                .read(favoritesProvider.notifier)
                                .toggle(FavKind.voice, voices[i].id),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    VoicePlayerBar(
                      title: voices[i].title,
                      durationSeconds: voices[i].durationSeconds,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 80).ms).moveY(begin: 14, end: 0),
            ),
        ],
      ),
    );
  }
}
