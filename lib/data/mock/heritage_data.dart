import '../../core/router/app_routes.dart';
import '../models/heritage_models.dart';

/// The family's heritage record.
///
/// ⚠️ THE RULE FOR THIS FILE — read before adding anything ⚠️
/// ---------------------------------------------------------
/// Only put something here if a **person actually told us**. This file is the
/// one place in the app where a plausible guess does real damage: a made-up Rai
/// word or an invented "tradition" would be indistinguishable from a true one
/// in ten years, and would quietly replace the real thing.
///
/// The Rai are not one people with one language — Bantawa, Chamling, Kulung and
/// two dozen others sit under that surname, and their words differ. So the only
/// Kirat vocabulary seeded below is the Mundhum/Sakela vocabulary this app
/// already uses on the Sakela Than screen. **Everyday words in the family's own
/// dialect are deliberately absent** — they are listed as things to collect
/// from Kopa and Mummy instead.
///
/// Same rule for the food: we know which dishes matter and why. Nobody has
/// written down how Mummy actually makes them. So the stories are here and the
/// methods are empty and labelled, exactly like the unconfirmed birthdays.
abstract final class HeritageData {
  HeritageData._();

  // ── Words ────────────────────────────────────────────────────────────────

  static const words = <HeritageWord>[
    // Kirat — the vocabulary already used elsewhere in this app.
    HeritageWord(
      id: 'w_sewa',
      word: 'सेवा',
      roman: 'Sewa',
      meaning: 'Our greeting. Hello, and respect, in one word.',
      kind: WordKind.kirat,
      note: 'We are Rai, so we say Sewa. Sewaro is Limbu — close neighbours, '
          'different people. Getting this right matters to us.',
      saidBy: 'All of us',
      colorSeed: 1,
    ),
    HeritageWord(
      id: 'w_mundhum',
      word: 'मुन्धुम',
      roman: 'Mundhum',
      meaning: 'Our scripture — history, law and prayer together.',
      kind: WordKind.kirat,
      note: 'It was never written down. It lives in the memory of the people '
          'who can recite it, which is why writing any of this down matters.',
      colorSeed: 2,
    ),
    HeritageWord(
      id: 'w_sakela',
      word: 'साकेला',
      roman: 'Sakela',
      meaning: 'Our festival, and the ground we dance it on.',
      kind: WordKind.kirat,
      note: 'Also said Sakewa.',
      colorSeed: 3,
    ),
    HeritageWord(
      id: 'w_sili',
      word: 'सिली',
      roman: 'Sili',
      meaning: 'The steps of the Sakela dance.',
      kind: WordKind.kirat,
      note: 'Each sili copies something from the natural world — a bird, the '
          'plough, the work of the season. The dance is a description of how '
          'to live in these hills.',
      colorSeed: 4,
    ),
    HeritageWord(
      id: 'w_ubhauli',
      word: 'उभौली',
      roman: 'Ubhauli',
      meaning: 'Upward. Spring — when we climb with the warmth.',
      kind: WordKind.kirat,
      note: 'Danced before planting, asking the earth for a good year.',
      colorSeed: 5,
    ),
    HeritageWord(
      id: 'w_udhauli',
      word: 'उधौली',
      roman: 'Udhauli',
      meaning: 'Downward. Autumn — when we come down with the cold.',
      kind: WordKind.kirat,
      note: 'Danced after the harvest, to say thank you.',
      colorSeed: 6,
    ),
    HeritageWord(
      id: 'w_than',
      word: 'थान',
      roman: 'Than',
      meaning: 'The sacred place. Stones set under a tree.',
      kind: WordKind.kirat,
      note: 'Not a temple and not a building — a clearing. We worship the '
          'earth and the sky, so the altar is outside, in both.',
      colorSeed: 7,
    ),
    HeritageWord(
      id: 'w_sumnima',
      word: 'सुम्निमा',
      roman: 'Sumnima',
      meaning: 'Earth mother.',
      kind: WordKind.kirat,
      colorSeed: 8,
    ),
    HeritageWord(
      id: 'w_paruhang',
      word: 'पारुहाङ',
      roman: 'Paruhang',
      meaning: 'Sky father.',
      kind: WordKind.kirat,
      colorSeed: 9,
    ),

    // The words of this particular house — the everyday Nepali that means
    // something specific here.
    HeritageWord(
      id: 'w_jaato',
      word: 'जाँतो',
      roman: 'Jaato',
      meaning: 'The stone hand-mill for grinding maize into flour.',
      kind: WordKind.nepali,
      note: 'Mummy at the jaato, early, before anyone else is properly awake — '
          'that sound is what morning means in this house.',
      saidBy: 'Mummy',
      colorSeed: 2,
    ),
    HeritageWord(
      id: 'w_chulo',
      word: 'चुलो',
      roman: 'Chulo',
      meaning: 'The hearth. The fire you cook on.',
      kind: WordKind.nepali,
      note: 'आगो बाल्नु — aago balnu, to light the fire. A child\'s job, and '
          'the first useful thing any of us learned to do.',
      colorSeed: 4,
    ),
    HeritageWord(
      id: 'w_kholo',
      word: 'कोलो',
      roman: 'Kholo',
      meaning: 'The warm mash cooked for the cow.',
      kind: WordKind.nepali,
      note: 'Also said koley. Cooked every day, without fail, before anyone '
          'sits down to their own food.',
      saidBy: 'Mummy',
      colorSeed: 6,
    ),
    HeritageWord(
      id: 'w_aagan',
      word: 'आँगन',
      roman: 'Aagan',
      meaning: 'The courtyard in front of the house.',
      kind: WordKind.nepali,
      note: 'Where the pots are, where the studying happened, where everything '
          'in this family that wasn\'t sleeping or cooking took place.',
      colorSeed: 1,
    ),
    HeritageWord(
      id: 'w_goth',
      word: 'गोठ',
      roman: 'Goth',
      meaning: 'The cattle shed.',
      kind: WordKind.nepali,
      colorSeed: 8,
    ),
    HeritageWord(
      id: 'w_sisnu',
      word: 'सिस्नु',
      roman: 'Sisnu',
      meaning: 'Nettle. It stings on the way in and is wonderful on the way '
          'out.',
      kind: WordKind.nepali,
      note: 'Dipisha\'s favourite. A hill food — free, everywhere, and better '
          'than most things people pay for.',
      colorSeed: 3,
    ),
    HeritageWord(
      id: 'w_gundri',
      word: 'गुन्द्री',
      roman: 'Gundri',
      meaning: 'The woven straw mat you sit or lie on.',
      kind: WordKind.nepali,
      note: 'Diya reads on hers in the aagan.',
      colorSeed: 5,
    ),

    // Ours — real sentences, said by real people in this family.
    HeritageWord(
      id: 'w_lau_pani',
      word: 'कान्छा, लौ पानी',
      roman: 'Kanxa, lau pani',
      meaning: 'Kanxa, here — drink some water.',
      kind: WordKind.ours,
      note: 'Mummy, carrying water out to Papa in the field. She has said this '
          'more times than anyone could count.',
      saidBy: 'Mummy, to Papa',
      colorSeed: 7,
    ),
    HeritageWord(
      id: 'w_hera_phul',
      word: 'दिदी, हेर यो फूल',
      roman: 'Didi, hera yo phul',
      meaning: 'Didi, look at this flower.',
      kind: WordKind.ours,
      note: 'Diya, from the gundri in the aagan, interrupting Diksha\'s '
          'studying for the hundredth time. 🌸',
      saidBy: 'Diya, to Diksha',
      colorSeed: 9,
    ),
  ];

