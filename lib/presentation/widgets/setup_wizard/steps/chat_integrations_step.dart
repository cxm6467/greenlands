import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../providers/setup_wizard_provider.dart';
import '../validated_text_field.dart';

/// Chat integrations configuration step
class ChatIntegrationsStep extends ConsumerWidget {
  const ChatIntegrationsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            '💬 CHAT INTEGRATIONS 💬',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: GreenlandsTheme.accentGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Connect Greenfield to your favorite chat platforms (all optional)',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Discord
          _buildIntegrationCard(
            context,
            title: 'Discord Bot',
            emoji: '💜',
            description:
                'Receive quest notifications and game updates in Discord',
            child: ValidatedTextField(
              label: 'Discord Bot Token',
              hint: 'MTk4...',
              value: state.discordBotToken,
              onChanged: notifier.setDiscordBotToken,
              obscureText: true,
              showHealthCheck: true,
              healthCheckResult: state.discordHealthCheck,
              onRunHealthCheck: notifier.checkDiscordHealth,
              isCheckingHealth:
                  state.isCheckingHealth &&
                  state.currentHealthCheckService == 'Discord',
            ),
          ),

          const SizedBox(height: 16),

          // Slack
          _buildIntegrationCard(
            context,
            title: 'Slack App',
            emoji: '💼',
            description: 'Integrate with your Slack workspace',
            child: ValidatedTextField(
              label: 'Slack App Token',
              hint: 'xoxb-...',
              value: state.slackAppToken,
              onChanged: notifier.setSlackAppToken,
              obscureText: true,
              showHealthCheck: true,
              healthCheckResult: state.slackHealthCheck,
              onRunHealthCheck: notifier.checkSlackHealth,
              isCheckingHealth:
                  state.isCheckingHealth &&
                  state.currentHealthCheckService == 'Slack',
            ),
          ),

          const SizedBox(height: 16),

          // Google Chat
          _buildIntegrationCard(
            context,
            title: 'Google Chat',
            emoji: '🟢',
            description: 'Send updates to Google Chat spaces',
            child: ValidatedTextField(
              label: 'Google Chat Webhook URL',
              hint: 'https://chat.googleapis.com/v1/spaces/...',
              value: state.googleChatWebhook,
              onChanged: notifier.setGoogleChatWebhook,
              obscureText: false,
              showHealthCheck: true,
              healthCheckResult: state.googleChatHealthCheck,
              onRunHealthCheck: notifier.checkGoogleChatHealth,
              isCheckingHealth:
                  state.isCheckingHealth &&
                  state.currentHealthCheckService == 'GoogleChat',
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationCard(
    BuildContext context, {
    required String title,
    required String emoji,
    required String description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
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
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
