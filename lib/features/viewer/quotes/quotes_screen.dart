import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/content_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';

/// ===========================================================================
/// THINGS WE ALWAYS SAY
/// FAMILY SAYINGS MUSEUM
/// ===========================================================================
///
/// Visual direction:
/// - Dark intimate museum/gallery
/// - Warm brass framing
/// - Large central featured memory
/// - Realistic paper exhibits
/// - Museum plaques
/// - Three-column collection
/// - Subtle shadows and motion
/// - No external assets required
/// ===========================================================================

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  static const _wall = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF171B18),
      Color(0xFF121613),
      Color(0xFF0D110F),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final sourceQuotes = ref.watch(quotesProvider);

    final exhibits = _buildExhibits(sourceQuotes);

    if (exhibits.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionScaffold(
      title: 'Things We Always Say',
      subtitle: 'Words that somehow became ours.',
      emoji: '🏛️',
      gradient: _wall,
      particles: false,
      child: _Museum(
        lang: lang,
        exhibits: exhibits,
      ),
    );
  }

  List<_MuseumQuote> _buildExhibits(List<Quote> sourceQuotes) {
    final result = <_MuseumQuote>[];

    // -----------------------------------------------------------------------
    // REAL FAMILY CONTENT
    // -----------------------------------------------------------------------

    for (final quote in sourceQuotes) {
      result.add(
        _MuseumQuote(
          text: quote.text,
          author: quote.author,
          title: 'Family Saying',
          description: 'A familiar voice from home.',
          material: _ExhibitMaterial.paper,
        ),
      );
    }

    // -----------------------------------------------------------------------
    // DISPLAY COLLECTION
    // -----------------------------------------------------------------------

    const additional = [
      _MuseumQuote(
        text: 'Are you home yet?',
        author: 'Mom',
        title: 'The First Question',
        description: 'Always. Even now.',
        material: _ExhibitMaterial.paper,
      ),
      _MuseumQuote(
        text: 'Eat first.',
        author: 'Mom',
        title: 'The Dinner Rule',
        description: 'Always hungry.',
        material: _ExhibitMaterial.paperWarm,
      ),
      _MuseumQuote(
        text: 'Be kind.',
        author: 'The family',
        title: 'The Little Reminder',
        description: 'Every day.',
        material: _ExhibitMaterial.chalk,
      ),
      _MuseumQuote(
        text: 'You can do it.',
        author: 'Dad',
        title: 'The Quiet Push',
        description: 'Still with us.',
        material: _ExhibitMaterial.notebook,
      ),
      _MuseumQuote(
        text: 'Don’t forget your jacket.',
        author: 'Mom',
        title: 'The Departure Line',
        description: 'In every season.',
        material: _ExhibitMaterial.paper,
      ),
      _MuseumQuote(
        text: 'Good things take time.',
        author: 'The family',
        title: 'The Patient One',
        description: 'Always.',
        material: _ExhibitMaterial.photo,
      ),
      _MuseumQuote(
        text: 'Home is a feeling.',
        author: 'The family',
        title: 'The Simplest Truth',
        description: 'No place like it.',
        material: _ExhibitMaterial.tornPaper,
      ),
      _MuseumQuote(
        text: 'Keep going.',
        author: 'The family',
        title: 'The Encouragement',
        description: 'For the hard days.',
        material: _ExhibitMaterial.bluePaper,
      ),
      _MuseumQuote(
        text: 'Family first.',
        author: 'The family',
        title: 'The Always',
        description: 'No matter what.',
        material: _ExhibitMaterial.paper,
      ),
      _MuseumQuote(
        text: 'You are enough.',
        author: 'The family',
        title: 'The Gentle Truth',
        description: 'Always.',
        material: _ExhibitMaterial.greenPaper,
      ),
    ];

    for (final quote in additional) {
      final exists = result.any(
        (existing) =>
            existing.text.toLowerCase() == quote.text.toLowerCase(),
      );

      if (!exists) {
        result.add(quote);
      }
    }

    return [
      for (var i = 0; i < result.length; i++)
        result[i].copyWith(number: i + 1),
    ];
  }
}

