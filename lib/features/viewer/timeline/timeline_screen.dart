import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/cover.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/lottie_art.dart';
import '../../../shared/widgets/section_scaffold.dart';

/// **Our Years** — a hallway you walk down, not a feed you scroll.
///
/// It was a vertical rail of white cards, all the same size, all on the same
/// side. A corridor of family photographs doesn't look like that: the frames
/// hang on alternate walls, each on its own short wire off the picture rail,
/// and the years are brass plates screwed to it.
///
/// The year buttons along the top walk you straight to that stretch of the
/// hallway.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final _scroll = ScrollController();
  final _yearKeys = <int, GlobalKey>{};

  static const _hallway = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF1EAF3), Color(0xFFF6F0E8)],
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _walkTo(int year) {
    final key = _yearKeys[year];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final events = [...ref.watch(timelineProvider)]
      ..sort((a, b) => b.date.compareTo(a.date));

    final years = <int, List<TimelineEvent>>{};
    for (final e in events) {
      years.putIfAbsent(e.year, () => []).add(e);
    }
    for (final y in years.keys) {
      _yearKeys.putIfAbsent(y, () => GlobalKey());
    }

    return SectionScaffold(
      title: 'Our Years',
      subtitle: 'Walk down the hallway',
      emoji: '🖼️',
      gradient: _hallway,
      particles: false,
      scrollable: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Jump straight to a year.
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
              children: [
                for (final y in years.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _YearButton(year: y, onTap: () => _walkTo(y)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg, AppDimens.sm, AppDimens.lg, 60),
              children: [
                // The memory tree the village points at. Left in place —
                // deleting it would break that landmark's meaning.
                Center(
                  child: Column(
                    children: [
                      const LottieArt(Anim.treeInWind,
                          height: 130, semanticLabel: 'Our memory tree'),
                      Text(
                        trS(lang, 'Our Memory Tree · सम्झनाको रूख'),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: AppColors.purpleMid),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trS(lang, 'Every year, another ring.'),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ).animate().fadeIn(duration: 460.ms),
                ),
                const SizedBox(height: AppDimens.lg),
                for (final entry in years.entries) ...[
                  _YearPlate(key: _yearKeys[entry.key], year: entry.key),
                  for (var i = 0; i < entry.value.length; i++)
                    _HungFrame(
                      event: entry.value[i],
                      // Alternate walls as you walk down.
                      onLeft: i.isEven,
                      index: i,
                      lang: lang,
                    ),
                ],
                const SizedBox(height: AppDimens.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearButton extends StatelessWidget {
  const _YearButton({required this.year, required this.onTap});

  final int year;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Walk to $year',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: AppDimens.brPill,
            border:
                Border.all(color: AppColors.lavender.withValues(alpha: 0.30)),
          ),
          child: Text(
            '$year',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: AppColors.purpleMid,
            ),
          ),
        ),
      ),
    );
  }
}

/// A brass plate on the rail, marking where a year starts.
class _YearPlate extends StatelessWidget {
  const _YearPlate({super.key, required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
      child: Row(
        children: [
          Expanded(child: _rail()),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0C489), Color(0xFFB9975A)],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 6,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Text(
              '$year',
              style: const TextStyle(
                color: Color(0xFF4A3714),
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(child: _rail()),
        ],
      ),
    );
  }

  Widget _rail() => Container(
        height: 2,
        color: const Color(0xFFC9B79B),
      );
}

/// One year's moment, framed and hung on one wall of the hallway.
class _HungFrame extends StatefulWidget {
  const _HungFrame({
    required this.event,
    required this.onLeft,
    required this.index,
    required this.lang,
  });

  final TimelineEvent event;
  final bool onLeft;
  final int index;
  final AppLang lang;

  @override
  State<_HungFrame> createState() => _HungFrameState();
}

class _HungFrameState extends State<_HungFrame> {
  bool _held = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final t = Theme.of(context).textTheme;
    final base = CoverPalette.base(e.colorSeed);
    // Nothing on a wall hangs straight.
    final tilt = (widget.index.isEven ? 1 : -1) * 0.012;

    final frame = Semantics(
      label: '${trS(widget.lang, e.title)}, ${e.date.prettyDate}. '
          'A framed moment.',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _held = true),
        onTapUp: (_) => setState(() => _held = false),
        onTapCancel: () => setState(() => _held = false),
        child: AnimatedRotation(
          turns: _held ? 0 : tilt / (2 * 3.1415926),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: _held ? 1.03 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFB08A63),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: _held ? 0.26 : 0.15),
                    blurRadius: _held ? 16 : 9,
                    offset: Offset(0, _held ? 8 : 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(AppDimens.md),
                color: AppColors.warmWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: CoverPalette.gradient(e.colorSeed),
                            shape: BoxShape.circle,
                          ),
                          child: Text(e.emoji,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(
                            trS(widget.lang, e.title),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      trS(widget.lang, e.description),
                      style: t.bodySmall?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.date.prettyDate,
                      style: TextStyle(
                          fontSize: 10.5, color: base.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.xl),
      child: Row(
        children: [
          if (!widget.onLeft) const Spacer(),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.62,
            child: Column(
              crossAxisAlignment: widget.onLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                // The wire it hangs from.
                Padding(
                  padding: EdgeInsets.only(
                      left: widget.onLeft ? 26 : 0,
                      right: widget.onLeft ? 0 : 26),
                  child: Container(
                    width: 1.5,
                    height: 14,
                    color: const Color(0xFFC0AC8E),
                  ),
                ),
                frame,
              ],
            ),
          ),
          if (widget.onLeft) const Spacer(),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (widget.index * 60).ms, duration: 320.ms)
        .moveY(begin: 8, end: 0);
  }
}
