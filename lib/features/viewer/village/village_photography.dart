import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/browser_file.dart' as browser;
import 'day_night.dart';

class VillagePostcardService {
  static const _channel = MethodChannel('com.rai.dear_dipisha/postcards');
  static const _shareText = 'A postcard from Rai Village 💜';

  static Future<bool> save(Uint8List bytes) async {
    if (kIsWeb) {
      browser.downloadBytes(bytes, _filename(), 'image/png');
      return true;
    }
    final result = await _channel.invokeMethod<bool>('savePostcard', {
      'bytes': bytes,
      'filename': _filename(),
    });
    return result ?? false;
  }

  static Future<bool> share(Uint8List bytes) async {
    if (kIsWeb) {
      return browser.shareBytes(
        bytes,
        _filename(),
        'image/png',
        text: _shareText,
      );
    }
    final result = await _channel.invokeMethod<bool>('sharePostcard', {
      'bytes': bytes,
      'filename': _filename(),
      'text': _shareText,
    });
    return result ?? false;
  }

  static String _filename() {
    final now = DateTime.now();
    return 'rai-village-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch}.png';
  }
}

Future<Uint8List?> captureVillageBoundary(
  GlobalKey boundaryKey, {
  double pixelRatio = 2,
}) async {
  await WidgetsBinding.instance.endOfFrame;
  final boundary = boundaryKey.currentContext?.findRenderObject();
  if (boundary is! RenderRepaintBoundary) return null;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data?.buffer.asUint8List();
}

Future<void> showVillagePostcardEditor(
  BuildContext context,
  Uint8List villageImage,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _VillagePostcardEditor(image: villageImage),
  );
}

class _VillagePostcardEditor extends StatefulWidget {
  const _VillagePostcardEditor({required this.image});

  final Uint8List image;

  @override
  State<_VillagePostcardEditor> createState() => _VillagePostcardEditorState();
}

class _VillagePostcardEditorState extends State<_VillagePostcardEditor> {
  final _postcardKey = GlobalKey();
  late final TextEditingController _caption = TextEditingController(
    text: _defaultCaption(),
  );
  bool _busy = false;

  String _defaultCaption() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Rai Village · ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<Uint8List?> _renderPostcard() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _busy = true);
    await WidgetsBinding.instance.endOfFrame;
    return captureVillageBoundary(_postcardKey, pixelRatio: 2.4);
  }

  Future<void> _save() async {
    try {
      final bytes = await _renderPostcard();
      if (bytes == null) throw StateError('Postcard was not ready');
      final saved = await VillagePostcardService.save(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !saved
                ? 'The postcard could not be saved.'
                : kIsWeb
                ? 'Postcard downloaded.'
                : 'Postcard saved to Pictures / Our Home.',
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The postcard could not be saved.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    try {
      final bytes = await _renderPostcard();
      if (bytes == null) throw StateError('Postcard was not ready');
      final shared = await VillagePostcardService.share(bytes);
      // A computer browser has no share sheet for pictures. Rather than the
      // button doing nothing, give her the postcard to send herself.
      if (!shared && kIsWeb && mounted) {
        await VillagePostcardService.save(bytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This browser can’t share pictures, so the postcard was '
              'downloaded instead.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The postcard could not be shared.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF2E2635),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close postcard editor',
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Make a Village Postcard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: _postcardKey,
                      child: Container(
                        width: screen.width.clamp(280, 620),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFCF4),
                          border: Border.all(color: Colors.white, width: 8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: screen.width / screen.height,
                              child: Image.memory(
                                widget.image,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                11,
                                16,
                                13,
                              ),
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _caption,
                                builder: (context, value, _) => Text(
                                  value.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF5B3D3D),
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _caption,
                      enabled: !_busy,
                      maxLength: 80,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Handwritten caption',
                        labelStyle: const TextStyle(color: Colors.white70),
                        counterStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.09),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _save,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _share,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8C76D),
                        foregroundColor: const Color(0xFF3D2D2A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded),
                      label: const Text('Share'),
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

class VillagePhotographyOverlay extends StatelessWidget {
  const VillagePhotographyOverlay({
    super.key,
    required this.phase,
    required this.festivalLabel,
    required this.capturing,
    required this.onPhase,
    required this.onFestival,
    required this.onCapture,
    required this.onClose,
  });

  final VillagePhase phase;
  final String festivalLabel;
  final bool capturing;
  final ValueChanged<VillagePhase> onPhase;
  final VoidCallback onFestival;
  final VoidCallback onCapture;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 8,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Exit photography mode',
                onPressed: capturing ? null : onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Material(
              color: const Color(0xD92E2635),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pan and pinch to compose your postcard',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final item in const [
                          (VillagePhase.dawn, '🌄'),
                          (VillagePhase.day, '☀️'),
                          (VillagePhase.dusk, '🌇'),
                          (VillagePhase.night, '🌙'),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ChoiceChip(
                              selected: phase == item.$1,
                              onSelected: (_) => onPhase(item.$1),
                              label: Text(item.$2),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        const SizedBox(width: 5),
                        // A long festival name ("Memory anniversary") would
                        // otherwise push this row off a 720-wide screen. The
                        // four phase chips keep their size; only the label
                        // gives way.
                        Flexible(
                          child: ActionChip(
                            onPressed: onFestival,
                            avatar: const Text('🎊'),
                            label: Text(
                              festivalLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    GestureDetector(
                      onTap: capturing ? null : onCapture,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE8C76D),
                            width: 5,
                          ),
                        ),
                        child: capturing
                            ? const Padding(
                                padding: EdgeInsets.all(15),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF3D2D2A),
                                size: 28,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VillageCameraButton extends StatelessWidget {
  const VillageCameraButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xF2FFF8EC),
    elevation: 4,
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: 'Village photography mode',
      onPressed: onTap,
      icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4B3528)),
    ),
  );
}
