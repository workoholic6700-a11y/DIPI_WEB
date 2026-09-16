import 'widgets/gallery_auto_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../core/constants/app_photos.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/cover.dart';
import '../../../shared/widgets/gallery_photo.dart';
import '../../../data/gallery/gallery_providers.dart';
import '../../../data/gallery/photo_download_service.dart';
import '../../../core/i18n/l10n.dart';
import '../../../data/providers/album_photos_provider.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import '../../../shared/widgets/states.dart';

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.albumId});
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref
        .watch(albumsProvider)
        .where((a) => a.id == albumId)
        .firstOrNull;
    if (album == null) {
      return const Scaffold(body: ErrorStateView(title: 'Album not found'));
    }
    final state = ref.watch(albumPhotosProvider(albumId));
    final cloud = ref.watch(cloudPhotosProvider);
    final photos = state.value ?? [];
    final count = photos.length;
    final lang = ref.watch(langProvider);
    final loading =
        (state.isLoading && !state.hasValue) ||
        (photos.isEmpty && cloud.isLoading);
    final failed =
        (state.hasError && !state.hasValue) ||
        (photos.isEmpty && cloud.hasError);

    return GalleryAutoRefresh(
      child: SectionScaffold(
        title: album.name,
        subtitle: loading
            ? 'Checking photos…'
            : failed
            ? 'Photo count unavailable'
            : count == 0
            ? 'No photographs in here yet'
            : trS(
                lang,
                count == 1 ? '{count} photograph' : '{count} photographs',
              ).replaceAll('{count}', '$count'),
        emoji: '🌸',
        scrollable: false,
        padding: EdgeInsets.zero,
        actions: [
          IconButton(
            tooltip: trS(lang, 'Refresh'),
            onPressed: () {
              ref.invalidate(cloudPhotosProvider);
              ref.invalidate(albumPhotosProvider(albumId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : failed
            ? Center(child: Text(trS(lang, 'Could not connect. Please retry.')))
            : photos.isEmpty
            ? const EmptyState(
                icon: Icons.photo_album_outlined,
                title: 'This album is waiting',
                message: 'Diksha can add photographs from the album desk.',
              )
            : Column(
                children: [
                  if (cloud.hasError)
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.md),
                      child: Text(
                        trS(
                          lang,
                          'Cloud photos are unavailable. The photos included in the app are still here.',
                        ),
                      ),
                    ),
                  Expanded(
                    child: _AlbumPages(
                      key: ValueKey(photos.map((p) => p.id).join()),
                      album: album,
                      photos: photos,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The album remains a book after it leaves the shelf. Four photographs sit on
/// each paper page, and a horizontal gesture turns to the next page.
class _AlbumPages extends ConsumerStatefulWidget {
  const _AlbumPages({super.key, required this.album, required this.photos});

  final Album album;
  final List<Photo> photos;

  @override
  ConsumerState<_AlbumPages> createState() => _AlbumPagesState();
}

class _AlbumPagesState extends ConsumerState<_AlbumPages> {
  late final PageController _controller;
  int _page = 0;

  List<List<Photo>> get _pages {
    final pages = <List<Photo>>[];
    for (var i = 0; i < widget.photos.length; i += 4) {
      pages.add(
        widget.photos.sublist(
          i,
          i + 4 > widget.photos.length ? widget.photos.length : i + 4,
        ),
      );
    }
    return pages;
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.93);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final lang = ref.watch(langProvider);
    final firstDot = (_page - 3).clamp(
      0,
      (pages.length - 7).clamp(0, pages.length),
    );
    final lastDot = (firstDot + 7).clamp(0, pages.length);
    if (pages.isEmpty) {
      return const EmptyState(
        icon: Icons.photo_album_outlined,
        title: 'This album is waiting for photographs',
        message: 'Photographs placed in this album will appear here.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.lg,
            AppDimens.sm,
            AppDimens.lg,
            AppDimens.sm,
          ),
          child: Hero(
            tag: 'album-${widget.album.id}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                decoration: BoxDecoration(
                  gradient: CoverPalette.gradient(widget.album.colorSeed),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  trS(lang, 'Open album · page {page} of {pages}')
                      .replaceAll('{page}', '${_page + 1}')
                      .replaceAll('{pages}', '${pages.length}'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: _AlbumPage(
                photos: pages[index],
                pageNumber: index + 1,
                onOpen: (photo) => _openViewer(context, photo),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.sm,
              AppDimens.lg,
              AppDimens.md,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: trS(lang, 'Previous page'),
                  onPressed: _page == 0
                      ? null
                      : () => _controller.previousPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        ),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = firstDot; i < lastDot; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: i == _page ? 22 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? AppColors.lavender
                                : AppColors.lavenderSoft,
                            borderRadius: AppDimens.brPill,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: trS(lang, 'Next page'),
                  onPressed: _page == pages.length - 1
                      ? null
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        ),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openViewer(BuildContext context, Photo photo) {
    final index = widget.photos.indexOf(photo);
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _FullscreenViewer(photos: widget.photos, initialIndex: index),
      ),
    );
  }
}

class _AlbumPage extends StatelessWidget {
  const _AlbumPage({
    required this.photos,
    required this.pageNumber,
    required this.onOpen,
  });

  final List<Photo> photos;
  final int pageNumber;
  final ValueChanged<Photo> onOpen;

  @override
  Widget build(BuildContext context) {
    final slots = <Widget>[
      for (var i = 0; i < 4; i++)
        Expanded(
          flex: i.isEven ? 11 : 9,
          child: i < photos.length
              ? _PagePhoto(
                  photo: photos[i],
                  tilt: (i.isEven ? -1 : 1) * 0.008,
                  onTap: () => onOpen(photos[i]),
                )
              : const SizedBox.shrink(),
        ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: AppDimens.brSm,
        border: Border.all(color: const Color(0xFFE7D9C8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [slots[0], const SizedBox(width: 12), slots[1]],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [slots[2], const SizedBox(width: 12), slots[3]],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— $pageNumber —',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PagePhoto extends ConsumerWidget {
  const _PagePhoto({
    required this.photo,
    required this.tilt,
    required this.onTap,
  });

  final Photo photo;
  final double tilt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final n = int.tryParse(photo.id.split('-p').last) ?? 0;
    final landscape = AppPhotos.landscapeAlbumPhotos.contains(photo.assetPath);
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: CoverPalette.gradient(photo.colorSeed),
      ),
      child: Center(
        child: Icon(
          CoverPalette.icon(photo.colorSeed),
          color: Colors.white.withValues(alpha: 0.8),
          size: 30,
        ),
      ),
    );

    final photograph = Hero(
      tag: 'photo-${photo.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: GalleryPhoto(
          path:
              photo.thumbPath ??
              photo.assetPath ??
              AppPhotos.albumPhoto(photo.albumId, n),
          remote: photo.thumbPath != null,
          fit: landscape ? BoxFit.contain : BoxFit.cover,
          fallback: placeholder,
        ),
      ),
    );
    final card = Container(
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: landscape ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (landscape)
            AspectRatio(aspectRatio: 3 / 2, child: photograph)
          else
            Expanded(child: photograph),
          const SizedBox(height: 5),
          Text(
            trS(lang, photo.caption),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: [
        if (photo.caption.isNotEmpty) trS(lang, photo.caption),
        trS(lang, 'Opens the photograph.'),
      ].join(' '),
      child: Transform.rotate(
        angle: tilt,
        child: GestureDetector(
          onTap: onTap,
          child: landscape ? Align(child: card) : card,
        ),
      ),
    ).animate().fadeIn(duration: 320.ms);
  }
}

class _FullscreenViewer extends ConsumerStatefulWidget {
  const _FullscreenViewer({required this.photos, required this.initialIndex});
  final List<Photo> photos;
  final int initialIndex;

  @override
  ConsumerState<_FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends ConsumerState<_FullscreenViewer> {
  late final PageController _controller;
  late int _index;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    if (_saving) return;
    final photo = widget.photos[_index];
    final service = ref.read(photoDownloadServiceProvider);
    setState(() => _saving = true);
    try {
      final result = await service.save(photo);
      if (!mounted || result == PhotoSaveResult.cancelled) return;
      _message(
        result == PhotoSaveResult.gallery
            ? 'Photo saved to Pictures/Our Home.'
            : 'Photo saved.',
      );
    } catch (_) {
      if (mounted) _message('Could not save photo. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(trS(ref.read(langProvider), text))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final caption = widget.photos[_index].caption;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: caption.isEmpty
            ? null
            : Text(
                trS(lang, caption),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
        actions: [
          if (PhotoDownloadService.supported)
            IconButton(
              tooltip: trS(lang, _saving ? 'Saving photo…' : 'Download photo'),
              onPressed: _saving ? null : _download,
              icon: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                        semanticsLabel: trS(lang, 'Saving photo…'),
                      ),
                    )
                  : const Icon(Icons.download_outlined, size: 24),
            ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.photos.length,
        pageController: _controller,
        onPageChanged: (index) => setState(() => _index = index),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        builder: (context, i) {
          final p = widget.photos[i];
          return PhotoViewGalleryPageOptions.customChild(
            heroAttributes: PhotoViewHeroAttributes(tag: 'photo-${p.id}'),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            child: Center(
              child: GalleryPhoto(
                path:
                    p.storagePath ??
                    p.assetPath ??
                    AppPhotos.albumPhoto(
                      p.albumId,
                      int.tryParse(p.id.split('-p').last) ?? 0,
                    ),
                remote: p.storagePath != null,
                fit: BoxFit.contain,
                fallback: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: CoverPalette.gradient(p.colorSeed),
                      borderRadius: AppDimens.brLg,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CoverPalette.icon(p.colorSeed),
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            p.caption,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
