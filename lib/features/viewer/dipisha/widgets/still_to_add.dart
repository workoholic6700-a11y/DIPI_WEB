import 'package:flutter/material.dart';

import '../../../../core/i18n/l10n.dart';

/// An honest gap in Dipisha's World.
///
/// Empty heirloom content is not a broken state. It is a note naming the
/// person who can fill it, so a polished placeholder can never become family
/// history by accident.
class StillToAdd extends StatelessWidget {
  const StillToAdd({
    super.key,
    required this.lang,
    required this.message,
    this.compact = false,
  });

  final AppLang lang;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${trS(lang, 'Still to add 💌')}. ${trS(lang, message)}',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: EdgeInsets.all(compact ? 18 : 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF4).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4CFAE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💌', style: TextStyle(fontSize: 34)),
            const SizedBox(height: 8),
            Text(
              trS(lang, 'Still to add 💌'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4D3D56),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              trS(lang, message),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF786B7F),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              trS(lang, 'Ask Diksha'),
              style: const TextStyle(
                color: Color(0xFF8E5BA6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
