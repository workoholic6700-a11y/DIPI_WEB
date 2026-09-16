/// Central manifest of every real-photo "slot" in the app.
///
/// HOW IT WORKS
/// ------------
/// Every place that can show a real photo references a *named slot* from here.
/// To fill a slot, just drop an image file with the matching name into the
/// matching folder under `assets/images/` — the app picks it up automatically
/// on the next run. If a file is missing, that spot shows a soft gradient
/// placeholder (or the person's emoji) instead — never a crash.
///
/// See `PHOTOS_GUIDE.md` at the project root for the full human-readable list
/// of filenames and which screen each one appears on.
abstract final class AppPhotos {
  AppPhotos._();

  static const _base = 'assets/images';

  // ── Family avatars → assets/images/family/<name>.jpg ─────────────────────
  // Used on: Family Members, Family Tree, Member detail, Birthdays, Profile.
  static const grandfather =
      '$_base/family/grandfather.jpg'; // Dalbahadur (Kopa)
  static const father = '$_base/family/father.jpg'; // Rup Raj (Papa)
  static const mother = '$_base/family/mother.jpg'; // Sanchu (Mummy)
  static const diksha = '$_base/family/diksha.jpg'; // Didi
  static const diya = '$_base/family/diya.jpg';
  static const dipisha = '$_base/family/dipisha.jpg';
  static const dipishaSchool = '$_base/family/dipisha_school.jpg';
  static const arjun = '$_base/family/arjun.jpg'; // dog
  static const meow = '$_base/family/meow.jpg'; // cat
  static const stubby = '$_base/family/stubby.jpg'; // memorial

  /// Mummy and Papa together — the one picture of the family rather than of a
  /// person. Used as the big frame on the Home mantel.
  static const parents = '$_base/family/parents.jpg';
  static const familyComposite = '$_base/family/family_composite_v2.png';

  /// Diksha's graduation — the day the years in Malaysia paid for.
  static const graduation = '$_base/family/graduation.jpg';

  // ── Dynamic slots (built from an item's id) ──────────────────────────────

  /// The folder every album cover and album photo lives in. Exposed so the
  /// real photo count can be read off the asset bundle instead of trusting a
  /// hand-written number.
  static const albumsDir = '$_base/albums/';
  static const allPhotosAlbumId = 'all_photos';
  static const dipishaPinkWhite = '${albumsDir}dipisha_13.png';
  static const dipishaGownWhite = '${albumsDir}dipisha_14.png';
  static const graduationFamilyPortrait = '${albumsDir}graduation_10.png';
  static const graduationFamilyFullLength = '${albumsDir}graduation_11.png';
  static const graduationFamilyStudio = '${albumsDir}graduation_12.png';
  static const mummyKitchen = '${albumsDir}parents_7.png';
  static const papaWateringVegetables = '${albumsDir}parents_8.png';
  static const papaTeaFields = '${albumsDir}parents_9.png';
  static const papaCardamomGinger = '${albumsDir}parents_10.png';
  static const dipishaDrawing = '${albumsDir}dipisha_15.png';
  static const dipishaDashain = '${albumsDir}dipisha_16.png';
  static const dipishaCycling = '${albumsDir}dipisha_17.png';
  static const rainyMomos = '${albumsDir}dipisha_18.png';
  static const antuSunrise = '${albumsDir}tea_gardens_1.png';
  static const rankeFields = '${albumsDir}hills_nature_1.png';
  static const ilamFields = '${albumsDir}hills_nature_2.png';
  static const lumbiniGarden = '${albumsDir}school_1.png';
  static const kathmanduSisters = '${albumsDir}family_together_20.png';
  static const imaginedStoryCaption = 'AI-imagined from our stories';
  static const storyScenes = {
    mummyKitchen,
    papaWateringVegetables,
    papaTeaFields,
    papaCardamomGinger,
    dipishaDrawing,
    dipishaDashain,
    dipishaCycling,
    rainyMomos,
    antuSunrise,
    rankeFields,
    ilamFields,
    lumbiniGarden,
    kathmanduSisters,
  };
  static const landscapeAlbumPhotos = {
    graduationFamilyPortrait,
    graduationFamilyFullLength,
    graduationFamilyStudio,
    ...storyScenes,
  };
  static const albumCaptions = {
    dipishaPinkWhite: 'AI-edited · white background',
    dipishaGownWhite: 'AI-edited · white background',
    graduationFamilyPortrait: 'AI-composed from our photos',
    graduationFamilyFullLength: 'AI-composed from our photos',
    graduationFamilyStudio: 'AI-composed from our photos',
    mummyKitchen: imaginedStoryCaption,
    papaWateringVegetables: imaginedStoryCaption,
    papaTeaFields: imaginedStoryCaption,
    papaCardamomGinger: imaginedStoryCaption,
    dipishaDrawing: imaginedStoryCaption,
    dipishaDashain: imaginedStoryCaption,
    dipishaCycling: imaginedStoryCaption,
    rainyMomos: imaginedStoryCaption,
    antuSunrise: imaginedStoryCaption,
    rankeFields: imaginedStoryCaption,
    ilamFields: imaginedStoryCaption,
    lumbiniGarden: imaginedStoryCaption,
    kathmanduSisters: imaginedStoryCaption,
  };

