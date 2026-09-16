import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/content_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/portrait_scope.dart';
import '../../../shared/widgets/scrapbook.dart';
import 'widgets/envelope.dart';
import 'widgets/treehouse_backdrop.dart';

/// **Letters from Nana** — a mailbox and a tray, not a grid of cards.
///
/// Three things live here, in the order you'd meet them in the treehouse: the
/// mailbox with the next sealed letter in it, the shelf of letters kept for
/// particular feelings, and the tray holding everything else.
///
/// The search box and the row of category chips are gone from the surface —
/// they were the most website-like thing on the screen. Search is behind the
/// small magnifier in the corner, and the categories that matter are the three
/// that answer "how are you feeling", which is how anyone actually reaches for
/// one of these.
class LettersScreen extends ConsumerStatefulWidget {
  const LettersScreen({super.key});

  @override
  ConsumerState<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends ConsumerState<LettersScreen> {
  String _query = '';
  LetterCategory? _need;
  bool _searching = false;

  /// The three letters written for a feeling rather than an occasion.
  static const _needs = [
    LetterCategory.whenSad,
    LetterCategory.whenHappy,
    LetterCategory.whenScared,
  ];

  // Opening is recorded by the detail screen itself, so every route to a
  // letter counts the same. The tray rebuilds when she comes back.
  void _open(Letter l) => context.push(Routes.letterOf(l.id));

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final all = ref.watch(lettersProvider);
    final unopened = ref.watch(unopenedLettersProvider);

    final q = _query.trim().toLowerCase();
    final tray = all.where((l) {
      final matchesNeed = _need == null || l.category == _need;
      final matchesQuery =
          q.isEmpty ||
          l.title.toLowerCase().contains(q) ||
          l.body.toLowerCase().contains(q);
      return matchesNeed && matchesQuery;
    }).toList()..sort((a, b) => b.dateWritten.compareTo(a.dateWritten));

    // Reached from Dipisha's World, which is locked sideways. A letter is a
    // portrait object — you don't read one lengthways.
    return PortraitScope(
      child: Scaffold(
        body: TreehouseBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                _bar(context, lang),
                if (_searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.lg,
                      0,
                      AppDimens.lg,
                      AppDimens.sm,
                    ),
                    child: _PaperSurface(
                      padding: EdgeInsets.zero,
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: trS(lang, 'Search letters…'),
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.lg,
                      AppDimens.sm,
                      AppDimens.lg,
                      60,
                    ),
                    children: [
                      // ── The mailbox ──
                      if (q.isEmpty && _need == null)
                        _Mailbox(
                          next: unopened.isEmpty ? null : unopened.first,
                          remaining: unopened.length,
                          onOpen: _open,
                        ).animate().fadeIn(duration: 320.ms),
                      const SizedBox(height: AppDimens.xl),

                      // ── When you need… ──
                      if (q.isEmpty) ...[
                        Text(
                          trS(lang, 'When you need…'),
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        _FeelingsShelf(
                          child: Wrap(
                            spacing: AppDimens.sm,
                            runSpacing: AppDimens.sm,
                            children: [
                              for (final c in _needs)
                                _NeedChip(
                                  category: c,
                                  selected: _need == c,
                                  onTap: () => setState(
                                    () => _need = _need == c ? null : c,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimens.xl),
                      ],

                      // ── The tray ──
                      _WritingDesk(
                        label: trS(
                          lang,
                          _need == null
                              ? 'The letter tray'
                              : 'Letters for that',
                        ),
                        child: tray.isEmpty
                            ? _NoLetters(lang: lang)
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: AppDimens.lg,
                                      crossAxisSpacing: AppDimens.md,
                                      mainAxisExtent: 158,
                                    ),
                                itemCount: tray.length,
                                itemBuilder: (context, i) =>
                                    EnvelopeTile(
                                      letter: tray[i],
                                      onTap: () => _open(tray[i]),
                                    ).animate().fadeIn(
                                      delay: (i * 45).ms,
                                      duration: 280.ms,
                                    ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, AppLang lang) {
    return _PaperSurface(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.sm,
        AppDimens.sm,
        AppDimens.sm,
        AppDimens.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        2,
        AppDimens.xs,
        AppDimens.sm,
        AppDimens.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.purpleMid,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trS(lang, 'Inside the Treehouse'),
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9A6948),
                  ),
                ),
                Text(
                  trS(lang, 'Letters from Nana'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  trS(lang, 'Kept for whenever you need them'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: trS(lang, 'Search letters…'),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
            icon: Icon(
              _searching ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.purpleMid,
            ),
          ),
        ],
      ),
    );
  }
}

/// The mailbox on the wall, holding the next unopened letter.
class _Mailbox extends ConsumerWidget {
  const _Mailbox({
    required this.next,
    required this.remaining,
    required this.onOpen,
  });

  final Letter? next;
  final int remaining;
  final void Function(Letter) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final has = next != null;

    return Semantics(
      button: has,
      label: has
          ? '${trS(lang, 'The mailbox. A letter is waiting.')} '
                '${next!.title}. ${trS(lang, 'Opens it.')}'
          : trS(lang, 'The mailbox. Every letter has been opened.'),
      child: GestureDetector(
        onTap: has ? () => onOpen(next!) : null,
        child: Container(
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF6E9), Color(0xFFF1DAC0)],
            ),
            borderRadius: AppDimens.brXl,
            border: Border.all(color: const Color(0xFFB7845A), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5F3924).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // The box, with its flag up when something is waiting.
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.warmWhite,
                          borderRadius: AppDimens.brMd,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            has ? '💌' : '📭',
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                    ),
                    // The flag. Up only when there is genuinely something in
                    // there — it reads directly off the persisted state.
                    if (has)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          width: 5,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.pinkDeep,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trS(
                        lang,
                        has ? 'A letter for today' : 'The box is empty',
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9A5F7C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      has
                          ? next!.title
                          : trS(lang, 'You have opened every one.'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: handwriting(
                        fontSize: 21,
                        color: AppColors.purpleMid,
                      ),
                    ),
                    if (has) ...[
                      const SizedBox(height: 5),
                      Text(
                        remaining == 1
                            ? trS(lang, 'the last sealed one')
                            : '$remaining ${trS(lang, 'still sealed')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedChip extends ConsumerWidget {
  const _NeedChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final LetterCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.heartGradient : null,
          color: selected ? null : AppColors.warmWhite,
          borderRadius: AppDimens.brPill,
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.pinkLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              trS(lang, category.label),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pinned sheet of paper used for the treehouse sign and search field.
class _PaperSurface extends StatelessWidget {
  const _PaperSurface({
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(AppDimens.md),
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF8), Color(0xFFF8EEDC)],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC79A71), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF55331F).withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// The feeling labels rest on a timber ledge instead of floating like filters.
class _FeelingsShelf extends StatelessWidget {
  const _FeelingsShelf({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 14),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: Color(0xFF865433), width: 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A shallow wooden writing desk holding the actual envelopes.
class _WritingDesk extends StatelessWidget {
  const _WritingDesk({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.md,
        AppDimens.md,
        AppDimens.md,
        AppDimens.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7E4C4), Color(0xFFE6BF8C)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9C6842), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF55331F).withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 17,
                color: Color(0xFF895735),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF75482E),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          child,
        ],
      ),
    );
  }
}

class _NoLetters extends StatelessWidget {
  const _NoLetters({required this.lang});

  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
      child: Column(
        children: [
          const Icon(
            Icons.mail_outline_rounded,
            size: 38,
            color: AppColors.purpleMid,
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(lang, 'No letters found'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 3),
          Text(
            trS(lang, 'Try another word.'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
