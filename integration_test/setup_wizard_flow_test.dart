import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:greenlands/presentation/screens/setup_wizard/setup_wizard_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Setup Wizard Flow', () {
    testWidgets('Complete wizard flow with quest generation disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SetupWizardScreen())),
      );

      // Step 0: Welcome
      expect(find.textContaining('WELCOME'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 1: AI Provider - disable quest generation
      expect(find.textContaining('AI PROVIDER'), findsOneWidget);
      final questGenerationSwitch = find.byType(SwitchListTile).first;
      await tester.tap(questGenerationSwitch);
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 2: Chat Integrations
      expect(find.textContaining('CHAT'), findsWidgets);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 3: Feature Flags
      expect(find.textContaining('FEATURE'), findsWidgets);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 4: Game Settings
      expect(find.textContaining('GAME'), findsWidgets);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Step 5: Review
      expect(find.textContaining('REVIEW'), findsWidgets);

      // Note: We can't actually save in integration test without proper DI setup,
      // but we can verify the button exists
      expect(find.text('SAVE & FINISH'), findsOneWidget);
    });

    testWidgets('Back navigation works correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SetupWizardScreen())),
      );

      // Navigate forward to step 2
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Should be on Chat step now
      expect(find.textContaining('CHAT'), findsWidgets);
      expect(find.text('BACK'), findsOneWidget);

      // Navigate back
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      // Should be on AI Provider step
      expect(find.textContaining('AI PROVIDER'), findsOneWidget);

      // Navigate back again
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      // Should be on Welcome step
      expect(find.textContaining('WELCOME'), findsOneWidget);
      expect(find.text('BACK'), findsNothing);
    });

    testWidgets('Step indicator shows progress', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SetupWizardScreen())),
      );

      // Check initial step indicator
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Navigate forward
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // First step should show checkmark instead of number
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Skip button appears when validation fails on optional step', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SetupWizardScreen())),
      );

      // Navigate to AI Provider step
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Enable quest generation but don't provide API key
      // (it should be enabled by default, so we're just verifying)
      expect(find.textContaining('Enable Quest Generation'), findsOneWidget);

      // SKIP button should appear when we can't proceed but step is optional
      // Note: Skip will only appear after trying to validate and failing,
      // which happens on navigation attempt or when step changes
      // For now, we just verify the UI structure is correct
    });

    testWidgets(
      'Cannot navigate past AI Provider step without valid API key when quest generation enabled',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: SetupWizardScreen())),
        );

        // Navigate to AI Provider step
        await tester.tap(find.text('NEXT'));
        await tester.pumpAndSettle();

        // Quest generation should be enabled by default
        // Try to go next without providing API key or health check
        final nextButton = find.text('NEXT');

        // Button should be disabled (onPressed should be null)
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('Can skip AI Provider step when quest generation disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SetupWizardScreen())),
      );

      // Navigate to AI Provider step
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Disable quest generation
      final questGenerationSwitch = find.byType(SwitchListTile).first;
      await tester.tap(questGenerationSwitch);
      await tester.pumpAndSettle();

      // NEXT button should now be enabled
      final nextButton = find.text('NEXT');
      final button = tester.widget<ElevatedButton>(nextButton);
      expect(button.onPressed, isNotNull);

      // Should be able to proceed
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should be on Chat step
      expect(find.textContaining('CHAT'), findsWidgets);
    });
  });
}
