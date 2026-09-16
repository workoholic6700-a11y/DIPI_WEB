import '../../core/constants/app_photos.dart';
import '../../core/constants/enums.dart';
import '../../shared/widgets/lottie_art.dart';
import '../models/content_models.dart';
import '../models/people.dart';
import '../models/story_models.dart';

/// Central store of realistic mock content for the UI phase.
///
/// Everything the app displays before the backend exists lives here so screens
/// feel completely alive. Dates are anchored around mid-2026 so the birthday
/// countdown and "recent" sections look natural.
abstract final class MockData {
  MockData._();

  // ── Dipisha ────────────────────────────────────────────────────────────
  static final DipishaProfile dipisha = DipishaProfile(
    name: 'Dipisha',
    nickname: 'Dipu',
    birthday: DateTime(2018, 6, 28), // Asar 14, 2075 BS
    tagline: 'My World, My Story',
    emoji: '👧🏻',
    height: '122 cm',
    favoriteFood: 'Sisnu ko curry & dal',
    favoriteCartoon: 'Doraemon',
    dreamJob: 'Doctor',
    bestFriend: 'Aayush',
    favoriteSubject: 'Science',
    favoriteColor: 'Lavender',
    likes: const ['Sisnu ko curry', 'Dal bhat', 'A little chocolate'],
    dislikes: const ['Spicy food', 'Loud noises', 'Homework on Sundays'],
    colorSeed: 1,
    photo: AppPhotos.dipisha,
  );

  // ── Real birthdays ───────────────────────────────────────────────────────
  /// The family thinks in Bikram Sambat, so each is noted with the BS date it
  /// was converted from (via the `nepali_utils` calendar, never by hand).
  ///
  /// The Birthdays page and the Celebration Hall both read from here, so they
  /// can never disagree.
  static final Map<String, DateTime> birthdays = {
    'f_diksha': DateTime(2005, 3, 26), // चैत १३, २०६१
    'f_diya': DateTime(2006, 8, 6), // साउन २१, २०६३
    'f_dipisha': DateTime(2018, 6, 28), // असार १४, २०७५
    // Given by Diksha, 2026-08-05, in BS as the family keeps them. Converted
    // with nepali_utils (tool/convert_bs.dart) — never by hand, because BS
    // month lengths vary year to year.
    'f_father': DateTime(1986, 5, 21), // जेष्ठ ७, २०४३
    'f_mother': DateTime(1987, 4, 18), // बैशाख ५, २०४४
    'f_grandpa': DateTime(1968, 8, 30), // भाद्र १५, २०२५ — confirmed by Diksha
  };

  /// Whose birthday above is a guess rather than a fact.
  ///
  /// Empty as of 2026-08-05: every date here came from the family. Keep the
  /// mechanism — the moment somebody adds a person whose date nobody has, they
  /// belong in this set rather than in a plausible-looking guess.
  static const Set<String> placeholderBirthdays = <String>{};

  /// True when [memberId]'s birthday is a stand-in, not something the family
  /// actually told us. Drives the "not confirmed" mark in the UI.
  static bool isPlaceholderBirthday(String memberId) =>
      placeholderBirthdays.contains(memberId);

  /// Only birthdays we can stand behind. Countdowns read from this.
  static Map<String, DateTime> get confirmedBirthdays => {
    for (final e in birthdays.entries)
      if (!isPlaceholderBirthday(e.key)) e.key: e.value,
  };

