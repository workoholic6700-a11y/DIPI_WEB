/// A chapter in the "Our Story" book.
class StoryChapter {
  const StoryChapter({
    required this.year,
    required this.title,
    required this.body,
    required this.emoji,
    this.colorSeed = 0,
    this.hasPhoto = true,
  });

  final String year;
  final String title;
  final String body;
  final String emoji;
  final int colorSeed;
  final bool hasPhoto;
}

/// A place the family has travelled to.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.region,
    required this.story,
    required this.year,
    required this.emoji,
    this.colorSeed = 0,
    this.photoCount = 0,
  });

  final String id;
  final String name;
  final String region;
  final String story;
  final int year;
  final String emoji;
  final int colorSeed;
  final int photoCount;
}

/// An achievement in Dipisha's World.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.emoji,
    this.colorSeed = 0,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String emoji;
  final int colorSeed;
}

/// A dream on Dipisha's dream board.
class DreamItem {
  const DreamItem({
    required this.text,
    required this.emoji,
    this.rotation = 0,
    this.colorSeed = 0,
  });

  final String text;
  final String emoji;
  final double rotation;
  final int colorSeed;
}

/// A future message that unlocks on a milestone (UI-only teaser here).
class FutureMessage {
  const FutureMessage({
    required this.id,
    required this.title,
    required this.unlockLabel,
    required this.preview,
    this.emoji = '💌',
    this.colorSeed = 0,
  });

  final String id;
  final String title;
  final String unlockLabel;
  final String preview;
  final String emoji;
  final int colorSeed;
}
