import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/heritage_data.dart';
import '../models/heritage_models.dart';

/// Providers for the Heritage section.
///
/// Same seam as [content_providers]: the widgets only ever depend on these, so
/// when this content moves out of a Dart file and into something the family can
/// actually edit, no screen changes.

final heritageWordsProvider =
    Provider<List<HeritageWord>>((ref) => HeritageData.words);

/// Words grouped by where they come from — drives the sections on the words
/// screen, and keeps the order of [WordKind] as the single source of truth.
final wordsByKindProvider = Provider<Map<WordKind, List<HeritageWord>>>((ref) {
  final map = <WordKind, List<HeritageWord>>{};
  for (final kind in WordKind.values) {
    final of = ref
        .watch(heritageWordsProvider)
        .where((w) => w.kind == kind)
        .toList();
    if (of.isNotEmpty) map[kind] = of;
  }
  return map;
});

final recipesProvider = Provider<List<Recipe>>((ref) => HeritageData.recipes);

final traditionsProvider =
    Provider<List<Tradition>>((ref) => HeritageData.traditions);

final rootsProvider = Provider<List<RootStep>>((ref) => HeritageData.roots);

/// The one place the family actually lives, pulled out for the roots screen.
final homeRootProvider = Provider<RootStep?>(
    (ref) => ref.watch(rootsProvider).where((r) => r.isHome).firstOrNull);

// ── What's still missing ───────────────────────────────────────────────────

/// Every gap in the heritage record, from all four areas at once.
///
/// This is deliberately a first-class provider rather than a detail of one
/// screen: the whole section is built around showing what we don't have yet.
final toCollectProvider = Provider<List<Collectable>>((ref) => [
      ...HeritageData.wordsToCollect,
      ...HeritageData.recipesToCollect,
      ...HeritageData.rootsToCollect,
      for (final r in ref.watch(recipesProvider))
        if (r.missing != null) r.missing!,
      for (final t in ref.watch(traditionsProvider))
        if (t.missing != null) t.missing!,
    ]);

/// The gaps only an elder can fill. These are the ones with a deadline.
final urgentToCollectProvider = Provider<List<Collectable>>(
    (ref) => ref.watch(toCollectProvider).where((c) => c.urgent).toList());

/// A small summary for the hub: how much of the record exists, and how much of
/// it is still only in somebody's memory.
typedef HeritageTally = ({
  int words,
  int wordsWithAudio,
  int recipes,
  int recipesComplete,
  int traditions,
  int places,
  int toCollect,
  int urgent,
});

final heritageTallyProvider = Provider<HeritageTally>((ref) {
  final words = ref.watch(heritageWordsProvider);
  final recipes = ref.watch(recipesProvider);
  return (
    words: words.length,
    wordsWithAudio: words.where((w) => w.hasAudio).length,
    recipes: recipes.length,
    recipesComplete: recipes.where((r) => r.isComplete).length,
    traditions: ref.watch(traditionsProvider).length,
    places: ref.watch(rootsProvider).length,
    toCollect: ref.watch(toCollectProvider).length,
    urgent: ref.watch(urgentToCollectProvider).length,
  );
});
