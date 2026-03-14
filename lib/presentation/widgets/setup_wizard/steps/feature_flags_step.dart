import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../providers/setup_wizard_provider.dart';

/// Feature flags configuration step
class FeatureFlagsStep extends ConsumerWidget {
  const FeatureFlagsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            '🎮 FEATURE PREFERENCES 🎮',
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
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive quest reminders and updates'),
                    value: state.enableNotifications,
                    onChanged: notifier.setEnableNotifications,
                    activeTrackColor: GreenlandsTheme.accentGold,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Enable Recurring Events'),
                    subtitle: const Text('Daily quests and timed events'),
                    value: state.enableRecurringEvents,
                    onChanged: notifier.setEnableRecurringEvents,
                    activeTrackColor: GreenlandsTheme.accentGold,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Enable Chat Bots'),
                    subtitle: const Text(
                      'Activate configured chat integrations',
                    ),
                    value: state.enableChatBots,
                    onChanged: notifier.setEnableChatBots,
                    activeTrackColor: GreenlandsTheme.accentGold,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: GreenlandsTheme.accentGold.withValues(alpha: 0.1),
              border: Border.all(color: GreenlandsTheme.accentGold, width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: GreenlandsTheme.accentGold),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can change these settings anytime in Admin Settings',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