  static String? captionFor(String asset) =>
      albumCaptions[asset] ??
      {
        grandfather: 'Kopa · family portrait',
        father: 'Papa · family portrait',
        mother: 'Mummy · family portrait',
        parents: 'A photograph from our family album',
        diksha: 'Diksha · family portrait',
        diya: 'Diya · family portrait',
        dipisha: 'Dipisha · family portrait',
        dipishaSchool: 'Dipisha · school portrait',
        stubby: 'Stubby · original photograph',
        '$_base/memories/m10.jpg': 'Stubby · original photograph',
      }[asset];

  /// Album cover → `assets/images/albums/<albumId>.jpg`  (e.g. a1.jpg)
  static String album(String albumId) => '$_base/albums/$albumId.jpg';

  /// A photo inside an album → `assets/images/albums/<albumId>_<n>.jpg`
  /// (n starts at 1, e.g. a1_1.jpg, a1_2.jpg …)
  static String albumPhoto(String albumId, int index) =>
      '$_base/albums/${albumId}_${index + 1}.jpg';

  /// Memory cover → `assets/images/memories/<memoryId>.jpg`  (e.g. m1.jpg)
  static String memory(String memoryId) => '$_base/memories/$memoryId.jpg';

  /// The chosen cover for memory cards, their opened page and story view.
  static String memoryCardCover(String memoryId) => switch (memoryId) {
    'm1' => antuSunrise,
    'm2' => dipishaGownWhite,
    'm3' => dipishaDrawing,
    'm4' => dipishaDashain,
    'm5' => lumbiniGarden,
    'm6' => dipishaCycling,
    'm7' => rainyMomos,
    'm8' => dipishaSchool,
    'm9' => mummyKitchen,
    _ => memory(memoryId),
  };

  static String? storyChapterPhoto(String title) => const {
    'Where it all began': grandfather,
    'Rup Raj & Sanchu': parents,
    'The first little star — Diksha': diksha,
    'Along came Diya': diya,
    'Our littlest star — Dipisha': dipisha,
    'Stubby, Arjun & Meow': stubby,
    'Growing up in Ilam': ilamFields,
    'Maize, kholo & the chulo fire': mummyKitchen,
    'He went far, so we could go far': father,
    'Stubby, our first love': stubby,
    'Still writing our story': graduationFamilyStudio,
  }[title];

  /// A photo inside a memory → `assets/images/memories/<memoryId>_<n>.jpg`
  static String memoryPhoto(String memoryId, int index) =>
      '$_base/memories/${memoryId}_${index + 1}.jpg';

  /// Letter photo → `assets/images/letters/<letterId>_<n>.jpg`
  static String letterPhoto(String letterId, int index) =>
      '$_base/letters/${letterId}_${index + 1}.jpg';

  /// Place cover → `assets/images/places/<placeId>.jpg`  (e.g. pl1.jpg)
  static String place(String placeId) => switch (placeId) {
    'pl1' => ilamFields,
    'pl2' => antuSunrise,
    'pl3' => rankeFields,
    'pl4' => lumbiniGarden,
    'pl5' => kathmanduSisters,
    _ => '$_base/places/$placeId.jpg',
  };
}
