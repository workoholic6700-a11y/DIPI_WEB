import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VillageDiscoveryEntry {
  const VillageDiscoveryEntry({
    required this.id,
    required this.emoji,
    required this.title,
    required this.hint,
  });

  final String id;
  final String emoji;
  final String title;
  final String hint;
}

const villageDiscoveryCatalog = [
  VillageDiscoveryEntry(
    id: 'forest_echo',
    emoji: '🌲',
    title: 'Forest Echo',
    hint: 'Listen near the Memory Tree.',
  ),
  VillageDiscoveryEntry(
    id: 'pond_memory',
    emoji: '💧',
    title: 'Pond Reflection',
    hint: 'Look for a golden glint on the pond.',
  ),
  VillageDiscoveryEntry(
    id: 'prayer_flag_saying',
    emoji: '🎏',
    title: 'Words on the Wind',
    hint: 'Search beneath the prayer flags.',
  ),
  VillageDiscoveryEntry(
    id: 'family_bridge',
    emoji: '🧭',
    title: 'The Family Bridge',
    hint: 'A route is hidden where two banks meet.',
  ),
  VillageDiscoveryEntry(
    id: 'garden_flower',
    emoji: '🌸',
    title: 'A Family Flower',
    hint: 'One flower in the garden belongs to someone.',
  ),
  VillageDiscoveryEntry(
    id: 'sakela_word',
    emoji: '🌿',
    title: 'A Word by the Than',
    hint: 'A Rai word rests near the sacred clearing.',
  ),
  VillageDiscoveryEntry(
    id: 'stubby_paw',
    emoji: '🐾',
    title: 'Stubby’s Paw Mark',
    hint: 'Look quietly beside Stubby’s memorial.',
  ),
];

class VillageDiscoveriesNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'village_discoveries';

  @override
  Set<String> build() {
    _restore();
    return <String>{};
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_prefsKey)?.toSet() ?? <String>{};
  }

  Future<void> discover(String id) async {
    if (state.contains(id)) return;
    HapticFeedback.mediumImpact();
    state = {...state, id};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.toList());
  }
}

final villageDiscoveriesProvider =
    NotifierProvider<VillageDiscoveriesNotifier, Set<String>>(
      VillageDiscoveriesNotifier.new,
    );

Future<void> showVillageDiscoveryBook(BuildContext context) {
  HapticFeedback.selectionClick();
  return showDialog<void>(
    context: context,
    builder: (context) => const _VillageDiscoveryBookDialog(),
  );
}

class _VillageDiscoveryBookDialog extends ConsumerWidget {
  const _VillageDiscoveryBookDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final found = ref.watch(villageDiscoveriesProvider);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 410, maxHeight: 570),
        decoration: BoxDecoration(
          color: const Color(0xFFF7E9CC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF795A38), width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 18,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 11, 7, 9),
              decoration: const BoxDecoration(
                color: Color(0xFF7B5940),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Row(
                children: [
                  const Text('📔', style: TextStyle(fontSize: 25)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VILLAGE DISCOVERY BOOK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        Text(
                          '${found.length} of ${villageDiscoveryCatalog.length} pressed into these pages',
                          style: const TextStyle(
                            color: Color(0xFFEADBC5),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close discovery book',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(13),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.12,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: villageDiscoveryCatalog.length,
                itemBuilder: (context, index) {
                  final entry = villageDiscoveryCatalog[index];
                  return _ScrapbookStamp(
                    entry: entry,
                    found: found.contains(entry.id),
                    rotation: index.isEven ? -0.025 : 0.025,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrapbookStamp extends StatelessWidget {
  const _ScrapbookStamp({
    required this.entry,
    required this.found,
    required this.rotation,
  });

  final VillageDiscoveryEntry entry;
  final bool found;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: found ? const Color(0xFFFFFCF4) : const Color(0xFFE8DCC5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: found ? const Color(0xFFC7A56E) : const Color(0xFFB8AA96),
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              found ? entry.emoji : '❔',
              style: TextStyle(fontSize: found ? 31 : 27),
            ),
            const SizedBox(height: 4),
            Text(
              found ? entry.title : 'Undiscovered',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4B3528),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              found ? 'FOUND · kept forever' : entry.hint,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF89766B),
                fontSize: 8,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VillageDiscoveryBookButton extends ConsumerWidget {
  const VillageDiscoveryBookButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final found = ref.watch(villageDiscoveriesProvider).length;
    return Semantics(
      button: true,
      label:
          'Village discovery book. $found of ${villageDiscoveryCatalog.length} found.',
      child: Material(
        color: const Color(0xF2FFF8EC),
        elevation: 4,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('📔', style: TextStyle(fontSize: 19)),
                Positioned(
                  right: 2,
                  top: 2,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: const Color(0xFF5D7E52),
                    child: Text(
                      '$found',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
