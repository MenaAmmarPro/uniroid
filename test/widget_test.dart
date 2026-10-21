import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uniroid/main.dart';

void main() {
  testWidgets('Uniroid shell renders home with four tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UniroidApp(initialDark: true));

    // Home grid should show on first launch.
    expect(find.text('Uniroid'), findsOneWidget);
    expect(find.text('Our Countdown'), findsOneWidget);
    expect(find.text('65 Reasons'), findsOneWidget);

    // The four tabs exist in the navigation bar.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Us'), findsOneWidget);

    // Tapping "Games" shows the arcade list.
    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();
    expect(find.text('Memory Match'), findsOneWidget);
    expect(find.text('2048'), findsOneWidget);
  });
}
