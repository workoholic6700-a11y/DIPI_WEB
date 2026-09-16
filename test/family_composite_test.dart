import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_dipisha/features/viewer/family/widgets/family_composite_frame.dart';

void main() {
  testWidgets(
    'generated portrait stays labelled when enlarged on a narrow phone',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: FamilyCompositeFrame()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AI-composed from our photos'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('AI-composed from our photos'),
        ),
        findsOneWidget,
      );
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    },
  );
}
