# Decisions

Choices the family has made about **Dear Dipisha** that look like bugs from
the outside.

More than one assistant works on this repo. Everything here has already been
argued once and settled by Diksha — so if a change of yours would reverse
something on this list, **ask her first**. Don't "fix" it.

Add to this file whenever she decides something a reasonable person would
otherwise undo.

---

## Nana's letters open only through Dipisha's World

**Decided:** 2026-08-05, confirmed twice.

Tapping the envelope on the Home table opens **`Routes.dipishaGate`**, not
`Routes.letterOf(...)`. Letters are also deliberately absent from the family
cabinet.

*Why:* the letters are Nana's, written to Dipisha. They belong inside her own
world, not in the family front room where anyone might open one. The envelope
on the table says a letter is waiting — it doesn't hand it over.

*Why it looks wrong:* an object that names a letter and then opens a gate reads
like a routing mistake. It is not.

*What is fine:* the envelope shows only "To: Dipisha / From: Nana" — never the
letter's title, on screen or to a screen reader.

`lib/features/viewer/home/room/home_room_screen.dart` → `onLetter`

---

## Nothing is invented — ever

**Standing rule.** The hardest one on this project.

A plausible-looking guess is worse than a visible gap, because in ten years
nobody will be able to tell it from the truth. This has already gone wrong
three times:

- **Birthdays** displayed three stand-in dates as fact for months.
- **Albums** claimed 30–80 photographs each while containing none, and
  generated placeholder tiles captioned "… · moment 1 … moment 80".
- **A person's page** showed the four most *recent* memories as that person's
  "Favourite Memories" — the same four for everyone.

All three are fixed, and each is now held by a test rather than a comment:
`test/birthdays_honesty_test.dart`, `test/heritage_test.dart`.

**When you don't have something, say so and name who can supply it.** That is
what "Still to add 💌", "not confirmed", and the whole Our Roots section are
for. Follow the existing convention rather than inventing a new one.

The family's own Rai dialect is absent from Our Words **on purpose** — "Rai"
spans Bantawa, Chamling, Kulung and ~30 more languages, and only this family
knows which is theirs. A test fails the build if anyone seeds a Kirat word
outside the Mundhum/Sakela vocabulary already in use.

---

## Kopa is alive

**Decided:** 2026-08-05.

Whether a seat, frame or entry is a memorial comes from
`FamilyMember.inMemoriam` and nowhere else. **Stubby the dog is the only one.**

The Celebration Hall used to hardcode `id == 'f_grandpa'` as deceased and lay
his place with a marigold. It was wrong, and Our Roots was simultaneously
telling the reader to go and ask him things.

---

## Never a work domain

**Decided:** 2026-08-05.

The app id is **`com.rai.dear_dipisha`** (iOS `com.rai.dearDipisha`). This is a
private family gift and has no connection to anyone's employer. Never
reintroduce a company domain into package ids, bundle ids, copyright strings,
author fields or store listings.

---

## Every asset is ours or openly licensed

**Standing rule.**

A Blue Lock manga panel used to sit in Didi's Corner — the one asset that was
neither. It's gone, replaced by `family/widgets/didi_pitch.dart`, drawn in
code. Naming the show she loves is fine; the artwork couldn't travel.

If something can't be drawn, check the licence before it lands in `assets/`.

---

## Light is the default; only the world film loops

**Standing rules.**

`themeMode` follows a remembered choice ("Reading in bed", in the family
cabinet) and **not** the system setting — half the phones in this family sit in
dark mode permanently, and a pastel scrapbook that turned dark on first open
would read as broken.

Entrance animations play once and stop. There are no ambient particles or
continuous loops: a per-frame sim already had to be removed once for stuttering
on the target device (SM-A065F). State changes that mean something — a sealed
envelope, a lit candle, a raised mailbox flag — are worth more than motion.

**Exception decided by Diksha, 2026-08-07:** the eight-second background film
in Dipisha's World loops continuously. The moving dog, ducks, water, leaves and
blossoms are the life of that place, not decorative UI particles. It stays
silent, uses the platform video decoder, and keeps the static world PNG beneath
it as a loading/error fallback.

This exception is only for `assets/videos/dipisha_world.mp4`. It does not allow
repeating Flutter animation controllers, Lotties, particles, or looping video
on any other screen. If the film performs poorly on the SM-A065F, show the PNG
fallback; do not add a second animation system on top.

---

## Names don't split

**Standing rule.**

Use `FamilyMember.shortName`, never `name.split(' ').first`. Papa is **Rup
Raj** Rai — his given name is two words, and splitting called him "Rup" in 17
places. Set `callName` for anyone whose short form isn't the first word.


