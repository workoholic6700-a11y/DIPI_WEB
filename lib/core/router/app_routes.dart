/// All route paths for **Our Home**. The public family app is read-only;
/// only Dipisha's World sits behind a playful gate.
abstract final class Routes {
  Routes._();

  static const splash = '/';
  static const home = '/home';
  static const cabinet = '/cabinet';

  // Rai Village — the optional immersive "living world" layer (opens the
  // existing screens; never replaces them).
  static const village = '/village';

  // Sakela Than — our Kirat sacred spot (nature worship, Sumnima & Paruhang).
  static const sakela = '/sakela';

  // Flower Garden — our phulbari, the living garden scene.
  static const garden = '/garden';

  // Celebration Hall — the long table, laid.
  static const hall = '/hall';

  // Heritage — the part of this home that isn't photographs: our words, our
  // food, why we do what we do every year, and how we ended up spread across
  // three places.
  static const heritage = '/heritage';
  static const heritageWords = '/heritage/words';
  static const heritageRecipes = '/heritage/recipes';
  static const heritageTraditions = '/heritage/traditions';
  static const heritageRoots = '/heritage/roots';

  // Family app (read-only)
  static const familyTree = '/family-tree';
  static const members = '/members';
  static const memberDetail = '/members/:id';
  static const ourStory = '/our-story';
  static const pets = '/pets';
  static const gallery = '/gallery';
  static const album = '/gallery/:id';
  static const timeline = '/timeline';
  static const birthdays = '/birthdays';
  static const places = '/places';
  static const quotes = '/quotes';
  static const memories = '/memories';
  static const memoryDetail = '/memories/:id';

  // Dipisha's World (gated)
  static const dipishaGate = '/dipisha';
  static const dipishaWorld = '/dipisha/world';

  // Rooms inside her world — each one is Nana talking to her, not a
  // duplicate of the family app.
  static const dipishaRoom = '/dipisha/world/room';
  static const letters = '/dipisha/letters';
  static const letterDetail = '/dipisha/letters/:id';
  static const surprise = '/dipisha/surprise';
  static const voices = '/dipisha/voices';
  static const achievements = '/dipisha/achievements';
  static const dreamBoard = '/dipisha/dreams';
  static const futureMessages = '/dipisha/future';
  static const hug = '/dipisha/hug';

  static String memberOf(String id) => '/members/$id';
  static String memoryOf(String id) => '/memories/$id';
  static String letterOf(String id) => '/dipisha/letters/$id';
  static String albumOf(String id) => '/gallery/$id';
}
