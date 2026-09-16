import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The two — and only two — kinds of user in the platform.
enum UserRole {
  admin,
  viewer;

  static UserRole fromString(String? value) => switch (value) {
        'admin' => UserRole.admin,
        _ => UserRole.viewer,
      };

  String get value => name;
  bool get isAdmin => this == UserRole.admin;
  bool get isViewer => this == UserRole.viewer;
}

/// Mood attached to memories & letters. Drives the little emoji + tint.
enum Mood {
  happy('Happy', '😊', AppColors.gold),
  loved('Loved', '🥰', AppColors.pink),
  excited('Excited', '🤩', AppColors.goldDeep),
  proud('Proud', '🌟', AppColors.lavender),
  calm('Calm', '😌', AppColors.skyBlue),
  grateful('Grateful', '🙏', AppColors.lavenderLight),
  silly('Silly', '🤪', AppColors.pinkDeep),
  sad('Sad', '🥺', AppColors.skyBlue),
  nostalgic('Nostalgic', '🍂', AppColors.goldDeep);

  const Mood(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;

  static Mood fromString(String? value) =>
      Mood.values.firstWhere((m) => m.name == value, orElse: () => Mood.happy);
}

/// High-level category for memories (used for filtering chips).
enum MemoryCategory {
  all('All', Icons.auto_awesome_rounded),
  trips('Trips', Icons.luggage_rounded),
  birthday('Birthday', Icons.cake_rounded),
  family('Family', Icons.family_restroom_rounded),
  school('School', Icons.school_rounded),
  festivals('Festivals', Icons.celebration_rounded),
  everyday('Everyday', Icons.wb_sunny_rounded),
  achievements('Achievements', Icons.emoji_events_rounded);

  const MemoryCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  String get value => name;
  static MemoryCategory fromString(String? value) => MemoryCategory.values
      .firstWhere((c) => c.name == value, orElse: () => MemoryCategory.everyday);
}

/// Emotional "when to read" category for letters (from the brief).
enum LetterCategory {
  whenSad('When you\'re sad', '🌧️'),
  whenHappy('When you\'re happy', '☀️'),
  whenScared('When you\'re scared', '🫂'),
  birthday('Birthday', '🎂'),
  christmas('Christmas', '🎄'),
  dashain('Dashain', '🪔'),
  tihar('Tihar', '🎆'),
  examDay('Exam Day', '📚'),
  graduation('Graduation', '🎓'),
  future('Future', '🔮'),
  general('Just because', '💌');

  const LetterCategory(this.label, this.emoji);
  final String label;
  final String emoji;

  String get value => name;
  static LetterCategory fromString(String? value) => LetterCategory.values
      .firstWhere((c) => c.name == value, orElse: () => LetterCategory.general);
}

/// How a surprise (locked) message becomes unlockable.
enum UnlockType {
  date('Specific Date', Icons.calendar_month_rounded),
  age('Specific Age', Icons.cake_rounded),
  birthday('On a Birthday', Icons.celebration_rounded),
  password('Password', Icons.lock_rounded);

  const UnlockType(this.label, this.icon);
  final String label;
  final IconData icon;

  String get value => name;
  static UnlockType fromString(String? value) => UnlockType.values
      .firstWhere((t) => t.name == value, orElse: () => UnlockType.date);
}

/// Status of a content item — supports the admin "archive / draft" workflow.
enum ContentStatus {
  draft,
  published,
  archived;

  String get value => name;
  static ContentStatus fromString(String? value) => ContentStatus.values
      .firstWhere((s) => s.name == value, orElse: () => ContentStatus.published);
}
