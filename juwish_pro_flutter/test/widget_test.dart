import 'package:flutter_test/flutter_test.dart';
import 'package:juwish_pro/main.dart';

void main() {
  testWidgets('Renders JuwishPro responsive app cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const JuwishProApp());
    await tester.pump();

    // Verify Brand title is rendered
    expect(find.text('JUWISH'), findsOneWidget);
    expect(find.text('PRO'), findsOneWidget);

    // Verify Navigation destinations
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Markets'), findsOneWidget);
    expect(find.text('Trade'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
  });
}
