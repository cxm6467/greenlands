import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../services/settings_storage_service.dart';

class AppConfig {
  static final _logger = Logger();
  static SettingsStorageService? _settingsStorage;

  // AI Provider Configuration
  static String aiProvider = 'claude'; // 'claude' or 'bedrock'

  // Anthropic Claude API
  static String claudeApiKey = '';
  static String claudeModel = 'claude-3-5-sonnet-20241022';

  // AWS Bedrock Configuration
  static String bedrockModel =
      'anthropic.claude-3-haiku-20240307-v1:0'; // Claude 3 Haiku via Bedrock (cheapest)

  // Proxy URL (works for both Claude and Bedrock)
  // Local development: http://localhost:3001
  // Production: https://your-project.web.app/api/claude (set via .env)
  static String aiProxyUrl = 'http://localhost:3001';

  // Multi-Chat MCP Server
  static String mcpServerUrl = 'http://localhost:3000';
  static String googleChatWebhookUrl = '';
  static String discordBotToken = '';
  static String slackAppToken = '';

  // Feature Flags
  static bool enableQuestGeneration = true;
  static bool enableChatBots = false;
  static bool enableNotifications = true;
  static bool enableRecurringEvents = true;

  // Game Config
  static int maxFellowshipSize = 8;
  static double xpMultiplier = 1.0;
  static int dailyQuestResetHour = 0;
  static bool debugMode = true;

  /// Initialize settings storage (call before load())
  static void setSettingsStorage(SettingsStorageService settingsStorage) {
    _settingsStorage = settingsStorage;
  }

  static Future<void> load() async {
    try {
      _logger.i('Loading app configuration...');

      // Skip .env loading on web builds (security: never expose .env on client)
      // On web, configuration comes from environment or defaults
      if (!kIsWeb) {
        try {
          await dotenv.load(fileName: '.env');
          _logger.i('.env file loaded successfully');
        } catch (e) {
          _logger.w('.env file not found, using default configuration');
        }
      } else {
        _logger.i(
          'Web build detected - skipping .env file load (using defaults/stored settings)',
        );
      }

      // Priority: Stored settings > .env > defaults
      // Helper to safely get env vars (avoid dotenv errors on web)
      String? getEnvVar(String key) {
        try {
          return kIsWeb ? null : dotenv.env[key];
        } catch (e) {
          _logger.w('Failed to read env var $key: $e');
          return null;
        }
      }

      // Load AI Provider configuration
      aiProvider = getEnvVar('AI_PROVIDER') ?? 'claude';

      // Load API keys (stored > .env > default)
      final storedClaudeApiKey = _settingsStorage != null
          ? await _settingsStorage!.getClaudeApiKey()
          : null;
      claudeApiKey = storedClaudeApiKey ?? getEnvVar('CLAUDE_API_KEY') ?? '';
      claudeModel =
          _settingsStorage?.getClaudeModel() ??
          getEnvVar('CLAUDE_MODEL') ??
          'claude-3-5-sonnet-20241022';
      bedrockModel =
          getEnvVar('BEDROCK_MODEL') ??
          'anthropic.claude-3-sonnet-20240229-v1:0';
      aiProxyUrl = getEnvVar('AI_PROXY_URL') ?? 'http://localhost:3001';

      // Load MCP Server config
      mcpServerUrl =
          _settingsStorage?.getMcpServerUrl() ??
          getEnvVar('MCP_SERVER_URL') ??
          'http://localhost:3000';
      final storedGoogleChatWebhook = _settingsStorage != null
          ? await _settingsStorage!.getGoogleChatWebhook()
          : null;
      googleChatWebhookUrl =
          storedGoogleChatWebhook ?? getEnvVar('GOOGLE_CHAT_WEBHOOK_URL') ?? '';
      final storedDiscordBotToken = _settingsStorage != null
          ? await _settingsStorage!.getDiscordBotToken()
          : null;
      discordBotToken =
          storedDiscordBotToken ?? getEnvVar('DISCORD_BOT_TOKEN') ?? '';
      slackAppToken =
          await _settingsStorage?.getSlackAppToken() ??
          getEnvVar('SLACK_APP_TOKEN') ??
          '';

      // Load feature flags
      enableQuestGeneration =
          _settingsStorage?.getEnableQuestGeneration() ??
          _parseBool(getEnvVar('ENABLE_QUEST_GENERATION'), true);
      enableChatBots =
          _settingsStorage?.getEnableChatBots() ??
          _parseBool(getEnvVar('ENABLE_CHAT_BOTS'), false);
      enableNotifications =
          _settingsStorage?.getEnableNotifications() ??
          _parseBool(getEnvVar('ENABLE_NOTIFICATIONS'), true);
      enableRecurringEvents =
          _settingsStorage?.getEnableRecurringEvents() ??
          _parseBool(getEnvVar('ENABLE_RECURRING_EVENTS'), true);

      // Load game config
      maxFellowshipSize =
          _settingsStorage?.getMaxFellowshipSize() ??
          int.tryParse(getEnvVar('MAX_FELLOWSHIP_SIZE') ?? '8') ??
          8;
      xpMultiplier =
          _settingsStorage?.getXpMultiplier() ??
          double.tryParse(getEnvVar('XP_MULTIPLIER') ?? '1.0') ??
          1.0;
      dailyQuestResetHour =
          _settingsStorage?.getDailyQuestResetHour() ??
          int.tryParse(getEnvVar('DAILY_QUEST_RESET_HOUR') ?? '0') ??
          0;
      debugMode =
          _settingsStorage?.getDebugMode() ??
          _parseBool(getEnvVar('DEBUG_MODE'), true);

      _logger.i('App configuration loaded successfully');
      _logger.i(
        'Settings source: ${_settingsStorage != null ? "Stored + .env + defaults" : ".env + defaults"}',
      );

      // Validate critical configuration
      _validate();
    } catch (e) {
      _logger.e('Error loading app configuration: $e');
      throw Exception('Failed to load app configuration: $e');
    }
  }

