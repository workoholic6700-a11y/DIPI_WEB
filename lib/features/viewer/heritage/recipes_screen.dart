import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/mock/heritage_data.dart';
import '../../../data/models/heritage_models.dart';
import '../../../data/providers/heritage_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/heritage_widgets.dart';

/// **Our Recipes** — what this family cooks, and who taught it.
///
/// Every dish here has its story and none of them has its method, which is an
/// accurate picture of where the family actually is: we all know exactly what
/// Mummy's sisnu tastes like and not one of us could make it. The empty methods
/// are the feature — they're a list of afternoons to spend in the kitchen with
/// a notebook.
class HeritageRecipesScreen extends ConsumerWidget {
  const HeritageRecipesScreen({super.key});

  static const _paper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBEFF3), Color(0xFFFBF6EF)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final recipes = ref.watch(recipesProvider);
    final t = Theme.of(context).textTheme;

    return SectionScaffold(
      title: 'Our Recipes',
      subtitle: 'What Mummy cooks · हाम्रो भान्सा',
      emoji: '🍲',
      gradient: _paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            trS(
                lang,
                'A recipe is a chain of people. These pages care as much about '
                'who taught it as about what goes in.'),
            style: t.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, height: 1.55),
          ),
          const SizedBox(height: AppDimens.xl),
          for (var i = 0; i < recipes.length; i++) ...[
            _RecipeCard(recipe: recipes[i])
                .animate()
                .fadeIn(delay: (70 * i).ms, duration: 320.ms)
                .moveY(begin: 10, end: 0),
            const SizedBox(height: AppDimens.md),
          ],
          const SizedBox(height: AppDimens.lg),
          SectionHeader(
              title: trS(lang, 'Still in somebody\'s hands'), emoji: '🕯️'),
          for (final c in HeritageData.recipesToCollect) ...[
            ToCollectCard(item: c),
            const SizedBox(height: AppDimens.sm),
          ],
          const SizedBox(height: AppDimens.xl),
          const ClosingNote(
            emoji: '🍚',
            text: 'Ask her while she is standing at the chulo. '
                'She will show you faster than she can tell you.',
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final accent = _accent(recipe.colorSeed);

    return HeritageCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: AppDimens.brMd,
                ),
                child:
                    Text(recipe.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name,
                        style: t.titleMedium?.copyWith(color: accent)),
                    Text(recipe.english,
                        style: t.bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(trS(lang, recipe.story),
              style: t.bodyMedium?.copyWith(height: 1.55)),
          const SizedBox(height: AppDimens.md),
          TaughtByLine(
              taughtBy: recipe.taughtBy, learnedFrom: recipe.learnedFrom),

          // The method — either the real thing, or an honest hole.
          if (recipe.isComplete) ...[
            const SizedBox(height: AppDimens.lg),
            _method(context, lang),
          ] else if (recipe.missing != null) ...[
            const SizedBox(height: AppDimens.md),
            ToCollectCard(item: recipe.missing!),
          ],

          if (recipe.handwritten == null) ...[
            const SizedBox(height: AppDimens.md),
            Row(
              children: [
                const Icon(Icons.eco_outlined,
                    size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trS(lang, 'No photo of this written in her hand yet'),
                    style:
                        t.labelSmall?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _method(BuildContext context, AppLang lang) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recipe.ingredients.isNotEmpty) ...[
          Text(trS(lang, 'What goes in'), style: t.titleSmall),
          const SizedBox(height: AppDimens.xs),
          for (final i in recipe.ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('· ${trS(lang, i)}', style: t.bodySmall),
            ),
          const SizedBox(height: AppDimens.md),
        ],
        Text(trS(lang, 'How'), style: t.titleSmall),
        const SizedBox(height: AppDimens.xs),
        for (var i = 0; i < recipe.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('${i + 1}. ${trS(lang, recipe.steps[i])}',
                style: t.bodySmall?.copyWith(height: 1.5)),
          ),
      ],
    );
  }

  Color _accent(int seed) {
    const palette = [
      AppColors.pinkDeep,
      AppColors.goldDeep,
      AppColors.lavender,
      AppColors.purpleMid,
    ];
    return palette[seed % palette.length];
  }
}
