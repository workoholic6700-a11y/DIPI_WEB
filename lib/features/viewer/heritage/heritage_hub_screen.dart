import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/providers/heritage_providers.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/heritage_widgets.dart';

/// **What we keep** — the heritage record.
///
/// The rest of this app remembers what days *looked* like. This corner
/// remembers what the family *knew*: the words, the food, the reasons behind
/// the year, and the moves that put us in three countries.
///
/// It is built to show its own gaps. A photo album with holes in it looks
/// broken; a record of a living family that admits what it hasn't asked yet is
/// simply honest — and it turns the section into a list of questions while
/// there is still somebody to ask.
class HeritageHubScreen extends ConsumerWidget {
  const HeritageHubScreen({super.key});

  // Warm paper — this is an archive, not a celebration.
  static const _paper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6F1E6), Color(0xFFFBF6EF)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tally = ref.watch(heritageTallyProvider);

    return SectionScaffold(
      title: 'Our Roots',
      subtitle: 'Stories, words and traditions we carry · हाम्रो सम्पदा',
      emoji: '🪔',
      gradient: _paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _opening(context, lang),
          const SizedBox(height: AppDimens.xl),
          _tallyStrip(context, lang, tally),
          const SizedBox(height: AppDimens.xl),
          ..._cards(context, lang),
          if (tally.urgent > 0) ...[
            const SizedBox(height: AppDimens.xl),
            _elderCall(context, lang, tally.urgent),
          ],
          const SizedBox(height: AppDimens.xxl),
          const ClosingNote(
            emoji: '🌿',
            text: 'A family is not only its photographs.',
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }

  Widget _opening(BuildContext context, AppLang lang) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E8D5), Color(0xFFF7EFE2)],
        ),
        borderRadius: AppDimens.brXl,
        boxShadow: [
          BoxShadow(
              color: AppColors.goldDeep.withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text('हाम्रो सम्पदा',
              style: handwriting(fontSize: 30, color: const Color(0xFF8A6A2F))),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(
                lang,
                'Photographs keep what a day looked like. These pages keep '
                'what we knew — and what nobody has written down yet.'),
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary, height: 1.55),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// A quiet count of what exists versus what is still only in someone's head.
  Widget _tallyStrip(BuildContext context, AppLang lang, HeritageTally tally) {
    return Row(
      children: [
        Expanded(
            child: _stat(context, lang, '${tally.words}', 'words kept',
                AppColors.lavender)),
        const SizedBox(width: AppDimens.sm),
        Expanded(
            child: _stat(context, lang, '${tally.recipes}', 'recipes',
                AppColors.pinkDeep)),
        const SizedBox(width: AppDimens.sm),
        // Was "18 still to ask", which reads like an admin backlog on a page
        // meant for the family. It's the same number; it just isn't a chore.
        Expanded(
            child: _stat(context, lang, '${tally.toCollect}',
                'stories we hope to hear', AppColors.goldDeep)),
      ],
    );
  }

  Widget _stat(BuildContext context, AppLang lang, String value, String label,
      Color color) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppDimens.md, horizontal: AppDimens.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppDimens.brMd,
      ),
      child: Column(
        children: [
          Text(value,
              style: t.headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(trS(lang, label),
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  List<Widget> _cards(BuildContext context, AppLang lang) {
    const entries = <_HeritageEntry>[
      _HeritageEntry(
        emoji: '🗣️',
        title: 'Our Words',
        blurb: 'Kirat words, the words of this house, and the sentences only '
            'we say.',
        route: Routes.heritageWords,
        color: AppColors.lavender,
      ),
      _HeritageEntry(
        emoji: '🍲',
        title: 'Our Recipes',
        blurb: 'What Mummy cooks, and who taught it to her.',
        route: Routes.heritageRecipes,
        color: AppColors.pinkDeep,
      ),
      _HeritageEntry(
        emoji: '🪔',
        title: 'What We Do, and Why',
        blurb: 'Sakela, Tihar, Dashain — and the fire lit every morning.',
        route: Routes.heritageTraditions,
        color: AppColors.goldDeep,
      ),
      _HeritageEntry(
        emoji: '🧭',
        title: 'Where We Come From',
        blurb: 'Ilam, Ranke, Malaysia, Kathmandu — and why we moved.',
        route: Routes.heritageRoots,
        color: AppColors.skyBlue,
      ),
    ];

    return [
      for (var i = 0; i < entries.length; i++) ...[
        _entryCard(context, lang, entries[i])
            .animate()
            .fadeIn(delay: (80 * i).ms, duration: 320.ms)
            .moveY(begin: 10, end: 0),
        if (i != entries.length - 1) const SizedBox(height: AppDimens.md),
      ],
    ];
  }

  Widget _entryCard(BuildContext context, AppLang lang, _HeritageEntry e) =>
      _Drawer(entry: e, lang: lang);

  /// The only part of this app with any urgency in it.
  Widget _elderCall(BuildContext context, AppLang lang, int count) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: AppDimens.brLg,
        border: Border.all(color: AppColors.goldDeep.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🕯️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(trS(lang, 'While we can still ask'),
                  style: t.titleSmall
                      ?.copyWith(color: const Color(0xFF8A6A2F))),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            '$count ${trS(lang, 'things here live only in Kopa\'s and '
                'Mummy\'s memory. Recording them takes an afternoon. Not '
                'recording them takes everything.')}',
            style: t.bodySmall?.copyWith(
                color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HeritageEntry {
  const _HeritageEntry({
    required this.emoji,
    required this.title,
    required this.blurb,
    required this.route,
    required this.color,
  });

  final String emoji;
  final String title;
  final String blurb;
  final String route;
  final Color color;
}

/// One drawer of the cabinet.
///
/// The hub was four rounded cards with chevrons — the same list shape as
/// everywhere else. A record like this is kept in a cabinet, so these are
/// drawers: a timber front, a brass label plate, and two pulls. Take hold of
/// one and it slides out towards you as its page opens.
class _Drawer extends StatefulWidget {
  const _Drawer({required this.entry, required this.lang});

  final _HeritageEntry entry;
  final AppLang lang;

  @override
  State<_Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<_Drawer> {
  bool _pulled = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final t = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: '${trS(widget.lang, e.title)}. ${trS(widget.lang, e.blurb)} '
          'Opens this drawer.',
      child: GestureDetector(
        onTap: () => context.push(e.route),
        onTapDown: (_) => setState(() => _pulled = true),
        onTapUp: (_) => setState(() => _pulled = false),
        onTapCancel: () => setState(() => _pulled = false),
        child: AnimatedSlide(
          // Slides out of the cabinet when you take hold of it.
          offset: Offset(_pulled ? 0.022 : 0, 0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.lg, vertical: AppDimens.lg),
            decoration: BoxDecoration(
              // Timber, tinted towards this drawer's own colour.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(const Color(0xFFD3B48C), e.color, 0.10)!,
                  Color.lerp(const Color(0xFFBB9468), e.color, 0.14)!,
                ],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pulled ? 0.28 : 0.16),
                  blurRadius: _pulled ? 18 : 9,
                  offset: Offset(0, _pulled ? 9 : 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // The brass label plate on the drawer front.
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE6CE9A), Color(0xFFC0A263)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(e.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: AppDimens.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trS(widget.lang, e.title),
                        style: t.titleMedium?.copyWith(
                            color: const Color(0xFF4A3418),
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        trS(widget.lang, e.blurb),
                        style: t.bodySmall?.copyWith(
                            color: const Color(0xFF6B5334), height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                // Two pulls, like a real drawer front.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      Container(
                        width: 15,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A6A3E),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      if (i == 0) const SizedBox(height: 5),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
