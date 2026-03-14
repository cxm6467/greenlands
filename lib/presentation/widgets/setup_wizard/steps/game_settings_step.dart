import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../providers/setup_wizard_provider.dart';

/// Game settings configuration step
class GameSettingsStep extends ConsumerWidget {
  const GameSettingsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            '⚙️ GAME SETTINGS ⚙️',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: GreenlandsTheme.accentGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: state.maxFellowshipSize.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Max Fellowship Size',
                      hintText: '8',
                      helperText: 'Maximum number of NPCs in your fellowship',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GreenlandsTheme.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GreenlandsTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        notifier.setMaxFellowshipSize(parsed);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: state.xpMultiplier.toString(),
                    decoration: const InputDecoration(
                      labelText: 'XP Multiplier',
                      hintText: '1.0',
                      helperText:
                          'Multiplier for experience points earned (1.0 = normal)',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GreenlandsTheme.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GreenlandsTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        notifier.setXpMultiplier(parsed);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: state.dailyQuestResetHour.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Daily Quest Reset Hour (0-23)',
                      hintText: '0',
                      helperText:
                          'Hour of day when daily quests reset (0 = midnight)',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GreenlandsTheme.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GreenlandsTheme.accentGold,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= 0 && parsed <= 23) {
                        notifier.setDailyQuestResetHour(parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
