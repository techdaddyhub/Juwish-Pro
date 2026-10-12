import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juwish_pro/main.dart';

void main() {
  testWidgets('Renders JuwishPro responsive app cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const JuwishProApp());
    await tester.pump();

    // Verify Brand title RichText widget is present
    expect(find.byType(RichText), findsWidgets);

    // Verify Navigation destinations
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Markets'), findsWidgets);
    expect(find.text('Trade'), findsWidgets);
    expect(find.text('Vault'), findsWidgets);
    expect(find.text('Wallet'), findsWidgets);
  });
}
