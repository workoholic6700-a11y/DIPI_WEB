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
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/heritage_widgets.dart';

/// **Where We Come From** — the Rai name, and the moves.
///
/// Read top to bottom this is one sentence: the family is from these hills, the
/// father went abroad so the daughters could be schooled, and the daughters are
/// now in the city with degrees. The thread is drawn deliberately — every stop
/// after Ilam exists because of the one before it.
class HeritageRootsScreen extends ConsumerWidget {
  const HeritageRootsScreen({super.key});

  static const _paper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE9F1F7), Color(0xFFFBF6EF)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final roots = ref.watch(rootsProvider);

    return SectionScaffold(
      title: 'Where We Come From',
      subtitle: 'The Rai name, and the moves · हाम्रो जरा',
      emoji: '🧭',
      gradient: _paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _theName(context, lang),
          const SizedBox(height: AppDimens.xl),
          SectionHeader(title: trS(lang, 'The places, in order'), emoji: '📍'),
          for (var i = 0; i < roots.length; i++)
            _RootStepRow(
              step: roots[i],
              isFirst: i == 0,
              isLast: i == roots.length - 1,
            ).animate().fadeIn(delay: (90 * i).ms, duration: 340.ms),
          const SizedBox(height: AppDimens.lg),
          _thePoint(context, lang),
          const SizedBox(height: AppDimens.xl),
          SectionHeader(
              title: trS(lang, 'What we haven\'t asked yet'), emoji: '🕯️'),
          for (final c in HeritageData.rootsToCollect) ...[
            ToCollectCard(item: c),
            const SizedBox(height: AppDimens.sm),
          ],
          const SizedBox(height: AppDimens.xl),
          const ClosingNote(
            emoji: '🌏',
            text: 'Three places, one family. '
                'The distance was never the point — the reason was.',
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }

  /// Who we are before where we've been.
  Widget _theName(BuildContext context, AppLang lang) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDEBC6), Color(0xFFE8F0DA)],
        ),
        borderRadius: AppDimens.brXl,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF5C9A4E).withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text('राई',
              style: handwriting(
                  fontSize: 40, color: const Color(0xFF4F7A3A))),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(
                lang,
                'We are Kirat Rai — one of the oldest peoples of these hills. '
                'We worship the earth and the sky, Sumnima and Paruhang, and '
                'we carry our history in the Mundhum rather than in a book.'),
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
                color: const Color(0xFF4A5A3C), height: 1.6),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            trS(lang,
                '"Rai" is a surname over many languages — Bantawa, Chamling, '
                'Kulung and more. Which one is ours is a question for Kopa.'),
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(
                color: const Color(0xFF6B7A5C),
                fontStyle: FontStyle.italic,
                height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// The sentence the whole page exists to make.
  Widget _thePoint(BuildContext context, AppLang lang) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: AppDimens.brLg,
      ),
      child: Column(
        children: [
          const Text('💜', style: TextStyle(fontSize: 26)),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(
                lang,
                'A father went a very long way from home so that three girls '
                'in Ilam could stay in school. One of them wrote this app. '
                'That is the whole story, and it is worth saying plainly at '
                'least once.'),
            textAlign: TextAlign.center,
            style: t.bodyMedium
                ?.copyWith(color: AppColors.purpleMid, height: 1.6),
          ),
        ],
      ),
    );
  }
}

/// One stop on the journey, drawn as a thread with a knot at each place.
class _RootStepRow extends ConsumerWidget {
  const _RootStepRow({
    required this.step,
    required this.isFirst,
    required this.isLast,
  });

  final RootStep step;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final accent = _accent(step.colorSeed);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The thread running down the left, connecting the moves.
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : AppColors.lavender.withValues(alpha: 0.35),
                  ),
                ),
                Container(
                  width: step.isHome ? 16 : 12,
                  height: step.isHome ? 16 : 12,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: step.isHome
                        ? Border.all(color: AppColors.gold, width: 3)
                        : null,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : AppColors.lavender.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: HeritageCard(
                accent: accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(step.emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(step.place,
                              style: t.titleMedium?.copyWith(color: accent)),
                        ),
                        if (step.isHome)
                          Pill(
                              label: trS(lang, 'home'),
                              color: AppColors.goldDeep),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${trS(lang, step.region)} · ${trS(lang, step.period)}',
                        style: t.labelSmall
                            ?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: AppDimens.md),
                    Text(trS(lang, step.story),
                        style: t.bodySmall?.copyWith(height: 1.6)),
                    if (step.who != null) ...[
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          const Icon(Icons.people_alt_rounded,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${trS(lang, 'There now')} · '
                              '${trS(lang, step.who!)}',
                              style: t.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _accent(int seed) {
    const palette = [
      AppColors.skyBlue,
      AppColors.lavender,
      AppColors.pinkDeep,
      AppColors.goldDeep,
      AppColors.purpleMid,
    ];
    return palette[seed % palette.length];
  }
}
