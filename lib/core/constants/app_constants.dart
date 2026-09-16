/// App-wide string & config constants.
abstract final class AppConstants {
  AppConstants._();

  // ── Identity ─────────────────────────────────────────────────────────
  static const String appName = 'Our Home';
  static const String familyName = 'The Rai Family';
  static const String appTagline = 'Every family has a story. This is ours.';

  static const String welcomeTitle = 'Welcome Home';
  static const String welcomeLine1 = 'Every family has a story.';
  static const String welcomeLine2 = 'This is ours.';

  // ── Dipisha's World (the one gated, magical space) ───────────────────
  static const String dipishaWorldName = 'Dipisha\'s World';
  static const String dipishaWorldTagline =
      'A magical little world, made with love by Nana ✨';
  static const String viewerName = 'Dipisha';
  static const String elderSisterName = 'Diksha';
  static const String elderSisterNickname = 'Nana';

  /// The "hug" message shown in Dipisha's World.
  static const String hugMessage =
      'No matter how old you become,\nyou will always be our little star.';

  static const int splashDurationMs = 2600;
  static const int cacheTtlMinutes = 60;
}

/// Supabase table names — kept in one place so a rename is a one-line change.
abstract final class SupaTables {
  SupaTables._();

  static const String profiles = 'profiles';
  static const String albums = 'albums';
  static const String memories = 'memories';
  static const String memoryImages = 'memory_images';
  static const String memoryVideos = 'memory_videos';
  static const String voiceMessages = 'voice_messages';
  static const String letters = 'letters';
  static const String letterImages = 'letter_images';
  static const String letterAudio = 'letter_audio';
  static const String surpriseMessages = 'surprise_messages';
  static const String birthdayMemories = 'birthday_memories';
  static const String timelineEvents = 'timeline_events';
  static const String achievements = 'achievements';
  static const String quotes = 'quotes';
  static const String dailyMessages = 'daily_messages';
  static const String categories = 'categories';
  static const String favorites = 'favorites';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
}

/// Supabase Storage bucket names.
abstract final class SupaBuckets {
  SupaBuckets._();

  static const String avatars = 'avatars';
  static const String photos = 'photos';
  static const String videos = 'videos';
  static const String voices = 'voices';
  static const String letters = 'letters';
  static const String thumbnails = 'thumbnails';
  static const String birthday = 'birthday';
  static const String timeline = 'timeline';

  static const List<String> all = [
    avatars, photos, videos, voices, letters, thumbnails, birthday, timeline,
  ];
}
