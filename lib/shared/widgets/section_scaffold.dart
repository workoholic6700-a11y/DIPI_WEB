import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import 'common.dart';
import 'scrapbook.dart';

/// A consistent scaffold for the read-only section pages: soft gradient
/// background, floating particles, and a rounded back button. Title & subtitle
/// auto-translate to Nepali when the app language is नेपाली.
class SectionScaffold extends ConsumerWidget {
  const SectionScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.emoji,
    this.gradient,
    this.particles = true,
    this.actions,
    this.scrollable = true,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 40),
    this.onDark = false,
  });

  final String title;
  final String? subtitle;
  final String? emoji;
  final Widget child;
  final Gradient? gradient;
  final bool particles;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  /// Set when [gradient] is a dark one. The header text defaults to the app's
  /// dark ink, which vanishes on a dark ground — this flips it to light.
  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(langProvider);
    final tTitle = trS(lang, title);
    final tSubtitle = subtitle == null ? null : trS(lang, subtitle!);
    // Each screen picks a ground that suits it — plaster for the portrait
    // wall, aged paper for the map, warm timber for the bookcase. Those are
    // all daylight colours, so in night mode we drop them and let
    // [AppBackground] use the dark wash instead. One place, and every screen
    // built on this scaffold turns off its lights together.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: AppBackground(
        gradient: isDark ? null : gradient,
        child: Stack(
          children: [
            if (particles) const Positioned.fill(child: FloatingParticles()),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                    child: Row(
                      children: [
                        const _BackButton(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (emoji != null) ...[
                                    Text(emoji!,
                                        style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 6),
                                  ],
                                  Flexible(
                                    child: Text(tTitle,
                                        style: onDark
                                            ? t.headlineMedium
                                                ?.copyWith(color: Colors.white)
                                            : t.headlineMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              if (tSubtitle != null)
                                Text(tSubtitle,
                                    style: t.bodySmall?.copyWith(
                                        color: onDark
                                            ? Colors.white
                                                .withValues(alpha: 0.7)
                                            : AppColors.textMuted)),
                            ],
                          ),
                        ),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ),
                  Expanded(
                    child: scrollable
                        ? SingleChildScrollView(
                            padding: padding, child: child)
                        : Padding(padding: padding, child: child),
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

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.lavender.withValues(alpha: 0.18),
                blurRadius: 12),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: AppColors.purpleMid, size: 22),
      ),
    );
  }
}
