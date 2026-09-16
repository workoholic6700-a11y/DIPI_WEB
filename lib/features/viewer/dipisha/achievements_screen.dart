import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/models/cover.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/still_to_add.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(achievementsProvider);
    final lang = ref.watch(langProvider);
    return SectionScaffold(
      title: 'Achievements',
      subtitle: 'The milestones Diksha has confirmed',
      emoji: '🏆',
      child: items.isEmpty
          ? StillToAdd(
              lang: lang,
              message:
                  'Diksha can add Dipisha\'s real milestones and dates here.',
            )
          : Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                    child:
                        Container(
                              padding: const EdgeInsets.all(AppDimens.lg),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppDimens.brLg,
                                boxShadow: [
                                  BoxShadow(
                                    color: CoverPalette.base(
                                      items[i].colorSeed,
                                    ).withValues(alpha: 0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: CoverPalette.gradient(
                                        items[i].colorSeed,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      items[i].emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items[i].title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          items[i].description,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          items[i].date.prettyDate,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (i * 80).ms)
                            .moveX(begin: 16, end: 0),
                  ),
              ],
            ),
    );
  }
}
