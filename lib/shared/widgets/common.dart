import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

/// A full-screen soft gradient background used behind most screens.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ??
            (isDark
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.darkBg, Color(0xFF231A30)],
                  )
                : AppColors.homeGradient),
      ),
      child: child,
    );
  }
}

/// A section title with an optional trailing action ("See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.emoji,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? emoji;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title, style: t.titleLarge)),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// A small rounded tag/pill.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lavender;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? c : c.withValues(alpha: 0.12),
        borderRadius: AppDimens.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: filled ? Colors.white : c),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : c,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// An animated heart favourite toggle with a little bounce.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 22,
    this.background = true,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      color: isFavorite ? AppColors.pinkDeep : AppColors.textMuted,
      size: size,
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: background
            ? BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              )
            : null,
        child: isFavorite
            ? icon
                .animate(key: const ValueKey('fav-on'))
                .scaleXY(begin: 0.5, end: 1, duration: 260.ms, curve: Curves.elasticOut)
            : icon,
      ),
    );
  }
}

/// A circular avatar built from an emoji on a gradient (no image assets yet).
class EmojiAvatar extends StatelessWidget {
  const EmojiAvatar({
    super.key,
    required this.emoji,
    this.size = 48,
    this.seed = 1,
    this.ring = false,
  });

  final String emoji;
  final double size;
  final int seed;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        shape: BoxShape.circle,
        border: ring
            ? Border.all(color: Colors.white, width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// Shows a person's real [photo] when we have one, otherwise their [emoji],
/// sized to fill its parent. The parent is responsible for the shape/clip
/// (e.g. `clipBehavior: Clip.antiAlias` on a circular/rounded container), so
/// this can back both round avatars and rectangular cover images.
class MemberFace extends StatelessWidget {
  const MemberFace({
    super.key,
    required this.photo,
    required this.emoji,
    required this.emojiSize,
  });

  final String? photo;
  final String emoji;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    final fallback =
        Center(child: Text(emoji, style: TextStyle(fontSize: emojiSize)));
    if (photo != null && photo!.isNotEmpty) {
      return SizedBox.expand(
        child: Image.asset(
          photo!,
          fit: BoxFit.cover,
          // If the named file hasn't been uploaded yet, show the emoji instead
          // of a broken image — so slots are always safe to reference.
          errorBuilder: (_, _, _) => fallback,
        ),
      );
    }
    return fallback;
  }
}
