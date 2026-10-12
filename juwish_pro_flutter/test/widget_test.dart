import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juwish_pro/main.dart';

void main() {
  testWidgets('Renders JuwishPro responsive mobile layout cleanly',
      (WidgetTester tester) async {
    // Set phone screen size (iPhone 14 / Pixel 7: 390x844)
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JuwishProApp());
    await tester.pumpAndSettle();

    // Verify Brand title is rendered
    expect(find.text('JUWISH'), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);

    // Verify Bottom Navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Markets'), findsOneWidget);
    expect(find.text('Trade'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
  });

  testWidgets('Renders JuwishPro responsive tablet layout cleanly',
      (WidgetTester tester) async {
    // Set tablet screen size (iPad: 810x1080)
    tester.view.physicalSize = const Size(810 * 2, 1080 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JuwishProApp());
    await tester.pumpAndSettle();

    // Verify Navigation Rail exists for wide screens
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
