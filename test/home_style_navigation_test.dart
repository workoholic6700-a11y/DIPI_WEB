import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_dipisha/features/viewer/home/home_entry.dart';
import 'package:dear_dipisha/features/viewer/home/home_hub_screen.dart';
import 'package:dear_dipisha/features/viewer/home/room/home_room_screen.dart';

void main() {
  testWidgets('a remembered classic home has a working path back to the room', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'home_style': 'classic'});
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeEntry())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeHubScreen), findsOneWidget);
    await tester.tap(find.text('Switch to the new home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeRoomScreen), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getString('home_style'),
      'room',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeEntry())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeRoomScreen), findsOneWidget);
  });
}
