import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juwish_pro/main.dart';

void main() {
  testWidgets('Renders JuwishPro production mobile app shell cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const JuwishProApp());
    await tester.pump();

    // Verify MaterialApp and core shell widgets are present
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(JuwishProApp), findsOneWidget);
    expect(find.byType(ProductionAppShell), findsOneWidget);
  });
}