/// ===========================================================================
/// MUSEUM
/// ===========================================================================

class _Museum extends StatelessWidget {
  const _Museum({
    required this.lang,
    required this.exhibits,
  });

  final AppLang lang;
  final List<_MuseumQuote> exhibits;

  @override
  Widget build(BuildContext context) {
    final featured = exhibits.first;
    final remaining = exhibits.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimens.sm),

        _MuseumHeader(
          count: exhibits.length,
        )
            .animate()
            .fadeIn(
              duration: 500.ms,
            )
            .moveY(
              begin: -8,
              end: 0,
            ),

        const SizedBox(height: AppDimens.xl),

        const _MuseumIntro()
            .animate()
            .fadeIn(
              delay: 100.ms,
              duration: 450.ms,
            ),

        const SizedBox(height: AppDimens.xl),

        _FeaturedMuseumExhibit(
          exhibit: featured,
        )
            .animate()
            .fadeIn(
              delay: 180.ms,
              duration: 550.ms,
            )
            .moveY(
              begin: 18,
              end: 0,
            ),

        const SizedBox(height: AppDimens.xl),

        _CollectionHeading(
          count: remaining.length,
        )
            .animate()
            .fadeIn(
              delay: 250.ms,
              duration: 400.ms,
            ),

        const SizedBox(height: AppDimens.lg),

        _ExhibitGrid(
          exhibits: remaining,
        ),

        const SizedBox(height: AppDimens.xl),

        _MuseumClosing(
          lang: lang,
          count: exhibits.length,
        )
            .animate()
            .fadeIn(
              duration: 500.ms,
            ),

        const SizedBox(height: AppDimens.lg),

        Text(
          trS(
            lang,
            'Said so often nobody remembers who said it first.',
          ),
          textAlign: TextAlign.center,
          style: _serif(
            size: 14,
            color: Colors.white.withValues(alpha: 0.55),
            italic: true,
          ),
        ),

        const SizedBox(height: AppDimens.lg),
      ],
    );
  }
}

/// ===========================================================================
/// HEADER
/// ===========================================================================

