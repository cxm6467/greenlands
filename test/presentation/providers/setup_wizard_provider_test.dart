import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:greenlands/presentation/providers/setup_wizard_provider.dart';
import 'package:greenlands/core/services/health_check/health_check_result.dart';
import 'package:greenlands/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../mocks/mock_settings_storage_service.mocks.dart';
import '../../mocks/mock_health_check_services.mocks.dart';
import '../../mocks/mock_logger.mocks.dart';

void main() {
  // Initialize dotenv for tests that call AppConfig.load()
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize dotenv with empty environment to avoid NotInitializedError
    dotenv.testLoad(fileInput: '');
  });

  group('SetupWizardProvider', () {
    late SetupWizardNotifier notifier;
    late MockSettingsStorageService mockStorage;
    late MockClaudeHealthCheckService mockClaudeHealthCheck;
    late MockDiscordHealthCheckService mockDiscordHealthCheck;
    late MockSlackHealthCheckService mockSlackHealthCheck;
    late MockGoogleChatHealthCheckService mockGoogleChatHealthCheck;
    late MockLogger mockLogger;

    setUp(() {
      mockStorage = MockSettingsStorageService();
      mockClaudeHealthCheck = MockClaudeHealthCheckService();
      mockDiscordHealthCheck = MockDiscordHealthCheckService();
      mockSlackHealthCheck = MockSlackHealthCheckService();
      mockGoogleChatHealthCheck = MockGoogleChatHealthCheckService();
      mockLogger = MockLogger();

      // Set up default mock behaviors for AppConfig.load()
      when(mockStorage.getClaudeApiKey()).thenAnswer((_) async => null);
      when(mockStorage.getClaudeModel()).thenReturn(null);
      when(mockStorage.getMcpServerUrl()).thenReturn(null);
      when(mockStorage.getGoogleChatWebhook()).thenAnswer((_) async => null);
      when(mockStorage.getDiscordBotToken()).thenAnswer((_) async => null);
      when(mockStorage.getSlackAppToken()).thenAnswer((_) async => null);
      when(mockStorage.getEnableQuestGeneration()).thenReturn(null);
      when(mockStorage.getEnableChatBots()).thenReturn(null);
      when(mockStorage.getEnableNotifications()).thenReturn(null);
      when(mockStorage.getEnableRecurringEvents()).thenReturn(null);
      when(mockStorage.getMaxFellowshipSize()).thenReturn(null);
      when(mockStorage.getXpMultiplier()).thenReturn(null);
      when(mockStorage.getDailyQuestResetHour()).thenReturn(null);
      when(mockStorage.getDebugMode()).thenReturn(null);

      // Set up AppConfig with mock storage before each test
      AppConfig.setSettingsStorage(mockStorage);

      notifier = SetupWizardNotifier(
        storage: mockStorage,
        claudeHealthCheck: mockClaudeHealthCheck,
        discordHealthCheck: mockDiscordHealthCheck,
        slackHealthCheck: mockSlackHealthCheck,
        googleChatHealthCheck: mockGoogleChatHealthCheck,
        logger: mockLogger,
      );
    });

    test('initial state is correct', () {
      expect(notifier.state.currentStep, 0);
      expect(notifier.state.enableQuestGeneration, true);
      expect(notifier.state.claudeModel, 'claude-3-5-sonnet-20241022');
      expect(notifier.state.claudeApiKey, '');
      expect(notifier.state.isCheckingHealth, false);
    });

    group('navigation', () {
      test('nextStep increments currentStep', () {
        notifier.nextStep();
        expect(notifier.state.currentStep, 1);
      });

      test('nextStep does not exceed max step', () {
        // Disable quest generation so all steps are valid and nextStep() works
        notifier.setEnableQuestGeneration(false);
        for (var i = 0; i < 10; i++) {
          notifier.nextStep();
        }
        expect(notifier.state.currentStep, lessThanOrEqualTo(5));
      });

      test('previousStep decrements currentStep', () {
        // Disable quest generation so all steps are valid and nextStep() works
        notifier.setEnableQuestGeneration(false);
        notifier.nextStep();
        notifier.nextStep();
        notifier.previousStep();
        expect(notifier.state.currentStep, 1);
      });

      test('previousStep does not go below zero', () {
        notifier.previousStep();
        notifier.previousStep();
        expect(notifier.state.currentStep, 0);
      });

      test('goToStep sets specific step', () {
        notifier.goToStep(3);
        expect(notifier.state.currentStep, 3);
      });

      test('goToStep rejects invalid steps', () {
        notifier.goToStep(-1);
        expect(notifier.state.currentStep, 0);

        notifier.goToStep(10);
        expect(notifier.state.currentStep, 0);
      });
    });

    group('setters', () {
      test('setClaudeApiKey updates state and clears health check', () {
        notifier.setClaudeApiKey('new-key');
        expect(notifier.state.claudeApiKey, 'new-key');
        expect(notifier.state.claudeHealthCheck, null);
      });

      test('setClaudeModel updates state', () {
        notifier.setClaudeModel('claude-3-opus-20240229');
        expect(notifier.state.claudeModel, 'claude-3-opus-20240229');
      });

      test('setEnableQuestGeneration updates state', () {
        notifier.setEnableQuestGeneration(false);
        expect(notifier.state.enableQuestGeneration, false);
      });

      test('setDiscordBotToken updates state and clears health check', () {
        notifier.setDiscordBotToken('new-token');
        expect(notifier.state.discordBotToken, 'new-token');
        expect(notifier.state.discordHealthCheck, null);
      });

      test('setSlackAppToken updates state and clears health check', () {
        notifier.setSlackAppToken('new-token');
        expect(notifier.state.slackAppToken, 'new-token');
        expect(notifier.state.slackHealthCheck, null);
      });

      test('setGoogleChatWebhook updates state and clears health check', () {
        notifier.setGoogleChatWebhook('new-webhook');
        expect(notifier.state.googleChatWebhook, 'new-webhook');
        expect(notifier.state.googleChatHealthCheck, null);
      });

      test('setEnableChatBots updates state', () {
        notifier.setEnableChatBots(true);
        expect(notifier.state.enableChatBots, true);
      });

      test('setEnableNotifications updates state', () {
        notifier.setEnableNotifications(false);
        expect(notifier.state.enableNotifications, false);
      });

      test('setEnableRecurringEvents updates state', () {
        notifier.setEnableRecurringEvents(false);
        expect(notifier.state.enableRecurringEvents, false);
      });

      test('setMaxFellowshipSize updates state', () {
        notifier.setMaxFellowshipSize(5);
        expect(notifier.state.maxFellowshipSize, 5);
      });

      test('setXpMultiplier updates state', () {
        notifier.setXpMultiplier(1.5);
        expect(notifier.state.xpMultiplier, 1.5);
      });

      test('setDailyQuestResetHour updates state', () {
        notifier.setDailyQuestResetHour(12);
        expect(notifier.state.dailyQuestResetHour, 12);
      });
    });

    group('health checks', () {
      test('checkClaudeHealth runs health check', () async {
        notifier.setClaudeApiKey('sk-ant-api03-test');

        when(
          mockClaudeHealthCheck.runAllChecks(any),
        ).thenAnswer((_) async => HealthCheckResult.valid('Valid'));

        await notifier.checkClaudeHealth();

        expect(
          notifier.state.claudeHealthCheck?.status,
          HealthCheckStatus.valid,
        );
        expect(notifier.state.isCheckingHealth, false);
        expect(notifier.state.currentHealthCheckService, null);
        verify(
          mockClaudeHealthCheck.runAllChecks('sk-ant-api03-test'),
        ).called(1);
      });

      test('checkClaudeHealth returns invalid for empty key', () async {
        await notifier.checkClaudeHealth();

        expect(
          notifier.state.claudeHealthCheck?.status,
          HealthCheckStatus.invalid,
        );
        expect(notifier.state.claudeHealthCheck?.message, contains('required'));
        verifyNever(mockClaudeHealthCheck.runAllChecks(any));
      });

      test('checkClaudeHealth handles errors', () async {
        notifier.setClaudeApiKey('sk-ant-api03-test');

        when(
          mockClaudeHealthCheck.runAllChecks(any),
        ).thenThrow(Exception('Network error'));

        await notifier.checkClaudeHealth();

        expect(
          notifier.state.claudeHealthCheck?.status,
          HealthCheckStatus.invalid,
        );
        expect(notifier.state.isCheckingHealth, false);
      });

      test('checkDiscordHealth runs health check', () async {
        notifier.setDiscordBotToken('test-token.abc.def');

        when(
          mockDiscordHealthCheck.runAllChecks(any),
        ).thenAnswer((_) async => HealthCheckResult.valid('Valid'));

        await notifier.checkDiscordHealth();

        expect(
          notifier.state.discordHealthCheck?.status,
          HealthCheckStatus.valid,
        );
        expect(notifier.state.isCheckingHealth, false);
        verify(
          mockDiscordHealthCheck.runAllChecks('test-token.abc.def'),
        ).called(1);
      });

      test('checkSlackHealth runs health check', () async {
        notifier.setSlackAppToken('xoxb-test-token');

        when(
          mockSlackHealthCheck.runAllChecks(any),
        ).thenAnswer((_) async => HealthCheckResult.valid('Valid'));

        await notifier.checkSlackHealth();

        expect(
          notifier.state.slackHealthCheck?.status,
          HealthCheckStatus.valid,
        );
        expect(notifier.state.isCheckingHealth, false);
        verify(mockSlackHealthCheck.runAllChecks('xoxb-test-token')).called(1);
      });

      test('checkGoogleChatHealth runs health check', () async {
        notifier.setGoogleChatWebhook(
          'https://chat.googleapis.com/v1/spaces/test',
        );

        when(
          mockGoogleChatHealthCheck.runAllChecks(any),
        ).thenAnswer((_) async => HealthCheckResult.valid('Valid'));

        await notifier.checkGoogleChatHealth();

        expect(
          notifier.state.googleChatHealthCheck?.status,
          HealthCheckStatus.valid,
        );
        expect(notifier.state.isCheckingHealth, false);
        verify(
          mockGoogleChatHealthCheck.runAllChecks(
            'https://chat.googleapis.com/v1/spaces/test',
          ),
        ).called(1);
      });
    });

    group('validation', () {
      test('isStep0Valid is always true', () {
        expect(notifier.state.isStep0Valid, true);
      });

      test('isStep1Valid returns true when quest generation disabled', () {
        notifier.setEnableQuestGeneration(false);
        expect(notifier.state.isStep1Valid, true);
      });

      test('isStep1Valid returns false when API key empty', () {
        notifier.setEnableQuestGeneration(true);
        expect(notifier.state.isStep1Valid, false);
      });

      test('isStep1Valid returns true when API key valid', () {
        notifier.setEnableQuestGeneration(true);
        notifier.setClaudeApiKey('sk-ant-api03-test');
        notifier.state = notifier.state.copyWith(
          claudeHealthCheck: HealthCheckResult.valid('Valid'),
        );
        expect(notifier.state.isStep1Valid, true);
      });

      test('isStep1Valid returns true with warning status', () {
        notifier.setEnableQuestGeneration(true);
        notifier.setClaudeApiKey('sk-ant-api03-test');
        notifier.state = notifier.state.copyWith(
          claudeHealthCheck: HealthCheckResult.warning('Warning'),
        );
        expect(notifier.state.isStep1Valid, true);
      });

      test('isStep2Valid is always true', () {
        expect(notifier.state.isStep2Valid, true);
      });

      test('isStep3Valid is always true', () {
        expect(notifier.state.isStep3Valid, true);
      });

      test('isStep4Valid is always true', () {
        expect(notifier.state.isStep4Valid, true);
      });

      test('isStep5Valid is always true', () {
        expect(notifier.state.isStep5Valid, true);
      });
    });

    group('canGoNext', () {
      test('returns correct value for each step', () {
        // Step 0 - always valid
        expect(notifier.canGoNext(), true);

        // Step 1 - invalid without API key
        notifier.goToStep(1);
        expect(notifier.canGoNext(), false);

        // Step 1 - valid with quest generation disabled
        notifier.setEnableQuestGeneration(false);
        expect(notifier.canGoNext(), true);

        // Steps 2-5 - always valid
        for (var i = 2; i <= 5; i++) {
          notifier.goToStep(i);
          expect(notifier.canGoNext(), true);
        }
      });
    });

    group('saveAllSettings', () {
      test('saves all settings to storage', () async {
        // Set up mock responses
        when(mockStorage.setClaudeApiKey(any)).thenAnswer((_) async => {});
        when(mockStorage.setClaudeModel(any)).thenAnswer((_) async => {});
        when(
          mockStorage.setEnableQuestGeneration(any),
        ).thenAnswer((_) async => {});
        when(mockStorage.setDiscordBotToken(any)).thenAnswer((_) async => {});
        when(mockStorage.setSlackAppToken(any)).thenAnswer((_) async => {});
        when(mockStorage.setGoogleChatWebhook(any)).thenAnswer((_) async => {});
        when(mockStorage.setEnableChatBots(any)).thenAnswer((_) async => {});
        when(
          mockStorage.setEnableNotifications(any),
        ).thenAnswer((_) async => {});
        when(
          mockStorage.setEnableRecurringEvents(any),
        ).thenAnswer((_) async => {});
        when(mockStorage.setMaxFellowshipSize(any)).thenAnswer((_) async => {});
        when(mockStorage.setXpMultiplier(any)).thenAnswer((_) async => {});
        when(
          mockStorage.setDailyQuestResetHour(any),
        ).thenAnswer((_) async => {});

        // Set some values
        notifier.setClaudeApiKey('sk-ant-api03-test');
        notifier.setClaudeModel('claude-3-opus-20240229');
        notifier.setMaxFellowshipSize(10);

        await notifier.saveAllSettings();

        // Verify all save methods were called
        verify(mockStorage.setClaudeApiKey('sk-ant-api03-test')).called(1);
        verify(mockStorage.setClaudeModel('claude-3-opus-20240229')).called(1);
        verify(mockStorage.setMaxFellowshipSize(10)).called(1);
      });

      test('rethrows errors from storage', () async {
        when(
          mockStorage.setClaudeApiKey(any),
        ).thenThrow(Exception('Storage error'));

        expect(() async => await notifier.saveAllSettings(), throwsException);
      });
    });
  });
}
