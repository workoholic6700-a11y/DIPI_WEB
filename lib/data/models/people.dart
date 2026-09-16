/// Profile of Dipisha (the "About Dipisha" + Profile screens).
class DipishaProfile {
  const DipishaProfile({
    required this.name,
    required this.nickname,
    required this.birthday,
    required this.tagline,
    required this.emoji,
    required this.height,
    required this.favoriteFood,
    required this.favoriteCartoon,
    required this.dreamJob,
    required this.bestFriend,
    required this.favoriteSubject,
    required this.favoriteColor,
    required this.likes,
    required this.dislikes,
    this.colorSeed = 0,
    this.photo,
    this.callName,
  });

  final String name;
  final String nickname;

  /// What she's actually called, when that isn't the first word of [name].
  /// Same reasoning as [FamilyMember.callName] — names don't reliably split.
  final String? callName;

  /// The name to show when there isn't room for the whole thing.
  String get shortName => callName ?? name.split(' ').first;
  final DateTime birthday;
  final String tagline;
  final String emoji;
  final String height;
  final String favoriteFood;
  final String favoriteCartoon;
  final String dreamJob;
  final String bestFriend;
  final String favoriteSubject;
  final String favoriteColor;
  final List<String> likes;
  final List<String> dislikes;
  final int colorSeed;

  /// Optional real photo asset path (falls back to [emoji] when null).
  final String? photo;
}

/// Which generation a family member belongs to (drives the tree layout).
enum Generation { grandparents, parents, children, pets }

/// A member on the Family page & Family Tree.
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.emoji,
    required this.bio,
    required this.funFact,
    required this.generation,
    this.isPet = false,
    this.inMemoriam = false,
    this.colorSeed = 0,
    this.photo,
    this.callName,
  });

  final String id;
  final String name;
  final String relation; // e.g. "Grandfather", "Eldest Sister", "Dog"

  /// What the family actually calls them, when it isn't simply the first word
  /// of [name].
  ///
  /// Papa is **Rup Raj** Rai — his given name is two words, so splitting on
  /// the first space called him "Rup" on the portrait wall, at the table, on
  /// the calendar and everywhere else. Names don't reliably split; set this
  /// whenever the short form isn't obvious.
  final String? callName;

  /// The name to show when there isn't room for the whole thing.
  String get shortName => callName ?? name.split(' ').first;
  final String emoji;
  final String bio;
  final String funFact;
  final Generation generation;
  final bool isPet;
  final bool inMemoriam;
  final int colorSeed;

  /// Optional real photo asset path (falls back to [emoji] when null).
  final String? photo;
}
