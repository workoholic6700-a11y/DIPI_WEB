import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/i18n/l10n.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_mode.dart';
import '../home_atmosphere.dart';
import '../../../visitors/garden_visitors.dart';

/// The piece of furniture that holds the rest of the app.
///
/// It is deliberately not a menu button. On Home it reads as a real cabinet;
/// opening it reveals the same cabinet at room scale, with destinations kept
/// as objects on shelves.
class CabinetHandle extends ConsumerWidget {
  const CabinetHandle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final atmos = ref.watch(atmosphereProvider);
    final wood = Color.lerp(atmos.frameWood, const Color(0xFF6A3F2A), 0.42)!;
    final darkWood = Color.lerp(wood, Colors.black, 0.30)!;

    return Semantics(
      button: true,
      label: trS(lang, 'The family cabinet. Open everything we keep.'),
      child: GestureDetector(
        onTap: () => showFamilyCabinet(context),
        child: SizedBox(
          height: 166,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 8,
                right: 8,
                top: 9,
                bottom: 7,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [wood, darkWood],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                      bottom: Radius.circular(5),
                    ),
                    border: Border.all(color: darkWood, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: atmos.shelfShadow,
                        blurRadius: 16,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _MiniDoor(
                                wood: wood,
                                darkWood: darkWood,
                                handleOnRight: true,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _MiniDoor(
                                wood: wood,
                                darkWood: darkWood,
                                handleOnRight: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 25,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            wood,
                            const Color(0xFFB7794C),
                            0.18,
                          ),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: darkWood),
                        ),
                        child: Center(
                          child: Container(
                            width: 34,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7B66B),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 17,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkWood, wood, darkWood],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEACF8B), Color(0xFFB98A3F)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: const Color(0xFF8E652C)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                    child: Text(
                      trS(lang, 'EVERYTHING WE KEEP'),
                      style: TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                        color: darkWood,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                left: 17,
                right: 17,
                child: Text(
                  trS(lang, 'Tap the brass handles to open'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: atmos.inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniDoor extends StatelessWidget {
  const _MiniDoor({
    required this.wood,
    required this.darkWood,
    required this.handleOnRight,
  });

  final Color wood;
  final Color darkWood;
  final bool handleOnRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color.lerp(wood, Colors.white, 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: darkWood),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: darkWood.withValues(alpha: 0.65)),
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(wood, Colors.white, 0.10)!,
                    Color.lerp(wood, Colors.black, 0.11)!,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: handleOnRight ? 5 : null,
            left: handleOnRight ? null : 5,
            child: Center(
              child: Container(
                width: 8,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF2D083), Color(0xFFA8752C)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF80571F)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Every existing destination remains here. Tests and other screens can keep
/// treating this as the source of truth for cabinet navigation.
const familyCabinet = <(String, List<(String, String, IconData)>)>[
  (
    'Family',
    [
      ('Family Members', Routes.members, Icons.groups_rounded),
      ('Family Tree', Routes.familyTree, Icons.account_tree_rounded),
      ('Our Story', Routes.ourStory, Icons.menu_book_rounded),
      ('Pets', Routes.pets, Icons.pets_rounded),
    ],
  ),
  (
    'Memories',
    [
      ('Gallery', Routes.gallery, Icons.photo_library_rounded),
      ('Memories', Routes.memories, Icons.auto_stories_rounded),
      ('Timeline', Routes.timeline, Icons.timeline_rounded),
      ('Places', Routes.places, Icons.map_rounded),
      ('Family Quotes', Routes.quotes, Icons.format_quote_rounded),
    ],
  ),
  (
    'Celebrations',
    [
      ('Birthdays', Routes.birthdays, Icons.cake_rounded),
      ('Celebration Hall', Routes.hall, Icons.celebration_rounded),
    ],
  ),
  (
    'Our Roots',
    [
      ('Our Roots', Routes.heritage, Icons.history_edu_rounded),
      ('Sakela Than', Routes.sakela, Icons.park_rounded),
      ('Flower Garden', Routes.garden, Icons.local_florist_rounded),
    ],
  ),
  ('Outside', [('Rai Village', Routes.village, Icons.cottage_rounded)]),
  (
    'Magic',
    [('Dipisha\'s World', Routes.dipishaGate, Icons.auto_awesome_rounded)],
  ),
];

/// Opens the cabinet as a see-through page over the room. Whatever is taken
/// down from a shelf opens on top of it, so back returns to the open cabinet
/// and only Close (or tapping outside) returns to the room. See DECISIONS.md.
Future<void> showFamilyCabinet(BuildContext context) =>
    GoRouter.of(context).push<void>(Routes.cabinet);

/// The cabinet's route, shared by the app router and its tests.
GoRoute familyCabinetRoute() => GoRoute(
  path: Routes.cabinet,
  pageBuilder: (context, state) {
    final lang = ProviderScope.containerOf(context).read(langProvider);
    return CustomTransitionPage<void>(
      key: state.pageKey,
      opaque: false,
      barrierDismissible: true,
      barrierLabel: trS(lang, 'Close the family cabinet'),
      barrierColor: const Color(0xC92A1713),
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      child: const FamilyCabinetRoom(),
      transitionsBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  },
);

class FamilyCabinetRoom extends ConsumerStatefulWidget {
  const FamilyCabinetRoom({super.key});

  @override
  ConsumerState<FamilyCabinetRoom> createState() => _FamilyCabinetRoomState();
}

class _FamilyCabinetRoomState extends ConsumerState<FamilyCabinetRoom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _doors;

  @override
  void initState() {
    super.initState();
    _doors = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 880),
    )..forward();
  }

  @override
  void dispose() {
    _doors.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        minimum: const EdgeInsets.all(9),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: _CabinetFrame(lang: lang, doors: _doors),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Semantics(
                          button: true,
                          label: trS(lang, 'Close the family cabinet'),
                          child: Material(
                            color: const Color(0xFFE4C477),
                            shape: const CircleBorder(),
                            elevation: 5,
                            child: IconButton(
                              tooltip: trS(lang, 'Close'),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Color(0xFF55331F),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CabinetFrame extends StatelessWidget {
  const _CabinetFrame({required this.lang, required this.doors});

  final AppLang lang;
  final AnimationController doors;

  @override
  Widget build(BuildContext context) {
    const wood = Color(0xFF75472F);
    const woodDark = Color(0xFF3F241B);

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 35, 13, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B6743), wood, woodDark],
          stops: [0, 0.46, 1],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
          bottom: Radius.circular(9),
        ),
        border: Border.all(color: const Color(0xFF301A14), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -27,
            left: 42,
            right: 42,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0D590), Color(0xFFB78236)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF704919),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 5),
                  ],
                ),
                child: Text(
                  trS(lang, 'THE RAI FAMILY CABINET'),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4C2B19),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D201D),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: woodDark, width: 2),
              ),
              child: _CabinetInterior(lang: lang),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: doors,
              builder: (context, _) {
                final opening = Curves.easeInOutCubic.transform(doors.value);
                return IgnorePointer(
                  ignoring: opening > 0.45,
                  child: Row(
                    children: [
                      Expanded(
                        child: Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(-1.28 * opening),
                          child: const _LargeDoor(handleOnRight: true),
                        ),
                      ),
                      Expanded(
                        child: Transform(
                          alignment: Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(1.28 * opening),
                          child: const _LargeDoor(handleOnRight: false),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeDoor extends StatelessWidget {
  const _LargeDoor({required this.handleOnRight});

  final bool handleOnRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: handleOnRight ? Alignment.centerLeft : Alignment.centerRight,
          end: handleOnRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: const [Color(0xFF9B6642), Color(0xFF5A3425)],
        ),
        border: Border.all(color: const Color(0xFF351E17), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(child: _DoorPanel(arched: true)),
                const SizedBox(height: 9),
                const Expanded(child: _DoorPanel()),
              ],
            ),
          ),
          Positioned(
            right: handleOnRight ? 5 : null,
            left: handleOnRight ? null : 5,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 13,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE3A0), Color(0xFFB47B29)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF754A17)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoorPanel extends StatelessWidget {
  const _DoorPanel({this.arched = false});

  final bool arched;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF865637), Color(0xFF67402D)],
        ),
        borderRadius: arched
            ? const BorderRadius.vertical(top: Radius.circular(45))
            : BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF45281E), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          arched ? Icons.family_restroom_rounded : Icons.spa_rounded,
          color: const Color(0x55E6BD74),
          size: arched ? 46 : 34,
        ),
      ),
    );
  }
}