  // ── Family (the Rai family) ──────────────────────────────────────────────
  static const List<FamilyMember> family = [
    // Grandparents
    FamilyMember(
      id: 'f_grandpa',
      name: 'Dalbahadur Rai',
      relation: 'Grandfather',
      emoji: '👴🏻',
      bio:
          'The gentle root of our family tree. Full of old stories, warm '
          'blessings and the best hugs.',
      funFact: 'Can tell the same joke a hundred times and it\'s still funny.',
      generation: Generation.grandparents,
      colorSeed: 3,
      photo: AppPhotos.grandfather,
    ),
    // Parents
    FamilyMember(
      id: 'f_father',
      name: 'Rup Raj Rai',
      // Given name is two words — he is Rup Raj, never "Rup".
      callName: 'Rup Raj',
      relation: 'Father · in Malaysia',
      emoji: '👨🏻',
      bio:
          'Our steady mountain. He works far away in Malaysia so his daughters '
          'could study and chase their dreams — a sacrifice we can never repay. '
          'The strongest, most selfless love we know.',
      funFact: 'Video-calls home every night, no matter how tired he is.',
      generation: Generation.parents,
      colorSeed: 2,
      photo: AppPhotos.father,
    ),
    FamilyMember(
      id: 'f_mother',
      name: 'Sanchu Rai',
      relation: 'Mother · at home in Ilam',
      emoji: '👩🏻',
      bio:
          'The heart of our home in Ilam. She holds everything together and '
          'raises Dipisha with endless love — her kitchen always smelling of '
          'woodfire, maize and warmth.',
      funFact: 'Somehow always knows when you\'re about to be naughty.',
      generation: Generation.parents,
      colorSeed: 1,
      photo: AppPhotos.mother,
    ),
    // Children (sisters)
    FamilyMember(
      id: 'f_diksha',
      name: 'Diksha Rai',
      relation: 'Eldest Sister · Diksha',
      emoji: '👩🏻‍💻',
      bio:
          'The keeper of memories — a Flutter developer living in Kathmandu, '
          'fresh out of her BSc (Hons) IT. She built this whole little world so '
          'you never, ever forget how loved you are.',
      funFact: 'Cries happy tears at every single one of your birthdays.',
      generation: Generation.children,
      colorSeed: 0,
      photo: AppPhotos.diksha,
    ),
    FamilyMember(
      id: 'f_diya',
      name: 'Diya Rai',
      relation: 'Middle Sister',
      emoji: '🧑🏻',
      bio:
          'Your partner in mischief, now studying BBS (2nd year) in Kathmandu '
          'with Diksha. Still the best pillow-fort architect in the whole family.',
      funFact: 'Taught you to ride a bicycle in a single afternoon.',
      generation: Generation.children,
      colorSeed: 6,
      photo: AppPhotos.diya,
    ),
    FamilyMember(
      id: 'f_dipisha',
      name: 'Dipisha Rai',
      relation: 'The Little Star · Class 3',
      emoji: '👧🏻',
      bio:
          'That\'s you! Eight years old, in class 3, growing up in our village '
          'home in Ilam with Mummy — the tiny human who makes every ordinary '
          'day feel like a celebration.',
      funFact: 'Once named a stray puppy "Prime Minister".',
      generation: Generation.children,
      colorSeed: 4,
      photo: AppPhotos.dipisha,
    ),
    // Pets
    FamilyMember(
      id: 'f_arjun',
      name: 'Arjun Rai',
      relation: 'Our Dog',
      emoji: '🐶',
      bio:
          'Stubby\'s brave little son and the fluffiest member of the family. '
          'Guards the house and steals the slippers.',
      funFact: 'Comes running the second he hears the fridge open.',
      generation: Generation.pets,
      isPet: true,
      colorSeed: 5,
      photo: AppPhotos.arjun,
    ),
    FamilyMember(
      id: 'f_meow',
      name: 'Meow Rai',
      relation: 'Our Cat',
      emoji: '🐱',
      bio:
          'The tiny ruler of the house. Naps in every sunbeam and judges '
          'everyone equally.',
      funFact: 'Owns the whole family and knows it.',
      generation: Generation.pets,
      isPet: true,
      colorSeed: 7,
      photo: AppPhotos.meow,
    ),
    FamilyMember(
      id: 'f_stubby',
      name: 'Stubby Rai',
      relation: 'Forever in our hearts',
      emoji: '🐾',
      bio:
          'Our very first furry friend and Arjun\'s mother. She watched you '
          'grow up and loved you fiercely. Always remembered. 🌈',
      funFact: 'Would not sleep until every family member was home.',
      generation: Generation.pets,
      isPet: true,
      inMemoriam: true,
      colorSeed: 6,
      photo: AppPhotos.stubby,
    ),
  ];

  // ── Quotes ─────────────────────────────────────────────────────────────
  static const List<Quote> quotes = [
    Quote(
      id: 'q1',
      text:
          'You are braver than you believe, stronger than you seem, and '
          'smarter than you think.',
      author: 'A. A. Milne',
    ),
    Quote(
      id: 'q2',
      text: 'Little sister, you are a tiny miracle wrapped in giggles.',
      author: 'Diksha',
    ),
    Quote(
      id: 'q3',
      text: 'The best thing to hold onto in life is each other.',
      author: 'Audrey Hepburn',
    ),
    Quote(
      id: 'q4',
      text: 'Keep shining, little star. The whole sky is watching.',
      author: 'Diksha',
    ),
    Quote(
      id: 'q5',
      text:
          'Wherever you go, no matter the weather, always bring your own '
          'sunshine.',
      author: 'Anthony J. D\'Angelo',
    ),
  ];

