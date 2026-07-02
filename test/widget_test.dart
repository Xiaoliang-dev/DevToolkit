// Flutter widget tests for DevToolkit

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devtoolkit/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DevToolkitApp());
    await tester.pumpAndSettle();

    // Verify the app renders with navigation
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.construction_outlined), findsOneWidget);
    expect(find.byIcon(Icons.code_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('Navigation works between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const DevToolkitApp());
    await tester.pumpAndSettle();

    // Tap on Tools tab
    await tester.tap(find.byIcon(Icons.construction_outlined));
    await tester.pump(const Duration(milliseconds: 500));

    // Tap on GitHub tab (needs extra time for simulated network load)
    await tester.tap(find.byIcon(Icons.code_outlined));
    await tester.pump(const Duration(seconds: 1));

    // Tap on Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump(const Duration(milliseconds: 500));

    // Navigate back to home (Home icon is now outlined)
    await tester.tap(find.byIcon(Icons.home_outlined));
    // HomeScreen has finite animations (800ms header + 600ms grid), so pumpAndSettle is safe
    await tester.pumpAndSettle();
  });
}