/// How far the opened doors reach back over the inside of the cabinet.
///
/// The doors are drawn on top of the interior, so anything laid out closer to
/// the edges than this disappears behind them once they swing open. Shelf
/// labels were being clipped to "…UR ROOTS" and "…mily Members" for exactly
/// this reason.
const double kCabinetDoorInset = 72;

class _CabinetInterior extends ConsumerWidget {
  const _CabinetInterior({required this.lang});

  final AppLang lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final night = ref.watch(themeChoiceProvider) == AppThemeChoice.night;
    final room = ref.watch(homeStyleProvider) == HomeStyle.room;
    final visitors = ref.watch(visitorsEnabledProvider);

    void openRoute(String route) {
      // The cabinet stays open underneath the screen it opens, so the back
      // button returns to it rather than to the room. See DECISIONS.md.
      GoRouter.of(context).push(route);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF312522), Color(0xFF1E1716)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    kCabinetDoorInset, 20, 62, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trS(lang, 'Everything we keep'),
                      style: t.headlineSmall?.copyWith(
                        color: const Color(0xFFFFF5E6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trS(lang, 'Choose something from our family shelves.'),
                      style: const TextStyle(
                        color: Color(0xFFCDBEB4),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < familyCabinet.length; i++)
              SliverToBoxAdapter(
                child: _KeepsakeShelf(
                  title: trS(lang, familyCabinet[i].$1),
                  groupIndex: i,
                  items: familyCabinet[i].$2,
                  lang: lang,
                  onOpen: openRoute,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                // Clear of both doors — the lamp switch was half hidden under
                // the right one.
                padding: const EdgeInsets.fromLTRB(
                    kCabinetDoorInset - 14, 10, kCabinetDoorInset - 14, 18),
                child: Column(
                  children: [
                    _CabinetDrawer(
                      icon: night
                          ? Icons.bedtime_rounded
                          : Icons.wb_sunny_rounded,
                      label: trS(
                        lang,
                        night ? 'Turn the lamp on' : 'Reading in bed',
                      ),
                      trailing: Switch.adaptive(
                        value: night,
                        activeTrackColor: AppColors.lavender,
                        onChanged: (_) =>
                            ref.read(themeChoiceProvider.notifier).toggle(),
                      ),
                      onTap: () =>
                          ref.read(themeChoiceProvider.notifier).toggle(),
                    ),
                    const SizedBox(height: 8),
                    _CabinetDrawer(
                      icon: room
                          ? Icons.grid_view_rounded
                          : Icons.chair_rounded,
                      label: room
                          ? trS(lang, 'Switch to the old home')
                          : trS(lang, 'Switch to the new home'),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFE9C77C),
                      ),
                      onTap: () {
                        ref.read(homeStyleProvider.notifier).toggle();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 8),
                    _CabinetDrawer(
                      icon: Icons.emoji_nature_rounded,
                      label: trS(
                        lang,
                        visitors ? 'Let the bees rest' : 'Let the bees fly',
                      ),
                      trailing: Switch.adaptive(
                        value: visitors,
                        activeTrackColor: AppColors.lavender,
                        onChanged: (_) =>
                            ref.read(visitorsEnabledProvider.notifier).toggle(),
                      ),
                      onTap: () =>
                          ref.read(visitorsEnabledProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeepsakeShelf extends StatelessWidget {
  const _KeepsakeShelf({
    required this.title,
    required this.groupIndex,
    required this.items,
    required this.lang,
    required this.onOpen,
  });

  final String title;
  final int groupIndex;
  final List<(String, String, IconData)> items;
  final AppLang lang;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Clear of the open doors. The doors swing back over the outer
            // edges of the interior, so content padded to 16 sat underneath
            // them — every shelf label lost its first letters ("…UR ROOTS").
            padding: const EdgeInsets.only(left: kCabinetDoorInset, right: 20),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4C477),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE8D5B6),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Two to a row, wrapping onto the next line.
          //
          // These used to sit in one horizontally-scrolling row, which put a
          // third keepsake half under the right door on every shelf — you
          // could reach it, but only by discovering that the shelf scrolled,
          // and a cupboard shelf that hides things is a bad cupboard. Wrapping
          // means everything on a shelf is visible at once.
          Padding(
            padding: const EdgeInsets.only(
                left: kCabinetDoorInset - 8, right: kCabinetDoorInset - 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                for (var i = 0; i < items.length; i++)
                  _Keepsake(
                    label: trS(lang, items[i].$1),
                    icon: items[i].$3,
                    color: _groupColor(groupIndex),
                    shapeIndex: i,
                    onTap: () => onOpen(items[i].$2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 10,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFA26A42), Color(0xFF503024)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 7,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Color _groupColor(int index) => const [
    Color(0xFFD9A6B8),
    Color(0xFF9FBBD3),
    Color(0xFFE4BD6A),
    Color(0xFF89B18A),
    Color(0xFFC39D77),
    Color(0xFFAA91D2),
  ][index % 6];
}

class _Keepsake extends StatelessWidget {
  const _Keepsake({
    required this.label,
    required this.icon,
    required this.color,
    required this.shapeIndex,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int shapeIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final round = shapeIndex.isOdd;
    return Semantics(
      button: true,
      label: '$label. Open from the family cabinet.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            // Sized so two sit side by side between the open doors, with the
            // label underneath having room for two lines.
            width: 78,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 5, 2, 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: shapeIndex.isEven ? -0.015 : 0.015,
                    child: Container(
                      width: round ? 46 : 50,
                      height: round ? 46 : 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: round
                            ? BorderRadius.circular(30)
                            : BorderRadius.circular(7),
                        border: Border.all(color: color, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6EBDD),
                          borderRadius: round
                              ? BorderRadius.circular(25)
                              : BorderRadius.circular(4),
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFF5A3B38),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF7E9D6),
                      fontSize: 10.5,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CabinetDrawer extends StatelessWidget {
  const _CabinetDrawer({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          // Container takes constraints, not a bare minHeight.
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(13, 6, 7, 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8D5A3C), Color(0xFF5B3528)],
            ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF3B211A)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFE9C77C), size: 19),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFFFEDDA),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