## Gallery viewing needs no account

**Decided:** 2026-09-07. Published albums and their published photos are readable
without signing in. Only the admin album desk requires login. A small icon at the top of the gallery
opens it natively inside the app (requested by Diksha); the web portal is optional. Draft albums,
draft photos, and all upload/edit/delete operations remain restricted to the admin.

## Admin login lasts only for the current app session

**Decided:** 2026-09-07. Diksha wants admin login again after fully closing and
reopening the app, not every time the Album Desk icon is tapped. Keep the session
in memory, never persist it across launches, and remove the previously saved
Supabase session when upgrading. Brief backgrounding, including the photo picker,
must not interrupt the current login. Published family albums still need no login.
The optional web admin also starts signed out after a page reload.

## Imported photos are bundled; All Photos includes every album

**Decided:** 2026-09-09. Diksha supplies local photo folders to include in the
app assets and save Supabase storage. Keep one bundled copy of exact duplicate
files. The All Photos album includes every bundled gallery photo and every
published cloud photo, regardless of its album. It is a combined view, not
a second copy or a folder that needs filling separately. Drafts stay private.
Bundled photos remain viewable while the cloud is loading or unavailable.

The September import uses visible occasions, settings, and group compositions
for album placement. Names, exact places, and capture dates remain unconfirmed
unless the family supplies them; do not derive dates from WhatsApp filenames.

## Photographs are filed by who is in them

**Decided:** 2026-09-09, by Diksha.

A picture of one person goes in that person's album — Little Dipisha, Diya,
Diksha, Mummy & Papa, Kopa's Blessings, the pets. A picture of several people
goes in Family Together. Diksha's graduation has **one** album,
`graduation` ("Diksha's Graduation 🎓"); the duplicate `graduation_days` was
removed, and so was `out_and_about`, which held only single-person portraits.

*Why it looks wrong:* Everyday Magic and Cakes & Candles now stand empty on the
shelf while Dipisha with her teddy bear and Diya's 20th birthday sit in the
person albums. That is the filing rule, not a lost photo.

*What is still open:* nobody has been named from a face where the match was
not certain — see the September import note in `PHOTOS_GUIDE.md` for the five
files waiting on Diksha or Mummy.

## The app icon is Dipisha holding out her pink dress, on white

**Decided:** 2026-09-09, by Diksha, with the exact photograph attached in chat.

Use the photograph in `assets/images/albums/dipisha_8.jpg`: Dipisha holding out
the sides of her pink dress. The launcher artwork has the background removed
and replaced with white. The selected icon asset is
`assets/images/albums/dipisha_13.png`, separate from her family-page portrait.
Android's adaptive background is white too, with padding to keep her head and
dress inside the launcher mask. Android, iOS and web icons use this same asset.

Diksha also asked to keep **both** generated white-background pictures in Little
Dipisha and All Photos: the skirt-held-out picture (`dipisha_13.png`) and the
long gown with the yellow flower hair clip (`dipisha_14.png`). Both are captioned
**AI-edited · white background**, including in the full-screen viewer; their
original photographs remain in the album. The icon and gallery share the same
skirt-held-out image file.

## Dipisha's birthday card uses the first generated portrait

**Decided:** 2026-09-09, by Diksha.

The “Dipisha's Birthday” polaroid on the Home table uses the first generated
white-background picture: the long pink gown with the yellow flower hair clip
(`AppPhotos.dipishaGownWhite`, `dipisha_14.png`). It carries the same AI-edited
caption as the album. Diksha also asked for that same picture on the page opened
from the card. Use it consistently on memory cards, the opened memory page and
its story cover, with the whole portrait visible and the caption outside the
image. Original memory photo slots and birthday details remain intact.

## Decorative emojis should feel like the family home

**Decided:** 2026-09-09, by Diksha.

Avoid camera emojis in app decoration and headings. Diksha prefers plants,
flowers, hearts and faces; camera emojis make the design feel AI-generated to
her. Apply this preference to future additions as well. Camera controls that
actually take a picture retain their recognizable action icons.

## The imagined family graduation pictures belong in the albums

**Decided:** 2026-09-09, by Diksha.

Keep all three requested family graduation composites in Diksha's Graduation and
All Photos: the close portrait (`graduation_10.png`) and full-length picture
(`graduation_11.png`), plus the classic studio portrait (`graduation_12.png`)
with Papa in a formal suit and all five standing upright and elegant. Keep the
earlier two pictures as well. They are captioned **AI-composed from our photos**
and have no capture date. Diksha said only Diya could attend; these pictures imagine
the parents and Dipisha joining them. Show the complete group in landscape
album frames so no family member is cropped out.

