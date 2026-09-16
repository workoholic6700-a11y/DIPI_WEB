import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/content_models.dart';
import '../models/people.dart';
import '../models/story_models.dart';
import '../mock/mock_data.dart';
import '../gallery/gallery_providers.dart';

/// Riverpod providers that surface the mock dataset to the UI.
///
/// In Phase 2 these bodies swap to repository/Supabase calls — the widget layer
/// never changes because it only depends on the provider, not the source.

// ── Static content ─────────────────────────────────────────────────────────
final dipishaProfileProvider = Provider<DipishaProfile>(
  (ref) => MockData.dipisha,
);

final familyProvider = Provider<List<FamilyMember>>((ref) => MockData.family);

FamilyMember? familyMemberById(String id) =>
    MockData.family.where((m) => m.id == id).firstOrNull;

/// Family grouped by generation (for the Family Tree layout).
final familyByGenerationProvider =
    Provider<Map<Generation, List<FamilyMember>>>((ref) {
      final map = <Generation, List<FamilyMember>>{};
      for (final m in ref.watch(familyProvider)) {
        map.putIfAbsent(m.generation, () => []).add(m);
      }
      return map;
    });

final petsProvider = Provider<List<FamilyMember>>(
  (ref) => ref.watch(familyProvider).where((m) => m.isPet).toList(),
);

final storyProvider = Provider<List<StoryChapter>>((ref) => MockData.story);
final placesProvider = Provider<List<Place>>((ref) => MockData.places);
final achievementsProvider = Provider<List<Achievement>>(
  (ref) => MockData.achievements,
);
final dreamsProvider = Provider<List<DreamItem>>((ref) => MockData.dreams);
final futureMessagesProvider = Provider<List<FutureMessage>>(
  (ref) => MockData.futureMessages,
);

/// A stable "random" family quote that rotates.
final familyQuoteProvider = Provider<Quote>((ref) {
  final quotes = ref.watch(quotesProvider);
  final minute = DateTime.now().minute;
  return quotes[minute % quotes.length];
});

final quotesProvider = Provider<List<Quote>>((ref) => MockData.quotes);

/// A stable "quote of the day" that changes daily.
final quoteOfDayProvider = Provider<Quote>((ref) {
  final quotes = ref.watch(quotesProvider);
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year))
      .inDays;
  return quotes[dayOfYear % quotes.length];
});

final memoriesProvider = Provider<List<Memory>>((ref) => MockData.memories);

final lettersProvider = Provider<List<Letter>>((ref) => MockData.letters);

final voicesProvider = Provider<List<VoiceMessage>>((ref) => MockData.voices);

final timelineProvider = Provider<List<TimelineEvent>>(
  (ref) => MockData.timeline,
);

final albumsProvider = Provider<List<Album>>((ref) {
  final cloud = ref.watch(cloudAlbumsProvider).value ?? [];
  final merged = {for (final a in MockData.albums) a.id: a};
  for (final row in cloud) {
    final id = row['id'] as String;
    merged[id] = Album(
      id: id,
      name: (row['name'] as String)
          .replaceAll('📸', '🌿')
          .replaceAll('📷', '🌿'),
      date: DateTime.parse(row['created_at'] as String),
      photoCount: 0,
      colorSeed: merged[id]?.colorSeed ?? 0,
      coverAsset: row['cover_asset'] as String?,
    );
  }
  return merged.values.toList();
});

final videosProvider = Provider<List<VideoItem>>((ref) => MockData.videos);

final notificationsProvider = Provider<List<AppNotification>>(
  (ref) => MockData.notifications,
);

/// "Memory of the day" — the featured memory on Home (most recent favourite,
/// else most recent overall).
final memoryOfDayProvider = Provider<Memory>((ref) {
  final memories = [...ref.watch(memoriesProvider)]
    ..sort((a, b) => b.date.compareTo(a.date));
  return memories.firstWhere((m) => m.isFavorite, orElse: () => memories.first);
});

/// Recent memories, newest first.
final recentMemoriesProvider = Provider<List<Memory>>((ref) {
  return [...ref.watch(memoriesProvider)]
    ..sort((a, b) => b.date.compareTo(a.date));
});

// ── Persistence ────────────────────────────────────────────────────────────

/// Reads a saved set of keys, or `null` when this device has never saved one.
///
/// The null-vs-empty distinction matters: `null` means "first run, use the
/// seed values", while an empty list means "the user really did clear
/// everything" — and that choice has to survive a restart too.
Future<Set<String>?> _loadKeys(String prefsKey) async {
  final p = await SharedPreferences.getInstance();
  return p.getStringList(prefsKey)?.toSet();
}

