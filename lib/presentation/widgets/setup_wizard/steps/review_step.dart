import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../providers/setup_wizard_provider.dart';

/// Review configuration step - shows summary of all settings
class ReviewStep extends ConsumerWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            '📋 REVIEW CONFIGURATION 📋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: GreenlandsTheme.accentGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Review your settings before saving',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // AI Provider
          _buildSection(context, 'AI PROVIDER', [
            _buildItem(
              'Quest Generation',
              state.enableQuestGeneration ? 'Enabled' : 'Disabled',
              state.enableQuestGeneration
                  ? GreenlandsTheme.successGreen
                  : GreenlandsTheme.textSecondary,
            ),
            if (state.enableQuestGeneration) ...[
              _buildItem(
                'Claude API Key',
                state.claudeApiKey.isEmpty ? 'Not set' : 'Configured',
                state.claudeApiKey.isEmpty
                    ? GreenlandsTheme.errorRed
                    : GreenlandsTheme.successGreen,
              ),
              _buildItem('Claude Model', state.claudeModel, null),
            ],
          ]),

          // Chat Integrations
          _buildSection(context, 'CHAT INTEGRATIONS', [
            _buildItem(
              'Discord',
              state.discordBotToken.isEmpty ? 'Not configured' : 'Configured',
              state.discordBotToken.isEmpty
                  ? GreenlandsTheme.textSecondary
                  : GreenlandsTheme.successGreen,
            ),
            _buildItem(
              'Slack',
              state.slackAppToken.isEmpty ? 'Not configured' : 'Configured',
              state.slackAppToken.isEmpty
                  ? GreenlandsTheme.textSecondary
                  : GreenlandsTheme.successGreen,
            ),
            _buildItem(
              'Google Chat',
              state.googleChatWebhook.isEmpty ? 'Not configured' : 'Configured',
              state.googleChatWebhook.isEmpty
                  ? GreenlandsTheme.textSecondary
                  : GreenlandsTheme.successGreen,
            ),
          ]),

          // Features
          _buildSection(context, 'FEATURES', [
            _buildItem(
              'Notifications',
              state.enableNotifications ? 'Enabled' : 'Disabled',
              state.enableNotifications
                  ? GreenlandsTheme.successGreen
                  : GreenlandsTheme.textSecondary,
            ),
            _buildItem(
              'Recurring Events',
              state.enableRecurringEvents ? 'Enabled' : 'Disabled',
              state.enableRecurringEvents
                  ? GreenlandsTheme.successGreen
                  : GreenlandsTheme.textSecondary,
            ),
            _buildItem(
              'Chat Bots',
              state.enableChatBots ? 'Enabled' : 'Disabled',
              state.enableChatBots
                  ? GreenlandsTheme.successGreen
                  : GreenlandsTheme.textSecondary,
            ),
          ]),

          // Game Settings
          _buildSection(context, 'GAME SETTINGS', [
            _buildItem(
              'Max Fellowship Size',
              state.maxFellowshipSize.toString(),
              null,
            ),
            _buildItem('XP Multiplier', '${state.xpMultiplier}x', null),
            _buildItem(
              'Daily Quest Reset',
              '${state.dailyQuestResetHour}:00',
              null,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GreenlandsTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                ...children,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItem(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
