import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_photos.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/models/content_models.dart';
import '../../../shared/widgets/gradient_cover.dart';

/// A quiet, full-screen way to experience one memory without app chrome.
/// It intentionally uses taps instead of autoplay so the reader controls the
/// pace of an emotional story.
class MemoryStoryMode extends StatefulWidget {
  const MemoryStoryMode({super.key, required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  State<MemoryStoryMode> createState() => _MemoryStoryModeState();
}

class _MemoryStoryModeState extends State<MemoryStoryMode> {
  late final PageController _controller;
  int _page = 0;

  int get _pageCount => widget.memory.hasVoice ? 4 : 3;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pageCount - 1) {
      Navigator.of(context).pop();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    if (_page == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;
    final pages = <Widget>[
      _CoverPage(memory: memory, lang: widget.lang),
      _WordsPage(memory: memory, lang: widget.lang),
      if (memory.hasVoice) _VoicePage(memory: memory, lang: widget.lang),
      _ClosingPage(memory: memory, lang: widget.lang),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF17101F),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) => setState(() => _page = value),
            children: pages,
          ),
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Previous part',
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _previous,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Semantics(
                    button: true,
                    label: 'Next part',
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _next,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < pages.length; i++)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            height: 3,
                            margin: EdgeInsets.only(
                              right: i == pages.length - 1 ? 0 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: i <= _page
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.24),
                              borderRadius: AppDimens.brPill,
                            ),
                          ),
                        ),
                      const SizedBox(width: AppDimens.md),
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.28),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IgnorePointer(
                    child: Text(
                      trS(
                        widget.lang,
                        _page == pages.length - 1
                            ? 'Tap to return to the memory'
                            : 'Tap the right side to continue',
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPage extends StatelessWidget {
  const _CoverPage({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final asset = AppPhotos.memoryCardCover(memory.id);
    final caption = AppPhotos.captionFor(asset);
    if (caption != null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 90, 24, 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: GradientCover(
                    seed: memory.colorSeed,
                    icon: memory.category.icon,
                    asset: asset,
                    fit: BoxFit.contain,
                    showSparkle: false,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.lg),
              _details(caption: caption),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GradientCover(
          seed: memory.colorSeed,
          icon: memory.category.icon,
          asset: asset,
          showSparkle: false,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black12, Colors.transparent, Color(0xE617101F)],
              stops: [0, 0.42, 1],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 90, 24, 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const Spacer(), _details()],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _details({String? caption}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          memory.date.prettyDate.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          trS(lang, memory.title),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (memory.location != null) ...[
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              const Icon(Icons.place_rounded, color: AppColors.gold, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trS(lang, memory.location!),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
        if (caption != null) ...[
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(lang, caption),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _WordsPage extends StatelessWidget {
  const _WordsPage({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return _NightPage(
      eyebrow: trS(lang, 'THE STORY BEHIND THE MOMENT'),
      icon: Icons.auto_stories_rounded,
      child: Text(
        trS(lang, memory.description),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          height: 1.55,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VoicePage extends StatelessWidget {
  const _VoicePage({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return _NightPage(
      eyebrow: trS(lang, 'A VOICE KEPT WITH THIS DAY'),
      icon: Icons.graphic_eq_rounded,
      child: Column(
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.heartGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.38),
                  blurRadius: 42,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: Colors.white,
              size: 54,
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          Text(
            lang == AppLang.ne
                ? 'दीक्षाले “${trS(lang, memory.title)}” सम्झिन्छिन्'
                : 'Diksha remembers “${memory.title}”',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(lang, 'The voice note remains available on the memory page.'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ClosingPage extends StatelessWidget {
  const _ClosingPage({required this.memory, required this.lang});

  final Memory memory;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final years = DateTime.now().difference(memory.date).inDays ~/ 365;
    return _NightPage(
      eyebrow: trS(lang, 'KEPT IN OUR HOME'),
      icon: Icons.favorite_rounded,
      child: Column(
        children: [
          Text(memory.mood.emoji, style: const TextStyle(fontSize: 62)),
          const SizedBox(height: AppDimens.xl),
          Text(
            lang == AppLang.ne
                ? (years > 0
                      ? '$years वर्ष बिते। त्यो अनुभूति अझै यहीं छ।'
                      : 'यो दिन अझै नजिक छ। यसको अनुभूति अहिल्यै सँगाल्न लायक छ।')
                : (years > 0
                      ? '$years ${years == 1 ? 'year has' : 'years have'} passed. The feeling stayed.'
                      : 'The day is still close. The feeling is already worth keeping.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          Text(
            trS(lang, 'Kept by Diksha, with all my love. 💜'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _NightPage extends StatelessWidget {
  const _NightPage({
    required this.eyebrow,
    required this.icon,
    required this.child,
  });

  final String eyebrow;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17101F), Color(0xFF3B2355), Color(0xFF6B3FA0)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 100, 28, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.gold, size: 18),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: Text(
                      eyebrow,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(child: child),
              const Spacer(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 450.ms);
  }
}