class _MuseumHeader extends StatelessWidget {
  const _MuseumHeader({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF171A17),
            border: Border.all(
              color: const Color(0xFFC59A5A).withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_outlined,
            color: Color(0xFFE2C184),
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE FAMILY ARCHIVE',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  color: const Color(0xFFD5B57A).withValues(alpha: 0.85),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Things We Always Say',
                style: _serif(
                  size: 24,
                  color: const Color(0xFFF3EEE3),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'Words that somehow became ours.',
                style: _serif(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count quotes',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// INTRO
/// ===========================================================================

class _MuseumIntro extends StatelessWidget {
  const _MuseumIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF202621).withValues(alpha: 0.90),
        border: Border.all(
          color: const Color(0xFFB8945D).withValues(alpha: 0.34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFC7A369),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A COLLECTION OF LITTLE REMINDERS FROM HOME.',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: const Color(0xFFD3B47E),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Some sayings never leave us. They live in our memories, our habits, and in everyday moments.',
                  style: _serif(
                    size: 12,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.70),
                    italic: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// COLLECTION HEADING
/// ===========================================================================

class _CollectionHeading extends StatelessWidget {
  const _CollectionHeading({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERMANENT COLLECTION',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: const Color(0xFFD0AA6E),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Words that stayed',
                style: _serif(
                  size: 21,
                  color: const Color(0xFFF0E8DA),
                ),
              ),
            ],
          ),
        ),

        Text(
          '$count exhibits',
          style: TextStyle(
            fontSize: 8,
            color: Colors.white.withValues(alpha: 0.42),
          ),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// FEATURED EXHIBIT
/// ===========================================================================

class _FeaturedMuseumExhibit extends StatefulWidget {
  const _FeaturedMuseumExhibit({
    required this.exhibit,
  });

  final _MuseumQuote exhibit;

  @override
  State<_FeaturedMuseumExhibit> createState() =>
      _FeaturedMuseumExhibitState();
}

class _FeaturedMuseumExhibitState
    extends State<_FeaturedMuseumExhibit> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.exhibit;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selected = !_selected;
        });
      },
      child: AnimatedScale(
        scale: _selected ? 1.012 : 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // LARGE FRAME
            // ---------------------------------------------------------------

            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF805D35),
                    Color(0xFFE0B978),
                    Color(0xFF76512B),
                    Color(0xFFC79A58),
                    Color(0xFF76502B),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.60),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD8B16C).withValues(
                      alpha: _selected ? 0.25 : 0.08,
                    ),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE4C98E),
                    width: 1,
                  ),
                ),
                child: Container(
                  height: 238,
                  decoration: const BoxDecoration(
                    color: Color(0xFF252B24),
                  ),
                  child: Stack(
                    children: [
                      const _FrameGlow(),

                      Center(
                        child: _PaperQuote(
                          exhibit: q,
                          featured: true,
                          selected: _selected,
                        ),
                      ),

                      const Positioned(
                        top: 10,
                        right: 12,
                        child: _FrameHanger(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------------------------------------------------------------
            // BRASS PLAQUE
            // ---------------------------------------------------------------

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 42),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFAA793F),
                    Color(0xFFD5AE6B),
                    Color(0xFFA6743B),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    q.title,
                    textAlign: TextAlign.center,
                    style: _serif(
                      size: 11,
                      color: const Color(0xFF2A1D10),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    q.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7.5,
                      color: const Color(0xFF402B17),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _selected
                    ? 'EXHIBIT HIGHLIGHTED'
                    : 'TAP A QUOTE TO STRAIGHTEN IT',
                key: ValueKey(_selected),
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white.withValues(alpha: 0.40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// GRID
/// ===========================================================================

class _ExhibitGrid extends StatelessWidget {
  const _ExhibitGrid({
    required this.exhibits,
  });

  final List<_MuseumQuote> exhibits;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 700
            ? 4
            : 3;

        final gap = width >= 460 ? 12.0 : 7.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exhibits.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap + 5,
            childAspectRatio: width < 460 ? 0.72 : 0.82,
          ),
          itemBuilder: (context, index) {
            return _SmallExhibit(
              exhibit: exhibits[index],
              index: index,
            )
                .animate()
                .fadeIn(
                  delay: Duration(
                    milliseconds: 60 * index,
                  ),
                  duration: 350.ms,
                )
                .moveY(
                  begin: 12,
                  end: 0,
                );
          },
        );
      },
    );
  }
}

/// ===========================================================================
/// SMALL EXHIBIT
/// ===========================================================================

class _SmallExhibit extends StatefulWidget {
  const _SmallExhibit({
    required this.exhibit,
    required this.index,
  });

  final _MuseumQuote exhibit;
  final int index;

  @override
  State<_SmallExhibit> createState() => _SmallExhibitState();
}

class _SmallExhibitState extends State<_SmallExhibit> {
  bool _selected = false;

  static const _rotations = [
    -0.018,
    0.012,
    -0.009,
    0.015,
    -0.012,
    0.008,
  ];

