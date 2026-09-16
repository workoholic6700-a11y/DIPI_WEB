import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/viewer/birthdays/birthdays_screen.dart';
import '../../features/viewer/dipisha/achievements_screen.dart';
import '../../features/viewer/dipisha/dipisha_gate_screen.dart';
import '../../features/viewer/dipisha/world/dipisha_world_map_screen.dart';
import '../../features/viewer/dipisha/world/rooms/dipisha_room_screen.dart';
import '../../features/viewer/dipisha/dream_board_screen.dart';
import '../../features/viewer/dipisha/future_messages_screen.dart';
import '../../features/viewer/dipisha/hug_screen.dart';
import '../../features/viewer/dipisha/surprise_screen.dart';
import '../../features/viewer/family/family_tree_screen.dart';
import '../../features/viewer/family/member_detail_screen.dart';
import '../../features/viewer/family/members_screen.dart';
import '../../features/viewer/gallery/album_screen.dart';
import '../../features/viewer/gallery/gallery_screen.dart';
import '../../features/viewer/home/home_entry.dart';
import '../../features/viewer/letters/letter_detail_screen.dart';
import '../../features/viewer/letters/letters_screen.dart';
import '../../features/viewer/memories/memories_screen.dart';
import '../../features/viewer/memories/memory_detail_screen.dart';
import '../../features/viewer/pets/pets_screen.dart';
import '../../features/viewer/places/places_screen.dart';
import '../../features/viewer/quotes/quotes_screen.dart';
import '../../features/viewer/garden/flower_garden_screen.dart';
import '../../features/viewer/hall/celebration_hall_screen.dart';
import '../../features/viewer/heritage/heritage_hub_screen.dart';
import '../../features/viewer/heritage/recipes_screen.dart';
import '../../features/viewer/heritage/roots_screen.dart';
import '../../features/viewer/heritage/traditions_screen.dart';
import '../../features/viewer/heritage/words_screen.dart';
import '../../features/viewer/sakela/sakela_than_screen.dart';
import '../../features/viewer/splash/splash_screen.dart';
import '../../features/viewer/story/our_story_screen.dart';
import '../../features/viewer/timeline/timeline_screen.dart';
import '../../features/viewer/village/village_screen.dart';
import '../../features/viewer/voice/voices_screen.dart';
import '../../features/viewer/home/room/widgets/family_cabinet.dart';
import 'app_routes.dart';

/// The single GoRouter for the whole read-only family storybook.
final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    _page(Routes.splash, (s) => const SplashScreen()),
    _page(Routes.home, (s) => const HomeEntry()),
    familyCabinetRoute(),
    _page(Routes.village, (s) => const VillageScreen()),
    _page(Routes.sakela, (s) => const SakelaThanScreen()),
    _page(Routes.garden, (s) => const FlowerGardenScreen()),
    _page(Routes.hall, (s) => const CelebrationHallScreen()),

    // Heritage — what we keep that isn't photographs.
    _page(Routes.heritage, (s) => const HeritageHubScreen()),
    _page(Routes.heritageWords, (s) => const HeritageWordsScreen()),
    _page(Routes.heritageRecipes, (s) => const HeritageRecipesScreen()),
    _page(Routes.heritageTraditions, (s) => const HeritageTraditionsScreen()),
    _page(Routes.heritageRoots, (s) => const HeritageRootsScreen()),

    // Family app
    _page(Routes.familyTree, (s) => const FamilyTreeScreen()),
    _page(Routes.members, (s) => const MembersScreen()),
    _page(Routes.memberDetail,
        (s) => MemberDetailScreen(memberId: s.pathParameters['id']!)),
    _page(Routes.ourStory, (s) => const OurStoryScreen()),
    _page(Routes.pets, (s) => const PetsScreen()),
    _page(Routes.gallery, (s) => const GalleryScreen()),
    _page(Routes.album, (s) => AlbumScreen(albumId: s.pathParameters['id']!)),
    _page(Routes.timeline, (s) => const TimelineScreen()),
    _page(Routes.birthdays, (s) => const BirthdaysScreen()),
    _page(Routes.places, (s) => const PlacesScreen()),
    _page(Routes.quotes, (s) => const QuotesScreen()),
    _page(Routes.memories, (s) => const MemoriesScreen()),
    _page(Routes.memoryDetail,
        (s) => MemoryDetailScreen(memoryId: s.pathParameters['id']!)),

    // Dipisha's World (gated)
    _page(Routes.dipishaGate, (s) => const DipishaGateScreen()),
    _page(Routes.dipishaWorld, (s) => const DipishaWorldMapScreen()),
    _page(Routes.dipishaRoom, (s) => const DipishaRoomScreen()),
    _page(Routes.letters, (s) => const LettersScreen()),
    _page(Routes.letterDetail,
        (s) => LetterDetailScreen(letterId: s.pathParameters['id']!)),
    _page(Routes.surprise, (s) => const SurpriseScreen()),
    _page(Routes.voices, (s) => const VoicesScreen()),
    _page(Routes.achievements, (s) => const AchievementsScreen()),
    _page(Routes.dreamBoard, (s) => const DreamBoardScreen()),
    _page(Routes.futureMessages, (s) => const FutureMessagesScreen()),
    _page(Routes.hug, (s) => const HugScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Lost the page: ${state.error}')),
  ),
);

/// Builds a route with a soft fade + slide transition (storybook feel).
GoRoute _page(String path, Widget Function(GoRouterState) builder) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: builder(state),
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondary, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
