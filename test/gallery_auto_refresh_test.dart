import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dear_dipisha/data/gallery/gallery_providers.dart';
import 'package:dear_dipisha/data/gallery/gallery_repository.dart';
import 'package:dear_dipisha/features/viewer/gallery/widgets/gallery_auto_refresh.dart';

void main() {
  testWidgets(
    'visible gallery refreshes periodically, pauses, and catches up on resume',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      var reads = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(_ConfiguredGallery()),
            cloudAlbumsProvider.overrideWith((ref) async => []),
            cloudPhotosProvider.overrideWith((ref) async {
              reads++;
              return [
                {'id': '$reads'},
              ];
            }),
          ],
          child: MaterialApp(
            home: GalleryAutoRefresh(
              child: Consumer(
                builder: (context, ref, _) {
                  ref.watch(cloudAlbumsProvider);
                  final photos = ref.watch(cloudPhotosProvider).value ?? [];
                  return Text(
                    photos.isEmpty ? 'loading' : photos.first['id'] as String,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initial = reads;
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(reads, initial + 1);
      expect(find.text('$reads'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 45));
      expect(reads, initial + 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(reads, initial + 2);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 30));
      expect(reads, initial + 2);
    },
  );
}

class _ConfiguredGallery implements GalleryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
