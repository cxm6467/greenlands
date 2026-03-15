import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenfield/presentation/providers/setup_wizard_provider.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_settings_storage_service.mocks.dart';
import '../mocks/mock_health_check_services.mocks.dart';
import '../mocks/mock_logger.mocks.dart';

/// Creates provider overrides for testing widget screens
///
/// This allows widget tests to use real providers with mocked dependencies,
/// avoiding GetIt initialization issues.
List<Override> createTestProviderOverrides({
  MockSettingsStorageService? mockStorage,
  MockClaudeHealthCheckService? mockClaudeHealthCheck,
  MockDiscordHealthCheckService? mockDiscordHealthCheck,
  MockSlackHealthCheckService? mockSlackHealthCheck,
  MockGoogleChatHealthCheckService? mockGoogleChatHealthCheck,
  MockLogger? mockLogger,
}) {
  // Create default mocks if not provided
  final storage = mockStorage ?? MockSettingsStorageService();
  final claudeHealthCheck =
      mockClaudeHealthCheck ?? MockClaudeHealthCheckService();
  final discordHealthCheck =
      mockDiscordHealthCheck ?? MockDiscordHealthCheckService();
  final slackHealthCheck =
      mockSlackHealthCheck ?? MockSlackHealthCheckService();
  final googleChatHealthCheck =
      mockGoogleChatHealthCheck ?? MockGoogleChatHealthCheckService();
  final logger = mockLogger ?? MockLogger();

  // Set up default mock behaviors
  _setupDefaultMockBehaviors(storage: storage);

  return [
    // Override setupWizardProvider with mocked dependencies
    setupWizardProvider.overrideWith((ref) {
      final notifier = SetupWizardNotifier(
        storage: storage,
        claudeHealthCheck: claudeHealthCheck,
        discordHealthCheck: discordHealthCheck,
        slackHealthCheck: slackHealthCheck,
        googleChatHealthCheck: googleChatHealthCheck,
        logger: logger,
      );
      // Initialize with quest generation disabled to make all steps valid for testing
      notifier.setEnableQuestGeneration(false);
      return notifier;
    }),
  ];
}

/// Set up default mock behaviors to avoid null pointer exceptions
void _setupDefaultMockBehaviors({required MockSettingsStorageService storage}) {
  // SettingsStorageService - return valid default values for testing
  // Async methods (using FlutterSecureStorage)
  when(storage.getClaudeApiKey()).thenAnswer((_) async => '');
  when(storage.getDiscordBotToken()).thenAnswer((_) async => '');
  when(storage.getSlackAppToken()).thenAnswer((_) async => '');
  when(storage.getGoogleChatWebhook()).thenAnswer((_) async => '');

  // Synchronous methods (using SharedPreferences)
  when(storage.getClaudeModel()).thenReturn('claude-3-5-sonnet-20241022');
  // Disable quest generation by default so step 1 validation passes without API key
  when(storage.getEnableQuestGeneration()).thenReturn(false);
  when(storage.getEnableChatBots()).thenReturn(false);
  when(storage.getEnableNotifications()).thenReturn(true);
  when(storage.getEnableRecurringEvents()).thenReturn(true);
  when(storage.getMaxFellowshipSize()).thenReturn(8);
  when(storage.getXpMultiplier()).thenReturn(1.0);
  when(storage.getDailyQuestResetHour()).thenReturn(0);

  // All setters return successfully
  when(storage.setClaudeApiKey(any)).thenAnswer((_) async {});
  when(storage.setClaudeModel(any)).thenAnswer((_) async {});
  when(storage.setEnableQuestGeneration(any)).thenAnswer((_) async {});
  when(storage.setDiscordBotToken(any)).thenAnswer((_) async {});
  when(storage.setSlackAppToken(any)).thenAnswer((_) async {});
  when(storage.setGoogleChatWebhook(any)).thenAnswer((_) async {});
  when(storage.setEnableChatBots(any)).thenAnswer((_) async {});
  when(storage.setEnableNotifications(any)).thenAnswer((_) async {});
  when(storage.setEnableRecurringEvents(any)).thenAnswer((_) async {});
  when(storage.setMaxFellowshipSize(any)).thenAnswer((_) async {});
  when(storage.setXpMultiplier(any)).thenAnswer((_) async {});
  when(storage.setDailyQuestResetHour(any)).thenAnswer((_) async {});
}
