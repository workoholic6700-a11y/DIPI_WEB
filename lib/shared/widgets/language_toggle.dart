import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';

/// A small pill that flips the whole app between English and नेपाली. Kept simple
/// and obvious so parents can find it: a globe + the two languages, the active
/// one highlighted. Tap either side to switch.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.compact = false});

  /// When compact, drops the globe icon (for tight spots like app bars).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final isNe = lang == AppLang.ne;

    Widget seg(String label, bool active) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.lavender : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : AppColors.purpleMid,
            ),
          ),
        );

    return Semantics(
      button: true,
      label: 'Switch language / भाषा फेर्नुहोस्',
      child: GestureDetector(
        onTap: () => ref.read(langProvider.notifier).toggle(),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: AppColors.lavender.withValues(alpha: 0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.lavender.withValues(alpha: 0.16),
                  blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compact) ...[
                const SizedBox(width: 5),
                const Text('🌐', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 3),
              ],
              seg('EN', !isNe),
              seg('ने', isNe),
            ],
          ),
        ),
      ),
    );
  }
}
