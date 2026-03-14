import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenlands/presentation/screens/setup_wizard/setup_wizard_screen.dart';

import '../../../helpers/test_providers.dart';

void main() {
  group('SetupWizardScreen', () {
    testWidgets('displays step indicator with correct steps', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // Check that step indicator shows all steps
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('AI Provider'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('displays NEXT button on first step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );

      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('BACK'), findsNothing);
    });

    testWidgets('NEXT button navigates to next step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap NEXT button
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Should now show BACK button
      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('BACK button navigates to previous step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate forward
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      // BACK button should be gone (we're on step 0)
      expect(find.text('BACK'), findsNothing);
    });

    testWidgets('can navigate between steps', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we start at Welcome step (0)
      expect(find.textContaining('WELCOME'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);

      // Navigate to AI Provider step (1)
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      expect(find.textContaining('AI PROVIDER'), findsOneWidget);

      // Verify BACK button appears after navigating forward
      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('step indicator highlights current step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // First step should be highlighted
      final firstStepText = find.text('Welcome');
      expect(firstStepText, findsOneWidget);

      // Navigate to next step
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Second step should be highlighted
      final secondStepText = find.text('AI Provider');
      expect(secondStepText, findsOneWidget);

      // Navigate through remaining steps to reach the last step (Review)
      await tester.tap(find.text('NEXT')); // to Chat
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT')); // to Features
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT')); // to Game
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT')); // to Review (last step)
      await tester.pumpAndSettle();

      // Verify we're on the Review step via the step indicator
      expect(find.text('Review'), findsOneWidget);

      // On the last step, "SAVE & FINISH" should be shown and "NEXT" hidden
      expect(find.text('SAVE & FINISH'), findsOneWidget);
      expect(find.text('NEXT'), findsNothing);
    });

    testWidgets('shows app bar with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // There may be multiple instances of the title text (e.g., in AppBar and elsewhere)
      expect(find.text('SETUP WIZARD'), findsAtLeastNWidgets(1));
    });

    testWidgets('hides back button when isRerunningSetup is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(
            home: SetupWizardScreen(isRerunningSetup: false),
          ),
        ),
      );

      // App bar back button should not be shown
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('shows back button when isRerunningSetup is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SetupWizardScreen(isRerunningSetup: true),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to SetupWizardScreen to create a navigation stack
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // App bar back button should be shown
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('displays welcome step content on first load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // Should show welcome step content
      expect(find.textContaining('WELCOME'), findsOneWidget);
    });

    testWidgets('step content changes when navigating', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestProviderOverrides(),
          child: const MaterialApp(home: SetupWizardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial step
      expect(find.textContaining('WELCOME'), findsOneWidget);

      // Navigate to AI Provider step
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Should show AI Provider content
      expect(find.textContaining('AI PROVIDER'), findsOneWidget);
    });
  });
}
