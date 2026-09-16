import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/date_x.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/portrait_scope.dart';
import '../../../shared/widgets/states.dart';
import 'widgets/treehouse_backdrop.dart';

class LetterDetailScreen extends ConsumerStatefulWidget {
  const LetterDetailScreen({super.key, required this.letterId});
  final String letterId;

  @override
  ConsumerState<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends ConsumerState<LetterDetailScreen> {
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    // Reading it is what opens it — recorded here rather than at each place
    // that pushes a letter, so a letter reached from the Home table, the
    // mailbox or her world all count the same. The envelope in the tray will
    // be sitting open when she comes back.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(openedLettersProvider.notifier).markOpened(widget.letterId);
      }
    });
    // Auto "unfold" the letter shortly after entering.
    Future.delayed(
      const Duration(milliseconds: 350),
      () => mounted ? setState(() => _opened = true) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final letter = ref
        .watch(lettersProvider)
        .where((l) => l.id == widget.letterId)
        .firstOrNull;

    if (letter == null) {
      return Scaffold(
        body: ErrorStateView(title: trS(lang, 'Letter not found')),
      );
    }

    final fav = ref.watch(
      isFavoriteProvider((kind: FavKind.letter, id: letter.id)),
    );

    // Held upright even when it was opened from the sideways world — a long
    // letter read lengthways on a phone is miserable.
    return PortraitScope(
      child: Scaffold(
        backgroundColor: const Color(0xFFE8C899),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8EEDC),
          foregroundColor: AppColors.textPrimary,
          title: Text(
            '${letter.category.emoji} ${trS(lang, letter.category.label)}',
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.sm),
              child: FavoriteButton(
                isFavorite: fav,
                background: false,
                onTap: () => ref
                    .read(favoritesProvider.notifier)
                    .toggle(FavKind.letter, letter.id),
              ),
            ),
          ],
        ),
        body: TreehouseBackdrop(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Hero(
              tag: 'letter-${letter.id}',
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(AppDimens.xl),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF8),
                    borderRadius: AppDimens.brLg,
                    border: Border.all(
                      color: const Color(0xFFC79A71),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF55331F).withValues(alpha: 0.24),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _opened ? 1 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                letter.category.emoji,
                                style: const TextStyle(fontSize: 34),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                letter.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                letter.dateWritten.prettyDate,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimens.lg),
                        const Divider(color: AppColors.pinkLight),
                        const SizedBox(height: AppDimens.lg),
                        // The letter body in a handwriting-flavoured serif.
                        Text(
                          letter.body,
                          style: GoogleFonts.caveat(
                            fontSize: 23,
                            height: 1.5,
                            color: const Color(0xFF4A3E57),
                          ),
                        ),
                        const SizedBox(height: AppDimens.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '— Diksha',
                            style: GoogleFonts.caveat(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pinkDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).moveY(begin: 20, end: 0),
          ),
        ),
      ),
    );
  }
}
