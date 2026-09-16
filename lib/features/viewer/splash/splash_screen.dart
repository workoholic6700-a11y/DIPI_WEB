import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/brand_loading_view.dart';

/// Animated splash: floating hearts, sparkles, script logo, gentle fade — then
/// advances to onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMs),
      () {
        if (mounted) context.go(Routes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: BrandLoadingView(showTitle: false),
          ),
          // Overlay the full brand lockup with tagline.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 150),
                Text(AppConstants.appName,
                        style: AppTypography.brandScript(fontSize: 52))
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 700.ms)
                    .moveY(begin: 14, end: 0),
                const SizedBox(height: 8),
                Text(AppConstants.familyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ))
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 700.ms),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 700.ms),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 44),
              child: Icon(Icons.favorite_rounded,
                  color: AppColors.pinkLight, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