## Story illustrations fill picture spaces, not missing family facts

**Decided:** 2026-09-09, by Diksha.

Diksha asked for realistic scenes using the family's real faces to fill missing
pictures across Memories, Our Story and Places. These are commissioned story
illustrations, labelled **AI-imagined from our stories**, not documentary event
photos. Reuse their single gallery asset in each relevant screen and All Photos;
keep original family photographs and stored story text/dates intact. Counts come
from actual bundled files, never declared empty photo slots or place counts.

Her explicit kitchen direction is Mummy cooking sabji of peas grown in their own
fields on a chulo in an Ilam/Mangalbare village kitchen. She requested corrected
face/body proportions after the first version. The selected revised file is
`parents_7.png` (`mummy-peas-chulo-v2.png` in the generation record). The written
maize/kholo memory stays intact; the image is an imagined scene using the newly
supplied visual detail.

Named-person and birth chapters use existing family portraits, not invented baby
photos. Dipisha's school memory uses her original school portrait; the Lumbini
tour uses scenery rather than inventing past classmates. Unknown pet appearances,
unwritten messages, unconfirmed achievements and missing recipe methods or
handwriting remain gaps. Full audit/placements and prompts live in
`output/imagegen/story-scenes-20260909/README.md`.

## Papa's village fields belong with the family pictures

**Decided:** 2026-09-09, by Diksha.

Diksha says vegetable fields surround their village home: maize, peas, tea,
cardamom, ginger, mustard, chillies and cauliflower, with rhododendron in the
surroundings. Papa used to sprinkle water on the plants. She requested realistic
pictures of him there, using his real face.

Keep the three imagined scenes in Mummy & Papa and All Photos: watering the
vegetables (`parents_8.png`), tea hills with mustard and rhododendron
(`parents_9.png`), and cardamom/ginger (`parents_10.png`). Use the existing
**AI-imagined from our stories** caption, no capture date, and a complete
landscape frame. Exact layout, clothes and staging are imagined; the supplied
crop list and watering memory come from Diksha. Preserve Papa's original
portrait and the Malaysia chapter. Prompts and outputs are recorded in
`output/imagegen/papa-fields-20260909/README.md`.

## Wait for the family's real home photograph

**Decided:** 2026-09-09, by Diksha, superseding the imagined home placement above.

Diksha says the generated house does not look like their actual home and will
supply a photograph later. Remove the **Ilam — Our Home** album (`ilam`) and
the standalone imagined house image (`albums/ilam_1.png`) from the app, including
All Photos, the Growing up in Ilam chapter and the Mangalbare place. Do not invent
a replacement house or restore the removed album without her photo/direction.
The generation record is historical provenance, not a reference for the actual house.

**Follow-up direction in the same conversation:** show the place's environment
without the house. Use the new house-free fields/hills scene
(`albums/hills_nature_2.png`, `AppPhotos.ilamFields`) in Mangalbare and Growing up
in Ilam, plus Hills & Nature and All Photos. Keep the imagined-story caption and
no photo date. The `ilam` album remains removed. Exact prompt and output:
`output/imagegen/ilam-fields-no-house-20260909/README.md`.

## Back from a cabinet shelf returns to the open cabinet

**Decided:** 2026-09-10, by Diksha.

Taking something down from the family cabinet leaves the cabinet open
underneath it. Pressing back from Gallery, Members, Places and the rest lands
in front of the open cabinet, and only its Close button (or tapping outside it)
returns to the room. Do not "fix" this by closing the cabinet before opening a
shelf; `test/cabinet_back_test.dart` holds it.

*Why:* Diksha opens the cabinet to browse several things in a row. Being
dropped back into the room after each one meant reopening the cabinet every
time.

## A bee and a butterfly visit every family screen

**Decided:** 2026-09-10, by Diksha, asked three times, after being told this
is the ambient life the "nothing loops" rule exists to prevent.

A honey bee or the orange butterfly wanders over the viewer's screens the way
it would over a garden: flies in, rests on a "flower" a few seconds, flies on,
leaves; touching it shows a small cute line. Never on the album desk or on
anything opened from it. The limits that keep her phone smooth, and which
must stay:

- one visitor at a time, with long quiet stretches between visits;
- the drawing runs at 20 fps in its own layer, sized like a real insect;
- it is gone the moment reduced motion, the album desk, the background, or
  the cabinet switch says so;
- the cabinet has a switch ("Let the bees rest") and the choice is remembered.

*Why:* Diksha wanted the screens to feel alive the way the garden outside is.
If the phone stutters, turn it off in the cabinet and tell her; do not delete
it. `test/garden_visitors_test.dart` holds the behaviour.
