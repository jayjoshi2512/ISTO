// Basic widget test for ISTO game

import 'package:flutter_test/flutter_test.dart';

import 'package:isto_game/main.dart';

void main() {
  testWidgets('ISTO app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ISTOApp());

    // Verify that our app renders
    expect(find.byType(ISTOApp), findsOneWidget);
  });
}
