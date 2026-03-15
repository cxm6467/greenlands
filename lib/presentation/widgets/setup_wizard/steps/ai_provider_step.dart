import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../providers/setup_wizard_provider.dart';
import '../validated_text_field.dart';

/// AI Provider configuration step
class AiProviderStep extends ConsumerWidget {
  const AiProviderStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            '🤖 AI PROVIDER CONFIGURATION 🤖',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLAUDE API',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: GreenlandsTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Greenfield uses Claude to generate dynamic quests and power AI-driven NPCs.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Quest Generation'),
                    subtitle: const Text('Use AI to create dynamic quests'),
                    value: state.enableQuestGeneration,
                    onChanged: notifier.setEnableQuestGeneration,
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: GreenlandsTheme.accentGold,
                  ),
                  if (state.enableQuestGeneration) ...[
                    const SizedBox(height: 16),
                    ValidatedTextField(
                      label: 'Claude API Key',
                      hint: 'sk-ant-api03-...',
                      value: state.claudeApiKey,
                      onChanged: notifier.setClaudeApiKey,
                      obscureText: true,
                      showHealthCheck: true,
                      healthCheckResult: state.claudeHealthCheck,
                      onRunHealthCheck: notifier.checkClaudeHealth,
                      isCheckingHealth:
                          state.isCheckingHealth &&
                          state.currentHealthCheckService == 'Claude',
                    ),
                    const SizedBox(height: 16),
                    _ClaudeModelField(
                      value: state.claudeModel,
                      onChanged: notifier.setClaudeModel,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: GreenlandsTheme.accentGold.withValues(
                          alpha: 0.1,
                        ),
                        border: Border.all(
                          color: GreenlandsTheme.accentGold,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info, color: GreenlandsTheme.accentGold),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Get your API key at: https://console.anthropic.com/',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaudeModelField extends StatefulWidget {
  const _ClaudeModelField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_ClaudeModelField> createState() => _ClaudeModelFieldState();
}

class _ClaudeModelFieldState extends State<_ClaudeModelField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ClaudeModelField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Claude Model',
        hintText: 'claude-3-5-sonnet-20241022',
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: GreenlandsTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: GreenlandsTheme.accentGold, width: 2),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
