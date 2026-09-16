import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_photos.dart';
import '../../../../core/i18n/l10n.dart';

class FamilyCompositeFrame extends ConsumerWidget {
  const FamilyCompositeFrame({super.key});

  static Widget _portrait() => Image.asset(
    AppPhotos.familyComposite,
    fit: BoxFit.contain,
    errorBuilder: (_, _, _) =>
        const Center(child: Icon(Icons.family_restroom, size: 48)),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final caption = trS(lang, 'AI-composed from our photos');
    return Column(
      children: [
        Semantics(
          button: true,
          label: trS(lang, 'Our family portrait'),
          child: GestureDetector(
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: CloseButton(
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Flexible(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: _portrait(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(caption, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B7049),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: AspectRatio(aspectRatio: 1.5, child: _portrait()),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          trS(lang, 'Our family portrait'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(caption, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
