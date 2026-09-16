import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/data/models/archive_models.dart';
import 'package:dear_dipisha/data/providers/archive_providers.dart';
import 'package:dear_dipisha/features/archive/archive_desk_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  ArchiveEntry entry({
    String id = 'archive-1',
    String title = 'A real item to verify',
    String source = 'The family member who supplied it',
  }) {
    return ArchiveEntry.create(
      id: id,
      kind: ArchiveEntryKind.memory,
      title: title,
      details: 'Collected notes',
      sourceName: source,
      status: ArchiveEntryStatus.needsConfirmation,
      createdAt: DateTime(2026, 8, 17),
    );
  }

  Future<void> settleRestore() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('an archive entry cannot exist without a named source', () {
    expect(() => entry(source: '   '), throwsA(isA<ArgumentError>()));
  });

  test('archive entries round-trip without losing provenance', () {
    final original = entry();
    final restored = ArchiveEntry.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.sourceName, original.sourceName);
    expect(restored.status, ArchiveEntryStatus.needsConfirmation);
    expect(restored.details, original.details);
  });

  test('a collected folder survives an Archive Desk restart', () async {
    final first = ProviderContainer();
    addTearDown(first.dispose);
    await first.read(archiveEntriesProvider.notifier).save(entry());

    final relaunched = ProviderContainer();
    addTearDown(relaunched.dispose);
    relaunched.read(archiveEntriesProvider);
    await settleRestore();

    final entries = relaunched.read(archiveEntriesProvider);
    expect(entries, hasLength(1));
    expect(entries.single.title, 'A real item to verify');
    expect(entries.single.sourceName, 'The family member who supplied it');
  });

  testWidgets('the empty desk says collected material is not published', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ArchiveDeskScreen())),
    );
    await tester.pump();

    expect(find.text('The Archive Desk'), findsOneWidget);
    expect(
      find.textContaining('Nothing collected here appears in the family app'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Archive Desk has a way back when opened from the album desk', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ArchiveDeskScreen(),
                    ),
                  ),
                  child: const Text('open the desk'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open the desk'));
    await tester.pumpAndSettle();

    expect(find.text('The Archive Desk'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('open the desk'), findsOneWidget);
    expect(find.text('The Archive Desk'), findsNothing);
  });

  testWidgets('the Archive Desk as its own app draws no back arrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ArchiveDeskScreen())),
    );
    await tester.pump();
    expect(find.byType(BackButton), findsNothing);
  });
}
