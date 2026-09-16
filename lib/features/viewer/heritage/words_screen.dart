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

/// **Our Words** — a dictionary of this family.
///
/// Three kinds of word live here: the Kirat vocabulary we use at the than, the
/// everyday Nepali that means something particular in this house, and the
/// sentences only these six people say.
///
/// What is *not* here matters as much. The family's own Rai dialect is absent
/// on purpose: "Rai" covers Bantawa, Chamling, Kulung and many more, and only
/// the people who grew up speaking ours know which words are ours. Guessing
/// would put a wrong word in a place where a child will later trust it.
class HeritageWordsScreen extends ConsumerWidget {
  const HeritageWordsScreen({super.key});

  static const _paper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF2EEF8), Color(0xFFFBF6EF)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final byKind = ref.watch(wordsByKindProvider);

    return SectionScaffold(
      title: 'Our Words',
      subtitle: 'The dictionary of this family · हाम्रा शब्द',
      emoji: '🗣️',
      gradient: _paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in byKind.entries) ...[
            SectionHeader(
              title: trS(lang, entry.key.label),
              emoji: entry.key.emoji,
            ),
            _kindNote(context, lang, entry.key),
            for (var i = 0; i < entry.value.length; i++) ...[
              _WordCard(
                word: entry.value[i],
              ).animate().fadeIn(delay: (40 * i).ms, duration: 300.ms),
              const SizedBox(height: AppDimens.sm),
            ],
            const SizedBox(height: AppDimens.lg),
          ],
          const SizedBox(height: AppDimens.sm),
          SectionHeader(
            title: trS(lang, 'The words we don\'t have yet'),
            emoji: '🕯️',
          ),
          Text(
            trS(
              lang,
              'Nothing below is guessed. Each one waits for the person who '
              'actually knows it.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimens.md),
          for (final c in HeritageData.wordsToCollect) ...[
            ToCollectCard(item: c),
            const SizedBox(height: AppDimens.sm),
          ],
          const SizedBox(height: AppDimens.xl),
          const ClosingNote(
            emoji: '🌿',
            text: 'सेवा — the first word, and the one we start with.',
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }

  Widget _kindNote(BuildContext context, AppLang lang, WordKind kind) {
    final text = switch (kind) {
      WordKind.kirat =>
        'The words we use at the than. These belong to all Kirat Rai, not '
            'only to us.',
      WordKind.nepali =>
        'Ordinary Nepali words that mean something specific in this house.',
      WordKind.ours =>
        'Real sentences, said by real people, more times than anyone counted.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Text(
        trS(lang, text),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _WordCard extends ConsumerStatefulWidget {
  const _WordCard({required this.word});

  final HeritageWord word;

  @override
  ConsumerState<_WordCard> createState() => _WordCardState();
}

class _WordCardState extends ConsumerState<_WordCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final accent = _accent(word.colorSeed);

    return Semantics(
      button: true,
      expanded: _expanded,
      label:
          '${word.word}, ${word.roman}. ${word.meaning}. '
          '${_expanded ? 'Collapse' : 'Reveal its family note'}.',
      child: HeritageCard(
        accent: accent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.md,
        ),
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: t.headlineSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          word.roman,
                          style: t.labelLarge?.copyWith(
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (word.hasAudio)
                    Icon(Icons.graphic_eq_rounded, color: accent, size: 18)
                  else
                    Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.textMuted.withValues(alpha: 0.65),
                      size: 18,
                    ),
                  const SizedBox(width: AppDimens.sm),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                trS(lang, word.meaning),
                maxLines: _expanded ? null : 1,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: t.bodyMedium?.copyWith(height: 1.45),
              ),
              if (_expanded) ...[
                if (word.note != null) ...[
                  const SizedBox(height: AppDimens.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.07),
                      borderRadius: AppDimens.brSm,
                      border: Border(left: BorderSide(color: accent, width: 3)),
                    ),
                    child: Text(
                      trS(lang, word.note!),
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.md),
                Wrap(
                  spacing: AppDimens.sm,
                  runSpacing: AppDimens.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (word.saidBy != null)
                      Pill(label: trS(lang, word.saidBy!), color: accent),
                    if (!word.hasAudio) VoiceSlot(who: word.saidBy ?? 'anyone'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _accent(int seed) {
    const palette = [
      AppColors.lavender,
      AppColors.pinkDeep,
      AppColors.skyBlue,
      AppColors.goldDeep,
      AppColors.purpleMid,
    ];
    return palette[seed % palette.length];
  }
}
