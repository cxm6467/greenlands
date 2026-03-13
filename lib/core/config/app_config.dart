import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AppConfig {
  static final _logger = Logger();

  // Anthropic Claude API
  static String claudeApiKey = '';
  static String claudeModel = 'claude-3-5-sonnet-20241022';

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

  static Future<void> load() async {
    try {
      _logger.i('Loading app configuration...');

      // Try to load .env file, but don't fail if it doesn't exist
      // (especially important for web builds where .env isn't deployed)
      try {
        await dotenv.load(fileName: '.env');
        _logger.i('.env file loaded successfully');
      } catch (e) {
        _logger.w('.env file not found, using default configuration');
        _logger.w('This is normal for web builds');
      }

      // Load API keys
      claudeApiKey = dotenv.env['CLAUDE_API_KEY'] ?? '';
      claudeModel = dotenv.env['CLAUDE_MODEL'] ?? 'claude-3-5-sonnet-20241022';

      // Load MCP Server config
      mcpServerUrl = dotenv.env['MCP_SERVER_URL'] ?? 'http://localhost:3000';
      googleChatWebhookUrl = dotenv.env['GOOGLE_CHAT_WEBHOOK_URL'] ?? '';
      discordBotToken = dotenv.env['DISCORD_BOT_TOKEN'] ?? '';
      slackAppToken = dotenv.env['SLACK_APP_TOKEN'] ?? '';

      // Load feature flags
      enableQuestGeneration = _parseBool(
        dotenv.env['ENABLE_QUEST_GENERATION'],
        true,
      );
      enableChatBots = _parseBool(dotenv.env['ENABLE_CHAT_BOTS'], false);
      enableNotifications = _parseBool(
        dotenv.env['ENABLE_NOTIFICATIONS'],
        true,
      );
      enableRecurringEvents = _parseBool(
        dotenv.env['ENABLE_RECURRING_EVENTS'],
        true,
      );

      // Load game config
      maxFellowshipSize =
          int.tryParse(dotenv.env['MAX_FELLOWSHIP_SIZE'] ?? '8') ?? 8;
      xpMultiplier =
          double.tryParse(dotenv.env['XP_MULTIPLIER'] ?? '1.0') ?? 1.0;
      dailyQuestResetHour =
          int.tryParse(dotenv.env['DAILY_QUEST_RESET_HOUR'] ?? '0') ?? 0;
      debugMode = _parseBool(dotenv.env['DEBUG_MODE'], true);

      _logger.i('App configuration loaded successfully');

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
    === The Greenlands Configuration ===
    Claude Model: $claudeModel
    Claude API Key: ${claudeApiKey.isNotEmpty ? "✓ Set" : "✗ Not set"}
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
