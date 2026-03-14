import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../providers/setup_wizard_provider.dart';
import '../../widgets/setup_wizard/steps/ai_provider_step.dart';
import '../../widgets/setup_wizard/steps/chat_integrations_step.dart';
import '../../widgets/setup_wizard/steps/feature_flags_step.dart';
import '../../widgets/setup_wizard/steps/game_settings_step.dart';
import '../../widgets/setup_wizard/steps/review_step.dart';
import '../../widgets/setup_wizard/steps/welcome_step.dart';

/// Main setup wizard screen with multi-step navigation
class SetupWizardScreen extends ConsumerStatefulWidget {
  final bool isRerunningSetup;

  const SetupWizardScreen({super.key, this.isRerunningSetup = false});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  @override
  void initState() {
    super.initState();
    // Reset wizard state and load current settings when wizard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh the provider to ensure a fresh wizard state (currentStep, health checks, etc.)
      // ignore: unused_result
      ref.refresh(setupWizardProvider);
      ref.read(setupWizardProvider.notifier).loadCurrentSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETUP WIZARD'),
        centerTitle: true,
        automaticallyImplyLeading: widget.isRerunningSetup,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(context, state.currentStep),

          // Step content
          Expanded(
            child: IndexedStack(
              index: state.currentStep,
              children: const [
                WelcomeStep(),
                AiProviderStep(),
                ChatIntegrationsStep(),
                FeatureFlagsStep(),
                GameSettingsStep(),
                ReviewStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int currentStep) {
    final steps = [
      'Welcome',
      'AI Provider',
      'Chat',
      'Features',
      'Game',
      'Review',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? GreenlandsTheme.accentGold
                        : GreenlandsTheme.secondaryBrown,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? GreenlandsTheme.accentGold
                          : GreenlandsTheme.secondaryBrown,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? GreenlandsTheme.accentGold : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    SetupWizardState state,
    SetupWizardNotifier notifier,
  ) {
    final canGoNext = _canGoNext(state);
    final isLastStep = state.currentStep == 5;
    final canSkip =
        state.currentStep > 0 &&
        state.currentStep < 5 &&
        !canGoNext &&
        _isOptionalStep(state.currentStep);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: GreenlandsTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => notifier.previousStep(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: GreenlandsTheme.accentGold),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('BACK'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 16),

          // Skip button (for optional steps that fail validation)
          if (canSkip) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => notifier.nextStep(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: GreenlandsTheme.textSecondary),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('SKIP'),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Next/Save button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canGoNext
                  ? () => _handleNext(context, state, notifier, isLastStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: GreenlandsTheme.accentGold,
                foregroundColor: Colors.black,
                disabledBackgroundColor: GreenlandsTheme.secondaryBrown,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(isLastStep ? 'SAVE & FINISH' : 'NEXT'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoNext(SetupWizardState state) {
    switch (state.currentStep) {
      case 0:
        return state.isStep0Valid;
      case 1:
        return state.isStep1Valid;
      case 2:
        return state.isStep2Valid;
      case 3:
        return state.isStep3Valid;
      case 4:
        return state.isStep4Valid;
      case 5:
        return state.isStep5Valid;
      default:
        return false;
    }
  }

  bool _isOptionalStep(int step) {
    // Step 1 (AI Provider) is required if quest generation enabled
    // Steps 2-4 are all optional
    switch (step) {
      case 1:
        final state = ref.read(setupWizardProvider);
        return !state.enableQuestGeneration;
      case 2:
      case 3:
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleNext(
    BuildContext context,
    SetupWizardState state,
    SetupWizardNotifier notifier,
    bool isLastStep,
  ) async {
    if (isLastStep) {
      // Save all settings
      try {
        // Show loading indicator
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: GreenlandsTheme.accentGold,
              ),
            ),
          );
        }

        await notifier.saveAllSettings();

        if (context.mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: GreenlandsTheme.successGreen,
              duration: Duration(seconds: 2),
            ),
          );

          // Close wizard
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog if open
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save settings: $e'),
              backgroundColor: GreenlandsTheme.errorRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      notifier.nextStep();
    }
  }
}
