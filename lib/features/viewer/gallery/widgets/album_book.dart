import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_photos.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../data/gallery/gallery_providers.dart';
import '../../../../data/providers/album_photos_provider.dart';
import '../../../../data/models/content_models.dart';
import '../../../../data/models/cover.dart';
import '../../../../shared/widgets/gallery_photo.dart';

class AlbumBook extends ConsumerStatefulWidget {
  const AlbumBook({
    super.key,
    required this.album,
    required this.width,
    required this.height,
    required this.onTap,
    this.lean = 0,
  });
  final Album album;
  final double width, height, lean;
  final VoidCallback onTap;
  @override
  ConsumerState<AlbumBook> createState() => _AlbumBookState();
}

class _AlbumBookState extends ConsumerState<AlbumBook> {
  bool _held = false;
  @override
  Widget build(BuildContext context) {
    final a = widget.album;
    final lang = ref.watch(langProvider);
    String t(String s) => trS(lang, s);
    final cover = ref.watch(galleryCoverProvider(a.id));
    final bundled = ref.watch(bundledAlbumPhotosProvider).value;
    final bundledCover = bundledCoverFor(a, bundled);
    final cloud = ref.watch(cloudPhotosProvider);
    final counts = ref.watch(albumPhotoCountsProvider);
    final n = counts.value?[a.id] ?? 0;
    final waitingForCloud = n == 0 && cloud.isLoading;
    final cloudFailed = n == 0 && cloud.hasError;
    final empty = counts.hasValue && n == 0 && !waitingForCloud && !cloudFailed;
    final countLabel = waitingForCloud
        ? t('Checking photos…')
        : cloudFailed
        ? t('Photo count unavailable')
        : counts.hasValue
        ? (n == 0 ? t('Still to fill') : '$n ${t(n == 1 ? 'photo' : 'photos')}')
        : t(counts.hasError ? 'Photo count unavailable' : 'Checking photos…');
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = Color.lerp(
      CoverPalette.base(a.colorSeed),
      dark ? const Color(0xFF302735) : const Color(0xFFEAE2D6),
      empty ? .72 : .28,
    )!;
    final ink = dark ? const Color(0xFFF2E9DC) : const Color(0xFF463A38);
    final paper = dark ? const Color(0xFF342D35) : const Color(0xFFFFF9ED);
    final placeholder = ColoredBox(
      color: base,
      child: Center(
        child: Icon(
          Icons.photo_album_outlined,
          size: 36,
          color: ink.withValues(alpha: .45),
        ),
      ),
    );
    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: widget.onTap,
      label: '${t(a.name)}. $countLabel. ${t('Open album')}',
      child: AnimatedRotation(
        turns: _held ? 0 : widget.lean / (2 * 3.1415926),
        duration: const Duration(milliseconds: 220),
        child: AnimatedSlide(
          offset: Offset(0, _held ? -.035 : 0),
          duration: const Duration(milliseconds: 220),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .18),
                  blurRadius: _held ? 16 : 8,
                  offset: const Offset(2, 5),
                ),
              ],
            ),
            child: Material(
              color: base,
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (value) => setState(() => _held = value),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: .24),
                              Colors.white.withValues(alpha: .14),
                              Colors.black.withValues(alpha: .12),
                            ],
                          ),
                          border: Border(
                            right: BorderSide(
                              color: ink.withValues(alpha: .15),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      top: 4,
                      bottom: 4,
                      width: 2,
                      child: ColoredBox(color: paper.withValues(alpha: .6)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 13, 13, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: paper,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .12),
                                    blurRadius: 3,
                                    offset: const Offset(1, 2),
                                  ),
                                ],
                              ),
                              child: Hero(
                                tag: 'album-${a.id}',
                                child: cover != null
                                    ? GalleryPhoto(
                                        path: cover,
                                        fallback: placeholder,
                                      )
                                    : empty
                                    ? placeholder
                                    : Image.asset(
                                        AppPhotos.album(a.id),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            bundledCover == null
                                            ? placeholder
                                            : GalleryPhoto(
                                                path: bundledCover,
                                                remote: false,
                                                fallback: placeholder,
                                              ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: paper,
                              border: Border.all(
                                color: ink.withValues(alpha: .12),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t(a.name),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 14,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  countLabel,
                                  style: TextStyle(
                                    color: ink.withValues(alpha: .75),
                                    fontSize: 10.5,
                                    height: 1.2,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

class Shelf extends StatelessWidget {
  const Shelf({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 13,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD8B58F), Color(0xFFB38A64), Color(0xFF886445)],
      ),
      borderRadius: BorderRadius.circular(2),
      border: const Border(top: BorderSide(color: Color(0xFFEBD2B0), width: 2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .18),
          blurRadius: 8,
          offset: const Offset(0, 6),
        ),
      ],
    ),
  );
}
