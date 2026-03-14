import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme_config.dart';
import '../../providers/character_provider.dart';
import '../../widgets/character/class_selection_widget.dart';
import '../../widgets/character/fellowship_role_widget.dart';
import '../../widgets/character/name_input_widget.dart';
import '../../widgets/character/pixel_art_avatar.dart';
import '../../widgets/character/race_selection_widget.dart';
import '../../widgets/character/stat_allocation_widget.dart';

class CharacterCreationScreen extends ConsumerWidget {
  const CharacterCreationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(characterCreationProvider);
    final creationNotifier = ref.read(characterCreationProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Hero'), centerTitle: true),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(context, creationState.currentStep),

          // Pixel Art Avatar Preview
          if (creationState.race != null &&
              creationState.characterClass != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  PixelArtAvatar(
                    race: creationState.race!,
                    characterClass: creationState.characterClass!,
                    size: 160,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    creationState.name.isNotEmpty
                        ? creationState.name
                        : 'Your Hero',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${creationState.race?.displayName ?? ''} ${creationState.characterClass?.displayName ?? ''}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Step content
          Expanded(
            child: IndexedStack(
              index: creationState.currentStep,
              children: const [
                NameInputWidget(),
                RaceSelectionWidget(),
                ClassSelectionWidget(),
                FellowshipRoleWidget(),
                StatAllocationWidget(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(
            context,
            ref,
            creationState,
            creationNotifier,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int currentStep) {
    final steps = ['Name', 'Race', 'Class', 'Role', 'Stats'];

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
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? GreenlandsTheme.accentGold : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
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
    WidgetRef ref,
    CharacterCreationState state,
    CharacterCreationNotifier notifier,
  ) {
    final canGoNext = _canGoNext(state);
    final isLastStep = state.currentStep == 4;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => notifier.previousStep(),
                child: const Text('BACK'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 16),

          // Next/Create button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canGoNext
                  ? () => _handleNext(context, ref, state, notifier, isLastStep)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isLastStep ? 'CREATE CHARACTER' : 'NEXT'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoNext(CharacterCreationState state) {
    switch (state.currentStep) {
      case 0:
        return state.isNameValid;
      case 1:
        return state.isRaceSelected;
      case 2:
        return state.isClassSelected;
      case 3:
        return state.isFellowshipRoleSelected;
      case 4:
        return state.areStatsAllocated;
      default:
        return false;
    }
  }

  Future<void> _handleNext(
    BuildContext context,
    WidgetRef ref,
    CharacterCreationState state,
    CharacterCreationNotifier notifier,
    bool isLastStep,
  ) async {
    if (isLastStep) {
      // Create character
      try {
        await ref
            .read(characterProvider.notifier)
            .createNewCharacter(
              name: state.name,
              race: state.race!,
              characterClass: state.characterClass!,
              fellowshipRole: state.fellowshipRole!,
              allocatedStats: state.allocatedStats,
            );

        if (context.mounted) {
          notifier.reset();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create character: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      notifier.nextStep();
    }
  }
}