  /// Words we know exist but haven't collected. This list is the point of the
  /// screen as much as the words above are.
  static const wordsToCollect = <Collectable>[
    Collectable(
      what: 'Our own Rai words — for water, rice, mother, father, come, go.',
      askWho: 'Kopa',
      why: 'Rai is not one language. Bantawa, Chamling, Kulung and many more '
          'sit under our surname, and only the people who grew up speaking '
          'ours know which is which. Nothing here is guessed, so this space '
          'stays empty until he says them.',
      urgent: true,
    ),
    Collectable(
      what: 'How Kopa counts to ten.',
      askWho: 'Kopa',
      why: 'Numbers are usually the last thing a language keeps and the first '
          'thing worth recording.',
      urgent: true,
    ),
    Collectable(
      what: 'The names of the months and seasons as the old people said them.',
      askWho: 'Kopa or Mummy',
      urgent: true,
    ),
    Collectable(
      what: 'What our clan (thar) is, and what it means.',
      askWho: 'Papa',
    ),
    Collectable(
      what: 'The things Papa always says on the phone from Malaysia.',
      askWho: 'Anyone — just write them down next time',
    ),
  ];

  // ── Recipes ──────────────────────────────────────────────────────────────

  static const recipes = <Recipe>[
    Recipe(
      id: 'r_sisnu',
      name: 'सिस्नुको तरकारी',
      english: 'Sisnu ko tarkari · nettle curry',
      emoji: '🌿',
      story: 'Dipisha\'s favourite thing to eat. Nettle grows wild on every '
          'bank and edge in Ilam — you cut it with gloves, and it stops '
          'stinging the moment it meets heat. A food that costs nothing and '
          'tastes like home.',
      taughtBy: 'Mummy',
      colorSeed: 3,
      missing: Collectable(
        what: 'How Mummy actually makes it — what goes in, and in what order.',
        askWho: 'Mummy',
        why: 'Everyone in this family can taste this dish from memory and not '
            'one of us could write it down.',
      ),
    ),
    // Confirmed by Diksha, 2026-08-05: this family makes sel roti at Tihar.
    // Recorded here on that word alone — the method still isn't written down.
    Recipe(
      id: 'r_selroti',
      name: 'सेलरोटी',
      english: 'Sel roti',
      emoji: '🍩',
      story: 'We make sel roti at Tihar. It is poured by hand into the hot '
          'oil in one ring — the shape comes out of somebody\'s wrist rather '
          'than out of a mould, which is why no two families\' sel roti ever '
          'look quite the same.',
      taughtBy: 'Mummy',
      colorSeed: 9,
      missing: Collectable(
        what: 'What goes into Mummy\'s batter, and how she knows when it is '
            'ready to pour.',
        askWho: 'Mummy',
        why: 'This is the one that has to be watched rather than read. Film '
            'her hands at Tihar.',
      ),
    ),
    Recipe(
      id: 'r_dal',
      name: 'दाल',
      english: 'Dal',
      emoji: '🍚',
      story: 'The everyday one. Eaten more times than any other food in this '
          'house, which is exactly why nobody ever thought to write it down.',
      taughtBy: 'Mummy',
      colorSeed: 1,
      missing: Collectable(
        what: 'Mummy\'s dal — the jhaneko, the timing, what she puts in that '
            'other people don\'t.',
        askWho: 'Mummy',
      ),
    ),
    Recipe(
      id: 'r_kholo',
      name: 'कोलो',
      english: 'Kholo · the cow\'s warm mash',
      emoji: '🐄',
      story: 'Not for us — for the cow, cooked every single day before anyone '
          'in the house sat down to their own food. It belongs in a book of '
          'this family\'s cooking as much as anything we ate ourselves.',
      taughtBy: 'Mummy',
      colorSeed: 6,
      missing: Collectable(
        what: 'What actually goes into the kholo, and how much.',
        askWho: 'Mummy',
      ),
    ),
  ];

