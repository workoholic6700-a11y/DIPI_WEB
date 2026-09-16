import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/data/mock/mock_data.dart';
import 'package:dear_dipisha/data/providers/content_providers.dart';

/// Favourites and opened surprises used to live only in memory, so every heart
/// Dipisha tapped and every surprise she opened was forgotten the moment the
/// app closed. These tests simulate a restart by building a second
/// `ProviderContainer` over the same fake prefs.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Lets the notifier's async `_restore()` land before we assert.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// A fresh "app launch" reading the same persisted store.
  Future<Set<String>> relaunch<N extends Notifier<Set<String>>>(
    NotifierProvider<N, Set<String>> p,
  ) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p); // triggers build() + _restore()
    await settle();
    return c.read(p);
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('favourites', () {
    test('seed favourites apply on a first-ever launch', () async {
      final favs = await relaunch(favoritesProvider);
      final seeded = MockData.memories.where((m) => m.isFavorite);
      for (final m in seeded) {
        expect(favs, contains(favKey(FavKind.memory, m.id)));
      }
    });

    test('a newly favourited item survives a restart', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settle();

      final target = MockData.memories.firstWhere((m) => !m.isFavorite);
      c.read(favoritesProvider.notifier).toggle(FavKind.memory, target.id);
      await settle();

      final after = await relaunch(favoritesProvider);
      expect(after, contains(favKey(FavKind.memory, target.id)));
    });

    test('un-favouriting a seeded item also survives a restart', () async {
      // The case a naive "merge with the seed" implementation gets wrong:
      // the item comes back every launch and the heart won't stay off.
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settle();

      final seeded = MockData.memories.firstWhere((m) => m.isFavorite);
      c.read(favoritesProvider.notifier).toggle(FavKind.memory, seeded.id);
      await settle();
      expect(
        c.read(favoritesProvider),
        isNot(contains(favKey(FavKind.memory, seeded.id))),
      );

      final after = await relaunch(favoritesProvider);
      expect(
        after,
        isNot(contains(favKey(FavKind.memory, seeded.id))),
        reason: 'a heart turned off must stay off after a restart',
      );
    });
  });

  group('surprises', () {
    test('an opened surprise stays open after a restart', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settle();

      // Persistence does not need a demonstration gift in the family data.
      // A synthetic id tests the mechanism without shipping invented content.
      const id = 'confirmed-surprise-test';
      c.read(unlockedSurprisesProvider.notifier).unlock(id);
      await settle();

      final after = await relaunch(unlockedSurprisesProvider);
      expect(after, contains(id));
    });

    test('surprises that ship unlocked stay unlocked', () async {
      // Even if the saved set predates that flag.
      SharedPreferences.setMockInitialValues({
        'flutter.unlocked_surprises': <String>[],
      });
      final after = await relaunch(unlockedSurprisesProvider);
      for (final s in MockData.surprises.where((s) => s.isUnlocked)) {
        expect(after, contains(s.id));
      }
    });
  });
}