  // ── Memories ───────────────────────────────────────────────────────────
  static final List<Memory> memories = [
    Memory(
      id: 'm1',
      title: 'Sunrise at Shree Antu',
      description:
          'We woke in the dark and climbed to Shree Antu to watch the sun rise '
          'over a whole sea of tea gardens and cloud, the Himalaya glowing gold. '
          'Cold hands, hot tea, and a view we will never forget.',
      date: DateTime(2022, 11, 20),
      mood: Mood.excited,
      category: MemoryCategory.trips,
      location: 'Shree Antu, Ilam',
      tags: const ['ilam', 'sunrise', 'tea-gardens'],
      isFavorite: true,
      photoCount: 12,
      videoCount: 1,
      hasVoice: true,
      colorSeed: 2,
    ),
    Memory(
      id: 'm2',
      title: 'Dipisha\'s Birthday',
      description:
          'A whole day of love in our village home — sel roti, a little cake, '
          'and everyone singing. You blew the candles in one big breath and the '
          'whole house cheered.',
      date: DateTime(2025, 6, 28),
      mood: Mood.loved,
      category: MemoryCategory.birthday,
      location: 'Our home, Ilam',
      tags: const ['birthday', 'cake', 'family'],
      isFavorite: true,
      photoCount: 24,
      videoCount: 3,
      hasVoice: true,
      colorSeed: 1,
    ),
    Memory(
      id: 'm3',
      title: 'Drawing Competition Win',
      description:
          'You painted our whole family under a big rainbow and won first '
          'prize at school. You held that little trophy like it was made of '
          'gold. We were so proud.',
      date: DateTime(2026, 5, 18),
      mood: Mood.proud,
      category: MemoryCategory.achievements,
      location: 'Suryodaya Shiksha Sadan Secondary School',
      tags: const ['art', 'school', 'trophy'],
      photoCount: 6,
      hasVoice: false,
      colorSeed: 3,
    ),
    Memory(
      id: 'm4',
      title: 'Dashain Together',
      description:
          'Tika, jamara and so many blessings. You wore your new red dress '
          'and collected dakshina from everyone. You counted it three times!',
      date: DateTime(2025, 10, 3),
      mood: Mood.happy,
      category: MemoryCategory.festivals,
      location: 'Grandma\'s House',
      tags: const ['dashain', 'family', 'festival'],
      photoCount: 18,
      videoCount: 1,
      hasVoice: false,
      colorSeed: 5,
    ),
    Memory(
      id: 'm5',
      title: 'Lumbini School Tour',
      description:
          'My class-10 school tour from Suryodaya — just me and my classmates, a '
          'long, noisy bus ride all the way across the country, and then the calm '
          'sacred garden where the Buddha was born. My first big journey away '
          'from the hills. — Diksha',
      date: DateTime(2015, 3, 12),
      mood: Mood.calm,
      category: MemoryCategory.trips,
      location: 'Lumbini, Rupandehi',
      tags: const ['lumbini', 'school', 'tour'],
      photoCount: 9,
      hasVoice: false,
      colorSeed: 7,
    ),
    Memory(
      id: 'm6',
      title: 'Learning to Cycle',
      description:
          'Wobbly at first, then suddenly you were flying down the lane '
          'shouting "Look! No hands!" (there were, in fact, hands).',
      date: DateTime(2024, 3, 9),
      mood: Mood.excited,
      category: MemoryCategory.everyday,
      location: 'Our Lane',
      tags: const ['bicycle', 'milestone'],
      photoCount: 4,
      hasVoice: false,
      colorSeed: 4,
      animation: Anim.girlCycling,
    ),
    Memory(
      id: 'm7',
      title: 'Rainy Day Momos',
      description:
          'It poured all afternoon so we made momos together. More flour '
          'ended up on your face than in the dumplings.',
      date: DateTime(2026, 6, 2),
      mood: Mood.calm,
      category: MemoryCategory.everyday,
      location: 'Home Kitchen',
      tags: const ['cooking', 'rain'],
      photoCount: 7,
      hasVoice: false,
      colorSeed: 0,
    ),
    Memory(
      id: 'm8',
      title: 'First Day of School',
      description:
          'A backpack almost as big as you were. You held my hand at the gate of '
          'Suryodaya Shiksha Sadan — the very same school Diya and I walked '
          'through until class 10 — then walked in like the bravest little person '
          'in the world. Three sisters, one school, one set of corridors.',
      date: DateTime(2021, 4, 15),
      mood: Mood.nostalgic,
      category: MemoryCategory.school,
      location: 'Suryodaya Shiksha Sadan Secondary School',
      tags: const ['school', 'first-day', 'milestone'],
      photoCount: 5,
      hasVoice: false,
      colorSeed: 6,
    ),
    Memory(
      id: 'm9',
      title: 'Mummy\'s Morning Kitchen',
      description:
          'Before sunrise, Mummy ground maize on the jaato and cooked warm kholo '
          'for the cow. I helped light the chulo — aago balna — blowing at the '
          'flame till it caught, smoke curling into the cold Ilam morning. The '
          'smell of woodfire and maize is the smell of home.',
      date: DateTime(2013, 1, 12),
      mood: Mood.nostalgic,
      category: MemoryCategory.everyday,
      location: 'Our home, Ilam',
      tags: const ['ilam', 'chulo', 'mummy', 'childhood'],
      isFavorite: true,
      photoCount: 4,
      hasVoice: false,
      colorSeed: 3,
    ),
    Memory(
      id: 'm10',
      title: 'Kukur Tihar with Stubby',
      description:
          'We put a marigold garland and red tika on Stubby and worshipped her, '
          'the way Kirat families honour their dogs. She sat so proudly with her '
          'flowers. Our first, bravest, most loving friend. 🌈',
      date: DateTime(2019, 10, 27),
      mood: Mood.loved,
      category: MemoryCategory.festivals,
      location: 'Our home, Ilam',
      tags: const ['tihar', 'stubby', 'pets', 'festival'],
      isFavorite: true,
      photoCount: 6,
      hasVoice: false,
      colorSeed: 6,
    ),
  ];

