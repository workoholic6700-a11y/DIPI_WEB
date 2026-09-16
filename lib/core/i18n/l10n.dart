import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n_content.dart';

/// The two languages the app speaks. English is the default; Nepali (नेपाली) is
/// there so Mummy, Papa and anyone who reads Devanagari can enjoy the app too.
enum AppLang { en, ne }

/// App-wide, persisted language choice.
class LangNotifier extends Notifier<AppLang> {
  static const _key = 'app_lang';

  @override
  AppLang build() {
    _restore();
    return AppLang.en;
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    if (p.getString(_key) == 'ne') state = AppLang.ne;
  }

  Future<void> _persist(AppLang l) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, l == AppLang.ne ? 'ne' : 'en');
  }

  void toggle() {
    final next = state == AppLang.en ? AppLang.ne : AppLang.en;
    state = next;
    _persist(next);
  }

  void set(AppLang l) {
    if (l == state) return;
    state = l;
    _persist(l);
  }
}

final langProvider = NotifierProvider<LangNotifier, AppLang>(LangNotifier.new);

const _adminPortal = bool.fromEnvironment('ADMIN_PORTAL');

/// Translate a known English phrase to Nepali. Unknown strings pass through
/// unchanged, so English is always a safe fallback and screens can adopt this
/// gradually just by wrapping their visible text in `trS(lang, '...')`.
///
/// Looks in two maps: [_ne] for the app's own UI chrome, and [neContent] for
/// the family's actual writing (memories, letters, our story). Admin portal
/// builds omit the family writing so it cannot enter the public JavaScript.
String trS(AppLang lang, String en) => lang == AppLang.ne
    ? (_ne[en] ?? (_adminPortal ? null : neContent[en]) ?? en)
    : en;

/// True when [en] has no Nepali yet — used by tests to report coverage rather
/// than letting English silently leak into a Nepali screen.
bool hasNepali(String en) =>
    _ne.containsKey(en) || (!_adminPortal && neContent.containsKey(en));

