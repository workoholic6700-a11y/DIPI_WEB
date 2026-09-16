import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_photos.dart';
import '../../../../../core/i18n/l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/utils/date_x.dart';
import '../../../../../data/models/content_models.dart';
import '../../../../../data/providers/content_providers.dart';
import '../../../../../shared/widgets/scrapbook.dart';
import '../home_atmosphere.dart';

/// **Today's table** — what the family left out for her.
///
/// This replaces three equally-weighted gradient cards. The difference isn't
/// decoration: cards in a row are a menu, and things lying on a table are a
/// composition. So these overlap slightly, sit at different angles, and are
/// each shaped like the object they actually are — a photograph, an envelope, a
/// note by the calendar.
class TodaysTable extends ConsumerWidget {
  const TodaysTable({
    super.key,
    required this.memory,
    required this.letter,
    required this.birthday,
    required this.quote,
    required this.onMemory,
    required this.onLetter,
    required this.onBirthday,
  });

  final Memory memory;
  final Letter letter;
  final ({String name, int days}) birthday;
  final Quote quote;
  final VoidCallback onMemory;
  final VoidCallback onLetter;
  final VoidCallback onBirthday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atmos = ref.watch(atmosphereProvider);

    return LayoutBuilder(
      builder: (context, box) {
        // Two objects across, sized off the real width. On a very narrow
        // phone the table collapses to one column rather than overflowing —
        // objects on a small table get stacked, not squeezed.
        final w = (box.maxWidth - AppDimens.md) / 2;
        if (w < 150) return _stacked(atmos);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MemoryPolaroid(
                      memory: memory,
                      width: w,
                      shadow: atmos.shelfShadow,
                      onTap: onMemory,
                    )
                    .animate()
                    .fadeIn(delay: 380.ms, duration: 340.ms)
                    .moveY(begin: 12, end: 0)
                    .rotate(begin: -0.05, end: -0.028),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Envelope(
                            letter: letter,
                            shadow: atmos.shelfShadow,
                            onTap: onLetter,
                          )
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 340.ms)
                          .moveY(begin: 12, end: 0)
                          .rotate(begin: 0.04, end: 0.018),
                      const SizedBox(height: AppDimens.md),
                      _BirthdayNote(
                            birthday: birthday,
                            shadow: atmos.shelfShadow,
                            onTap: onBirthday,
                          )
                          .animate()
                          .fadeIn(delay: 520.ms, duration: 340.ms)
                          .moveY(begin: 12, end: 0),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sm),
            // Tucked half under the rest, the way a note actually ends up.
            _QuoteScrap(
              quote: quote,
            ).animate().fadeIn(delay: 600.ms, duration: 360.ms),
          ],
        );
      },
    );
  }

  /// One column, for the narrowest phones.
  Widget _stacked(Atmosphere atmos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Envelope(
          letter: letter,
          shadow: atmos.shelfShadow,
          onTap: onLetter,
        ).animate().fadeIn(delay: 380.ms, duration: 340.ms),
        const SizedBox(height: AppDimens.md),
        _BirthdayNote(
          birthday: birthday,
          shadow: atmos.shelfShadow,
          onTap: onBirthday,
        ).animate().fadeIn(delay: 450.ms, duration: 340.ms),
        const SizedBox(height: AppDimens.md),
        _QuoteScrap(
          quote: quote,
        ).animate().fadeIn(delay: 520.ms, duration: 340.ms),
      ],
    );
  }
}

/// The memory, as a photograph someone put down.
class _MemoryPolaroid extends ConsumerWidget {
  const _MemoryPolaroid({
    required this.memory,
    required this.width,
    required this.shadow,
    required this.onTap,
  });

