import 'package:flutter_test/flutter_test.dart';

import 'package:tattoo_ai/app.dart';

void main() {
  testWidgets('Base UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TattooAiApp());

    // Verify that our app shows the basic texts.
    expect(find.text('Tattoo AI'), findsWidgets);
    expect(find.text('Create your perfect tattoo'), findsOneWidget);
  });
}
