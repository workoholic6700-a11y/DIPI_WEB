import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/content_models.dart';
import '../../../data/models/cover.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/still_to_add.dart';

class SurpriseScreen extends ConsumerWidget {
  const SurpriseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surprises = ref.watch(surprisesProvider);
    final lang = ref.watch(langProvider);

    return SectionScaffold(
      title: 'Surprise Box',
      subtitle: 'Real messages, saved for the right day',
      emoji: '🎁',
      scrollable: surprises.isEmpty,
      padding: surprises.isEmpty
          ? const EdgeInsets.fromLTRB(16, 24, 16, 40)
          : EdgeInsets.zero,
      child: surprises.isEmpty
          ? StillToAdd(
              lang: lang,
              message: 'Diksha can place a real message here when it is ready.',
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: AppDimens.md,
                crossAxisSpacing: AppDimens.md,
                childAspectRatio: 0.85,
              ),
              itemCount: surprises.length,
              itemBuilder: (context, i) => _GiftCard(surprise: surprises[i])
                  .animate()
                  .fadeIn(delay: (i * 80).ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                  ),
            ),
    );
  }
}

class _GiftCard extends ConsumerWidget {
  const _GiftCard({required this.surprise});
  final Surprise surprise;

  String get _unlockLabel => switch (surprise.unlockType) {
    UnlockType.date => 'Opens ${surprise.unlockDate?.year ?? ''}',
    UnlockType.age => 'Opens at age ${surprise.unlockAge}',
    UnlockType.birthday => 'On your birthday',
    UnlockType.password => 'Secret word',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = surprise.isUnlocked;
    return GestureDetector(
      onTap: () => _open(context, ref),
      child: Container(
        decoration: BoxDecoration(
          gradient: unlocked
              ? CoverPalette.gradient(surprise.colorSeed)
              : LinearGradient(
                  colors: [
                    CoverPalette.base(
                      surprise.colorSeed,
                    ).withValues(alpha: 0.7),
                    CoverPalette.base(surprise.colorSeed),
                  ],
                ),
          borderRadius: AppDimens.brLg,
          boxShadow: [
            BoxShadow(
              color: CoverPalette.base(
                surprise.colorSeed,
              ).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(unlocked ? '🎉' : '🎁', style: const TextStyle(fontSize: 46)),
            const SizedBox(height: 8),
            Text(
              surprise.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: AppDimens.brPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unlocked ? 'Opened' : _unlockLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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

  void _open(BuildContext context, WidgetRef ref) {
    if (!surprise.isUnlocked) {
      ref.read(unlockedSurprisesProvider.notifier).unlock(surprise.id);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RevealSheet(surprise: surprise),
    );
  }
}

class _RevealSheet extends StatefulWidget {
  const _RevealSheet({required this.surprise});
  final Surprise surprise;

  @override
  State<_RevealSheet> createState() => _RevealSheetState();
}

class _RevealSheetState extends State<_RevealSheet> {
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surprise;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
          padding: const EdgeInsets.all(AppDimens.xl),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 54)).animate().scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                s.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                s.message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              const SizedBox(height: AppDimens.xl),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close with a smile 💜'),
              ),
              const SizedBox(height: AppDimens.sm),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirection: math.pi / 2,
          maxBlastForce: 6,
          minBlastForce: 3,
          emissionFrequency: 0.04,
          numberOfParticles: 18,
          gravity: 0.25,
          colors: const [
            AppColors.lavender,
            AppColors.pink,
            AppColors.gold,
            AppColors.skyBlue,
          ],
        ),
      ],
    );
  }
}
