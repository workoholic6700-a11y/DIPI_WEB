import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/i18n/l10n.dart';
import '../../data/gallery/gallery_providers.dart';
import '../../data/gallery/gallery_repository.dart';
import '../../data/providers/album_photos_provider.dart';
import '../../shared/widgets/gallery_photo.dart';
import '../../shared/widgets/language_toggle.dart';
import '../archive/archive_desk_screen.dart';
import 'gallery_desk_paper.dart';

class GalleryAdminScreen extends ConsumerStatefulWidget {
  const GalleryAdminScreen({super.key});
  @override
  ConsumerState<GalleryAdminScreen> createState() => _GalleryAdminScreenState();
}

class _GalleryAdminScreenState extends ConsumerState<GalleryAdminScreen> {
  List<Map<String, dynamic>> _albums = [], _photos = [];
  String? _selected, _message;
  bool _busy = true;
  GalleryRepository get repo => ref.read(galleryRepositoryProvider)!;
  String t(String s) => trS(ref.read(langProvider), s);

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (mounted) setState(() => _busy = true);
    try {
      await repo.ensureShelfAlbums();
      final albums = await repo.albums();
      final selected =
          _selected ?? (albums.isEmpty ? null : albums.first['id'] as String);
      final photos = selected == null
          ? <Map<String, dynamic>>[]
          : await repo.photos(albumId: selected);
      if (mounted) {
        setState(() {
          _albums = albums;
          _selected = selected;
          _photos = photos;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not connect. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(
    Future<void> Function() action, {
    String done = 'Saved.',
  }) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      if (mounted) setState(() => _message = done);
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(
          () => _message = e.message.contains('cover_asset')
              ? 'Run the newest Supabase migration first.'
              : 'Could not save. Please retry.',
        );
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Could not save. Please retry.');
    }
    if (mounted) await _load();
  }

  Future<String?> _text(
    String title,
    String initial, {
    int maxLength = 120,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t(title)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: maxLength,
          decoration: InputDecoration(labelText: t(title)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(t('Save')),
          ),
        ],
      ),
    );
    // Dialog animations can still reference the field until the route is gone.
    Future.delayed(const Duration(seconds: 1), controller.dispose);
    return result;
  }

  Future<void> _createAlbum() async {
    final name = await _text('Album name', '');
    if (name == null || name.isEmpty || !mounted) return;
    // Open the new album, so the status line below describes it and not
    // whichever album happened to be selected before.
    await _run(
      () async => _selected = await repo.createAlbum(name),
      done:
          'New album saved as a private draft. The family sees it once you publish it.',
    );
  }

