import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_photos.dart';
import '../../../core/constants/enums.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/cover.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/scrapbook.dart';
import '../../../shared/widgets/states.dart';

/// **Our Memories** — an open scrapbook, not a filtered database.
///
/// Header, search box, a row of technical category chips, then a column of
/// identical cards: that is a content-management screen, and it was the last
/// one in the app still shaped like one.
///
/// Now it's pages. Each year is a handwritten heading with the photographs
/// taped underneath at whatever size and angle they were stuck in — one big,
/// two small, never a grid. Searching and filtering moved behind one button,
/// because you open an album to look at it, not to query it.
class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  MemoryCategory _category = MemoryCategory.all;
  String _query = '';
  bool _favoritesOnly = false;

  static const _page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9F2E8), Color(0xFFF3E9DC)],
  );

  bool get _filtering =>
      _category != MemoryCategory.all || _query.isNotEmpty || _favoritesOnly;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final all = ref.watch(memoriesProvider);
    final favs = ref.watch(favoritesProvider);
    final q = _query.trim().toLowerCase();

    final filtered = all.where((m) {
      final matchesCat =
          _category == MemoryCategory.all || m.category == _category;
      final matchesQuery =
          q.isEmpty ||
          m.title.toLowerCase().contains(q) ||
          m.description.toLowerCase().contains(q) ||
          m.tags.any((t) => t.toLowerCase().contains(q));
      final matchesFav =
          !_favoritesOnly || favs.contains(favKey(FavKind.memory, m.id));
      return matchesCat && matchesQuery && matchesFav;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    // Pages are years.
    final years = <int, List<Memory>>{};
    for (final m in filtered) {
      years.putIfAbsent(m.date.year, () => []).add(m);
    }

    // Scrapbook paper is a daylight colour; at night the dark wash takes over.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        gradient: isDark ? null : _page,
        child: SafeArea(
          child: Column(
            children: [
              _bar(lang),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.auto_stories_rounded,
                        title: 'Nothing on this page',
                        message: _filtering
                            ? 'Try a different word, or clear the filters.'
                            : 'Memories will be pasted in here.',
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.lg,
                          AppDimens.sm,
                          AppDimens.lg,
                          80,
                        ),
                        children: [
                          for (final entry in years.entries) ...[
                            _YearHeading(year: entry.key),
                            ..._layOut(entry.value),
                            const SizedBox(height: AppDimens.xl),
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

  /// Lay a year's photographs onto the page: one wide, then pairs. Never an
  /// even grid — a scrapbook was filled a photo at a time, not laid out.
  List<Widget> _layOut(List<Memory> items) {
    final out = <Widget>[];
    var i = 0;
    var n = 0;
    while (i < items.length) {
      // Every third slot is a wide one.
      if (n % 3 == 0 || i == items.length - 1) {
        final memory = items[i];
        out.add(
          _Taped(
            memory: memory,
            wide: true,
            index: n,
            onTap: () => context.push(Routes.memoryOf(memory.id)),
          ),
        );
        i += 1;
      } else {
        final pair = items.skip(i).take(2).toList();
        out.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (k, memory) in pair.indexed) ...[
                Expanded(
                  child: _Taped(
                    memory: memory,
                    wide: false,
                    index: n + k,
                    onTap: () => context.push(Routes.memoryOf(memory.id)),
                  ),
                ),
                if (k == 0 && pair.length > 1)
                  const SizedBox(width: AppDimens.md),
              ],
            ],
          ),
        );
        i += pair.length;
      }
      out.add(const SizedBox(height: AppDimens.lg));
      n++;
    }
    return out;
  }

  Widget _bar(AppLang lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.sm,
        AppDimens.sm,
        AppDimens.md,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trS(lang, 'Our Memories'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  trS(lang, 'Pasted in, a day at a time'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // One button for everything that used to be a permanent toolbar.
          Semantics(
            button: true,
            label: trS(lang, 'Find a memory'),
            child: IconButton(
              onPressed: _openDrawer,
              icon: Icon(
                _filtering ? Icons.filter_alt_rounded : Icons.search_rounded,
                color: _filtering ? AppColors.pinkDeep : AppColors.purpleMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDrawer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterDrawer(
        query: _query,
        category: _category,
        favoritesOnly: _favoritesOnly,
        onChanged: (q, c, f) => setState(() {
          _query = q;
          _category = c;
          _favoritesOnly = f;
        }),
      ),
    );
  }
}

class _YearHeading extends StatelessWidget {
  const _YearHeading({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.md, bottom: AppDimens.lg),
      child: Row(
        children: [
          Text(
            '$year',
            style: handwriting(
              fontSize: 32,
              color: pageInk(context, strong: true),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.lavenderLight.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// A photograph taped onto the page.
class _Taped extends ConsumerWidget {
  const _Taped({
    required this.memory,
    required this.wide,
    required this.index,
    required this.onTap,
  });

  final Memory memory;
  final bool wide;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final asset = AppPhotos.memoryCardCover(memory.id);
    final caption = AppPhotos.captionFor(asset);
    final edited = caption != null;
    final fav = ref.watch(
      isFavoriteProvider((kind: FavKind.memory, id: memory.id)),
    );
    final tilt = (index.isEven ? 1 : -1) * (0.012 + (index % 3) * 0.006);

    return Semantics(
      button: true,
      label: '${memory.title}, ${memory.date.prettyDate}. Opens it.',
      child: GestureDetector(
        onTap: onTap,
        child: Transform.rotate(
          angle: tilt,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(9, 9, 9, 7),
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: wide ? 1.7 : 1,
                      child: Hero(
                        tag: 'memory-${memory.id}',
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: edited ? Colors.white : null,
                            gradient: edited
                                ? null
                                : CoverPalette.gradient(memory.colorSeed),
                          ),
                          child: Image.asset(
                            asset,
                            fit: edited ? BoxFit.contain : BoxFit.cover,
                            width: double.infinity,
                            // Most memories have no photo file yet; the
                            // coloured plate is the page showing through.
                            errorBuilder: (_, _, _) => Center(
                              child: Icon(
                                memory.category.icon,
                                color: edited
                                    ? AppColors.lavender
                                    : Colors.white.withValues(alpha: 0.55),
                                size: wide ? 34 : 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      trS(lang, memory.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: handwriting(
                        fontSize: wide ? 19 : 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            memory.date.dayMonth,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (memory.hasVoice)
                          const Icon(
                            Icons.graphic_eq_rounded,
                            size: 11,
                            color: AppColors.lavender,
                          ),
                        if (fav) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.favorite_rounded,
                            size: 11,
                            color: AppColors.pinkDeep,
                          ),
                        ],
                      ],
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 4),
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
              // The tape holding it down.
              Positioned(
                left: wide ? 24 : 12,
                top: -6,
                child: WashiTape(
                  width: wide ? 46 : 32,
                  rotation: index.isEven ? 0.3 : -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 55).ms, duration: 300.ms);
  }
}

/// Search, categories and favourites — all of it, out of the way until asked.
class _FilterDrawer extends StatefulWidget {
  const _FilterDrawer({
    required this.query,
    required this.category,
    required this.favoritesOnly,
    required this.onChanged,
  });

  final String query;
  final MemoryCategory category;
  final bool favoritesOnly;
  final void Function(String, MemoryCategory, bool) onChanged;

  @override
  State<_FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<_FilterDrawer> {
  late String _q = widget.query;
  late MemoryCategory _c = widget.category;
  late bool _f = widget.favoritesOnly;

  void _push() => widget.onChanged(_q, _c, _f);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.lg,
          AppDimens.md,
          AppDimens.lg,
          AppDimens.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            TextField(
              autofocus: true,
              controller: TextEditingController(text: _q)
                ..selection = TextSelection.collapsed(offset: _q.length),
              onChanged: (v) {
                _q = v;
                _push();
              },
              decoration: const InputDecoration(
                hintText: 'Search memories…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: AppDimens.sm,
              children: [
                for (final c in MemoryCategory.values)
                  GestureDetector(
                    onTap: () {
                      setState(() => _c = c);
                      _push();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: _c == c ? AppColors.softGradient : null,
                        color: _c == c ? null : AppColors.warmWhite,
                        borderRadius: AppDimens.brPill,
                        border: Border.all(
                          color: _c == c
                              ? Colors.transparent
                              : AppColors.lavenderSoft,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            c.icon,
                            size: 14,
                            color: _c == c
                                ? AppColors.purpleMid
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _c == c
                                  ? AppColors.purpleMid
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            GestureDetector(
              onTap: () {
                setState(() => _f = !_f);
                _push();
              },
              child: Row(
                children: [
                  Icon(
                    _f ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _f ? AppColors.pinkDeep : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: Text(
                      'Only the ones she loves',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _f ? AppColors.pinkDeep : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
