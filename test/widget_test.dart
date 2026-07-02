// Flutter widget tests for DevToolkit

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devtoolkit/main.dart';

void main() {
  testWidgets('App renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DevToolkitApp());

    // Verify the app renders with navigation
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.construction), findsOneWidget);
    expect(find.byIcon(Icons.code), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('Navigation works between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const DevToolkitApp());

    // Tap on Tools tab
    await tester.tap(find.byIcon(Icons.construction));
    await tester.pumpAndSettle();

    // Tap on GitHub tab
    await tester.tap(find.byIcon(Icons.code));
    await tester.pumpAndSettle();

    // Tap on Settings tab
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Navigate back to home
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
  });
}
