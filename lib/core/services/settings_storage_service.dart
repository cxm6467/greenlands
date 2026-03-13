import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving app settings
///
/// Uses flutter_secure_storage for sensitive data (API keys, tokens)
/// and shared_preferences for non-sensitive settings
class SettingsStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final Logger _logger;

  SettingsStorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
    required Logger logger,
  }) : _secureStorage = secureStorage,
       _prefs = prefs,
       _logger = logger;

  // Secure storage keys (for sensitive data)
  static const String _keyClaudeApiKey = 'claude_api_key';
  static const String _keyGoogleChatWebhook = 'google_chat_webhook';
  static const String _keyDiscordBotToken = 'discord_bot_token';
  static const String _keySlackAppToken = 'slack_app_token';
  static const String _keyAdminPassword = 'admin_password';

  // Shared preferences keys (for non-sensitive data)
  static const String _keyClaudeModel = 'claude_model';
  static const String _keyMcpServerUrl = 'mcp_server_url';
  static const String _keyEnableQuestGeneration = 'enable_quest_generation';
  static const String _keyEnableChatBots = 'enable_chat_bots';
  static const String _keyEnableNotifications = 'enable_notifications';
  static const String _keyEnableRecurringEvents = 'enable_recurring_events';
  static const String _keyMaxFellowshipSize = 'max_fellowship_size';
  static const String _keyXpMultiplier = 'xp_multiplier';
  static const String _keyDailyQuestResetHour = 'daily_quest_reset_hour';
  static const String _keyDebugMode = 'debug_mode';

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================

  /// Check if an admin password has been set
  Future<bool> hasAdminPassword() async {
    try {
      final password = await _secureStorage.read(key: _keyAdminPassword);
      return password != null && password.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking admin password: $e');
      return false;
    }
  }

  /// Set the admin password for settings access
  Future<void> setAdminPassword(String password) async {
    try {
      await _secureStorage.write(key: _keyAdminPassword, value: password);
      _logger.i('Admin password set successfully');
    } catch (e) {
      _logger.e('Error setting admin password: $e');
      throw Exception('Failed to set admin password');
    }
  }

  /// Verify the admin password
  Future<bool> verifyAdminPassword(String password) async {
    try {
      final storedPassword = await _secureStorage.read(key: _keyAdminPassword);
      return storedPassword == password;
    } catch (e) {
      _logger.e('Error verifying admin password: $e');
      return false;
    }
  }

  // ============================================================================
  // AI PROVIDER SETTINGS
  // ============================================================================

  Future<String?> getClaudeApiKey() async {
    return await _secureStorage.read(key: _keyClaudeApiKey);
  }

  Future<void> setClaudeApiKey(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyClaudeApiKey);
    } else {
      await _secureStorage.write(key: _keyClaudeApiKey, value: value);
    }
  }

  String? getClaudeModel() {
    return _prefs.getString(_keyClaudeModel);
  }

  Future<void> setClaudeModel(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_keyClaudeModel);
    } else {
      await _prefs.setString(_keyClaudeModel, value);
    }
  }

  // ============================================================================
  // CHAT INTEGRATIONS
  // ============================================================================

  String? getMcpServerUrl() {
    return _prefs.getString(_keyMcpServerUrl);
  }

  Future<void> setMcpServerUrl(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_keyMcpServerUrl);
    } else {
      await _prefs.setString(_keyMcpServerUrl, value);
    }
  }

  Future<String?> getGoogleChatWebhook() async {
    return await _secureStorage.read(key: _keyGoogleChatWebhook);
  }

  Future<void> setGoogleChatWebhook(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyGoogleChatWebhook);
    } else {
      await _secureStorage.write(key: _keyGoogleChatWebhook, value: value);
    }
  }

  Future<String?> getDiscordBotToken() async {
    return await _secureStorage.read(key: _keyDiscordBotToken);
  }

  Future<void> setDiscordBotToken(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keyDiscordBotToken);
    } else {
      await _secureStorage.write(key: _keyDiscordBotToken, value: value);
    }
  }

  Future<String?> getSlackAppToken() async {
    return await _secureStorage.read(key: _keySlackAppToken);
  }

  Future<void> setSlackAppToken(String? value) async {
    if (value == null || value.isEmpty) {
      await _secureStorage.delete(key: _keySlackAppToken);
    } else {
      await _secureStorage.write(key: _keySlackAppToken, value: value);
    }
  }

  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================

  bool? getEnableQuestGeneration() {
    return _prefs.getBool(_keyEnableQuestGeneration);
  }

  Future<void> setEnableQuestGeneration(bool value) async {
    await _prefs.setBool(_keyEnableQuestGeneration, value);
  }

  bool? getEnableChatBots() {
    return _prefs.getBool(_keyEnableChatBots);
  }

  Future<void> setEnableChatBots(bool value) async {
    await _prefs.setBool(_keyEnableChatBots, value);
  }

  bool? getEnableNotifications() {
    return _prefs.getBool(_keyEnableNotifications);
  }

  Future<void> setEnableNotifications(bool value) async {
    await _prefs.setBool(_keyEnableNotifications, value);
  }

  bool? getEnableRecurringEvents() {
    return _prefs.getBool(_keyEnableRecurringEvents);
  }

  Future<void> setEnableRecurringEvents(bool value) async {
    await _prefs.setBool(_keyEnableRecurringEvents, value);
  }

  // ============================================================================
  // GAME SETTINGS
  // ============================================================================

  int? getMaxFellowshipSize() {
    return _prefs.getInt(_keyMaxFellowshipSize);
  }

  Future<void> setMaxFellowshipSize(int value) async {
    await _prefs.setInt(_keyMaxFellowshipSize, value);
  }

  double? getXpMultiplier() {
    return _prefs.getDouble(_keyXpMultiplier);
  }

  Future<void> setXpMultiplier(double value) async {
    await _prefs.setDouble(_keyXpMultiplier, value);
  }

  int? getDailyQuestResetHour() {
    return _prefs.getInt(_keyDailyQuestResetHour);
  }

  Future<void> setDailyQuestResetHour(int value) async {
    await _prefs.setInt(_keyDailyQuestResetHour, value);
  }

  bool? getDebugMode() {
    return _prefs.getBool(_keyDebugMode);
  }

  Future<void> setDebugMode(bool value) async {
    await _prefs.setBool(_keyDebugMode, value);
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Clear all stored settings
  Future<void> clearAll() async {
    _logger.w('Clearing all stored settings...');
    await _secureStorage.deleteAll();
    await _prefs.clear();
    _logger.w('All settings cleared');
  }
}
