import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../data/models/heritage_models.dart';
import '../../../../shared/widgets/scrapbook.dart';

/// Shared pieces for the Heritage screens.
///
/// The important one is [ToCollectCard]. Everywhere else in this app an empty
/// space is a flaw; here it's content. These cards say what's missing and whose
/// memory it lives in, so the section works as a list of questions to ask.

/// A gap in the record, shown as a note pinned to the page.
class ToCollectCard extends ConsumerWidget {
  const ToCollectCard({super.key, required this.item});

  final Collectable item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final urgent = item.urgent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: urgent
            ? AppColors.gold.withValues(alpha: 0.14)
            : AppColors.lavenderSoft.withValues(alpha: 0.55),
        borderRadius: AppDimens.brLg,
        border: Border.all(
          color: urgent
              ? AppColors.goldDeep.withValues(alpha: 0.45)
              : AppColors.lavender.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(urgent ? '🕯️' : '💌', style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                trS(lang, urgent ? 'Ask while we can' : 'Still to add'),
                style: t.labelLarge?.copyWith(
                  color: urgent ? AppColors.goldDeep : AppColors.purpleMid,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(trS(lang, item.what),
              style: t.bodyMedium?.copyWith(height: 1.5)),
          if (item.why != null) ...[
            const SizedBox(height: AppDimens.sm),
            Text(trS(lang, item.why!),
                style: t.bodySmall
                    ?.copyWith(color: AppColors.textSecondary, height: 1.5)),
          ],
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              const Icon(Icons.record_voice_over_rounded,
                  size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${trS(lang, 'Ask')} ${trS(lang, item.askWho)}',
                  style: t.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Mummy — who learned it from her Ama." A recipe is a chain of people, and
/// the chain is the part worth showing.
class TaughtByLine extends ConsumerWidget {
  const TaughtByLine({super.key, required this.taughtBy, this.learnedFrom});

  final String? taughtBy;
  final String? learnedFrom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (taughtBy == null) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    return Row(
      children: [
        const Text('👐', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            learnedFrom == null
                ? '${trS(lang, 'Made by')} ${trS(lang, taughtBy!)}'
                : '${trS(lang, 'Made by')} ${trS(lang, taughtBy!)} · '
                    '${trS(lang, 'who learned it from')} '
                    '${trS(lang, learnedFrom!)}',
            style: t.bodySmall?.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// A placeholder for a recording nobody has made yet.
///
/// Deliberately not a disabled play button — there is nothing to play, and
/// pretending otherwise would be the same lie as an invented birthday.
class VoiceSlot extends ConsumerWidget {
  const VoiceSlot({super.key, required this.who});

  final String who;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color: AppColors.skyBlueSoft.withValues(alpha: 0.7),
        borderRadius: AppDimens.brPill,
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic_none_rounded,
              size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${trS(lang, 'No recording yet')} · ${trS(lang, who)}',
              style: t.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The soft card every heritage entry sits on. Kept here so all four screens
/// share one shadow and one radius instead of drifting apart.
class HeritageCard extends StatelessWidget {
  const HeritageCard({
    super.key,
    required this.child,
    this.accent,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimens.lg),
  });

  final Widget child;
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = accent ?? AppColors.lavender;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.warmWhite,
      borderRadius: AppDimens.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.brLg,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: AppDimens.brLg,
            border: Border.all(color: c.withValues(alpha: 0.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A short handwritten line, used to close each screen the way the Sakela page
/// closes with "Sewa!".
class ClosingNote extends ConsumerWidget {
  const ClosingNote({super.key, required this.text, this.emoji});

  final String text;
  final String? emoji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    return Column(
      children: [
        if (emoji != null)
          Text(emoji!, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: AppDimens.sm),
        Text(
          trS(lang, text),
          textAlign: TextAlign.center,
          // Written straight onto the page, so it follows the theme rather
          // than a fixed purple that disappears with the lamp off.
          style: handwriting(
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.lavenderLight
                : AppColors.purpleMid,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }
}