  // ── Letters ────────────────────────────────────────────────────────────
  static final List<Letter> letters = [
    Letter(
      id: 'l1',
      title: 'When You\'re Sad',
      body:
          'Hey Dipisha,\n\nWhenever you feel sad, remember that you are braver '
          'than you believe, stronger than you seem, and smarter than you '
          'think. Sad days are just clouds passing over your sunshine — they '
          'never stay forever.\n\nClose your eyes, take a deep breath, and '
          'imagine me giving you the biggest hug. I\'m always with you, even '
          'when I\'m far away.\n\nLove you always,\nDiksha 💜',
      category: LetterCategory.whenSad,
      mood: Mood.loved,
      dateWritten: DateTime(2026, 6, 5),
      isFavorite: true,
      colorSeed: 0,
    ),
    Letter(
      id: 'l2',
      title: 'When You\'re Happy',
      body:
          'My darling Dipu,\n\nIf you\'re reading this on a happy day — good! '
          'Dance a little. Twirl in the kitchen. Laugh so hard your tummy '
          'hurts. Your happiness is my happiness.\n\nSave this feeling. On '
          'harder days, remember it was always inside you.\n\nKeep smiling '
          'always,\nDiksha ☀️',
      category: LetterCategory.whenHappy,
      mood: Mood.happy,
      dateWritten: DateTime(2026, 5, 20),
      colorSeed: 3,
    ),
    Letter(
      id: 'l3',
      title: 'On Your Exam Day',
      body:
          'Dear Dipisha,\n\nToday you might feel a few butterflies — that just '
          'means you care. You\'ve prepared, you\'re ready, and one exam can '
          'never measure how wonderful you are.\n\nBreathe. Read slowly. Do '
          'your best and let the rest go.\n\nProud of you already,\nDiksha 📚',
      category: LetterCategory.examDay,
      mood: Mood.calm,
      dateWritten: DateTime(2026, 3, 11),
      colorSeed: 2,
    ),
    Letter(
      id: 'l4',
      title: 'Happy Dashain, Little One',
      body:
          'Sweetheart,\n\nMay this Dashain fill your little heart with as much '
          'joy as you bring to mine. Wear your brightest smile with your '
          'brightest dress.\n\nMay the goddess bless you with courage, health '
          'and endless giggles.\n\nWith all my love,\nDiksha 🪔',
      category: LetterCategory.dashain,
      mood: Mood.grateful,
      dateWritten: DateTime(2025, 9, 28),
      colorSeed: 5,
    ),
    Letter(
      id: 'l5',
      title: 'For When You\'re Scared',
      body:
          'Dipu,\n\nBeing scared is okay. Even the bravest people feel it. '
          'When the dark feels too big, remember: you are never, ever alone. '
          'I am only a memory away.\n\nHold this letter tight and feel me '
          'holding you.\n\nForever your safe place,\nDiksha 🫂',
      category: LetterCategory.whenScared,
      mood: Mood.loved,
      dateWritten: DateTime(2026, 2, 2),
      colorSeed: 6,
    ),
  ];

