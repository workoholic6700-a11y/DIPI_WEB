import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/models/story_models.dart';
import '../../../data/models/cover.dart';
import '../../../data/providers/content_providers.dart';
import '../../../shared/widgets/section_scaffold.dart';
import 'widgets/still_to_add.dart';

class FutureMessagesScreen extends ConsumerWidget {
  const FutureMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(futureMessagesProvider);
    final lang = ref.watch(langProvider);
    return SectionScaffold(
      title: 'Future Messages',
      subtitle: 'Letters Diksha has written for the years ahead',
      emoji: '🔮',
      child: messages.isEmpty
          ? StillToAdd(
              lang: lang,
              message:
                  'A sealed message will appear only after Diksha writes it.',
            )
          : Column(
              children: [
                for (var i = 0; i < messages.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.md),
                    child: _FutureCard(message: messages[i])
                        .animate()
                        .fadeIn(delay: (i * 90).ms)
                        .moveY(begin: 16, end: 0),
                  ),
              ],
            ),
    );
  }
}

class _FutureCard extends StatelessWidget {
  const _FutureCard({required this.message});
  final FutureMessage message;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: AppDimens.md),
              Text(message.title, style: t.titleLarge),
              const SizedBox(height: AppDimens.sm),
              Text(
                'This one is still sealed. It will open ${message.unlockLabel.toLowerCase()}. '
                'Something beautiful is waiting for you. 💜',
                textAlign: TextAlign.center,
                style: t.bodyMedium,
              ),
              const SizedBox(height: AppDimens.xl),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I\'ll wait 💫'),
              ),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimens.brLg,
          border: Border.all(color: AppColors.lavenderSoft, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: CoverPalette.base(
                message.colorSeed,
              ).withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: CoverPalette.gradient(message.colorSeed),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      message.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: AppColors.purpleMid,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.title, style: t.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    message.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lavenderSoft,
                      borderRadius: AppDimens.brPill,
                    ),
                    child: Text(
                      message.unlockLabel,
                      style: const TextStyle(
                        color: AppColors.purpleMid,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
