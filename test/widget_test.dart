import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flood_reporting_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flood_reporting_app/screens/wizard_screen.dart';
import 'package:flood_reporting_app/firebase_options.dart'; // Add this import

void main() {
  // Initialize Firebase before running tests
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use generated options
    );
  });

  testWidgets('App launches with initial WizardScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const FloodReportApp());

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify the app bar title exists
    expect(find.text('Flood Report'), findsOneWidget);

    // Verify the wizard screen is present
    expect(find.byType(WizardScreen), findsOneWidget);
  });

  testWidgets('App uses correct theme colors', (WidgetTester tester) async {
    await tester.pumpWidget(const FloodReportApp());

    // Wait for the widget tree to stabilize
    await tester.pump();

    // Verify app bar color matches theme
    final appBarFinder = find.byType(AppBar);
    expect(appBarFinder, findsOneWidget);

    final appBar = tester.widget<AppBar>(appBarFinder);
    expect(
        appBar.backgroundColor,
        const Color(0xFF1A91D7),
        reason: 'App bar should use primary theme color'
    );
  });
}