  static const recipesToCollect = <Collectable>[
    Collectable(
      what: 'What we cook at Dashain. (Tihar we know: sel roti.)',
      askWho: 'Mummy',
      why: 'Festival food is the most specific thing a family has and the '
          'easiest to lose when the people who cook it stop cooking.',
    ),
    Collectable(
      what: 'Anything Kopa knows how to make that nobody else does.',
      askWho: 'Kopa',
      urgent: true,
    ),
    Collectable(
      what: 'A photo of any recipe written in Mummy\'s own hand.',
      askWho: 'Mummy',
      why: 'The handwriting is half the heirloom.',
    ),
  ];

  // ── Traditions ───────────────────────────────────────────────────────────

  static const traditions = <Tradition>[
    Tradition(
      id: 't_sakela',
      name: 'Sakela · साकेला',
      when: 'Ubhauli in spring · Udhauli in autumn',
      what: 'We gather at the than, and dance the sili in a ring around the '
          'stones — to the dhol and the jhyamta, following the person in '
          'front.',
      why: 'We are Kirat. We do not worship in a building; we worship the '
          'earth that feeds us and the sky that waters it — Sumnima and '
          'Paruhang. Ubhauli asks for a good planting, Udhauli says thank you '
          'for the harvest. It is a farming people\'s calendar turned into a '
          'dance.',
      ours: 'Ours is the than under the big tree, with the upright stones and '
          'the two bamboo poles.',
      emoji: '🥁',
      route: Routes.sakela,
      colorSeed: 4,
    ),
    Tradition(
      id: 't_tihar',
      name: 'Tihar · तिहार',
      when: 'Autumn, after Dashain',
      what: 'Five days of lights. Marigolds strung into malas, diyo along '
          'every ledge, and a day given to each of the animals before the '
          'people get theirs.',
      why: 'It is the one festival that formally thanks the animals for the '
          'year — which, in a house with a cow, hens, a pig and three dogs '
          'and cats, is most of the household.',
      ours: 'We make sel roti. And on Kukur Tihar we make marigold malas for '
          'Stubby and Arjun and put tika on them — Stubby got hers every year '
          'she was here, and we have never once skipped Arjun.',
      emoji: '🪔',
      colorSeed: 9,
      missing: Collectable(
        what: 'Besides the sel roti — who comes, and what the aagan looks '
            'like on the night of Laxmi Puja.',
        askWho: 'Mummy',
      ),
    ),
    Tradition(
      id: 't_dashain',
      name: 'Dashain · दशैं',
      when: 'Autumn — the long one',
      what: 'The biggest festival of the year, and the one that pulls people '
          'home from wherever they have gone.',
      why: 'For a family split between Ilam, Kathmandu and Malaysia, Dashain '
          'is less about the rituals than about who manages to be in the same '
          'room. That is worth recording on its own.',
      emoji: '🌾',
      colorSeed: 7,
      missing: Collectable(
        what: 'How our family keeps Dashain — who gives tika to whom, where we '
            'go, what is different about ours.',
        askWho: 'Mummy and Papa',
        why: 'Every family does this differently, and only ours knows ours.',
      ),
    ),
    Tradition(
      id: 't_chulo',
      name: 'Lighting the chulo',
      when: 'Every single morning',
      what: 'The fire gets lit before anything else happens. Then the kholo '
          'for the cow. Then the people eat.',
      why: 'Not a festival — a rhythm. It is the thing this family has done '
          'more often than anything else in its history, and the kind of '
          'detail that vanishes precisely because nobody thinks it counts.',
      ours: 'Lighting it was a child\'s job. All three girls learned on that '
          'same hearth.',
      emoji: '🔥',
      colorSeed: 2,
    ),
    Tradition(
      id: 't_birthdays',
      name: 'Birthdays',
      when: 'Across the year',
      what: 'The family keeps birthdays in Bikram Sambat, and works out the '
          'English date afterwards.',
      why: 'Because that is how the people who gave us the dates think about '
          'them. The app converts, but it never guesses.',
      emoji: '🎂',
      route: Routes.hall,
      colorSeed: 5,
      missing: Collectable(
        what: 'Mummy\'s, Papa\'s and Kopa\'s birth dates in BS.',
        askWho: 'Mummy, Papa and Kopa',
        why: 'Three of the six people at our table still have no date. Nothing '
            'in this app will ever invent one.',
        urgent: true,
      ),
    ),
  ];

