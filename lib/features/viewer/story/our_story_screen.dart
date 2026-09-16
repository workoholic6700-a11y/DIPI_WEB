import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_photos.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/story_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/scrapbook.dart';

/// **Our Story** — an actual book.
///
/// It was one long scroll with ribbons between the chapters, which reads like
/// a web article. A story should be *paged*: one chapter at a time, on paper,
/// with the binding down the left, a page number, and the next chapter arriving
/// when you turn it.
///
/// The turn is a short slide and a crossfade rather than a page curl — a curl
/// is expensive, and on a phone it mostly gets in the way of the words.
class OurStoryScreen extends ConsumerStatefulWidget {
  const OurStoryScreen({super.key});

  @override
  ConsumerState<OurStoryScreen> createState() => _OurStoryScreenState();
}

class _OurStoryScreenState extends ConsumerState<OurStoryScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) => _pages.animateToPage(
    i,
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final chapters = ref.watch(storyProvider);
    if (chapters.isEmpty) return const Scaffold();

    final atStart = _page == 0;
    final atEnd = _page == chapters.length - 1;

    // The desk the book lies on — daylight timber, or the dark wash at night.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE9DECD), Color(0xFFDCCEB8)],
              ),
        child: SafeArea(
          child: Column(
            children: [
              _bar(lang, chapters.length),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: chapters.length,
                  itemBuilder: (context, i) =>
                      _Page(chapter: chapters[i], number: i + 1, lang: lang),
                ),
              ),
              _turner(lang, atStart, atEnd, chapters.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(AppLang lang, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.sm,
        AppDimens.sm,
        AppDimens.lg,
        AppDimens.sm,
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
            child: Text(
              trS(lang, 'Our Story'),
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${_page + 1} ${trS(lang, 'of')} $total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Where you turn the page from. Also the progress: one mark per chapter.
  Widget _turner(AppLang lang, bool atStart, bool atEnd, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.lg,
        AppDimens.sm,
        AppDimens.lg,
        AppDimens.lg,
      ),
      child: Row(
        children: [
          _TurnButton(
            icon: Icons.chevron_left_rounded,
            label: trS(lang, 'Back'),
            enabled: !atStart,
            onTap: () => _go(_page - 1),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < total; i++)
                  GestureDetector(
                    onTap: () => _go(i),
                    child: Container(
                      width: i == _page ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.purpleMid
                            : AppColors.purpleMid.withValues(alpha: 0.26),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _TurnButton(
            icon: Icons.chevron_right_rounded,
            label: trS(lang, 'Next'),
            enabled: !atEnd,
            trailing: true,
            onTap: () => _go(_page + 1),
          ),
        ],
      ),
    );
  }
}

class _TurnButton extends StatelessWidget {
  const _TurnButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailing = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    final c = enabled ? AppColors.purpleMid : AppColors.textMuted;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.35,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!trailing) Icon(icon, color: c, size: 20),
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              if (trailing) Icon(icon, color: c, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// One chapter, on one leaf of paper.
class _Page extends StatelessWidget {
  const _Page({
    required this.chapter,
    required this.number,
    required this.lang,
  });

  final StoryChapter chapter;
  final int number;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final photo = AppPhotos.storyChapterPhoto(chapter.title);
    final photoCaption = photo == null ? null : AppPhotos.captionFor(photo);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.md,
        AppDimens.sm,
        AppDimens.md,
        AppDimens.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFBF5E9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            bottomLeft: Radius.circular(3),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // The binding shadow down the inner edge.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFFD9C8AC).withValues(alpha: 0.9),
                      const Color(0xFFD9C8AC).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(30, 26, 22, 26),
              children: [
                Text(
                  '${trS(lang, 'Chapter')} $number',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldDeep,
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                Text(
                  '${chapter.emoji}  ${trS(lang, chapter.title)}',
                  style: t.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  chapter.year.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
                if (chapter.hasPhoto) ...[
                  LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: Polaroid(
                        key: ValueKey('story-photo-${chapter.title}'),
                        seed: chapter.colorSeed,
                        caption: trS(lang, chapter.title),
                        assetPath: photo,
                        provenance: photoCaption == null
                            ? null
                            : trS(lang, photoCaption),
                        width: (constraints.maxWidth - 28).clamp(0, 220),
                        rotation: number.isEven ? 0.035 : -0.035,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),
                ],
                Text(
                  trS(lang, chapter.body),
                  style: t.bodyLarge?.copyWith(height: 1.75, fontSize: 16),
                ),
                const SizedBox(height: AppDimens.xl),
                // The page number, where a book puts it.
                Center(
                  child: Text(
                    '— $number —',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 260.ms);
  }
}