Future<void> _saveKeys(String prefsKey, Set<String> keys) async {
  final p = await SharedPreferences.getInstance();
  await p.setStringList(prefsKey, keys.toList());
}

// ── Favourites (persisted) ─────────────────────────────────────────────────

/// Kinds of favouritable content — used to namespace favourite keys.
enum FavKind { memory, letter, voice }

String favKey(FavKind kind, String id) => '${kind.name}:$id';

/// Holds the set of favourited item keys. Seeded from the mock `isFavorite`
/// flags on the very first run, then remembered on this device from then on,
/// so a heart Dipisha taps is still there tomorrow.
class FavoritesNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'favorites';

  @override
  Set<String> build() {
    _restore();
    return {
      for (final m in MockData.memories)
        if (m.isFavorite) favKey(FavKind.memory, m.id),
      for (final l in MockData.letters)
        if (l.isFavorite) favKey(FavKind.letter, l.id),
      for (final v in MockData.voices)
        if (v.isFavorite) favKey(FavKind.voice, v.id),
    };
  }

  Future<void> _restore() async {
    final saved = await _loadKeys(_prefsKey);
    if (saved != null) state = saved;
  }

  bool isFavorite(FavKind kind, String id) => state.contains(favKey(kind, id));

  void toggle(FavKind kind, String id) {
    final key = favKey(kind, id);
    final next = {...state};
    if (!next.add(key)) next.remove(key);
    state = next;
    _saveKeys(_prefsKey, next);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

/// Convenience: is a specific item currently favourited?
final isFavoriteProvider = Provider.family<bool, ({FavKind kind, String id})>((
  ref,
  arg,
) {
  final favs = ref.watch(favoritesProvider);
  return favs.contains(favKey(arg.kind, arg.id));
});

// ── Which letters have been opened (persisted) ─────────────────────────────

/// Tracks which letters have actually been read.
///
/// Added deliberately, not as a styling detail: the mailbox shows sealed and
/// opened envelopes as physically different objects, and an envelope that
/// *looks* opened when nobody opened it — or reseals itself on restart — is
/// the app telling a small lie about her own history with it.
///
/// Nothing is ever un-opened. A letter she has read stays read.
class OpenedLettersNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'opened_letters';

  @override
  Set<String> build() {
    _restore();
    return <String>{};
  }

  Future<void> _restore() async {
    final saved = await _loadKeys(_prefsKey);
    if (saved != null) state = saved;
  }

  bool isOpened(String id) => state.contains(id);

  void markOpened(String id) {
    if (state.contains(id)) return;
    final next = {...state, id};
    state = next;
    _saveKeys(_prefsKey, next);
  }
}

final openedLettersProvider =
    NotifierProvider<OpenedLettersNotifier, Set<String>>(
      OpenedLettersNotifier.new,
    );

/// Has this particular letter been opened?
final isLetterOpenedProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(openedLettersProvider).contains(id),
);

/// The sealed ones, oldest first — what the mailbox offers next.
final unopenedLettersProvider = Provider<List<Letter>>((ref) {
  final opened = ref.watch(openedLettersProvider);
  return [...ref.watch(lettersProvider).where((l) => !opened.contains(l.id))]
    ..sort((a, b) => a.dateWritten.compareTo(b.dateWritten));
});

// ── Surprise unlock state (persisted) ──────────────────────────────────────

/// Tracks which surprises have been "opened". Once a surprise is opened it
/// stays open — re-locking a gift she has already seen would be unkind.
class UnlockedSurprisesNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'unlocked_surprises';

  @override
  Set<String> build() {
    _restore();
    return {
      for (final s in MockData.surprises)
        if (s.isUnlocked) s.id,
    };
  }

  Future<void> _restore() async {
    final saved = await _loadKeys(_prefsKey);
    // Union, not replace: a surprise that ships unlocked stays unlocked even
    // if it was saved before that flag was set.
    if (saved != null) state = {...state, ...saved};
  }

  void unlock(String id) {
    final next = {...state, id};
    state = next;
    _saveKeys(_prefsKey, next);
  }

  bool isUnlocked(String id) => state.contains(id);
}

final unlockedSurprisesProvider =
    NotifierProvider<UnlockedSurprisesNotifier, Set<String>>(
      UnlockedSurprisesNotifier.new,
    );

final surprisesProvider = Provider<List<Surprise>>((ref) {
  final unlocked = ref.watch(unlockedSurprisesProvider);
  return MockData.surprises
      .map((s) => s.copyWith(isUnlocked: unlocked.contains(s.id)))
      .toList();
});