  // ── Voice messages ───────────────────────────────────────────────────────
  static final List<VoiceMessage> voices = [
    VoiceMessage(
      id: 'v1',
      title: 'Good morning, sleepyhead',
      category: 'Morning',
      durationSeconds: 42,
      date: DateTime(2026, 6, 20),
      isFavorite: true,
      colorSeed: 0,
    ),
    VoiceMessage(
      id: 'v2',
      title: 'Your favourite bedtime story',
      category: 'Bedtime',
      durationSeconds: 214,
      date: DateTime(2026, 6, 10),
      colorSeed: 6,
    ),
    VoiceMessage(
      id: 'v3',
      title: 'A little pep talk',
      category: 'Encouragement',
      durationSeconds: 78,
      date: DateTime(2026, 5, 30),
      isFavorite: true,
      colorSeed: 2,
    ),
    VoiceMessage(
      id: 'v4',
      title: 'Our silly song',
      category: 'Fun',
      durationSeconds: 63,
      date: DateTime(2026, 5, 12),
      colorSeed: 3,
    ),
    VoiceMessage(
      id: 'v5',
      title: 'Happy birthday, my love',
      category: 'Birthday',
      durationSeconds: 55,
      date: DateTime(2025, 6, 28),
      colorSeed: 1,
    ),
  ];

  // ── Surprise box ─────────────────────────────────────────────────────────
  // No demonstration gifts ship as family history. Diksha will add each real
  // message and its real unlock rule when she has written it.
  static final List<Surprise> surprises = [];

  // ── Timeline ─────────────────────────────────────────────────────────────
  static final List<TimelineEvent> timeline = [
    TimelineEvent(
      id: 't1',
      title: 'Sunrise at Shree Antu',
      description: 'We watched the sun rise over the tea hills 🌄',
      date: DateTime(2022, 11, 20),
      emoji: '🌄',
      colorSeed: 7,
    ),
    TimelineEvent(
      id: 't2',
      title: 'Won Drawing Competition',
      description: 'You got 1st prize! 🏆',
      date: DateTime(2026, 5, 18),
      emoji: '🎨',
      colorSeed: 3,
    ),
    TimelineEvent(
      id: 't3',
      title: "Diksha's Graduation",
      description: 'Diksha finished her BSc (Hons) IT degree 🎓',
      date: DateTime(2026, 2, 1),
      emoji: '🎓',
      colorSeed: 2,
    ),
    TimelineEvent(
      id: 't4',
      title: 'Dipisha\'s Birthday',
      description: 'A beautiful celebration in our village home. 🎂',
      date: DateTime(2025, 6, 28),
      emoji: '🎂',
      colorSeed: 1,
    ),
    TimelineEvent(
      id: 't5',
      title: 'Started Dance Class',
      description: 'You were so excited! 💃',
      date: DateTime(2024, 9, 5),
      emoji: '💃',
      colorSeed: 6,
    ),
    TimelineEvent(
      id: 't6',
      title: 'Learned to Cycle',
      description: 'No more training wheels! 🚲',
      date: DateTime(2024, 3, 9),
      emoji: '🚲',
      colorSeed: 4,
    ),
    TimelineEvent(
      id: 't7',
      title: 'Lost Your First Tooth',
      description: 'The tooth fairy paid a visit. 🦷',
      date: DateTime(2022, 11, 20),
      emoji: '🦷',
      colorSeed: 5,
    ),
    TimelineEvent(
      id: 't8',
      title: 'First Day of School',
      description: 'The bravest little person. 🎒',
      date: DateTime(2021, 4, 15),
      emoji: '🎒',
      colorSeed: 0,
    ),
  ];

