import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/heritage_models.dart';
import '../../../data/providers/heritage_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/heritage_widgets.dart';

/// **What We Do, and Why** — the family's year.
///
/// Anyone can look up what Dashain is. Nobody can look up how *this* family
/// keeps it. So every entry separates three things: what happens, why it exists
/// at all, and — the only irreplaceable part — what ours looks like.
///
/// Where the third is missing it is left visibly empty rather than filled with
/// a general description, because a general description is exactly what would
/// quietly replace the real memory.
class HeritageTraditionsScreen extends ConsumerWidget {
  const HeritageTraditionsScreen({super.key});

  static const _paper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBF2E2), Color(0xFFFBF6EF)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final traditions = ref.watch(traditionsProvider);
    final t = Theme.of(context).textTheme;

    return SectionScaffold(
      title: 'What We Do, and Why',
      subtitle: 'Our year, and the reasons under it · हाम्रा चाडपर्व',
      emoji: '🪔',
      gradient: _paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            trS(
                lang,
                'Children ask why. Adults usually know, and usually forget to '
                'say it out loud. This page is the answer, written down once.'),
            style: t.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, height: 1.55),
          ),
          const SizedBox(height: AppDimens.xl),
          for (var i = 0; i < traditions.length; i++) ...[
            _TraditionCard(tradition: traditions[i])
                .animate()
                .fadeIn(delay: (70 * i).ms, duration: 320.ms)
                .moveY(begin: 10, end: 0),
            const SizedBox(height: AppDimens.md),
          ],
          const SizedBox(height: AppDimens.xl),
          const ClosingNote(
            emoji: '🥁',
            text: 'We do not worship in a building. '
                'We worship the earth and the sky.',
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }
}

class _TraditionCard extends ConsumerWidget {
  const _TraditionCard({required this.tradition});

  final Tradition tradition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final accent = _accent(tradition.colorSeed);

    return HeritageCard(
      accent: accent,
      onTap: tradition.route == null
          ? null
          : () => context.push(tradition.route!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tradition.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tradition.name,
                        style: t.titleMedium?.copyWith(color: accent)),
                    const SizedBox(height: 2),
                    Text(trS(lang, tradition.when),
                        style: t.labelSmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (tradition.route != null)
                Icon(Icons.chevron_right_rounded,
                    color: accent.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(trS(lang, tradition.what),
              style: t.bodyMedium?.copyWith(height: 1.55)),

          if (tradition.why != null) ...[
            const SizedBox(height: AppDimens.md),
            _block(context, lang, 'Why', tradition.why!, accent),
          ],

          // The part nobody else could write.
          if (tradition.ours != null) ...[
            const SizedBox(height: AppDimens.sm),
            _block(context, lang, 'How ours goes', tradition.ours!,
                AppColors.pinkDeep),
          ],

          if (tradition.missing != null) ...[
            const SizedBox(height: AppDimens.md),
            ToCollectCard(item: tradition.missing!),
          ],
        ],
      ),
    );
  }

  Widget _block(BuildContext context, AppLang lang, String label, String body,
      Color accent) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: AppDimens.brMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trS(lang, label),
              style: t.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(trS(lang, body), style: t.bodySmall?.copyWith(height: 1.55)),
        ],
      ),
    );
  }

  Color _accent(int seed) {
    const palette = [
      AppColors.goldDeep,
      AppColors.lavender,
      AppColors.pinkDeep,
      AppColors.purpleMid,
      AppColors.skyBlue,
    ];
    return palette[seed % palette.length];
  }
}
