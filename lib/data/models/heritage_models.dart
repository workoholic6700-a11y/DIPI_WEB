/// Models for the **Heritage** section — the part of this home that isn't
/// photographs.
///
/// Photos keep what a day looked like. These keep what the family *knew*: the
/// words, the food, the reasons behind what we do every year, and how the Rais
/// came to be spread across Ilam, Kathmandu and Malaysia.
///
/// A NOTE ON TRUTH
/// ---------------
/// Everything here follows the same rule the birthdays screen already follows:
/// **we never invent.** A recipe with no method, a word nobody has recorded
/// yet, a story only Kopa knows — those ship *empty and labelled*, with the
/// person who could fill them named. An heirloom with a guess in it is not an
/// heirloom. See [Collectable].
library;

/// Something we know is missing, and who can fill it.
///
/// This is the heart of the section. Rather than hiding gaps, every screen
/// shows them and says whose memory they live in — so the app doubles as a list
/// of questions to ask while there is still somebody to ask.
class Collectable {
  const Collectable({
    required this.what,
    required this.askWho,
    this.why,
    this.urgent = false,
  });

  /// The thing we don't have yet, in plain words.
  final String what;

  /// Who holds it — "Mummy", "Kopa", "Papa".
  final String askWho;

  /// Optional: why it's worth writing down.
  final String? why;

  /// Marks knowledge that only an elder holds. Shown with a gentle nudge,
  /// because this is the kind that gets lost.
  final bool urgent;
}

/// Where a word comes from.
enum WordKind {
  /// Kirat / Rai — Mundhum vocabulary and the words of our own people.
  kirat,

  /// Nepali words that carry a particular weight in this house.
  nepali,

  /// Things only our family says. The private dictionary.
  ours,
}

extension WordKindX on WordKind {
  String get label => switch (this) {
        WordKind.kirat => 'Kirat & Rai',
        WordKind.nepali => 'Words of this house',
        WordKind.ours => 'Only we say this',
      };

  String get emoji => switch (this) {
        WordKind.kirat => '🌿',
        WordKind.nepali => '🏔️',
        WordKind.ours => '💬',
      };
}

/// A word worth keeping.
class HeritageWord {
  const HeritageWord({
    required this.id,
    required this.word,
    required this.roman,
    required this.meaning,
    required this.kind,
    this.note,
    this.saidBy,
    this.audio,
    this.colorSeed = 0,
  });

  final String id;

  /// As written, in its own script where we have it.
  final String word;

  /// Romanised, so anyone can say it out loud.
  final String roman;

  final String meaning;
  final WordKind kind;

  /// When and how it's used — the part a dictionary would leave out.
  final String? note;

  /// Whose voice this word belongs to.
  final String? saidBy;

  /// Asset path for a recording of an elder saying it. Null until somebody
  /// actually holds up a phone and asks — which is the whole point.
  final String? audio;

  final int colorSeed;

  bool get hasAudio => audio != null;
}

/// A dish, and — just as importantly — who taught it to whom.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.english,
    required this.emoji,
    required this.story,
    this.taughtBy,
    this.learnedFrom,
    this.ingredients = const [],
    this.steps = const [],
    this.handwritten,
    this.missing,
    this.colorSeed = 0,
  });

  final String id;

  /// The name the family actually uses.
  final String name;
  final String english;
  final String emoji;

  /// Why this dish matters here — the memory attached to it.
  final String story;

  /// Who cooks it now.
  final String? taughtBy;

  /// Who *they* learned it from. A recipe is a chain of people.
  final String? learnedFrom;

  final List<String> ingredients;
  final List<String> steps;

  /// Asset path for a photo of the recipe in someone's own handwriting.
  final String? handwritten;

  /// Set when the method hasn't been written down yet.
  final Collectable? missing;

  final int colorSeed;

  bool get isComplete => steps.isNotEmpty;
}

/// Something this family does, and the reason underneath it.
class Tradition {
  const Tradition({
    required this.id,
    required this.name,
    required this.when,
    required this.what,
    required this.emoji,
    this.why,
    this.ours,
    this.route,
    this.missing,
    this.colorSeed = 0,
  });

  final String id;
  final String name;

  /// Roughly when in the year it falls.
  final String when;

  /// What happens.
  final String what;

  final String emoji;

  /// Why it matters — the part children ask about and adults forget to answer.
  final String? why;

  /// How *we* do it, as distinct from how it's done generally. This is the
  /// only part of a festival page that couldn't be looked up somewhere else.
  final String? ours;

  /// An existing screen this opens into, when one already exists.
  final String? route;

  final Collectable? missing;
  final int colorSeed;
}

/// A place the family has lived, and the move that took them there.
///
/// Read in order these make the migration story: the hills, then the city for
/// school, then abroad for the school fees.
class RootStep {
  const RootStep({
    required this.id,
    required this.place,
    required this.region,
    required this.period,
    required this.story,
    required this.emoji,
    this.who,
    this.isHome = false,
    this.colorSeed = 0,
  });

  final String id;
  final String place;
  final String region;

  /// "always", "since 2022", "since Diksha was small".
  final String period;

  final String story;
  final String emoji;

  /// Who is there now.
  final String? who;

  /// The one everything else is measured from.
  final bool isHome;

  final int colorSeed;
}
