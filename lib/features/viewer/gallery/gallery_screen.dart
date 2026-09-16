import 'widgets/gallery_auto_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/l10n.dart';
import '../../../data/gallery/gallery_providers.dart';
import '../../admin/gallery_admin_page.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/content_models.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/album_book.dart';

/// **Family Albums** — a bookcase, not a photo grid.
///
/// Gallery and Memories were becoming the same screen: two grids of coloured
/// tiles. They aren't the same thing. Memories are stories, organised by
/// meaning and time. These are *albums* — physical objects, bought in
/// different years, standing on a shelf with their spines out.
///
/// So they're drawn as books: different heights, a darker spine down the
/// binding edge, a strip of tape on the cover, and the last one on each shelf
/// leaning the way the last one always does. Press one and it slides up out of
/// the row and straightens toward you while the album opens.
///
/// Search is the small magnifier beside refresh, the same as on the letters
/// screen: the shelves stay the screen, and the search line only appears when
/// someone asks for it.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  /// Albums aren't all the same thickness or height.
  static const _heights = [218.0, 204.0, 212.0, 222.0];

  static const _room = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3EAE0), Color(0xFFEFE4D6)],
  );

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  bool _searching = false;
  String _query = '';

  void _refresh() {
    ref.invalidate(cloudAlbumsProvider);
    ref.invalidate(cloudPhotosProvider);
  }

  Future<void> _openDesk() async {
    final route = MaterialPageRoute<void>(
      builder: (_) => const GalleryAdminPage(),
    );
    await Navigator.of(context).push(route);
    await route.completed;
    if (!mounted) return;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final q = _query.trim().toLowerCase();
    // Match the name as it is shown, so Nepali finds Nepali and English
    // finds English.
    final albums = [
      for (final a in ref.watch(albumsProvider))
        if (q.isEmpty ||
            a.name.toLowerCase().contains(q) ||
            trS(lang, a.name).toLowerCase().contains(q))
          a,
    ];

    return GalleryAutoRefresh(
      child: SectionScaffold(
        title: 'Family Albums',
        subtitle: 'Every moment, kept on a shelf',
        gradient: GalleryScreen._room,
        particles: false,
        actions: [
          IconButton(
            tooltip: trS(lang, 'Your album desk'),
            icon: const Icon(Icons.manage_accounts_outlined),
            onPressed: _openDesk,
          ),
        ],
        child: LayoutBuilder(
          builder: (context, box) {
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final perShelf = (box.maxWidth / (145 * scale.clamp(1, 1.7)))
                .floor()
                .clamp(1, 4);
            final bookW =
                (box.maxWidth - AppDimens.md * (perShelf - 1)) / perShelf;
            final heights = [
              for (final h in GalleryScreen._heights)
                h + 80 * (scale - 1).clamp(0, 3),
            ];
            final shelves = <List<Album>>[
              for (var i = 0; i < albums.length; i += perShelf)
                albums.sublist(i, (i + perShelf).clamp(0, albums.length)),
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trS(lang, 'Take one down.'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: trS(lang, 'Search albums…'),
                      onPressed: () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _query = '';
                      }),
                      icon: Icon(_searching ? Icons.close : Icons.search),
                    ),
                    IconButton(
                      tooltip: trS(lang, 'Refresh'),
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                if (_searching)
                  _SearchLabel(
                    hint: trS(lang, 'Search albums…'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                if (ref.watch(cloudAlbumsProvider).hasError ||
                    ref.watch(cloudPhotosProvider).hasError)
                  Text(trS(lang, 'Could not connect. Please retry.')),
                const SizedBox(height: AppDimens.lg),
                if (albums.isEmpty) _NoAlbums(lang: lang),
                for (var s = 0; s < shelves.length; s++) ...[
                  _ShelfRow(
                    albums: shelves[s],
                    bookWidth: bookW,
                    heights: heights,
                    shelfIndex: s,
                    onOpen: (a) => context.push(Routes.albumOf(a.id)),
                  ),
                  const Shelf(),
                  const SizedBox(height: AppDimens.xxl),
                ],
                const SizedBox(height: AppDimens.lg),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A paper label tucked in front of the shelves, with a line to write on.
class _SearchLabel extends StatelessWidget {
  const _SearchLabel({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.xs),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF342D35) : const Color(0xFFFFF9ED),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD8B58F)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        autofocus: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

/// What the shelf says when the search matches no album.
class _NoAlbums extends StatelessWidget {
  const _NoAlbums({required this.lang});

  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
      child: Column(
        children: [
          const Icon(
            Icons.photo_album_outlined,
            size: 38,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            trS(lang, 'No albums found'),
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

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({
    required this.albums,
    required this.bookWidth,
    required this.heights,
    required this.shelfIndex,
    required this.onOpen,
  });

  final List<Album> albums;
  final double bookWidth;
  final List<double> heights;
  final int shelfIndex;
  final void Function(Album) onOpen;

  @override
  Widget build(BuildContext context) {
    final tallest = albums
        .asMap()
        .entries
        .map((e) => heights[(shelfIndex + e.key) % heights.length])
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: tallest,
      child: Row(
        // Standing on the shelf, so bottoms align and tops don't.
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < albums.length; i++) ...[
            AlbumBook(
                  album: albums[i],
                  width: bookWidth,
                  height: heights[(shelfIndex + i) % heights.length],
                  // Only the last book on a full shelf leans — the others hold
                  // each other up.
                  lean: (i == albums.length - 1 && albums.length > 1)
                      ? 0.022
                      : 0,
                  onTap: () => onOpen(albums[i]),
                )
                .animate()
                .fadeIn(delay: (shelfIndex * 90 + i * 60).ms, duration: 300.ms)
                .moveY(begin: 8, end: 0),
            if (i != albums.length - 1) const SizedBox(width: AppDimens.md),
          ],
        ],
      ),
    );
  }
}