  Future<void> _pick() async {
    final albumId = _selected;
    if (albumId == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final files = await ImagePicker().pickMultiImage(limit: 20);
      for (final file in files) {
        if (!mounted) break;
        if (await file.length() > 30 * 1024 * 1024) {
          throw const FormatException('Image is too large');
        }
        final bytes = await file.readAsBytes();
        if (!mounted) break;
        final caption = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _UploadPreview(bytes: bytes, name: file.name),
        );
        if (caption == null) continue;
        await repo.upload(albumId, bytes, caption);
      }
      if (mounted) {
        setState(
          () => _message = 'Photos saved as drafts. Publish when ready.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Upload stopped. Saved drafts are kept. Retry the remaining photos.',
        );
      }
    } finally {
      if (mounted) await _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Delete this photo?')),
        content: Text(
          t('This removes the uploaded copy from the family album.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('Delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _run(() => repo.deletePhoto(photo));
  }

  Future<void> _deleteAlbum(Map<String, dynamic> album) async {
    final id = album['id'] as String;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Delete this album?')),
        content: Text(
          '${album['name']}\n\n'
          '${t('Its uploaded photographs are removed with it, and the family app will no longer show it.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _selected = null;
    await _run(() => repo.deleteAlbum(id));
  }

  Future<void> _publishDrafts() async {
    final albumId = _selected;
    final ids = [
      for (final p in _photos)
        if (p['published'] != true) p['id'] as String,
    ];
    if (albumId == null || ids.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Publish all drafts')),
        content: Text(
          t(
            'This publishes all draft photos in this album and makes the album visible.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('Publish')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(() => repo.publishDrafts(albumId, ids));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(langProvider);
    final album = _albums.where((a) => a['id'] == _selected).firstOrNull;
    final bundled =
        ref.watch(bundledAlbumPhotosProvider).value?[_selected] ?? <String>[];
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF211B26)
          : const Color(0xFFE9D9C3),
      appBar: AppBar(
        title: Text(t('Your album desk')),
        actions: [
          IconButton(
            tooltip: t('Sign out'),
            onPressed: _busy
                ? null
                : () async {
                    await repo.client.auth.signOut();
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _busy ? null : _createAlbum,
                    icon: const Icon(Icons.add),
                    label: Text(t('New album')),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _load,
                    child: Text(t('Refresh')),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const ArchiveDeskScreen(),
                            ),
                          ),
                    child: Text(t('The Archive Desk')),
                  ),
                  const LanguageToggle(compact: true),
                ],
              ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(t(_message!)),
                ),
              if (_busy) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              GalleryDeskPaper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 12),
                          child: Icon(Icons.auto_stories_outlined, size: 30),
                        ),
                        Expanded(
                          child: Text(
                            t('Choose an album, collect photos, then publish.'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (_albums.isEmpty && !_busy)
                      Text(t('Create an album to begin.')),
                    if (_albums.isNotEmpty)
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selected),
                        initialValue: _selected,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: t('Album')),
                        items: [
                          for (final a in _albums)
                            DropdownMenuItem(
                              value: a['id'] as String,
                              child: Text(
                                a['name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (id) {
                                _selected = id;
                                _load();
                              },
                      ),
                    if (album != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        t(
                          album['published'] == true
                              ? 'Album is visible to family.'
                              : 'Album is a private draft.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: _busy ? null : _pick,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(t('Add photos')),
                          ),
                          if (_photos.any((p) => p['published'] != true))
                            FilledButton.tonalIcon(
                              onPressed: _busy ? null : _publishDrafts,
                              icon: const Icon(Icons.publish),
                              label: Text(t('Publish all drafts')),
                            ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () async {
                                    final name = await _text(
                                      'Album name',
                                      album['name'] as String,
                                    );
                                    if (name != null &&
                                        name.isNotEmpty &&
                                        mounted) {
                                      await _run(
                                        () => repo.updateAlbum(
                                          _selected!,
                                          name,
                                          album['published'] as bool,
                                        ),
                                      );
                                    }
                                  },
                            child: Text(t('Rename')),
                          ),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => _run(
                                    () => repo.updateAlbum(
                                      _selected!,
                                      album['name'] as String,
                                      album['published'] != true,
                                    ),
                                  ),
                            child: Text(
                              t(
                                album['published'] == true
                                    ? 'Unpublish album'
                                    : 'Publish album',
                              ),
                            ),
                          ),
                          if (!GalleryRepository.isShelfAlbum(
                            album['id'] as String,
                          ))
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _deleteAlbum(album),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              child: Text(t('Delete album')),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      if (bundled.isEmpty && _photos.isEmpty && !_busy)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Color(0xFFAA8E77),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('Room for your photographs'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t(
                                  'Diksha can add photographs from the album desk.',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      _photoRows(bundled),
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

  /// Prints go two to a row on the phone and three on a wide desk, so a
  /// full album no longer stretches into one long column. Tapping a print
  /// opens it large with everything that can be done to it.
  Widget _photoRows(List<String> bundled) {
    // A bundled cover only counts while no uploaded photo is marked, which
    // is the same rule the family app follows.
    final uploadedCover = _photos.any((p) => p['is_cover'] == true);
    final album = _albums.where((a) => a['id'] == _selected).firstOrNull;
    final coverAsset = album?['cover_asset'] as String?;
    final cells = <Widget>[
      for (final path in bundled)
        _bundledPrint(path, isCover: !uploadedCover && coverAsset == path),
      for (final photo in _photos) _photoPrint(photo),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 520 ? 3 : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cells.length; i += perRow)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < perRow; j++) ...[
                    if (j > 0) const SizedBox(width: 12),
                    Expanded(
                      child: i + j < cells.length
                          ? cells[i + j]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _coverLabel() {
    return Row(
      children: [
        const Icon(Icons.check, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            t('Album cover'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _bundledPrint(String path, {required bool isCover}) {
    return GalleryDeskPrint(
      child: InkWell(
        onTap: _busy ? null : () => _openBundledSheet(path, isCover: isCover),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: GalleryPhoto(path: path, remote: false),
            ),
            const SizedBox(height: 8),
            Text(
              t('Included in the app'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            if (isCover) _coverLabel(),
          ],
        ),
      ),
    );
  }

  Widget _photoPrint(Map<String, dynamic> photo) {
    final published = photo['published'] == true;
    final caption = photo['caption'] as String;
    final id = photo['id'] as String;
    return GalleryDeskPrint(
      draft: !published,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _busy ? null : () => _openPrintSheet(photo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: GalleryPhoto(path: photo['thumb_path'] as String),
                ),
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      published ? Icons.photo_album_outlined : Icons.edit_note,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        t(published ? 'Published' : 'Draft'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (photo['is_cover'] == true) _coverLabel(),
              ],
            ),
          ),
          if (!published)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(() => repo.updatePhoto(id, caption, true)),
              child: Text(t('Publish')),
            ),
        ],
      ),
    );
  }

  Future<void> _openBundledSheet(String path, {required bool isCover}) async {
    final albumId = _selected;
    if (albumId == null) return;
    final chosen = await _printSheet(
      photo: GalleryPhoto(path: path, remote: false, fit: BoxFit.contain),
      title: t('Included in the app'),
      actions: [
        _PrintAction(
          'cover',
          isCover ? Icons.check : Icons.photo_album_outlined,
          t(isCover ? 'Album cover' : 'Use as album cover'),
          enabled: !isCover,
        ),
      ],
    );
    if (chosen == 'cover' && mounted) {
      await _run(() => repo.setBundledCover(albumId, path));
    }
  }

  Future<void> _openPrintSheet(Map<String, dynamic> photo) async {
    final published = photo['published'] == true;
    final isCover = photo['is_cover'] == true;
    final caption = photo['caption'] as String;
    final chosen = await _printSheet(
      photo: GalleryPhoto(
        path: photo['thumb_path'] as String,
        fit: BoxFit.contain,
      ),
      title: caption.isNotEmpty ? caption : t(published ? 'Published' : 'Draft'),
      actions: [
        _PrintAction(
          'cover',
          isCover ? Icons.check : Icons.photo_album_outlined,
          t(isCover ? 'Album cover' : 'Use as album cover'),
          enabled: !isCover,
        ),
        _PrintAction(
          'publish',
          published ? Icons.visibility_off_outlined : Icons.publish,
          t(published ? 'Unpublish' : 'Publish'),
        ),
        _PrintAction('caption', Icons.edit_outlined, t('Edit caption')),
        _PrintAction(
          'delete',
          Icons.delete_outline,
          t('Delete'),
          destructive: true,
        ),
      ],
    );
    if (chosen == null || !mounted) return;
    await _photoAction(chosen, photo);
  }

  Future<String?> _printSheet({
    required Widget photo,
    required String title,
    required List<_PrintAction> actions,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final error = Theme.of(context).colorScheme.error;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SizedBox(height: 220, child: photo),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              for (final action in actions)
                ListTile(
                  enabled: action.enabled,
                  leading: Icon(
                    action.icon,
                    color: action.destructive ? error : null,
                  ),
                  title: Text(
                    action.label,
                    style: action.destructive ? TextStyle(color: error) : null,
                  ),
                  onTap: action.enabled
                      ? () => Navigator.pop(context, action.id)
                      : null,
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _photoAction(String action, Map<String, dynamic> photo) async {
    final id = photo['id'] as String;
    final caption = photo['caption'] as String;
    final published = photo['published'] as bool;
    switch (action) {
      case 'caption':
        final next = await _text('Caption (optional)', caption, maxLength: 500);
        if (next != null && mounted) {
          await _run(() => repo.updatePhoto(id, next, published));
        }
      case 'cover':
        await _run(() => repo.setCover(id));
      case 'publish':
        await _run(() => repo.updatePhoto(id, caption, !published));
      case 'delete':
        await _delete(photo);
    }
  }
}

/// One thing that can be done to a print from its open sheet.
class _PrintAction {
  const _PrintAction(
    this.id,
    this.icon,
    this.label, {
    this.enabled = true,
    this.destructive = false,
  });
  final String id;
  final IconData icon;
  final String label;
  final bool enabled;
  final bool destructive;
}

class _UploadPreview extends StatefulWidget {
  const _UploadPreview({required this.bytes, required this.name});
  final Uint8List bytes;
  final String name;
  @override
  State<_UploadPreview> createState() => _UploadPreviewState();
}

class _UploadPreviewState extends State<_UploadPreview> {
  final _caption = TextEditingController();
  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, _) {
      String t(String s) => trS(ref.watch(langProvider), s);
      return AlertDialog(
        title: Text(widget.name, maxLines: 2),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  widget.bytes,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      Text(t('Image preview unavailable.')),
                ),
                TextField(
                  controller: _caption,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: t('Caption (optional)'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('Skip')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _caption.text),
            child: Text(t('Save draft')),
          ),
        ],
      );
    },
  );
}