/// English → Nepali (Devanagari) for the app's navigation & headers. Devanagari
/// renders via the device's font fallback (same as the Sakela screen).
const Map<String, String> _ne = {
  'AI-imagined from our stories': 'हाम्रा कथाबाट एआईले कल्पना गरेको दृश्य',
  'Pictures for this story': 'यस कथाका तस्बिरहरू',
  'No pictures added yet. Diksha can add one.':
      'अहिलेसम्म तस्बिर थपिएको छैन। दीक्षाले थप्न सक्नुहुन्छ।',
  'Kopa · family portrait': 'कोपा · पारिवारिक तस्बिर',
  'Papa · family portrait': 'पापा · पारिवारिक तस्बिर',
  'Mummy · family portrait': 'मम्मी · पारिवारिक तस्बिर',
  'A photograph from our family album': 'हाम्रो पारिवारिक एल्बमको तस्बिर',
  'Diksha · family portrait': 'दीक्षा · पारिवारिक तस्बिर',
  'Diya · family portrait': 'दिया · पारिवारिक तस्बिर',
  'Dipisha · family portrait': 'दिपिशा · पारिवारिक तस्बिर',
  'Dipisha · school portrait': 'दिपिशा · विद्यालयको तस्बिर',
  'Stubby · original photograph': 'स्टब्बी · वास्तविक तस्बिर',
  'AI-edited · white background': 'एआईबाट सम्पादित · सेतो पृष्ठभूमि',
  'Download photo': 'तस्बिर डाउनलोड गर्नुहोस्',
  'Saving photo…': 'तस्बिर सुरक्षित गर्दै…',
  'Photo saved to Pictures/Our Home.':
      'तस्बिर Pictures/Our Home मा सुरक्षित भयो।',
  'Photo saved.': 'तस्बिर सुरक्षित भयो।',
  'Could not save photo. Please try again.':
      'तस्बिर सुरक्षित गर्न सकिएन। फेरि प्रयास गर्नुहोस्।',
  'Family Together': 'परिवारसँगै',
  'All Photos 🌿': 'सबै तस्बिरहरू 🌿',
  '{count} photograph': '{count} तस्बिर',
  '{count} photographs': '{count} तस्बिरहरू',
  'No photographs in here yet': 'यहाँ अझै तस्बिरहरू छैनन्',
  'Open album · page {page} of {pages}':
      'खुला एल्बम · {pages} मध्ये पृष्ठ {page}',
  'Opens the photograph.': 'तस्बिर खोल्नुहोस्।',
  'Previous page': 'अघिल्लो पृष्ठ',
  'Next page': 'अर्को पृष्ठ',
  'Cloud photos are unavailable. The photos included in the app are still here.':
      'अनलाइन तस्बिरहरू उपलब्ध छैनन्। एपमा समावेश तस्बिरहरू यहाँ छन्।',
  // Private album desk and family cloud access.
  'Still to fill': 'भर्न बाँकी',
  'photo': 'तस्बिर',
  'Open album': 'एल्बम खोल्नुहोस्',
  'Checking photos…': 'तस्बिरहरू हेर्दै…',
  'Photo count unavailable': 'तस्बिर सङ्ख्या उपलब्ध छैन',
  'Room for your photographs': 'तपाईंका तस्बिरहरूका लागि ठाउँ',
  "Included in the app": "एपमा समावेश छ",
  "Run the newest Supabase migration first.":
      "पहिले Supabase को सबैभन्दा नयाँ migration चलाउनुहोस्।",
  "Publish all drafts": "सबै मस्यौदा प्रकाशित गर्नुहोस्",
  "This publishes all draft photos in this album and makes the album visible.":
      "यसले यो एल्बमका सबै मस्यौदा तस्बिर प्रकाशित गर्छ र एल्बम देखिने बनाउँछ।",
  'Our family portrait': 'हाम्रो पारिवारिक तस्बिर',
  'AI-composed from our photos': 'हाम्रा तस्बिरहरूबाट AI ले बनाएको',
  "Use as album cover": "एल्बमको आवरण बनाउनुहोस्",
  "Album cover": "एल्बमको आवरण",
  "Your album desk": "तपाईंको एल्बम डेस्क",
  "Family album sign-in": "पारिवारिक एल्बममा साइन इन",
  "Cloud setup is needed before signing in.":
      "साइन इन गर्नुअघि क्लाउड सेटअप चाहिन्छ।",
  "Sign-in failed. Check your details and connection.":
      "साइन इन भएन। आफ्नो विवरण र इन्टरनेट जाँच्नुहोस्।",
  "Could not connect. Please retry.": "जडान हुन सकेन। फेरि प्रयास गर्नुहोस्।",
  "This account does not have access.": "यो खातालाई पहुँच दिइएको छैन।",
  "Retry": "फेरि प्रयास गर्नुहोस्",
  "Sign out": "साइन आउट",
  "Email": "इमेल",
  "Password": "पासवर्ड",
  "Show password": "पासवर्ड देखाउनुहोस्",
  "Hide password": "पासवर्ड लुकाउनुहोस्",
  "Let the bees rest": "माहुरीहरूलाई आराम गर्न दिनुहोस्",
  "Let the bees fly": "माहुरीहरूलाई उड्न दिनुहोस्",
  "A bee": "एउटा माहुरी",
  "A butterfly": "एउटा पुतली",
  "Bzzz! Hello there! 🍯": "भुनभुन! नमस्ते है! 🍯",
  "Busy busy, making honey for our home 💛":
      "व्यस्त व्यस्त, हाम्रो घरका लागि मह बनाउँदै 💛",
  "You found me! Bzz bzz 🐝": "मलाई भेट्टायौ! भुन भुन 🐝",
  "Is that a flower… oh, it is you! 🌼":
      "त्यो फूल हो कि… अहो, तिमी पो रहेछौ! 🌼",
  "Flutter flutter~ 🦋": "फरफर फरफर~ 🦋",
  "The wind told me to come and see you 🌸":
      "हावाले भन्यो, गएर तिमीलाई भेट 🌸",
  "Tap-tap! That tickles! 💗": "टप-टप! काउकुती लाग्यो! 💗",
  "Shh… I am dancing with the breeze 🍃": "स्स्… म बतासमा नाच्दैछु 🍃",
  "Signing in…": "साइन इन हुँदै…",
  "Sign in": "साइन इन",
  "Saved.": "सुरक्षित भयो।",
  "Could not save. Please retry.":
      "सुरक्षित गर्न सकिएन। फेरि प्रयास गर्नुहोस्।",
  "Album name": "एल्बमको नाम",
  "Cancel": "रद्द गर्नुहोस्",
  "Save": "सुरक्षित गर्नुहोस्",
  "Choose a shelf album": "शेल्फबाट एल्बम छान्नुहोस्",
  "Photos saved as drafts. Publish when ready.":
      "तस्बिरहरू मस्यौदाका रूपमा सुरक्षित भए। तयार भएपछि प्रकाशित गर्नुहोस्।",
  "Upload stopped. Saved drafts are kept. Retry the remaining photos.":
      "अपलोड रोकियो। सुरक्षित मस्यौदाहरू यथावत् छन्। बाँकी तस्बिरहरू फेरि प्रयास गर्नुहोस्।",
  "Delete this photo?": "यो तस्बिर मेटाउने?",
  "Delete album": "एल्बम मेटाउनुहोस्",
  "Delete this album?": "यो एल्बम मेटाउनुहुन्छ",
  "Its uploaded photographs are removed with it, and the family app will no longer show it.":
      "यसमा अपलोड गरिएका तस्बिरहरू पनि मेटिन्छन्, र परिवारको एपमा यो देखिने छैन।",
  "This removes the uploaded copy from the family album.":
      "यसले पारिवारिक एल्बमबाट अपलोड गरिएको प्रति हटाउँछ।",
  "Delete": "मेटाउनुहोस्",
  "Choose an album, collect photos, then publish.":
      "एल्बम छान्नुहोस्, तस्बिरहरू राख्नुहोस्, अनि प्रकाशित गर्नुहोस्।",
  "New album": "नयाँ एल्बम",
  "New album saved as a private draft. The family sees it once you publish it.":
      "नयाँ एल्बम निजी मस्यौदाका रूपमा सुरक्षित भयो। प्रकाशित गरेपछि मात्र परिवारले देख्नेछ।",
  "Refresh": "ताजा गर्नुहोस्",
  "Create an album to begin.": "सुरु गर्न एउटा एल्बम बनाउनुहोस्।",
  "Album": "एल्बम",
  "Album is visible to family.": "एल्बम परिवारले देख्न सक्छ।",
  "Album is a private draft.": "एल्बम निजी मस्यौदा हो।",
  "Add photos": "तस्बिर थप्नुहोस्",
  "Rename": "नाम फेर्नुहोस्",
  "Unpublish album": "एल्बमको प्रकाशन हटाउनुहोस्",
  "Publish album": "एल्बम प्रकाशित गर्नुहोस्",
  "Published": "प्रकाशित",
  "Draft": "मस्यौदा",
  "Caption (optional)": "तस्बिरको विवरण (ऐच्छिक)",
  "Edit caption": "विवरण सम्पादन गर्नुहोस्",
  "Unpublish": "प्रकाशन हटाउनुहोस्",
  "Publish": "प्रकाशित गर्नुहोस्",
  "Image preview unavailable.": "तस्बिरको पूर्वावलोकन उपलब्ध छैन।",
  "Skip": "छोड्नुहोस्",
  "Save draft": "मस्यौदा सुरक्षित गर्नुहोस्",
  "Diksha can add photographs from the album desk.":
      "दीक्षाले एल्बम डेस्कबाट तस्बिर थप्न सक्छिन्।",

  // ── Archive Desk ──
  'The Archive Desk': 'अभिलेख डेस्क',
  'Collect first. Confirm carefully. Publish later.':
      'पहिले सङ्कलन गर्नुहोस्। ध्यानपूर्वक पुष्टि गर्नुहोस्। पछि प्रकाशित गर्नुहोस्।',
  'Collect something': 'केही सङ्कलन गर्नुहोस्',
  'collected': 'सङ्कलित',
  'need confirmation': 'पुष्टि गर्न बाँकी',
  'On this device only': 'यस उपकरणमा मात्र',
  'The first folder is waiting': 'पहिलो फोल्डर पर्खिरहेको छ',
  'Save a real memory, question, photograph note, or recording idea. Nothing collected here appears in the family app yet.':
      'वास्तविक सम्झना, प्रश्न, फोटोसम्बन्धी टिपोट वा रेकर्डिङको विचार सुरक्षित गर्नुहोस्। यहाँ सङ्कलित कुनै कुरा अझै पारिवारिक एपमा देखिँदैन।',
  'Start a folder': 'फोल्डर सुरु गर्नुहोस्',
  'Source': 'स्रोत',
  'New archive folder': 'नयाँ अभिलेख फोल्डर',
  'Review archive folder': 'अभिलेख फोल्डर समीक्षा गर्नुहोस्',
  'A source is required. Confirmed entries still stay here until a separate publishing step is built.':
      'स्रोत आवश्यक छ। छुट्टै प्रकाशन चरण नबनेसम्म पुष्टि भएका सामग्री पनि यहीँ रहन्छन्।',
  'Kind of material': 'सामग्रीको प्रकार',
  'Title or question': 'शीर्षक वा प्रश्न',
  'Give this folder a title': 'यस फोल्डरलाई शीर्षक दिनुहोस्',
  'What we know so far': 'अहिलेसम्म हामीलाई थाहा भएको कुरा',
  'Who supplied this or can confirm it?':
      'यो कसले दिनुभयो वा कसले पुष्टि गर्न सक्नुहुन्छ?',
  'Name the person who can verify it':
      'यसलाई पुष्टि गर्न सक्ने व्यक्तिको नाम लेख्नुहोस्',
  'Verification': 'पुष्टि',
  'Add a known date (optional)': 'थाहा भएको मिति थप्नुहोस् (वैकल्पिक)',
  'Keep in the Archive Desk': 'अभिलेख डेस्कमा राख्नुहोस्',
  'Memory': 'सम्झना',
  'Birthday': 'जन्मदिन',
  'Photograph': 'तस्बिर',
  'Letter': 'चिठी',
  'Voice recording': 'आवाज रेकर्डिङ',
  'Recipe': 'परिकार विधि',
  'Family fact': 'पारिवारिक तथ्य',
  'Confirmed by source': 'स्रोतबाट पुष्टि भएको',
  'Needs confirmation': 'पुष्टि गर्न बाँकी',

  // ── Home ──
  'Welcome Home': 'स्वागत छ',
  'Every family has a story.': 'हरेक परिवारको एउटा कथा हुन्छ।',
  'This is ours.': 'यो हाम्रो हो।',
  'Good morning': 'शुभ प्रभात',
  'Good afternoon': 'शुभ दिउँसो',
  'Good evening': 'शुभ साँझ',
  'Good night': 'शुभ रात्री',
  'A quiet night': 'शान्त रात',
  'Here is what is waiting in our family today.':
      'आज हाम्रो परिवारमा यी माया भरिएका कुरा पर्खिरहेका छन्।',
  'Today in our family': 'आज हाम्रो परिवारमा',
  'Three little paths into our story': 'हाम्रो कथाभित्र जाने तीन साना बाटा',
  'REMEMBER': 'सम्झना',
  'UNFOLD': 'पत्र खोल्नुहोस्',
  'CELEBRATE': 'उत्सव',
  'A letter from Nana': 'नानाको एउटा पत्र',
  'Visit the family table': 'परिवारको भोजमा जानुहोस्',
  'WORDS FOR TODAY': 'आजका शब्द',
  'A moment worth keeping': 'सधैँ सँगाल्न लायक क्षण',
  'Experience this memory': 'यो सम्झना अनुभव गर्नुहोस्',
  'THE STORY BEHIND THE MOMENT': 'यो क्षण पछाडिको कथा',
  'Frames from this day': 'यस दिनका तस्बिरहरू',
  'A voice kept with this day': 'यस दिनसँग सँगालिएको आवाज',
  'A VOICE KEPT WITH THIS DAY': 'यस दिनसँग सँगालिएको आवाज',
  'The story continues': 'कथा अझै अगाडि बढ्छ',
  'Tap to return to the memory': 'सम्झनामा फर्कन थिच्नुहोस्',
  'Tap the right side to continue': 'अगाडि बढ्न दायाँपट्टि थिच्नुहोस्',
  'The voice note remains available on the memory page.':
      'आवाज सन्देश सम्झनाको पृष्ठमा सुन्न सकिन्छ।',
  'KEPT IN OUR HOME': 'हाम्रो घरमा सँगालिएको',
  'Kept by Diksha, with all my love. 💜': 'दीक्षाले सारा मायासहित सँगालेकी। 💜',
  'Step inside our home': 'हाम्रो घरभित्र पस्नुहोस्',
  'A memory from today': 'आजको एउटा सम्झना',
  'Open memory': 'सम्झना खोल्नुहोस्',
  '✨ Enter Rai Village': '✨ राई गाउँ पस्नुहोस्',
  'Explore our memories in a living world':
      'जीवन्त संसारमा हाम्रा सम्झना घुम्नुहोस्',
  'Enter  →': 'पस्नुहोस्  →',

  // ── Home section cards (title / subtitle) ──
  'Family Tree': 'वंश-वृक्ष',
  'Our roots & branches': 'हाम्रा जरा र हाँगा',
  'Our Story': 'हाम्रो कथा',
  'Read it like a book': 'किताबझैँ पढ्नुहोस्',
  'Family Members': 'परिवारका सदस्य',
  'Everyone we love': 'हामीले माया गर्ने सबै',
  'Gallery': 'ग्यालरी',
  'Photos & albums': 'तस्बिर र एल्बम',
  'Timeline': 'समयरेखा',
  'Year by year': 'वर्षैपिच्छे',
  'Pets': 'पाल्तु जनावर',
  'Our furry family': 'हाम्रो रौँदार परिवार',
  'Birthdays': 'जन्मदिन',
  'Cakes & countdowns': 'केक र दिन-गन्ती',
  'Places': 'ठाउँहरू',
  "Where we've been": 'हामी पुगेका ठाउँ',
  'Family Quotes': 'पारिवारिक भनाइ',
  'Things we always say': 'हामी सधैँ भन्ने कुरा',
  "Dipisha's World": 'दिपिशाको संसार',
  'Made with love by Nana ✨': 'नानाले मायाले बनाएको ✨',

  // ── Section screen headers (title / subtitle) ──
  'Where our story travelled': 'हाम्रो कथा पुगेका ठाउँ',
  'Our journey, year by year': 'हाम्रो यात्रा, वर्षैपिच्छे',
  'Our Pets': 'हाम्रा पाल्तु जनावर',
  'The fluffiest Rais of all': 'सबैभन्दा रौँदार राईहरू',
  'Once upon a family…': 'एउटा परिवारको कथा…',
  'Everyone who makes us, us': 'हामीलाई हामी बनाउने सबै',
  'Tap anyone to visit them': 'भेट्न कसैलाई थिच्नुहोस्',
  'Every moment, framed': 'हरेक क्षण, फ्रेममा',
  'Cakes, candles & countdowns': 'केक, मैनबत्ती र दिन-गन्ती',
  'Sakela Than': 'साकेला थान',
  'Our Kirat sacred place · प्रकृति पूजा':
      'हाम्रो किरात पवित्र स्थल · प्रकृति पूजा',

  // ── Dipisha's World (the explorable one) ──
  'A world made just for her': 'उनकै लागि बनेको संसार',
  'Go in': 'भित्र जानुहोस्',
  'Double tap to explore': 'घुम्न दुई पटक थिच्नुहोस्',
  'Letters from Nana, for whenever you need them':
      'नानाका पत्र, जब-जब तिमीलाई चाहिन्छ',
  'Our family photos, kept together':
      'हाम्रा पारिवारिक तस्बिर, एकै ठाउँमा सँगालिएका',
  'Our family garden, kept in one place':
      'हाम्रो पारिवारिक फूलबारी, एकै ठाउँमा',
  'Real messages, saved for the right day':
      'साँचा सन्देश, सही दिनका लागि सँगालिएका',
  'Voice messages kept by the family': 'परिवारले सँगालेका आवाज सन्देश',
  'Our family story, year by year': 'हाम्रो पारिवारिक कथा, वर्षैपिच्छे',
  'Still to add — Diksha will mark the trail':
      'अझै थप्न बाँकी — दीक्षाले बाटो चिन्ह लगाउनेछिन्',
  'Still to add — Diksha will fill this room':
      'अझै थप्न बाँकी — दीक्षाले यो कोठा भर्नेछिन्',
  'Still to add 💌': 'अझै थप्न बाँकी 💌',
  'Ask Diksha': 'दीक्षालाई सोध्नुहोस्',
  'Dipisha\'s Room': 'दिपिशाको कोठा',
  'Waiting for her real stories': 'उनका साँचा कथाको पर्खाइमा',
  'Diksha can fill this room with real objects and real memories.':
      'दीक्षाले यो कोठा साँचा सामान र साँचा सम्झनाले भर्न सक्छिन्।',

  // ── Dipisha's World gate and honest empty spaces ──
  'A magical little world, made with love by Nana ✨':
      'नानाले मायाले बनाएको सानो जादुई संसार ✨',
  'Whisper the magic word 🤫': 'जादुको शब्द बिस्तारै भन 🤫',
  'your secret word': 'तिम्रो गोप्य शब्द',
  'psst… any word works in here 💜': 'सुन… यहाँ जुनसुकै शब्द चल्छ 💜',
  'Open the door ✨': 'ढोका खोल ✨',
  'Made with endless love, by Nana': 'नानाले अनन्त मायाले बनाएको',
  'Achievements': 'उपलब्धिहरू',
  'The milestones Diksha has confirmed': 'दीक्षाले यकिन गरेका उपलब्धिहरू',
  'Diksha can add Dipisha\'s real milestones and dates here.':
      'दीक्षाले यहाँ दिपिशाका साँचा उपलब्धि र मिति थप्न सक्छिन्।',
  'Dream Board': 'सपनाको बोर्ड',
  'Dreams Dipisha has shared herself': 'दिपिशाले आफैँ भनेका सपना',
  'Dipisha can tell Diksha which dreams belong on this board.':
      'यो बोर्डमा कुन सपना राख्ने भनेर दिपिशाले दीक्षालाई भन्न सक्छिन्।',
  'Dream big, little one. Every one of these is possible. 💫':
      'ठूलो सपना देख, सानी। यी सबै सम्भव छन्। 💫',
  'Future Messages': 'भविष्यका सन्देश',
  'Letters Diksha has written for the years ahead':
      'आउने वर्षका लागि दीक्षाले लेखेका पत्र',
  'A sealed message will appear only after Diksha writes it.':
      'दीक्षाले लेखेपछि मात्र बन्द सन्देश यहाँ देखिनेछ।',
  'Surprise Box': 'आश्चर्यको बाकस',
  'Diksha can place a real message here when it is ready.':
      'दीक्षाले तयार भएपछि यहाँ साँचो सन्देश राख्न सक्छिन्।',
  'A big warm hug': 'ठूलो न्यानो अँगालो',
  'No matter how old you become,\nyou will always be our little star.':
      'तिमी जति ठूली भए पनि,\nहाम्रो सानो तारा सधैँ रहनेछौ।',
  'A voice hug can be added after Diksha records it.':
      'दीक्षाले रेकर्ड गरेपछि आवाजको अँगालो थप्न सकिन्छ।',

  // ── Celebration Hall ──
  'Celebration Hall': 'भोज कोठा',
  'The long table · हाम्रो भोज': 'हाम्रो भोजको लामो टेबल',
  'Next at our table': 'हाम्रो टेबलमा अर्को',
  'Happy birthday': 'जन्मदिनको शुभकामना',
  'Turning': 'पुग्दै',
  'today': 'आज',
  'days away': 'दिन बाँकी',
  'Every seat at our table': 'हाम्रो टेबलका हरेक ठाउँ',
  'Six places, laid. Oldest at the head, as it should be.':
      'छ ठाउँ, तयार। जेठो शिरमा, जसरी हुनुपर्छ।',
  'not confirmed': 'यकिन छैन',
  'Arjun is under the table. Arjun is always under the table.':
      'अर्जुन टेबलमुनि छ। अर्जुन सधैँ टेबलमुनि हुन्छ।',
  '* A date marked like this is pencilled in until someone tells us '
          'the real one. Nothing counts down to a pencilled date.':
      '* यसरी चिन्ह लगाइएको मिति कसैले साँचो नभनुञ्जेल सिसाकलमले लेखिएको हो। '
      'सिसाकलमको मितिको गणना कहिल्यै हुँदैन।',

  // ── The Two Skies ──
  'Papa · Malaysia': 'बुबा · मलेसिया',
  'Ilam · our sky': 'इलाम · हाम्रो आकाश',

  // ── Rai Village ──
  'Rai Village': 'राई गाउँ',
  'Drag to explore · tap a place to visit':
      'घुम्न घिच्नुहोस् · ठाउँ हेर्न थिच्नुहोस्',

  // ── Flower Garden (our phulbari) ──
  'Flower Garden': 'फूलबारी',
  'Our phulbari · फूलबारी': 'हाम्रो फूलबारी',
  'Every pot in our aagan was carried, filled and watered by somebody who '
          'loves you. Sit a while — the garden is awake.':
      'हाम्रो आँगनको हरेक गमला तिमीलाई माया गर्ने कसैले बोकेको, भरेको र '
      'पानी हालेको हो। छिनभर बस — बारी ब्युँझिएको छ।',
  'The flowers we grow': 'हामीले फुलाएका फूल',
  'Who visits our garden': 'हाम्रो बारीमा को आउँछ',
  'Our little ones, playing': 'हाम्रा नानीहरू, खेल्दै',
  'Who tends it': 'यसको हेरचाह कसले गर्छ',
  'Lali Guras · Rhododendron': 'लालीगुराँस',
  'Nepal\'s national flower. It sets the Ilam hills on fire, red across every '
          'ridge, every spring.':
      'नेपालको राष्ट्रिय फूल। हरेक वसन्तमा इलामका डाँडा रातै बनाइदिन्छ।',
  'Sayapatri · Marigold': 'सयपत्री',
  'The Tihar flower — we string it into malas for Stubby and Arjun on Kukur '
          'Tihar.':
      'तिहारको फूल — कुकुर तिहारमा स्टब्बी र अर्जुनलाई माला गाँस्छौं।',
  'Money plant': 'मनी प्लान्ट',
  'In a clay pot by the door, growing wherever it likes.':
      'ढोकानेरको माटोको गमलामा, आफूखुसी बढ्दै।',
  'Suntala · Orange': 'सुन्तला',
  'Ilam orange — sweet, cold, and best eaten in the winter sun.':
      'इलामे सुन्तला — गुलियो, चिसो, जाडोको घाममा खाँदा सबैभन्दा मीठो।',
  'Bee': 'माहुरी',
  'Butterfly': 'पुतली',
  'Songbird': 'चरा',
  'Parrot': 'सुगा',
  'guarding the marigolds': 'सयपत्रीको रखवाली गर्दै',
  'watching from behind the pots 🌈': 'गमलापछाडिबाट हेर्दै 🌈',
  'dancing through the pots like she owns them — because she does':
      'गमलाबीच नाच्दै, सबै आफ्नै हो जसरी — किनकि हो नि',
  'Mummy & her girls': 'मम्मी र उहाँका छोरीहरू',
  'Sanchu planted most of these. Three daughters grew up in this aagan beside '
          'them — and Meow supervised.':
      'यीमध्ये धेरै सान्चुले रोप्नुभएको हो। तीन छोरी यही आँगनमा यिनकै छेउमा '
      'हुर्किए — अनि म्याउले रेखदेख गर्‍यो।',
  'Dipisha, watering': 'दिपिशा, पानी हाल्दै',
  'Every evening, one pot at a time — and a long talk with each flower about '
          'its day.':
      'हरेक साँझ, एक-एक गमला — अनि हरेक फूलसँग दिनभरको लामो कुराकानी।',

  // ── Birthdays — the calendar by the door ──
  'The calendar by the door': 'ढोकानेरको पात्रो',
  'Next on the calendar': 'पात्रोमा अर्को',
  'Today': 'आज',
  'The rest of the year': 'वर्षको बाँकी',
  'day': 'दिन',
  'days': 'दिन',
  'we haven\'t written this one down yet. Nobody guesses it.':
      'यो अझै लेखिएको छैन। कसैले अनुमान गर्दैन।',
  'we haven\'t written these down yet. Nobody guesses one.':
      'यी अझै लेखिएका छैनन्। कसैले अनुमान गर्दैन।',

  // ── Our Memories — the scrapbook ──
  'Our Memories': 'हाम्रा सम्झना',
  'Pasted in, a day at a time': 'एक-एक दिन गरी टाँसिएको',
  'Find a memory': 'सम्झना खोज्नुहोस्',

  // ── A person's own page ──
  'Memories that mention them': 'उनलाई उल्लेख गर्ने सम्झना',
  'Not yet threaded together': 'अझै जोडिएको छैन',

  // ── Our Family Tree ──
  'Our Family Tree': 'हाम्रो वंश-वृक्ष',
  'Touch anyone to trace their line': 'कसैको वंश हेर्न थिच्नुहोस्',
  'Touch a face to follow their branch.':
      'कसैको हाँगा पछ्याउन अनुहार थिच्नुहोस्।',
  'Touch again to open their page.': 'पाना खोल्न फेरि थिच्नुहोस्।',
  // 'Our Roots' is already translated above — it's the Heritage section name,
  // and it means the same thing at the top of the tree.
  'Mum & Dad': 'मम्मी र बुबा',
  'The Three Stars': 'तीन तारा',
  'Our Furry Family': 'हाम्रो रौँदार परिवार',

  // ── Our Animals — their corner ──
  'Their corner of the house': 'घरको उनीहरूको कुना',
  'Everybody who has ever slept on this floor.': 'यो भुइँमा सुतेका सबै।',
  'Forever in our hearts': 'सधैँ हाम्रो मनमा',

  // ── Things We Always Say ──
  'Things We Always Say': 'हामी सधैँ भन्ने कुरा',
  'Written on whatever was to hand': 'हात परेको जुनसुकैमा लेखिएको',
  'in the margin': 'किनारामा',
  'Said so often nobody remembers who said it first.':
      'यति पटक भनियो कि पहिले कसले भनेको थियो कसैलाई याद छैन।',

  // ── Places — the map table ──
  'Places in Our Story': 'हाम्रो कथाका ठाउँ',
  'Shown approximately, from family memory.':
      'परिवारको सम्झनाबाट, अन्दाजी देखाइएको।',
  'Touch a pin to hear about that place.':
      'त्यो ठाउँबारे सुन्न पिन थिच्नुहोस्।',
  'All our places': 'हाम्रा सबै ठाउँ',
  'photos': 'तस्बिर',

  // ── Our Years — the hallway ──
  'Our Years': 'हाम्रा वर्षहरू',
  'Walk down the hallway': 'दलानमा हिँड्नुहोस्',
  'Our Memory Tree · सम्झनाको रूख': 'सम्झनाको रूख',
  'Every year, another ring.': 'हरेक वर्ष, अर्को चक्का।',

  // ── Our Story — the book ──
  'Chapter': 'अध्याय',
  'of': 'मध्ये',
  'Back': 'पछाडि',
  'Next': 'अर्को',

  // ── Family Albums — the bookcase ──
  'Family Albums': 'पारिवारिक एल्बम',
  'Every moment, kept on a shelf': 'हरेक क्षण, दराजमा राखिएको',
  'Take one down.': 'एउटा झिक्नुहोस्।',
  'Search albums…': 'एल्बम खोज्नुहोस्…',
  'No albums found': 'कुनै एल्बम भेटिएन',

  // ── Our People — the family wall ──
  'Our People': 'हाम्रा मान्छे',
  'Our animals': 'हाम्रा जनावर',

  // ── Letters — the mailbox and the tray ──
  'Inside the Treehouse': 'रूखको घरभित्र',
  'Letters from Nana': 'नानाका पत्र',
  'Kept for whenever you need them': 'जब-जब चाहिन्छ, त्यसैका लागि राखिएका',
  'A letter for today': 'आजको एउटा पत्र',
  'The box is empty': 'बाकस खाली छ',
  'You have opened every one.': 'तिमीले सबै खोलिसक्यौ।',
  'still sealed': 'अझै बन्द',
  'the last sealed one': 'अन्तिम बन्द पत्र',
  'When you need…': 'जब तिमीलाई चाहिन्छ…',
  'The letter tray': 'पत्रको थाल',
  'Letters for that': 'त्यसका लागि पत्र',
  'Search letters…': 'पत्र खोज्नुहोस्…',
  'No letters found': 'कुनै पत्र भेटिएन',
  'Try another word.': 'अर्को शब्द खोज्नुहोस्।',
  'Letter not found': 'पत्र भेटिएन',
  'opened': 'खोलिएको',
  'The mailbox. A letter is waiting.': 'पत्र बाकसमा एउटा पत्र पर्खिरहेको छ।',
  'The mailbox. Every letter has been opened.':
      'पत्र बाकस। सबै पत्र खोलिसकिएका छन्।',
  'An opened letter': 'खोलिएको पत्र',
  'A sealed letter': 'बन्द पत्र',
  'Opens it.': 'यसलाई खोल्छ।',
  'When you\'re sad': 'जब दुःखी हुन्छौ',
  'When you\'re happy': 'जब खुसी हुन्छौ',
  'When you\'re scared': 'जब डर लाग्छ',
  'Exam Day': 'परीक्षाको दिन',
  'Dashain': 'दशैं',

  // ── Inside Our Home — the room ──
  'Our Home': 'हाम्रो घर',
  'There are family stories waiting for you.':
      'तिम्रो लागि परिवारका कथा पर्खिरहेका छन्।',
  'Our people': 'हाम्रा मान्छे',
  'and underneath': 'अनि तल',
  'day away': 'दिन बाँकी',
  'Step outside  →': 'बाहिर निस्कनुहोस्  →',
  'Open the family cabinet': 'परिवारको दराज खोल्नुहोस्',
  'Everything we keep': 'हामीले राखेका सबै',
  'To': 'लाई',
  'From': 'बाट',
  'Nana': 'नाना',
  'Dipisha': 'दिपिशा',
  'Reading in bed': 'ओछ्यानमा पढ्दै',
  'Turn the lamp on': 'बत्ती बाल्नुहोस्',
  'Old home': 'पुरानो घर',
  'New home': 'नयाँ घर',
  'Switch to the old home': 'पुरानो घरमा फर्कनुहोस्',
  'Switch to the new home': 'नयाँ घरमा जानुहोस्',
  'Good Morning': 'शुभ प्रभात',
  'Good Afternoon': 'शुभ दिन',
  'Good Evening': 'शुभ सन्ध्या',
  'Good Night': 'शुभ रात्री',
  // Cabinet group headings.
  'Family': 'परिवार',
  'Memories': 'सम्झनाहरू',
  'Celebrations': 'उत्सव',
  'Outside': 'बाहिर',
  'Magic': 'जादू',
  // Semantics — screen-reader labels for the objects in the room.
  'The window. Our sky, and Papa\'s.': 'झ्याल। हाम्रो आकाश, र बुबाको।',
  'The front door. Steps outside into Rai Village.':
      'मुख्य ढोका। राई गाउँतिर बाहिर लैजान्छ।',
  'The family cabinet. Opens everything we keep.':
      'परिवारको दराज। हामीले राखेका सबै खोल्छ।',

  // ── Heritage — what we keep that isn't photographs ──
  'Our Roots': 'हाम्रो जरा',
  'Stories, words and traditions we carry · हाम्रो सम्पदा': 'हाम्रो सम्पदा',
  'Stories, words & traditions': 'कथा, शब्द र परम्परा',
  'Photographs keep what a day looked like. These pages keep '
          'what we knew — and what nobody has written down yet.':
      'तस्बिरले दिन कस्तो थियो भन्ने राख्छ। यी पानाहरूले हामीले जानेका कुरा '
      'राख्छन् — अनि अझै कसैले नलेखेका कुरा पनि।',
  'words kept': 'शब्द जोगिए',
  'recipes': 'परिकार',
  'still to ask': 'सोध्न बाँकी',
  'stories we hope to hear': 'सुन्न चाहेका कथा',
  'Our Words': 'हाम्रा शब्द',
  'The dictionary of this family · हाम्रा शब्द': 'यस परिवारको शब्दकोश',
  'Kirat words, the words of this house, and the sentences only '
          'we say.':
      'किरात शब्द, यस घरका शब्द, अनि हामी मात्रै भन्ने वाक्य।',
  'Our Recipes': 'हाम्रा परिकार',
  'What Mummy cooks · हाम्रो भान्सा': 'मम्मीले पकाउने कुरा',
  'What Mummy cooks, and who taught it to her.':
      'मम्मीले के पकाउनुहुन्छ, अनि उहाँलाई कसले सिकायो।',
  'What We Do, and Why': 'हामी के गर्छौं, र किन',
  'Our year, and the reasons under it · हाम्रा चाडपर्व':
      'हाम्रो वर्ष, र त्यसमुनिका कारण',
  'Sakela, Tihar, Dashain — and the fire lit every morning.':
      'साकेला, तिहार, दशैं — अनि हरेक बिहान बल्ने आगो।',
  'Where We Come From': 'हामी कहाँबाट आयौं',
  'The Rai name, and the moves · हाम्रो जरा': 'राई थर, र सर्दै गएका बाटा',
  'Ilam, Ranke, Malaysia, Kathmandu — and why we moved.':
      'इलाम, राँके, मलेसिया, काठमाडौं — अनि हामी किन सर्‍यौं।',

  // Heritage — the honesty vocabulary. These carry the whole section.
  'Still to add': 'थप्न बाँकी',
  'Ask while we can': 'सक्दै गर्दा सोधौं',
  'Ask': 'सोध्नुहोस्',
  'While we can still ask': 'जबसम्म सोध्न सकिन्छ',
  'Kirat & Rai': 'किरात र राई',
  'Words of this house': 'यस घरका शब्द',
  'Only we say this': 'यो हामी मात्रै भन्छौं',
  'No recording yet': 'अझै रेकर्ड छैन',
  'Made by': 'बनाउने',
  'who learned it from': 'जसले सिके',
  'The words we don\'t have yet': 'अझै नभएका शब्द',
  'Still in somebody\'s hands': 'अझै कसैको हातमा',
  'What we haven\'t asked yet': 'अझै नसोधेका कुरा',
  'The places, in order': 'ठाउँहरू, क्रमैसँग',
  'There now': 'अहिले त्यहाँ',
  'home': 'घर',
  'Why': 'किन',
  'How ours goes': 'हाम्रो कस्तो हुन्छ',
  'What goes in': 'के-के हाल्ने',
  'How': 'कसरी',
  'A family is not only its photographs.':
      'परिवार भनेको त्यसका तस्बिर मात्रै होइन।',

  // ── Dipisha's World (gated) ──
  'Voice Messages': 'आवाज सन्देश',
};
