import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dear_dipisha/core/router/app_routes.dart';
import 'package:dear_dipisha/features/viewer/home/room/widgets/family_cabinet.dart';

/// Diksha opens the cabinet, takes something down, and expects the back
/// button to put her in front of the open cabinet again, not back in the
/// room with the doors shut. See DECISIONS.md.
void main() {
  testWidgets('back from a cabinet destination returns to the open cabinet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showFamilyCabinet(context),
                  child: const Text('THE ROOM'),
                ),
              ),
            ),
          ),
        ),
        familyCabinetRoute(),
        GoRoute(
          path: Routes.gallery,
          builder: (_, _) => const Scaffold(body: Text('GALLERY PAGE')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    // Let the router settle its first route before pushing a dialog on it.
    await tester.pumpAndSettle();

    await tester.tap(find.text('THE ROOM'));
    await tester.pumpAndSettle();
    expect(find.text('Everything we keep'), findsOneWidget);

    await tester.ensureVisible(find.text('Gallery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(find.text('GALLERY PAGE'), findsOneWidget);

    // The phone's back button. The header may be scrolled away, so look at
    // the cabinet's Close button and the shelf that was just used.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('GALLERY PAGE'), findsNothing);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    // Closing the cabinet is what returns to the room.
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close'), findsNothing);
    expect(find.text('Gallery'), findsNothing);
    expect(find.text('THE ROOM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
