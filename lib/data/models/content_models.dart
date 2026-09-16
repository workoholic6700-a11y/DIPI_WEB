import '../../core/constants/enums.dart';

/// Immutable UI models for Phase 1 (mock data only — no backend).
///
/// These intentionally use plain Dart (not Freezed) to keep the UI phase fast
/// and codegen-free. When Phase 2 begins, the fields map 1:1 to Supabase rows.

class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.mood,
    required this.category,
    this.location,
    this.tags = const [],
    this.isFavorite = false,
    this.photoCount = 0,
    this.videoCount = 0,
    this.hasVoice = false,
    this.colorSeed = 0,
    this.animation,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final Mood mood;
  final MemoryCategory category;
  final String? location;
  final List<String> tags;
  final bool isFavorite;
  final int photoCount;
  final int videoCount;
  final bool hasVoice;
  final int colorSeed;

  /// Optional Lottie asset path (see `Anim` in `shared/widgets/lottie_art.dart`)
  /// for memories we have a little animation for. Null for most.
  final String? animation;

  Memory copyWith({bool? isFavorite}) => Memory(
    id: id,
    title: title,
    description: description,
    date: date,
    mood: mood,
    category: category,
    location: location,
    tags: tags,
    isFavorite: isFavorite ?? this.isFavorite,
    photoCount: photoCount,
    videoCount: videoCount,
    hasVoice: hasVoice,
    colorSeed: colorSeed,
    animation: animation,
  );
}

class Letter {
  const Letter({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.mood,
    required this.dateWritten,
    this.isFavorite = false,
    this.hasVoice = false,
    this.imageCount = 0,
    this.colorSeed = 0,
  });

  final String id;
  final String title;
  final String body;
  final LetterCategory category;
  final Mood mood;
  final DateTime dateWritten;
  final bool isFavorite;
  final bool hasVoice;
  final int imageCount;
  final int colorSeed;

  Letter copyWith({bool? isFavorite}) => Letter(
    id: id,
    title: title,
    body: body,
    category: category,
    mood: mood,
    dateWritten: dateWritten,
    isFavorite: isFavorite ?? this.isFavorite,
    hasVoice: hasVoice,
    imageCount: imageCount,
    colorSeed: colorSeed,
  );
}

class Quote {
  const Quote({required this.id, required this.text, required this.author});
  final String id;
  final String text;
  final String author;
}

class VoiceMessage {
  const VoiceMessage({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSeconds,
    required this.date,
    this.isFavorite = false,
    this.colorSeed = 0,
  });

  final String id;
  final String title;
  final String category;
  final int durationSeconds;
  final DateTime date;
  final bool isFavorite;
  final int colorSeed;

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  VoiceMessage copyWith({bool? isFavorite}) => VoiceMessage(
    id: id,
    title: title,
    category: category,
    durationSeconds: durationSeconds,
    date: date,
    isFavorite: isFavorite ?? this.isFavorite,
    colorSeed: colorSeed,
  );
}

class Surprise {
  const Surprise({
    required this.id,
    required this.title,
    required this.teaser,
    required this.message,
    required this.unlockType,
    this.unlockDate,
    this.unlockAge,
    this.isUnlocked = false,
    this.colorSeed = 0,
  });

  final String id;
  final String title;
  final String teaser;
  final String message;
  final UnlockType unlockType;
  final DateTime? unlockDate;
  final int? unlockAge;
  final bool isUnlocked;
  final int colorSeed;

  Surprise copyWith({bool? isUnlocked}) => Surprise(
    id: id,
    title: title,
    teaser: teaser,
    message: message,
    unlockType: unlockType,
    unlockDate: unlockDate,
    unlockAge: unlockAge,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    colorSeed: colorSeed,
  );
}

class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.emoji,
    this.colorSeed = 0,
    this.hasPhoto = true,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String emoji;
  final int colorSeed;
  final bool hasPhoto;

  int get year => date.year;
}

class Album {
  const Album({
    required this.id,
    required this.name,
    required this.date,
    required this.photoCount,
    this.colorSeed = 0,
    this.coverAsset,
  });

  final String id;
  final String name;
  final DateTime date;
  final int photoCount;
  final int colorSeed;

  /// A photograph bundled in the app, chosen on the album desk as this
  /// album's cover. Null means the first bundled photograph is shown.
  final String? coverAsset;
}

class Photo {
  const Photo({
    required this.id,
    required this.albumId,
    required this.caption,
    required this.date,
    this.colorSeed = 0,
    this.assetPath,
    this.storagePath,
    this.thumbPath,
  });

  final String id;
  final String albumId;
  final String caption;
  final DateTime? date;
  final int colorSeed;
  final String? assetPath;
  final String? storagePath;
  final String? thumbPath;
}

class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.date,
    this.category = 'Moments',
    this.colorSeed = 0,
  });

  final String id;
  final String title;
  final int durationSeconds;
  final DateTime date;
  final String category;
  final int colorSeed;

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

enum NotificationType { memory, letter, surprise, birthday, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
  final NotificationType type;
  final bool isRead;
}
