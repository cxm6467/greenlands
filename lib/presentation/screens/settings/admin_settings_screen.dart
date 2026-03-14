import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/theme_config.dart';
import '../../providers/settings_provider.dart';
import '../setup_wizard/setup_wizard_screen.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _isAuthenticated = false;
  bool _hasPassword = false;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Settings controllers
  final _claudeApiKeyController = TextEditingController();
  final _claudeModelController = TextEditingController();
  final _mcpServerUrlController = TextEditingController();
  final _googleChatWebhookController = TextEditingController();
  final _discordBotTokenController = TextEditingController();
  final _slackAppTokenController = TextEditingController();
  final _maxFellowshipSizeController = TextEditingController();
  final _xpMultiplierController = TextEditingController();
  final _dailyQuestResetHourController = TextEditingController();

  bool _enableQuestGeneration = true;
  bool _enableChatBots = false;
  bool _enableNotifications = true;
  bool _enableRecurringEvents = true;
  bool _debugMode = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _claudeApiKeyController.dispose();
    _claudeModelController.dispose();
    _mcpServerUrlController.dispose();
    _googleChatWebhookController.dispose();
    _discordBotTokenController.dispose();
    _slackAppTokenController.dispose();
    _maxFellowshipSizeController.dispose();
    _xpMultiplierController.dispose();
    _dailyQuestResetHourController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final hasPassword = await ref
        .read(settingsAuthProvider.notifier)
        .hasPassword();
    if (!mounted) return;
    setState(() {
      _hasPassword = hasPassword;
    });
  }

  void _loadCurrentSettings() {
    // Load current values from AppConfig
    _claudeApiKeyController.text = AppConfig.claudeApiKey;
    _claudeModelController.text = AppConfig.claudeModel;
    _mcpServerUrlController.text = AppConfig.mcpServerUrl;
    _googleChatWebhookController.text = AppConfig.googleChatWebhookUrl;
    _discordBotTokenController.text = AppConfig.discordBotToken;
    _slackAppTokenController.text = AppConfig.slackAppToken;
    _maxFellowshipSizeController.text = AppConfig.maxFellowshipSize.toString();
    _xpMultiplierController.text = AppConfig.xpMultiplier.toString();
    _dailyQuestResetHourController.text = AppConfig.dailyQuestResetHour
        .toString();

    setState(() {
      _enableQuestGeneration = AppConfig.enableQuestGeneration;
      _enableChatBots = AppConfig.enableChatBots;
      _enableNotifications = AppConfig.enableNotifications;
      _enableRecurringEvents = AppConfig.enableRecurringEvents;
      _debugMode = AppConfig.debugMode;
    });
  }

  Future<void> _handleAuth() async {
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (!_hasPassword) {
      // First time setup - set password
      await ref
          .read(settingsAuthProvider.notifier)
          .setPassword(_passwordController.text);
      if (!mounted) return;
      setState(() {
        _isAuthenticated = true;
        _hasPassword = true;
      });
      _showSuccess('Admin password set successfully');
    } else {
      // Verify existing password
      final isValid = await ref
          .read(settingsAuthProvider.notifier)
          .checkPassword(_passwordController.text);
      if (!mounted) return;
      if (isValid) {
        setState(() {
          _isAuthenticated = true;
        });
      } else {
        _showError('Incorrect password');
      }
    }
    _passwordController.clear();
  }

  Future<void> _saveSettings() async {
    try {
      final storage = ref.read(settingsStorageProvider);

      // Save all settings
      await storage.setClaudeApiKey(_claudeApiKeyController.text);
      await storage.setClaudeModel(_claudeModelController.text);
      await storage.setMcpServerUrl(_mcpServerUrlController.text);
      await storage.setGoogleChatWebhook(_googleChatWebhookController.text);
      await storage.setDiscordBotToken(_discordBotTokenController.text);
      await storage.setSlackAppToken(_slackAppTokenController.text);
      await storage.setEnableQuestGeneration(_enableQuestGeneration);
      await storage.setEnableChatBots(_enableChatBots);
      await storage.setEnableNotifications(_enableNotifications);
      await storage.setEnableRecurringEvents(_enableRecurringEvents);
      await storage.setMaxFellowshipSize(
        int.tryParse(_maxFellowshipSizeController.text) ?? 8,
      );
      await storage.setXpMultiplier(
        double.tryParse(_xpMultiplierController.text) ?? 1.0,
      );
      await storage.setDailyQuestResetHour(
        int.tryParse(_dailyQuestResetHourController.text) ?? 0,
      );
      await storage.setDebugMode(_debugMode);

      // Reload AppConfig
      await AppConfig.load();
      if (!mounted) return;

      _showSuccess('Settings saved and applied successfully.');
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save settings: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return _buildAuthScreen();
    }

    return _buildSettingsScreen();
  }

  Widget _buildAuthScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    _hasPassword
                        ? 'Enter Admin Password'
                        : 'Set Admin Password',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _hasPassword
                        ? 'Enter your admin password to access settings'
                        : 'Create an admin password to protect your settings',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => _handleAuth(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleAuth,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_hasPassword ? 'UNLOCK' : 'SET PASSWORD'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(settingsAuthProvider.notifier).logout();
              setState(() {
                _isAuthenticated = false;
              });
            },
            tooltip: 'Lock Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('AI Provider', [
            _buildTextField(
              'Claude API Key',
              _claudeApiKeyController,
              obscureText: true,
              hint: 'sk-ant-api03-...',
            ),
            _buildTextField(
              'Claude Model',
              _claudeModelController,
              hint: 'claude-3-5-sonnet-20241022',
            ),
          ]),
          _buildSection('Chat Integrations', [
            _buildTextField(
              'MCP Server URL',
              _mcpServerUrlController,
              hint: 'http://localhost:3000',
            ),
            _buildTextField(
              'Google Chat Webhook',
              _googleChatWebhookController,
              obscureText: true,
              hint: 'https://chat.googleapis.com/v1/spaces/...',
            ),
            _buildTextField(
              'Discord Bot Token',
              _discordBotTokenController,
              obscureText: true,
              hint: 'MTk...',
            ),
            _buildTextField(
              'Slack App Token',
              _slackAppTokenController,
              obscureText: true,
              hint: 'xoxb-...',
            ),
          ]),
          _buildSection('Feature Flags', [
            _buildSwitchTile(
              'Quest Generation',
              _enableQuestGeneration,
              (value) => setState(() => _enableQuestGeneration = value),
            ),
            _buildSwitchTile(
              'Chat Bots',
              _enableChatBots,
              (value) => setState(() => _enableChatBots = value),
            ),
            _buildSwitchTile(
              'Notifications',
              _enableNotifications,
              (value) => setState(() => _enableNotifications = value),
            ),
            _buildSwitchTile(
              'Recurring Events',
              _enableRecurringEvents,
              (value) => setState(() => _enableRecurringEvents = value),
            ),
          ]),
          _buildSection('Game Settings', [
            _buildTextField(
              'Max Fellowship Size',
              _maxFellowshipSizeController,
              keyboardType: TextInputType.number,
              hint: '8',
            ),
            _buildTextField(
              'XP Multiplier',
              _xpMultiplierController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hint: '1.0',
            ),
            _buildTextField(
              'Daily Quest Reset Hour (0-23)',
              _dailyQuestResetHourController,
              keyboardType: TextInputType.number,
              hint: '0',
            ),
            _buildSwitchTile(
              'Debug Mode',
              _debugMode,
              (value) => setState(() => _debugMode = value),
            ),
          ]),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const SetupWizardScreen(isRerunningSetup: true),
                ),
              );
              // Reload settings after wizard completes
              await AppConfig.load();
              _loadCurrentSettings();
            },
            icon: const Icon(
              Icons.settings_suggest,
              color: GreenlandsTheme.accentGold,
            ),
            label: const Text(
              'RUN SETUP WIZARD',
              style: TextStyle(color: GreenlandsTheme.accentGold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: GreenlandsTheme.accentGold),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('SAVE ALL SETTINGS'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Settings?'),
                  content: const Text(
                    'This will remove all stored settings and revert to .env defaults. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'CLEAR',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(settingsStorageProvider).clearAll();
                await AppConfig.load();
                _loadCurrentSettings();
                _showSuccess('All settings cleared');
              }
            },
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text(
              'CLEAR ALL SETTINGS',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: GreenlandsTheme.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