  // ── Albums & photos ──────────────────────────────────────────────────────
  // A big gallery: each album's photos are drop-in asset slots named
  // `assets/images/albums/<id>_<n>.jpg` (n from 1). The cover is
  // `assets/images/albums/<id>.jpg`. Missing files show soft placeholders, so
  // all ~1000 slots below are ready to fill just by dropping named files in.
  static final List<Album> albums = [
    // Every photo we have, all in one place 🌿
    Album(
      id: 'all_photos',
      name: 'All Photos 🌿',
      date: DateTime(2026, 7, 13),
      photoCount: 0,
      colorSeed: 1,
    ),
    Album(
      id: 'family_together',
      name: 'Family Together',
      date: DateTime(2026, 9, 9),
      photoCount: 0,
      colorSeed: 2,
    ),
    Album(
      id: 'tea_gardens',
      name: 'Tea Gardens 🍵',
      date: DateTime(2025, 5, 2),
      photoCount: 60,
      colorSeed: 3,
    ),
    Album(
      id: 'hills_nature',
      name: 'Hills & Nature',
      date: DateTime(2025, 3, 18),
      photoCount: 60,
      colorSeed: 6,
    ),
    // People
    Album(
      id: 'dipisha',
      name: 'Little Dipisha',
      date: DateTime(2024, 8, 1),
      photoCount: 80,
      colorSeed: 1,
    ),
    Album(
      id: 'diya',
      name: 'Diya',
      date: DateTime(2024, 7, 15),
      photoCount: 50,
      colorSeed: 6,
    ),
    Album(
      id: 'diksha',
      name: 'Diksha (Diksha)',
      date: DateTime(2024, 6, 20),
      photoCount: 50,
      colorSeed: 0,
    ),
    Album(
      id: 'parents',
      name: 'Mummy & Papa',
      date: DateTime(2023, 12, 5),
      photoCount: 40,
      colorSeed: 2,
    ),
    Album(
      id: 'kopa',
      name: "Kopa's Blessings",
      date: DateTime(2023, 10, 1),
      photoCount: 30,
      colorSeed: 5,
    ),
    Album(
      id: 'pets',
      name: 'Arjun, Meow & Stubby',
      date: DateTime(2025, 1, 12),
      photoCount: 40,
      colorSeed: 7,
    ),
    // Festivals
    Album(
      id: 'dashain2025',
      name: 'Dashain 2025',
      date: DateTime(2025, 10, 3),
      photoCount: 60,
      colorSeed: 5,
    ),
    Album(
      id: 'tihar2025',
      name: 'Tihar & Deusi Bhailo',
      date: DateTime(2025, 11, 1),
      photoCount: 60,
      colorSeed: 1,
    ),
    Album(
      id: 'festivals',
      name: 'Festivals & Pujas',
      date: DateTime(2025, 2, 14),
      photoCount: 50,
      colorSeed: 3,
    ),
    // Birthdays & school
    Album(
      id: 'birthday9',
      name: "Dipisha's Birthdays 🎂",
      date: DateTime(2025, 6, 28),
      photoCount: 40,
      colorSeed: 1,
    ),
    Album(
      id: 'birthday10',
      name: 'Cakes & Candles',
      date: DateTime(2024, 6, 28),
      photoCount: 40,
      colorSeed: 0,
    ),
    Album(
      id: 'school',
      name: 'School Days',
      date: DateTime(2025, 3, 1),
      photoCount: 50,
      colorSeed: 6,
    ),
    Album(
      id: "graduation",
      name: "Diksha's Graduation 🎓",
      date: DateTime(2026, 2, 1),
      photoCount: 25,
      colorSeed: 2,
    ),
    // Places we've been
    Album(
      id: 'shree_antu',
      name: 'Shree Antu 🌄',
      date: DateTime(2022, 11, 20),
      photoCount: 30,
      colorSeed: 4,
    ),
    Album(
      id: 'ranke',
      name: 'Ranke — Mamaghar',
      date: DateTime(2021, 10, 1),
      photoCount: 30,
      colorSeed: 3,
    ),
    Album(
      id: 'lumbini',
      name: 'Lumbini Tour',
      date: DateTime(2015, 3, 12),
      photoCount: 15,
      colorSeed: 2,
    ),
    Album(
      id: 'kathmandu',
      name: 'Kathmandu Days',
      date: DateTime(2024, 8, 1),
      photoCount: 40,
      colorSeed: 7,
    ),
    // Everyday & seasons
    Album(
      id: 'everyday',
      name: 'Everyday Magic',
      date: DateTime(2026, 6, 2),
      photoCount: 80,
      colorSeed: 0,
    ),
    Album(
      id: 'winter',
      name: 'Winter & Snow ❄️',
      date: DateTime(2025, 12, 20),
      photoCount: 30,
      colorSeed: 4,
    ),
  ];

  static List<Photo> photosFor(String albumId) {
    final album = albums.firstWhere((a) => a.id == albumId);
    return List.generate(
      album.photoCount,
      (i) => Photo(
        id: '$albumId-p$i',
        albumId: albumId,
        caption: '${album.name} · moment ${i + 1}',
        date: album.date.subtract(Duration(hours: i)),
        colorSeed: (album.colorSeed + i) % 8,
      ),
    );
  }

  static List<Photo> get allPhotos =>
      albums.expand((a) => photosFor(a.id)).toList();

