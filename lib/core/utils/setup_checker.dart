import 'package:logger/logger.dart';

import '../services/settings_storage_service.dart';

/// Utility to determine if the setup wizard should be shown
class SetupChecker {
  final SettingsStorageService _storage;
  final Logger _logger;

  SetupChecker({
    required SettingsStorageService storage,
    required Logger logger,
  }) : _storage = storage,
       _logger = logger;

  /// Check if the setup wizard should be shown
  ///
  /// Returns true if:
  /// 1. First run (no settings stored at all), OR
  /// 2. Quest generation enabled but Claude API key is missing, OR
  /// 3. Chat bots enabled but no chat integration tokens configured
  Future<bool> shouldShowSetupWizard() async {
    try {
      _logger.d('Checking if setup wizard should be shown...');

      // Check if first run (no settings at all)
      final hasAnySettings = await _hasAnyStoredSettings();
      if (!hasAnySettings) {
        _logger.i('First run detected - showing setup wizard');
        return true;
      }

      // Check if quest generation enabled but no API key
      final questGenerationEnabled =
          _storage.getEnableQuestGeneration() ?? false;
      if (questGenerationEnabled) {
        final claudeApiKey = await _storage.getClaudeApiKey();
        if (claudeApiKey == null || claudeApiKey.isEmpty) {
          _logger.w(
            'Quest generation enabled but Claude API key missing - showing setup wizard',
          );
          return true;
        }
      }

      // Check if chat bots enabled but no tokens
      final chatBotsEnabled = _storage.getEnableChatBots() ?? false;
      if (chatBotsEnabled) {
        final hasAnyToken = await _hasAnyChatToken();
        if (!hasAnyToken) {
          _logger.w(
            'Chat bots enabled but no chat tokens configured - showing setup wizard',
          );
          return true;
        }
      }

      _logger.d('All critical settings present - skipping setup wizard');
      return false;
    } catch (e) {
      _logger.e('Error checking setup wizard status: $e');
      // On error, don't show wizard to avoid blocking the user
      return false;
    }
  }

  /// Check if any settings have been stored
  Future<bool> _hasAnyStoredSettings() async {
    // Check a few key settings to determine if this is first run
    final claudeApiKey = await _storage.getClaudeApiKey();
    final claudeModel = _storage.getClaudeModel();
    final questGenerationEnabled = _storage.getEnableQuestGeneration();
    final maxFellowshipSize = _storage.getMaxFellowshipSize();
    final chatBotsEnabled = _storage.getEnableChatBots();
    final hasChatToken = await _hasAnyChatToken();

    return (claudeApiKey != null && claudeApiKey.isNotEmpty) ||
        (claudeModel != null && claudeModel.isNotEmpty) ||
        questGenerationEnabled != null ||
        maxFellowshipSize != null ||
        chatBotsEnabled != null ||
        hasChatToken;
  }

  /// Check if any chat integration token is configured
  Future<bool> _hasAnyChatToken() async {
    final discordToken = await _storage.getDiscordBotToken();
    final slackToken = await _storage.getSlackAppToken();
    final googleChatWebhook = await _storage.getGoogleChatWebhook();

    return (discordToken != null && discordToken.isNotEmpty) ||
        (slackToken != null && slackToken.isNotEmpty) ||
        (googleChatWebhook != null && googleChatWebhook.isNotEmpty);
  }
}
