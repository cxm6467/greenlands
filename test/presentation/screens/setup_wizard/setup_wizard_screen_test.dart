import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenlands/presentation/screens/setup_wizard/setup_wizard_screen.dart';

void main() {
  group('SetupWizardScreen', () {
    testWidgets('displays step indicator with correct steps', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
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
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('BACK'), findsNothing);
    });

    testWidgets('NEXT button navigates to next step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // Tap NEXT button
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Should now show BACK button
      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('BACK button navigates to previous step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // Navigate forward
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      // BACK button should be gone (we're on step 0)
      expect(find.text('BACK'), findsNothing);
    });

    testWidgets('displays SAVE & FINISH on last step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // Navigate to last step (step 5)
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('NEXT'));
        await tester.pumpAndSettle();
      }

      expect(find.text('SAVE & FINISH'), findsOneWidget);
      expect(find.text('NEXT'), findsNothing);
    });

    testWidgets('step indicator highlights current step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // First step should be highlighted
      final firstStepText = find.text('Welcome');
      expect(firstStepText, findsOneWidget);

      // Navigate to next step
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Second step should be highlighted
      final secondStepText = find.text('AI Provider');
      expect(secondStepText, findsOneWidget);
    });

    testWidgets('shows app bar with title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      expect(find.text('SETUP WIZARD'), findsOneWidget);
    });

    testWidgets('hides back button when isRerunningSetup is false', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen(isRerunningSetup: false)),
        ),
      );

      // App bar back button should not be shown
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('shows back button when isRerunningSetup is true', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen(isRerunningSetup: true)),
        ),
      );

      // App bar back button should be shown
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('displays welcome step content on first load', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

      // Should show welcome step content
      expect(find.textContaining('WELCOME'), findsOneWidget);
    });

    testWidgets('step content changes when navigating', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SetupWizardScreen()),
        ),
      );

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