  final Memory memory;
  final double width;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final cover = AppPhotos.memoryCardCover(memory.id);
    final caption = AppPhotos.captionFor(cover);
    return Semantics(
      button: true,
      label:
          '${trS(lang, 'Memory')}: ${trS(lang, memory.title)}, '
          '${memory.date.dayMonth}.',
      hint: trS(lang, 'Open memory'),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 14,
                offset: const Offset(2, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: caption != null
                      ? Colors.white
                      : AppColors.lavenderSoft,
                  child: Image.asset(
                    cover,
                    fit: caption != null ? BoxFit.contain : BoxFit.cover,
                    // Until a real photo is dropped in, this shows the soft
                    // gradient rather than a broken box.
                    errorBuilder: (_, _, _) => const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.softGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_florist_rounded,
                          size: 26,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                memory.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: handwriting(fontSize: 15, color: AppColors.textPrimary),
              ),
              Text(
                memory.date.dayMonth,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 3),
                Text(
                  trS(lang, caption),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The letter, as a sealed envelope. Closed means closed.
class _Envelope extends ConsumerWidget {
  const _Envelope({
    required this.letter,
    required this.shadow,
    required this.onTap,
  });

  final Letter letter;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final opened = ref.watch(isLetterOpenedProvider(letter.id));
    return Semantics(
      button: true,
      label:
          '${opened ? 'An opened' : 'A sealed'} letter to Dipisha from '
          'Nana: ${letter.title}. Opens the letter.',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF0F4),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.pink.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (opened)
                Positioned(
                  left: 12,
                  right: 12,
                  top: -13,
                  height: 48,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(9, 7, 9, 4),
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite,
                      border: Border.all(color: AppColors.pinkLight),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    child: Text(
                      letter.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: handwriting(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              // The flap, drawn as two folds meeting in the middle.
              Positioned.fill(
                child: CustomPaint(painter: _FlapPainter(opened: opened)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trS(lang, 'To')}: ${trS(lang, 'Dipisha')} 💜',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        // The wax seal disappears after this letter has been
                        // opened; a corner of the paper then peeks out above.
                        if (!opened)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.pinkDeep,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('💗', style: TextStyle(fontSize: 8)),
                            ),
                          ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '${trS(lang, 'From')}: ${trS(lang, 'Nana')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: handwriting(
                              fontSize: 15,
                              color: AppColors.purpleMid,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _FlapPainter extends CustomPainter {
  const _FlapPainter({required this.opened});

  final bool opened;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.pink.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // An opened envelope folds the flap back toward the top; a sealed one has
    // the familiar downward point.
    final apex = Offset(size.width / 2, opened ? 4 : size.height * 0.46);
    canvas.drawLine(Offset.zero, apex, p);
    canvas.drawLine(Offset(size.width, 0), apex, p);
  }

  @override
  bool shouldRepaint(covariant _FlapPainter oldDelegate) =>
      oldDelegate.opened != opened;
}

/// The next birthday, as a note left by the calendar.
class _BirthdayNote extends ConsumerWidget {
  const _BirthdayNote({
    required this.birthday,
    required this.shadow,
    required this.onTap,
  });

  final ({String name, int days}) birthday;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final today = birthday.days == 0;
    return Semantics(
      button: true,
      // The visible text got singular/plural right; this didn't, so a screen
      // reader was saying "in 1 days". Someone who only hears the app should
      // hear it as carefully written as someone who only sees it.
      label: today
          ? 'Note by the calendar: it is ${birthday.name}\'s birthday today. '
                'Opens the Celebration Hall.'
          : 'Note by the calendar: ${birthday.name}\'s birthday is in '
                '${birthday.days} '
                '${birthday.days == 1 ? 'day' : 'days'}. '
                'Opens the Celebration Hall.',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF3DC),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🎂', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      trS(lang, 'Next at our table'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9A7A34),
                      ),
                    ),
                  ),
                  // A marigold sits by the note, the way it would.
                  const Text('🌼', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                today
                    ? '${trS(lang, birthday.name)} · ${trS(lang, 'today')}'
                    // "1 days away" is the kind of small wrongness that makes a
                    // handmade thing feel machine-made.
                    : '${trS(lang, birthday.name)} · ${birthday.days} '
                          '${trS(lang, birthday.days == 1 ? 'day away' : 'days away')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: handwriting(
                  fontSize: 17,
                  color: const Color(0xFF7A5E22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The quote, on a torn scrap — small, and clearly not another panel.
class _QuoteScrap extends ConsumerWidget {
  const _QuoteScrap({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 8),
      child: Transform.rotate(
        angle: -0.012,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“${quote.text}”',
                style: handwriting(fontSize: 17, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                '— ${quote.author}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
