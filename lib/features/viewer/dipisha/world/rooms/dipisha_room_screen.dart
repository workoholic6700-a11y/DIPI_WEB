import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/i18n/l10n.dart';
import '../../../../../shared/widgets/landscape_scope.dart';
import '../../widgets/still_to_add.dart';

/// Dipisha's room stays visibly unfinished until Diksha supplies its real
/// objects and stories. A quiet, empty room is more honest than a detailed
/// fictional memory in a family heirloom.
class DipishaRoomScreen extends ConsumerWidget {
  const DipishaRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);

    return LandscapeScope(
      child: Scaffold(
        backgroundColor: const Color(0xFF342743),
        body: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _WaitingRoom())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Semantics(
                          button: true,
                          label: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.of(context).maybePop(),
                              child: const Padding(
                                padding: EdgeInsets.all(9),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: Color(0xFF5B2B8A),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trS(lang, 'Dipisha\'s Room'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 8),
                                ],
                              ),
                            ),
                            Text(
                              trS(lang, 'Waiting for her real stories'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(64, 16, 64, 6),
                          child: StillToAdd(
                            lang: lang,
                            compact: true,
                            message:
                                'Diksha can fill this room with real objects and real memories.',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A deliberately unclaimed room: plaster, floorboards and empty frames.
/// There is no bed, desk, window view or keepsake until the family confirms it.
class _WaitingRoom extends CustomPainter {
  const _WaitingRoom();

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Rect.fromLTWH(0, 0, size.width, size.height * 0.82);
    canvas.drawRect(
      wall,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF715983), Color(0xFF493755)],
        ).createShader(wall),
    );

    final floorTop = size.height * 0.82;
    canvas.drawRect(
      Rect.fromLTWH(0, floorTop, size.width, size.height - floorTop),
      Paint()..color = const Color(0xFF765337),
    );
    for (var x = -40.0; x < size.width; x += 72) {
      canvas.drawLine(
        Offset(x, floorTop),
        Offset(x + 44, size.height),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..strokeWidth = 1.2,
      );
    }

    for (final x in [0.16, 0.75]) {
      final frame = Rect.fromCenter(
        center: Offset(size.width * x, size.height * 0.38),
        width: size.width * 0.12,
        height: size.height * 0.22,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(frame, const Radius.circular(3)),
        Paint()
          ..color = const Color(0xFFCDAA79)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
      canvas.drawRect(
        frame.deflate(8),
        Paint()..color = Colors.white.withValues(alpha: 0.07),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaitingRoom oldDelegate) => false;
}