  // ── Videos ───────────────────────────────────────────────────────────────
  static final List<VideoItem> videos = [
    VideoItem(
      id: 'vid1',
      title: 'Sunrise at Shree Antu',
      durationSeconds: 47,
      date: DateTime(2022, 11, 20),
      category: 'Trips',
      colorSeed: 2,
    ),
    VideoItem(
      id: 'vid2',
      title: 'Blowing the candles',
      durationSeconds: 33,
      date: DateTime(2025, 7, 18),
      category: 'Birthday',
      colorSeed: 1,
    ),
    VideoItem(
      id: 'vid3',
      title: 'Dance recital',
      durationSeconds: 128,
      date: DateTime(2026, 2, 14),
      category: 'Moments',
      colorSeed: 6,
    ),
    VideoItem(
      id: 'vid4',
      title: 'First bicycle ride',
      durationSeconds: 62,
      date: DateTime(2024, 3, 9),
      category: 'Milestones',
      colorSeed: 4,
    ),
    VideoItem(
      id: 'vid5',
      title: 'Singing our silly song',
      durationSeconds: 54,
      date: DateTime(2026, 5, 12),
      category: 'Fun',
      colorSeed: 3,
    ),
  ];

  // ── Notifications ────────────────────────────────────────────────────────
  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'A new memory was added 🌸',
      body: '"Sunrise at Shree Antu" is waiting for you.',
      date: DateTime(2026, 7, 11, 9, 20),
      type: NotificationType.memory,
    ),
    AppNotification(
      id: 'n2',
      title: 'A surprise is almost ready 🎁',
      body: 'Something special unlocks on your birthday!',
      date: DateTime(2026, 7, 10, 18, 5),
      type: NotificationType.surprise,
    ),
    AppNotification(
      id: 'n3',
      title: 'New letter from Diksha 💌',
      body: '"When You\'re Sad" — read it whenever you need a hug.',
      date: DateTime(2026, 7, 8, 12, 0),
      type: NotificationType.letter,
      isRead: true,
    ),
    AppNotification(
      id: 'n4',
      title: 'Your birthday is coming! 🎂',
      body: 'Only a few days until your special day.',
      date: DateTime(2026, 7, 7, 8, 0),
      type: NotificationType.birthday,
      isRead: true,
    ),
  ];

  // ── Our Story (book chapters) ────────────────────────────────────────────
  static const List<StoryChapter> story = [
    StoryChapter(
      year: 'Once upon a time',
      title: 'Where it all began',
      body:
          'In a small home tucked into the hills, a family began — built not '
          'from bricks, but from laughter, warm daal-bhat, and the endless '
          'love of a grandfather whose stories could fill the whole sky.',
      emoji: '🏔️',
      colorSeed: 3,
    ),
    StoryChapter(
      year: 'Then came love',
      title: 'Rup Raj & Sanchu',
      body:
          'Two hearts found each other and decided to build a lifetime '
          'together. He was the steady mountain; she was the river that gave '
          'it life. Together they made a home that always had room for one '
          'more plate at the table.',
      emoji: '💞',
      colorSeed: 2,
    ),
    StoryChapter(
      year: '2005 · चैत १३, २०६१',
      title: 'The first little star — Diksha',
      body:
          'Their first daughter arrived and turned their world upside down in '
          'the best way. Curious, kind, and always the one holding the '
          'camera — she would one day build this very home you\'re reading.',
      emoji: '🌟',
      colorSeed: 0,
    ),
    StoryChapter(
      year: '2006 · साउन २१, २०६३',
      title: 'Along came Diya',
      body:
          'A second daughter, full of mischief and music. The house grew '
          'louder, the games grew wilder, and there was always someone to '
          'share secrets and pillow forts with.',
      emoji: '🎈',
      colorSeed: 6,
    ),
    StoryChapter(
      year: '2018 · असार १४, २०७५',
      title: 'Our littlest star — Dipisha',
      body:
          'On a warm Asar day, in the middle of the monsoon green, the youngest '
          'arrived and the family felt complete. Tiny hands, giant giggles, and a '
          'heart big enough to name a stray puppy "Prime Minister". The house has '
          'never stopped sparkling since.',
      emoji: '✨',
      colorSeed: 1,
    ),
    StoryChapter(
      year: 'And the family grew paws',
      title: 'Stubby, Arjun & Meow',
      body:
          'No Rai story is complete without fur. Stubby watched the girls '
          'grow up and left her brave son Arjun to guard the home. And Meow? '
          'Meow simply decided she owned all of us — and she was right.',
      emoji: '🐾',
      colorSeed: 5,
    ),
    StoryChapter(
      year: 'Our hills',
      title: 'Growing up in Ilam',
      body:
          'Home was the green hills of Ilam — tea gardens rolling into the mist, '
          'terraced fields of maize and millet, and mornings that smelled of '
          'woodsmoke and wet earth. As Kirat, we grew up loving the land itself: '
          'the forests, the rivers, the sky — Sumnima and Paruhang all around us.',
      emoji: '🍵',
      colorSeed: 5,
    ),
    StoryChapter(
      year: 'Mummy\'s mornings',
      title: 'Maize, kholo & the chulo fire',
      body:
          'Mummy woke before the sun. She ground maize on the jaato into flour '
          'and cooked warm kholo for the cow, while I helped light the chulo — '
          'aago balna — blowing at the little flame until it caught. Small hands, '
          'small chores, endless love. Those quiet mornings made us who we are.',
      emoji: '🔥',
      colorSeed: 3,
    ),
    StoryChapter(
      year: 'Papa\'s sacrifice',
      title: 'He went far, so we could go far',
      body:
          'When we were still little, Papa left for a foreign land to work — not '
          'because he wanted to be away, but so his daughters could study and '
          'chase their dreams. He gave up years of being with us, his own comfort '
          'and togetherness, for our tomorrow. We love and respect him beyond '
          'words. And Mummy held our whole home together while he was gone. 💜',
      emoji: '✈️',
      colorSeed: 2,
    ),
    StoryChapter(
      year: 'Kukur Tihar',
      title: 'Stubby, our first love',
      body:
          'Every Tihar we worshipped our dogs — tika on the forehead, a bright '
          'marigold garland around the neck. Stubby wore hers so proudly. She '
          'watched us grow, guarded our home, and loved us fiercely. Some paw '
          'prints never fade. 🌈',
      emoji: '🐾',
      colorSeed: 6,
    ),
    StoryChapter(
      year: 'Today',
      title: 'Still writing our story',
      body:
          'Every trip, every festival, every ordinary Tuesday adds another '
          'page. This home is where we keep them all — so that one day, we '
          'can sit together and remember exactly how loved we were.',
      emoji: '📖',
      colorSeed: 4,
    ),
  ];

  // ── Places ───────────────────────────────────────────────────────────────
  static const List<Place> places = [
    Place(
      id: 'pl1',
      name: 'Mangalbare, Ilam',
      region: 'Eastern Nepal · Home',
      story:
          'Our home in the hills of Ilam — tea gardens rolling into the mist, '
          'terraced fields, and the house where our whole story began.',
      year: 2000,
      emoji: '🏡',
      colorSeed: 5,
      photoCount: 40,
    ),
    Place(
      id: 'pl2',
      name: 'Shree Antu',
      region: 'Ilam',
      story:
          'The famous sunrise viewpoint — a whole sea of tea gardens and clouds '
          'below, and the Himalaya glowing gold at dawn.',
      year: 2022,
      emoji: '🌄',
      colorSeed: 4,
      photoCount: 20,
    ),
    Place(
      id: 'pl3',
      name: 'Ranke',
      region: 'Ilam · Mamaghar',
      story:
          'Mamaghar — where the holidays were warmest: cousins, maize fields, '
          'and endless love from the family home.',
      year: 2021,
      emoji: '💚',
      colorSeed: 3,
      photoCount: 18,
    ),
    Place(
      id: 'pl4',
      name: 'Lumbini',
      region: 'Rupandehi',
      story:
          'The birthplace of the Buddha. Diksha went here on her class-10 school '
          'tour — her trip alone, with her classmates, not the family\'s. A long '
          'bus ride and a calm, sacred garden she never forgot.',
      year: 2015,
      emoji: '☸️',
      colorSeed: 2,
      photoCount: 15,
    ),
    Place(
      id: 'pl5',
      name: 'Kathmandu',
      region: 'Our life now',
      story:
          'The city where Diksha & Diya live in a little rented room — studying, '
          'working, chasing dreams, and missing the hills of home.',
      year: 2024,
      emoji: '🏙️',
      colorSeed: 7,
      photoCount: 25,
    ),
  ];

  // ── Dipisha's World: achievements ────────────────────────────────────────
  // Achievements need a real event and a confirmed date from Diksha.
  static final List<Achievement> achievements = [];

  // ── Dipisha's World: dream board ─────────────────────────────────────────
  // A dream belongs to Dipisha only after she has said it herself.
  static const List<DreamItem> dreams = [];

  // ── Dipisha's World: future messages ─────────────────────────────────────
  // A sealed message exists only after Diksha has actually written it.
  static const List<FutureMessage> futureMessages = [];
}
