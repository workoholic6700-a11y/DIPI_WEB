import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../data/models/content_models.dart';
import '../../../../data/providers/content_providers.dart';
import '../../../../shared/widgets/scrapbook.dart';

/// A letter, as the physical object it is.
///
/// The old screen drew every letter as the same white rounded card, which is
/// why a drawer of very different things read as a database. Here the state of
/// the letter *is* its shape:
///
/// * never opened → flap down, wax seal intact
/// * opened before → flap up, the paper showing above the envelope's mouth
/// * favourite → a pressed flower kept inside it
///
/// All of that comes from real persisted state ([openedLettersProvider],
/// [isFavoriteProvider]) — nothing here implies a status the app hasn't stored.
class EnvelopeTile extends ConsumerWidget {
  const EnvelopeTile({super.key, required this.letter, required this.onTap});

  final Letter letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final opened = ref.watch(isLetterOpenedProvider(letter.id));
    final fav = ref.watch(
      isFavoriteProvider((kind: FavKind.letter, id: letter.id)),
    );

    return Semantics(
      button: true,
      label:
          '${trS(lang, opened ? 'An opened letter' : 'A sealed letter')}: '
          '${letter.title}. ${trS(lang, letter.category.label)}. '
          '${trS(lang, 'Opens it.')}',
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: 'letter-${letter.id}',
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: 158,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The paper, sitting up out of an opened envelope.
                  if (opened)
                    Positioned(
                      left: 10,
                      right: 10,
                      top: 0,
                      height: 92,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 9, 10, 0),
                        decoration: BoxDecoration(
                          color: AppColors.warmWhite,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          letter.body.replaceAll('\n', ' '),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: handwriting(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                  // The envelope body.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: opened ? 104 : 150,
                    child: CustomPaint(
                      painter: _EnvelopePainter(opened: opened),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          12,
                          opened ? 14 : 46,
                          12,
                          11,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              letter.category.emoji,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              letter.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: handwriting(
                                fontSize: 16,
                                color: AppColors.purpleMid,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                // A pressed flower, kept in the ones she loves.
                                if (fav) ...[
                                  const Text(
                                    '🌸',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                const Spacer(),
                                Text(
                                  letter.dateWritten.shortDate,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // The seal — only on one that has never been opened.
                  if (!opened)
                    Positioned(
                      top: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.pinkDeep,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pinkDeep.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '💗',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),

                  if (opened)
                    Positioned(
                      right: 12,
                      bottom: 88,
                      child: Text(
                        trS(lang, 'opened'),
                        style: const TextStyle(
                          fontSize: 8.5,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
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
  }
}

/// Draws the envelope: the pocket, and the flap either folded down over it or
/// standing open behind the paper.
class _EnvelopePainter extends CustomPainter {
  _EnvelopePainter({required this.opened});

  final bool opened;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFFFBEFF3);
    final edge = Paint()
      ..color = AppColors.pink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );
    canvas.drawRRect(r, body);
    canvas.drawRRect(r, edge);

    final flap = Paint()
      ..color = opened
          ? AppColors.pink.withValues(alpha: 0.18)
          : const Color(0xFFF7E2EA);

    if (opened) {
      // Flap thrown back — a shallow shape along the top edge.
      final p = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.10)
        ..lineTo(0, size.height * 0.10)
        ..close();
      canvas.drawPath(p, flap);
    } else {
      // Flap folded down: two diagonals meeting below the middle.
      final p = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height * 0.44)
        ..close();
      canvas.drawPath(p, flap);
      canvas.drawPath(p, edge);
    }
  }

  @override
  bool shouldRepaint(covariant _EnvelopePainter old) => old.opened != opened;
}
