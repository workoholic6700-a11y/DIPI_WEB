import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/cover.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/still_to_add.dart';

class DreamBoardScreen extends ConsumerWidget {
  const DreamBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamsProvider);
    final lang = ref.watch(langProvider);
    return SectionScaffold(
      title: 'Dream Board',
      subtitle: 'Dreams Dipisha has shared herself',
      emoji: '🌈',
      child: dreams.isEmpty
          ? StillToAdd(
              lang: lang,
              message:
                  'Dipisha can tell Diksha which dreams belong on this board.',
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.softGradient,
                    borderRadius: AppDimens.brLg,
                  ),
                  child: Text(
                    trS(
                      lang,
                      'Dream big, little one. Every one of these is possible. 💫',
                    ),
                    textAlign: TextAlign.center,
                    style: handwriting(
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                Wrap(
                  spacing: AppDimens.md,
                  runSpacing: AppDimens.lg,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < dreams.length; i++)
                      Transform.rotate(
                            angle: dreams[i].rotation,
                            child: Container(
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(AppDimens.md),
                              decoration: BoxDecoration(
                                gradient: CoverPalette.gradient(
                                  dreams[i].colorSeed,
                                ),
                                borderRadius: AppDimens.brLg,
                                boxShadow: [
                                  BoxShadow(
                                    color: CoverPalette.base(
                                      dreams[i].colorSeed,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dreams[i].emoji,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dreams[i].text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (i * 90).ms, duration: 400.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1),
                          ),
                  ],
                ),
                const SizedBox(height: AppDimens.xl),
              ],
            ),
    );
  }
}
