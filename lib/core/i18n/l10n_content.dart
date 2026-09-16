/// Nepali for the **content** of this home — the family's own writing, not the
/// app's buttons and headers (those live in `l10n.dart`).
///
/// Two notes for whoever edits this next:
///
/// 1. These are Diksha's words to her sister. The Nepali here is a translation,
///    not her voice — she should read it and change anything that doesn't sound
///    like her. A tender line in English can land flat in Nepali.
/// 2. Keys must match the English in `mock_data.dart` **character for
///    character**, including the em-dashes (—) and curly apostrophes. `trS`
///    falls back to English silently, so a mismatch just quietly un-translates.
///    `test/content_i18n_test.dart` fails loudly instead.
library;

const Map<String, String> neContent = {
  // ── Enum labels (moods, categories, unlock types) ────────────────────────
  'Happy': 'खुसी',
  'Loved': 'मायालु',
  'Excited': 'उत्साहित',
  'Proud': 'गर्वित',
  'Calm': 'शान्त',
  'Grateful': 'कृतज्ञ',
  'Silly': 'रमाइलो',
  'Sad': 'दुःखी',
  'Nostalgic': 'सम्झनामा',
  'All': 'सबै',
  'Trips': 'यात्रा',
  'Birthday': 'जन्मदिन',
  'Family': 'परिवार',
  'School': 'विद्यालय',
  'Festivals': 'चाडपर्व',
  'Everyday': 'दैनिकी',
  'Achievements': 'उपलब्धि',
  'When you\'re sad': 'जब तिमी दुःखी हुन्छौ',
  'When you\'re happy': 'जब तिमी खुसी हुन्छौ',
  'When you\'re scared': 'जब तिमी डराउँछौ',
  'Christmas': 'क्रिसमस',
  'Dashain': 'दशैं',
  'Tihar': 'तिहार',
  'Exam Day': 'परीक्षाको दिन',
  'Graduation': 'दीक्षान्त',
  'Future': 'भविष्य',
  'Just because': 'यसै भन्न मन लाग्यो',
  'Specific Date': 'निश्चित मिति',
  'Specific Age': 'निश्चित उमेर',
  'On a Birthday': 'जन्मदिनमा',
  'Password': 'पासवर्ड',

  // ── Memory locations ─────────────────────────────────────────────────────
  'Shree Antu, Ilam': 'श्री अन्तु, इलाम',
  'Our home, Ilam': 'हाम्रो घर, इलाम',
  'Suryodaya Shiksha Sadan Secondary School':
      'सूर्योदय शिक्षा सदन माध्यमिक विद्यालय',
  'Grandma\'s House': 'हजुरआमाको घर',
  'Lumbini, Rupandehi': 'लुम्बिनी, रूपन्देही',
  'Our Lane': 'हाम्रो गल्ली',
  'Home Kitchen': 'घरको भान्सा',

  // ── Quotes ───────────────────────────────────────────────────────────────
  'You are braver than you believe, stronger than you seem, and smarter than '
      'you think.':
      'तिमी सोचेभन्दा बढी बहादुर छौ, देखिएभन्दा बढी बलियो छौ, र ठानेभन्दा बढी '
          'बुद्धिमानी छौ।',
  'Little sister, you are a tiny miracle wrapped in giggles.':
      'सानी बहिनी, तिमी हाँसोमा बेरिएको सानो चमत्कार हौ।',
  'The best thing to hold onto in life is each other.':
      'जीवनमा समात्नुपर्ने सबैभन्दा राम्रो कुरा एकअर्कालाई हो।',
  'Keep shining, little star. The whole sky is watching.':
      'चम्किरहनू, सानो तारा। सारा आकाश हेरिरहेको छ।',
  'Wherever you go, no matter the weather, always bring your own sunshine.':
      'जहाँ गए पनि, मौसम जस्तोसुकै होस्, सधैँ आफ्नै घाम सँगै लैजानू।',

  // ── Memories ─────────────────────────────────────────────────────────────
  'Sunrise at Shree Antu': 'श्री अन्तुको सूर्योदय',
  'We woke in the dark and climbed to Shree Antu to watch the sun rise over a '
      'whole sea of tea gardens and cloud, the Himalaya glowing gold. Cold '
      'hands, hot tea, and a view we will never forget.':
      'अँध्यारैमा उठेर श्री अन्तु चढ्यौं — चियाबारी र बादलको सागरमाथि घाम '
          'झुल्किँदै थियो, हिमाल सुनजस्तै टल्किँदै। चिसा हातहरू, तातो चिया, र '
          'कहिल्यै नबिर्सने दृश्य।',
  'Dipisha\'s Birthday': 'दिपिशाको जन्मदिन',
  'A whole day of love in our village home — sel roti, a little cake, and '
      'everyone singing. You blew the candles in one big breath and the whole '
      'house cheered.':
      'गाउँको घरमा मायाले भरिएको पूरै दिन — सेलरोटी, सानो केक, र सबैको गीत। '
          'तिमीले एकै सासमा मैनबत्ती निभायौ अनि सारा घर तालीले गुन्जियो।',
  'Drawing Competition Win': 'चित्रकला प्रतियोगिता जित',
  'You painted our whole family under a big rainbow and won first prize at '
      'school. You held that little trophy like it was made of gold. We were '
      'so proud.':
      'तिमीले ठूलो इन्द्रेणीमुनि हाम्रो सारा परिवार बनायौ र विद्यालयमा प्रथम '
          'भयौ। त्यो सानो ट्रफी सुनकै हो जसरी समातेकी थियौ। हामी कति गर्वित '
          'थियौं।',
  'Dashain Together': 'सँगै मनाएको दशैं',
  'Tika, jamara and so many blessings. You wore your new red dress and '
      'collected dakshina from everyone. You counted it three times!':
      'टीका, जमरा र थुप्रै आशीर्वाद। तिमीले नयाँ रातो फ्रक लगायौ र सबैबाट '
          'दक्षिणा उठायौ। तीन पटक गनेकी थियौ!',
  'Lumbini School Tour': 'लुम्बिनी शैक्षिक भ्रमण',
  'My class-10 school tour from Suryodaya — just me and my classmates, a long, '
      'noisy bus ride all the way across the country, and then the calm sacred '
      'garden where the Buddha was born. My first big journey away from the '
      'hills. — Diksha':
      'सूर्योदयबाट मेरो कक्षा १० को शैक्षिक भ्रमण — म र मेरा सहपाठीहरू मात्रै, '
          'देशभरि कटेको लामो, हल्लाखल्ला बसयात्रा, अनि बुद्ध जन्मेको शान्त '
          'पवित्र बगैँचा। डाँडाबाट टाढाको मेरो पहिलो ठूलो यात्रा। — दीक्षा',
  'Learning to Cycle': 'साइकल सिक्दै',
  'Wobbly at first, then suddenly you were flying down the lane shouting '
      '"Look! No hands!" (there were, in fact, hands).':
      'पहिले लरबरिँदै, अनि एक्कासि गल्लीभरि उडिरहेकी — "हेर! हात छैन!" भन्दै '
          'कराउँदै (साँच्चै भन्ने हो भने, हात थियो)।',
  'Rainy Day Momos': 'झरीको दिनको मम',
  'It poured all afternoon so we made momos together. More flour ended up on '
      'your face than in the dumplings.':
      'दिनभरि झरी परेपछि हामीले सँगै मम बनायौं। ममभन्दा बढी पिठो त तिम्रै '
          'अनुहारमा पुग्यो।',
  'First Day of School': 'विद्यालयको पहिलो दिन',
  'A backpack almost as big as you were. You held my hand at the gate of '
      'Suryodaya Shiksha Sadan — the very same school Diya and I walked through '
      'until class 10 — then walked in like the bravest little person in the '
      'world. Three sisters, one school, one set of corridors.':
      'तिमी जत्रै ठूलो झोला। सूर्योदय शिक्षा सदनको गेटमा तिमीले मेरो हात '
          'समायौ — त्यही विद्यालय जहाँ म र दीया कक्षा १० सम्म हिँड्यौं — अनि '
          'संसारकै सबैभन्दा बहादुर नानी जसरी भित्र पस्यौ। तीन दिदीबहिनी, एउटै '
          'विद्यालय, उही बरन्डा।',
  'Mummy\'s Morning Kitchen': 'मम्मीको बिहानीको भान्सा',
  'Before sunrise, Mummy ground maize on the jaato and cooked warm kholo for '
      'the cow. I helped light the chulo — aago balna — blowing at the flame '
      'till it caught, smoke curling into the cold Ilam morning. The smell of '
      'woodfire and maize is the smell of home.':
      'घाम झुल्किनुअघि नै मम्मीले जाँतोमा मकै पिँध्नुहुन्थ्यो र गाईलाई न्यानो '
          'खोले पकाउनुहुन्थ्यो। म चुलो बाल्न सघाउँथें — आगो बाल्न — ज्वाला '
          'नसल्किउञ्जेल फुक्दै, धुवाँ इलामको चिसो बिहानीमा घुम्रिँदै। दाउराको '
          'आगो र मकैको बास्ना नै घरको बास्ना हो।',
  'Kukur Tihar with Stubby': 'स्टब्बीसँगको कुकुर तिहार',
  'We put a marigold garland and red tika on Stubby and worshipped her, the '
      'way Kirat families honour their dogs. She sat so proudly with her '
      'flowers. Our first, bravest, most loving friend. 🌈':
      'स्टब्बीलाई सयपत्रीको माला र रातो टीका लगाएर पूजा गर्‍यौं — किरात '
          'परिवारले आफ्ना कुकुरलाई सम्मान गरेजस्तै। फूल लगाएर कति गर्वले '
          'बसेकी थिई। हाम्रो पहिलो, सबैभन्दा बहादुर, सबैभन्दा मायालु साथी। 🌈',

  // ── Places ───────────────────────────────────────────────────────────────
  'Mangalbare, Ilam': 'मंगलबारे, इलाम',
  'Eastern Nepal · Home': 'पूर्वी नेपाल · घर',
  'Our home in the hills of Ilam — tea gardens rolling into the mist, terraced '
      'fields, and the house where our whole story began.':
      'इलामका डाँडामा हाम्रो घर — कुहिरोमा हराउने चियाबारी, गह्रा-गह्रा खेत, '
          'र त्यो घर जहाँबाट हाम्रो सारा कथा सुरु भयो।',
  'Shree Antu': 'श्री अन्तु',
  'Ilam': 'इलाम',
  'The famous sunrise viewpoint — a whole sea of tea gardens and clouds below, '
      'and the Himalaya glowing gold at dawn.':
      'प्रसिद्ध सूर्योदय दृश्यस्थल — तल चियाबारी र बादलको सागर, अनि बिहानै '
          'सुनजस्तै टल्किने हिमाल।',
  'Ranke': 'राँके',
  'Ilam · Mamaghar': 'इलाम · मामाघर',
  'Mamaghar — where the holidays were warmest: cousins, maize fields, and '
      'endless love from the family home.':
      'मामाघर — जहाँ बिदाहरू सबैभन्दा न्यानो हुन्थे: दाजुभाइ-दिदीबहिनी, '
          'मकैबारी, र घरभरिको असीम माया।',
  'Lumbini': 'लुम्बिनी',
  'Rupandehi': 'रूपन्देही',
  'The birthplace of the Buddha. Diksha went here on her class-10 school tour '
      '— her trip alone, with her classmates, not the family\'s. A long bus '
      'ride and a calm, sacred garden she never forgot.':
      'बुद्धको जन्मस्थल। दीक्षा कक्षा १० को शैक्षिक भ्रमणमा यहाँ गएकी थिइन् — '
          'उनको आफ्नै यात्रा, सहपाठीहरूसँग, परिवारको होइन। लामो बसयात्रा र '
          'कहिल्यै नबिर्सेको शान्त, पवित्र बगैँचा।',
  'Kathmandu': 'काठमाडौं',
  'Our life now': 'हाम्रो अहिलेको जीवन',
  'The city where Diksha & Diya live in a little rented room — studying, '
      'working, chasing dreams, and missing the hills of home.':
      'त्यो सहर जहाँ दीक्षा र दीया सानो भाडाको कोठामा बस्छन् — पढ्दै, काम '
          'गर्दै, सपना पछ्याउँदै, र घरका डाँडा सम्झिँदै।',

  // ── Timeline ─────────────────────────────────────────────────────────────
  'We watched the sun rise over the tea hills 🌄':
      'चियाका डाँडामाथि घाम झुल्किएको हेर्‍यौं 🌄',
  'Won Drawing Competition': 'चित्रकला प्रतियोगिता जितेँ',
  'You got 1st prize! 🏆': 'तिमी प्रथम भयौ! 🏆',
  'Diksha\'s Graduation': 'दीक्षाको दीक्षान्त',
  'Diksha finished her BSc (Hons) IT degree 🎓':
      'दीक्षाले BSc (Hons) IT सिध्याइन् 🎓',
  'A beautiful celebration in our village home. 🎂':
      'गाउँको घरमा एउटा सुन्दर उत्सव। 🎂',
  'Started Dance Class': 'नृत्य कक्षा सुरु',
  'You were so excited! 💃': 'तिमी कति उत्साहित थियौ! 💃',
  'Learned to Cycle': 'साइकल चलाउन सिकेँ',
  'No more training wheels! 🚲': 'अब सहायक पाङ्ग्रा चाहिँदैन! 🚲',
  'Lost Your First Tooth': 'पहिलो दाँत झर्‍यो',
  'The tooth fairy paid a visit. 🦷': 'दाँत परी आएकी थिइन्। 🦷',
  'The bravest little person. 🎒': 'सबैभन्दा बहादुर नानी। 🎒',

  // ── Family bios ──────────────────────────────────────────────────────────
  'Grandfather': 'हजुरबुबा',
  'The gentle root of our family tree. Full of old stories, warm blessings and '
      'the best hugs.':
      'हाम्रो वंश-वृक्षको कोमल जरा। पुराना कथा, न्यानो आशीर्वाद र संसारकै '
          'राम्रो अँगालोले भरिएका।',
  'Can tell the same joke a hundred times and it\'s still funny.':
      'उही ठट्टा सय पटक सुनाए पनि हाँसो उठिहाल्छ।',
  'Father · in Malaysia': 'बुबा · मलेसियामा',
  'Our steady mountain. He works far away in Malaysia so his daughters could '
      'study and chase their dreams — a sacrifice we can never repay. The '
      'strongest, most selfless love we know.':
      'हाम्रो अटल हिमाल। छोरीहरूले पढून्, सपना पछ्याऊन् भनेर उहाँ टाढा '
          'मलेसियामा काम गर्नुहुन्छ — यो त्याग हामी कहिल्यै तिर्न सक्दैनौं। '
          'हामीले चिनेको सबैभन्दा बलियो, सबैभन्दा निस्वार्थ माया।',
  'Video-calls home every night, no matter how tired he is.':
      'जति थाकेको भए पनि हरेक रात घरमा भिडियो कल गर्नुहुन्छ।',
  'Mother · at home in Ilam': 'आमा · इलामको घरमा',
  'The heart of our home in Ilam. She holds everything together and raises '
      'Dipisha with endless love — her kitchen always smelling of woodfire, '
      'maize and warmth.':
      'इलामको हाम्रो घरको मुटु। उहाँले सबथोक थामिराख्नुभएको छ र दिपिशालाई '
          'असीम मायाले हुर्काउनुहुन्छ — उहाँको भान्सा सधैँ दाउराको आगो, मकै र '
          'न्यानोपनको बास्नाले भरिएको।',
  'Somehow always knows when you\'re about to be naughty.':
      'तिमी बदमासी गर्न लाग्दै छौ भन्ने उहाँलाई कसरी हो थाहा भइहाल्छ।',
  'Eldest Sister · Diksha': 'जेठी दिदी · दीक्षा',
  'The keeper of memories — a Flutter developer living in Kathmandu, fresh out '
      'of her BSc (Hons) IT. She built this whole little world so you never, '
      'ever forget how loved you are.':
      'सम्झनाकी संरक्षक — काठमाडौंमा बस्ने Flutter डेभलपर, भर्खरै BSc (Hons) '
          'IT सकेकी। तिमी कति माया पाएकी छौ भन्ने कहिल्यै नबिर्सोस् भनेर '
          'उनैले यो सानो संसार बनाइन्।',
  'Cries happy tears at every single one of your birthdays.':
      'तिम्रो हरेक जन्मदिनमा खुसीका आँसु झार्छिन्।',
  'Middle Sister': 'माहिली दिदी',
  'Your partner in mischief, now studying BBS (2nd year) in Kathmandu with '
      'Diksha. Still the best pillow-fort architect in the whole family.':
      'तिम्री बदमासीकी साथी, अहिले दीक्षासँगै काठमाडौंमा BBS (दोस्रो वर्ष) '
          'पढ्दै। अझै पनि परिवारकै उत्कृष्ट सिरानी-किल्ला बनाउने कालिगड।',
  'Taught you to ride a bicycle in a single afternoon.':
      'एकै दिउँसोमा तिमीलाई साइकल चलाउन सिकाइन्।',
  'The Little Star · Class 3': 'सानो तारा · कक्षा ३',
  'That\'s you! Eight years old, in class 3, growing up in our village home in '
      'Ilam with Mummy — the tiny human who makes every ordinary day feel like '
      'a celebration.':
      'त्यो तिमी हौ! आठ वर्षकी, कक्षा ३ मा, इलामको गाउँघरमा मम्मीसँग '
          'हुर्किँदै — हरेक सामान्य दिनलाई उत्सव बनाइदिने सानो मान्छे।',
  'Once named a stray puppy "Prime Minister".':
      'एक पटक बाटोको छाउरोको नाम "प्रधानमन्त्री" राखेकी थियौ।',
  'Our Dog': 'हाम्रो कुकुर',
  'Stubby\'s brave little son and the fluffiest member of the family. Guards '
      'the house and steals the slippers.':
      'स्टब्बीको बहादुर छाउरो र परिवारकै सबैभन्दा भुवादार सदस्य। घर कुर्छ र '
          'चप्पल चोर्छ।',
  'Comes running the second he hears the fridge open.':
      'फ्रिज खुलेको आवाज सुन्नेबित्तिकै दौडेर आइपुग्छ।',
  'Our Cat': 'हाम्रो बिरालो',
  'The tiny ruler of the house. Naps in every sunbeam and judges everyone '
      'equally.':
      'घरकी सानी रानी। हरेक घामको छालमा सुत्छे र सबैलाई बराबर आँखा लगाउँछे।',
  'Owns the whole family and knows it.':
      'सारा परिवार उसकै हो, र त्यो उसलाई राम्ररी थाहा छ।',
  'Forever in our hearts': 'सधैँ हाम्रो मुटुमा',
  'Our very first furry friend and Arjun\'s mother. She watched you grow up '
      'and loved you fiercely. Always remembered. 🌈':
      'हाम्रो सबैभन्दा पहिलो भुवादार साथी र अर्जुनकी आमा। तिमीलाई हुर्केको '
          'हेरिन् र अगाध माया गरिन्। सधैँ सम्झनामा। 🌈',
  'Would not sleep until every family member was home.':
      'परिवारका सबै घर नआउञ्जेल सुत्दिनथिन्।',
};
