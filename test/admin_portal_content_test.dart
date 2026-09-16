import 'package:dear_dipisha/core/i18n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adminPortal = bool.fromEnvironment('ADMIN_PORTAL');

  test('album and archive controls keep Nepali in both build targets', () {
    for (final label in [
      'Your album desk',
      'Email',
      'Password',
      'Signing in…',
      'Sign in',
      'Sign out',
      'Add photos',
      'Publish all drafts',
      'The Archive Desk',
      'Memory',
      'Photograph',
      'Letter',
      'Voice recording',
      'Birthday',
      'Recipe',
      'Family fact',
      'Source',
      'Needs confirmation',
    ]) {
      expect(hasNepali(label), isTrue, reason: label);
      expect(trS(AppLang.ne, label), isNot(label), reason: label);
      expect(trS(AppLang.en, label), label);
    }
    expect(trS(AppLang.ne, 'Birthday'), 'जन्मदिन');
  });

  test(
    adminPortal
        ? 'admin lookup excludes family writing'
        : 'viewer lookup retains family writing',
    () {
      const memory =
          'You painted our whole family under a big rainbow and won first '
          'prize at school. You held that little trophy like it was made of '
          'gold. We were so proud.';
      expect(hasNepali(memory), !adminPortal);
      expect(
        trS(AppLang.ne, memory),
        adminPortal ? equals(memory) : isNot(memory),
      );
      expect(trS(AppLang.en, memory), memory);
    },
  );
}