  // ── Where we come from ───────────────────────────────────────────────────

  static const roots = <RootStep>[
    RootStep(
      id: 'rt_ilam',
      place: 'Mangalbare, Ilam',
      region: 'Eastern Nepal',
      period: 'Home. Always.',
      story: 'Mud, stone and wood, two floors under a tin roof, with the goth '
          'below and the aagan in front. Tea gardens on the hills around it '
          'and mist that comes up the valley most afternoons. Everything else '
          'on this page is measured from here.',
      who: 'Mummy and Dipisha',
      emoji: '🏡',
      isHome: true,
      colorSeed: 3,
    ),
    RootStep(
      id: 'rt_ranke',
      place: 'Ranke',
      region: 'Ilam · Mamaghar',
      period: 'Mummy\'s side',
      story: 'The mother\'s house — where Mummy comes from, and where her '
          'daughters went as children the way all children go to their '
          'mamaghar: for a few weeks, and with total authority.',
      emoji: '🌾',
      colorSeed: 5,
    ),
    RootStep(
      id: 'rt_malaysia',
      place: 'Malaysia',
      region: 'Foreign employment',
      period: 'Since Diksha was in class 4 or 5',
      story: 'Papa left when the girls were small, so that there would be '
          'school fees. He has been away for most of the years since. This is '
          'the single decision that shaped everything else in this family — '
          'and it was made quietly, by someone who then had to live with it '
          'alone.',
      who: 'Papa (Rup Raj)',
      emoji: '✈️',
      colorSeed: 8,
    ),
    RootStep(
      id: 'rt_ktm',
      place: 'Kathmandu',
      region: 'The city, for study and work',
      period: 'Now',
      story: 'One small rented room, two sisters. Diksha finished a BSc '
          '(Hons) in IT and works as a developer; Diya is in BBS second year. '
          'This is what the years in Malaysia bought — and this app was '
          'written in that room, by the eldest of the three, for the '
          'youngest.',
      who: 'Diksha and Diya',
      emoji: '🏙️',
      colorSeed: 1,
    ),
  ];

  static const rootsToCollect = <Collectable>[
    Collectable(
      what: 'Where the family lived before Mangalbare, and who moved first.',
      askWho: 'Kopa',
      why: 'Kopa is the last person who would remember the move before this '
          'one. After him it is gone.',
      urgent: true,
    ),
    Collectable(
      what: 'The names of Kopa\'s parents, and theirs if he knows them.',
      askWho: 'Kopa',
      urgent: true,
    ),
    Collectable(
      what: 'What Papa\'s first year in Malaysia was actually like.',
      askWho: 'Papa',
      why: 'He has never really been asked. He would probably tell Dipisha.',
    ),
  ];
}