  static bool _parseBool(String? value, bool defaultValue) {
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  static void _validate() {
    // Warn if Claude API key is missing (critical for RAG features)
    if (claudeApiKey.isEmpty && enableQuestGeneration) {
      _logger.w('Claude API key is not set. AI features will be disabled.');
      _logger.w('Get your API key at: https://console.anthropic.com/');
    }

    // Warn if chat bots enabled but no tokens
    if (enableChatBots) {
      if (googleChatWebhookUrl.isEmpty &&
          discordBotToken.isEmpty &&
          slackAppToken.isEmpty) {
        _logger.w(
          'Chat bots are enabled but no platform tokens are configured.',
        );
        enableChatBots = false;
      }
    }

    _logger.i('Configuration validation complete');
  }

  // Get formatted configuration for debugging
  static String getConfigSummary() {
    return '''
    === Greenfield Configuration ===
    AI Provider: $aiProvider
    ${aiProvider == 'claude' ? 'Claude Model: $claudeModel' : 'Bedrock Model: $bedrockModel'}
    ${aiProvider == 'claude' ? 'Claude API Key: ${claudeApiKey.isNotEmpty ? "✓ Set" : "✗ Not set"}' : 'AWS Bedrock: (configured via proxy)'}
    AI Proxy URL: $aiProxyUrl
    MCP Server URL: $mcpServerUrl

    Feature Flags:
    - Quest Generation: ${enableQuestGeneration ? "✓" : "✗"}
    - Chat Bots: ${enableChatBots ? "✓" : "✗"}
    - Notifications: ${enableNotifications ? "✓" : "✗"}
    - Recurring Events: ${enableRecurringEvents ? "✓" : "✗"}

    Game Config:
    - Max Fellowship Size: $maxFellowshipSize
    - XP Multiplier: ${xpMultiplier}x
    - Daily Quest Reset: $dailyQuestResetHour:00
    - Debug Mode: ${debugMode ? "ON" : "OFF"}
    ==============================
    ''';
  }
}
