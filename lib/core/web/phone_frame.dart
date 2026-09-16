import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows the app at phone width in a wide browser window.
///
/// Every screen was made on a 384-wide phone. Stretched across a laptop the
/// birthday photo fills half the window and the envelope turns into a ribbon.
/// So a wide window gets a phone-width column down the middle — the same app,
/// at the size it was made for. Dipisha's World and her rooms are landscape
/// places: they take the whole window, as they take the whole phone.
///
/// On a phone-sized window this does nothing at all.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  static const double phoneWidth = 430;

  /// Narrower than this is already a phone.
  static const double wideFrom = 600;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ScreenShape.landscape,
      builder: (context, landscape, _) {
        final media = MediaQuery.of(context);
        if (landscape || media.size.width < wideFrom) return child;
        final dark = Theme.of(context).brightness == Brightness.dark;
        return ColoredBox(
          color: dark ? const Color(0xFF120D19) : const Color(0xFFEDE3D6),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: dark ? AppColors.darkBg : AppColors.cream,
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 24),
                ],
              ),
              child: SizedBox(
                width: phoneWidth,
                child: ClipRect(
                  child: MediaQuery(
                    data: media.copyWith(
                      size: Size(phoneWidth, media.size.height),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Which shape the screen on top wants: phone-upright, or the whole window.
///
/// `LandscapeScope` and `PortraitScope` register here as well as asking the
/// phone to rotate, since a browser can't be rotated for them.
class ScreenShape {
  ScreenShape._();

  static final ValueNotifier<bool> landscape = ValueNotifier(false);
  static final List<(Object, bool)> _screens = [];

  /// Registers a screen; call [leave] with the token when it goes away.
  static Object enter({required bool landscape}) {
    final token = Object();
    _screens.add((token, landscape));
    _publish();
    return token;
  }

  static void leave(Object token) {
    _screens.removeWhere((screen) => identical(screen.$1, token));
    _publish();
  }

  // Scopes enter in initState and leave in dispose, when the tree can't be
  // rebuilt. The frame follows on the next frame, the way a phone rotates a
  // frame or two after the screen asks.
  static void _publish() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      landscape.value = _screens.isNotEmpty && _screens.last.$2;
    });
    WidgetsBinding.instance.scheduleFrame();
  }
}
