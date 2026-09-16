import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';

/// A dreamy gate into Dipisha's World. UI-only: any secret word opens it.
class DipishaGateScreen extends ConsumerStatefulWidget {
  const DipishaGateScreen({super.key});

  @override
  ConsumerState<DipishaGateScreen> createState() => _DipishaGateScreenState();
}

class _DipishaGateScreenState extends ConsumerState<DipishaGateScreen> {
  final _controller = TextEditingController();
  bool _opening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    setState(() => _opening = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    // `go` wiped the stack, which left the world's back button with nothing to
    // pop — you got in and couldn't get out. `pushReplacement` swaps the gate
    // for the world but keeps Home underneath, so back leads out of her world
    // and into the house rather than making her open the gate again.
    context.pushReplacement(Routes.dipishaWorld);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B1E6E), Color(0xFF7B4FB5), Color(0xFFB56F9E)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => context.pop(),
                              ),
                            ),
                            const Spacer(),
                            const Text('✨', style: TextStyle(fontSize: 60))
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .scaleXY(
                                  begin: 0.82,
                                  end: 1,
                                  duration: 700.ms,
                                  curve: Curves.easeOutBack,
                                ),
                            const SizedBox(height: 16),
                            Text(
                              trS(lang, AppConstants.dipishaWorldName),
                              textAlign: TextAlign.center,
                              style: AppTypography.brandScript(fontSize: 40),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              trS(lang, AppConstants.dipishaWorldTagline),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 36),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    trS(lang, 'Whisper the magic word 🤫'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _controller,
                                    obscureText: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: trS(lang, 'your secret word'),
                                      hintStyle: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 1.4,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (_) => _enter(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    trS(
                                      lang,
                                      'psst… any word works in here 💜',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _opening ? null : _enter,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF7B4FB5),
                                ),
                                child: _opening
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Color(0xFF7B4FB5),
                                        ),
                                      )
                                    : Text(trS(lang, 'Open the door ✨')),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              trS(lang, 'Made with endless love, by Nana'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