  @override
  Widget build(BuildContext context) {
    final q = widget.exhibit;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selected = !_selected;
        });
      },
      child: AnimatedScale(
        scale: _selected ? 1.025 : 1,
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF20251F),
            border: Border.all(
              color: _selected
                  ? const Color(0xFFD2A961)
                  : const Color(0xFF806B4C).withValues(alpha: 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _selected ? 0.58 : 0.40,
                ),
                blurRadius: _selected ? 17 : 10,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    8,
                    10,
                    8,
                    7,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: _selected
                          ? 0
                          : _rotations[
                              widget.index % _rotations.length
                            ],
                      child: _SmallQuoteMaterial(
                        exhibit: q,
                      ),
                    ),
                  ),
                ),
              ),

              _SmallMuseumLabel(
                title: q.title,
                description: q.description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// MATERIAL SWITCHER
/// ===========================================================================

class _SmallQuoteMaterial extends StatelessWidget {
  const _SmallQuoteMaterial({
    required this.exhibit,
  });

  final _MuseumQuote exhibit;

  @override
  Widget build(BuildContext context) {
    switch (exhibit.material) {
      case _ExhibitMaterial.chalk:
        return _ChalkQuote(
          exhibit: exhibit,
        );

      case _ExhibitMaterial.notebook:
        return _NotebookQuote(
          exhibit: exhibit,
        );

      case _ExhibitMaterial.photo:
        return _PhotoQuote(
          exhibit: exhibit,
        );

      default:
        return _PaperQuote(
          exhibit: exhibit,
          featured: false,
          selected: false,
        );
    }
  }
}

/// ===========================================================================
/// PAPER
/// ===========================================================================

class _PaperQuote extends StatelessWidget {
  const _PaperQuote({
    required this.exhibit,
    required this.featured,
    required this.selected,
  });

  final _MuseumQuote exhibit;
  final bool featured;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final fontSize = featured ? 24.0 : 14.0;

    return Container(
      width: featured ? 230 : double.infinity,
      constraints: BoxConstraints(
        minHeight: featured ? 145 : 75,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: featured ? 19 : 9,
        vertical: featured ? 21 : 11,
      ),
      decoration: BoxDecoration(
        color: _paperColor(exhibit.material),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: featured ? 14 : 7,
            offset: const Offset(3, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFBEA27A).withValues(alpha: 0.40),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (featured)
            const Positioned(
              top: -29,
              left: 0,
              right: 0,
              child: Center(
                child: _PaperTape(),
              ),
            ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '“${exhibit.text}”',
                textAlign: TextAlign.center,
                maxLines: featured ? 4 : 4,
                overflow: TextOverflow.ellipsis,
                style: _handwriting(
                  fontSize: fontSize,
                  color: const Color(0xFF292824),
                ),
              ),

              SizedBox(
                height: featured ? 17 : 7,
              ),

              Container(
                width: featured ? 34 : 20,
                height: 1,
                color: const Color(0xFF8B7658).withValues(alpha: 0.50),
              ),

              SizedBox(
                height: featured ? 8 : 5,
              ),

              Text(
                '— ${exhibit.author}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: featured ? 11 : 7.5,
                  color: const Color(0xFF5C4A35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _paperColor(_ExhibitMaterial material) {
    switch (material) {
      case _ExhibitMaterial.paperWarm:
        return const Color(0xFFE8B6A2);

      case _ExhibitMaterial.bluePaper:
        return const Color(0xFF9DB7CA);

      case _ExhibitMaterial.greenPaper:
        return const Color(0xFFB2C5AF);

      case _ExhibitMaterial.tornPaper:
        return const Color(0xFFE7D4B5);

      default:
        return const Color(0xFFF0D7AA);
    }
  }
}

/// ===========================================================================
/// CHALKBOARD
/// ===========================================================================

class _ChalkQuote extends StatelessWidget {
  const _ChalkQuote({
    required this.exhibit,
  });

  final _MuseumQuote exhibit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 75,
      ),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF151A18),
        border: Border.all(
          color: const Color(0xFF80694A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.48),
            blurRadius: 8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '“${exhibit.text}”',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: _handwriting(
                fontSize: 14,
                color: const Color(0xFFE5D5B6),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              '♡',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFD7B77C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// NOTEBOOK
/// ===========================================================================

class _NotebookQuote extends StatelessWidget {
  const _NotebookQuote({
    required this.exhibit,
  });

  final _MuseumQuote exhibit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 75,
      ),
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        8,
        8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DED0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 7,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: const Color(0xFFD18F84).withValues(alpha: 0.65),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '“${exhibit.text}”',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _handwriting(
                  fontSize: 14,
                  color: const Color(0xFF292722),
                ),
              ),
            ),
          ),

          const Positioned(
            right: -2,
            top: -5,
            child: Icon(
              Icons.attach_file_rounded,
              size: 17,
              color: Color(0xFF8A6B3E),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// PHOTO
/// ===========================================================================

class _PhotoQuote extends StatelessWidget {
  const _PhotoQuote({
    required this.exhibit,
  });

  final _MuseumQuote exhibit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 75,
      ),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFFE6DED0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 7,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8A9698),
                    Color(0xFF566C71),
                    Color(0xFF35464B),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.landscape_outlined,
                  size: 25,
                  color: Color(0xFFD7D2C4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '“${exhibit.text}”',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _handwriting(
              fontSize: 11,
              color: const Color(0xFF282722),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// SMALL MUSEUM LABEL
/// ===========================================================================

class _SmallMuseumLabel extends StatelessWidget {
  const _SmallMuseumLabel({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        6,
        7,
        6,
        8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9B713E),
            Color(0xFFC09455),
            Color(0xFF8C6335),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _serif(
              size: 8,
              color: const Color(0xFF261A0E),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 6.5,
              color: const Color(0xFF3E2915),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// FRAME GLOW
/// ===========================================================================

class _FrameGlow extends StatelessWidget {
  const _FrameGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.8),
              radius: 1.15,
              colors: [
                const Color(0xFFD7B477).withValues(alpha: 0.22),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// PAPER TAPE
/// ===========================================================================

class _PaperTape extends StatelessWidget {
  const _PaperTape();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.02,
      child: Container(
        width: 30,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFE8CFA0).withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// FRAME HANGER
/// ===========================================================================

class _FrameHanger extends StatelessWidget {
  const _FrameHanger();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD4AF6D).withValues(alpha: 0.72),
        ),
      ),
      child: const Icon(
        Icons.push_pin_outlined,
        size: 11,
        color: Color(0xFFD4AF6D),
      ),
    );
  }
}

/// ===========================================================================
/// CLOSING
/// ===========================================================================

class _MuseumClosing extends StatelessWidget {
  const _MuseumClosing({
    required this.lang,
    required this.count,
  });

  final AppLang lang;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B211D),
        border: Border.all(
          color: const Color(0xFFB18A54).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.museum_outlined,
            size: 22,
            color: Color(0xFFD0A968),
          ),

          const SizedBox(height: 9),

          Text(
            'THE ARCHIVE',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.1,
              color: const Color(0xFFD0A968),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '$count exhibits and counting.',
            textAlign: TextAlign.center,
            style: _serif(
              size: 17,
              color: const Color(0xFFF0E7D8),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            trS(
              lang,
              'Some memories are photographs. Others are only a sentence someone said a hundred times.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.53),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// DATA
/// ===========================================================================

enum _ExhibitMaterial {
  paper,
  paperWarm,
  chalk,
  notebook,
  photo,
  tornPaper,
  bluePaper,
  greenPaper,
}

class _MuseumQuote {
  const _MuseumQuote({
    required this.text,
    required this.author,
    required this.title,
    required this.description,
    required this.material,
    this.number = 0,
  });

  final String text;
  final String author;
  final String title;
  final String description;
  final _ExhibitMaterial material;
  final int number;

  _MuseumQuote copyWith({
    String? text,
    String? author,
    String? title,
    String? description,
    _ExhibitMaterial? material,
    int? number,
  }) {
    return _MuseumQuote(
      text: text ?? this.text,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      material: material ?? this.material,
      number: number ?? this.number,
    );
  }
}

/// ===========================================================================
/// TYPOGRAPHY
/// ===========================================================================

TextStyle _serif({
  required double size,
  required Color color,
  double height = 1.2,
  bool italic = false,
}) {
  return TextStyle(
    fontFamily: 'Georgia',
    fontSize: size,
    height: height,
    color: color,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  );
}

/// Handwritten-style treatment.
///
/// This intentionally does not depend on an external font package, so the
/// screen remains self-contained. Georgia Italic gives the paper notes a
/// softer handwritten/editorial feeling while remaining reliable on devices.
TextStyle _handwriting({
  required double fontSize,
  required Color color,
}) {
  return TextStyle(
    fontFamily: 'Georgia',
    fontSize: fontSize,
    height: 1.15,
    color: color,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
  );
}