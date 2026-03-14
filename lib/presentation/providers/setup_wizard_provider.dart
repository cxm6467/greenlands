import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/config/app_config.dart';
import '../../core/di/injection.dart';
import '../../core/services/health_check/claude_health_check_service.dart';
import '../../core/services/health_check/discord_health_check_service.dart';
import '../../core/services/health_check/google_chat_health_check_service.dart';
import '../../core/services/health_check/health_check_result.dart';
import '../../core/services/health_check/slack_health_check_service.dart';
import '../../core/services/settings_storage_service.dart';

/// State for the setup wizard
class SetupWizardState {
  final int
  currentStep; // 0=Welcome, 1=AI, 2=Chat, 3=Features, 4=Game, 5=Review

  // AI Provider settings
  final String claudeApiKey;
  final String claudeModel;
  final HealthCheckResult? claudeHealthCheck;
  final bool enableQuestGeneration;

  // Chat Integrations
  final String discordBotToken;
  final HealthCheckResult? discordHealthCheck;
  final String slackAppToken;
  final HealthCheckResult? slackHealthCheck;
  final String googleChatWebhook;
  final HealthCheckResult? googleChatHealthCheck;
  final bool enableChatBots;

  // Feature Flags
  final bool enableNotifications;
  final bool enableRecurringEvents;

  // Game Settings
  final int maxFellowshipSize;
  final double xpMultiplier;
  final int dailyQuestResetHour;

  // Wizard metadata
  final bool isCheckingHealth;
  final String? currentHealthCheckService;

  const SetupWizardState({
    required this.currentStep,
    required this.claudeApiKey,
    required this.claudeModel,
    this.claudeHealthCheck,
    required this.enableQuestGeneration,
    required this.discordBotToken,
    this.discordHealthCheck,
    required this.slackAppToken,
    this.slackHealthCheck,
    required this.googleChatWebhook,
    this.googleChatHealthCheck,
    required this.enableChatBots,
    required this.enableNotifications,
    required this.enableRecurringEvents,
    required this.maxFellowshipSize,
    required this.xpMultiplier,
    required this.dailyQuestResetHour,
    required this.isCheckingHealth,
    this.currentHealthCheckService,
  });

  /// Initial state with default values
  factory SetupWizardState.initial() {
    return SetupWizardState(
      currentStep: 0,
      claudeApiKey: '',
      claudeModel: 'claude-3-5-sonnet-20241022',
      enableQuestGeneration: true,
      discordBotToken: '',
      slackAppToken: '',
      googleChatWebhook: '',
      enableChatBots: false,
      enableNotifications: true,
      enableRecurringEvents: true,
      maxFellowshipSize: 8,
      xpMultiplier: 1.0,
      dailyQuestResetHour: 0,
      isCheckingHealth: false,
    );
  }

  /// Validation getters for each step
  bool get isStep0Valid => true; // Welcome - always valid

  bool get isStep1Valid {
    // AI Provider - valid if quest generation disabled OR API key is valid/warning
    if (!enableQuestGeneration) return true;
    final status = claudeHealthCheck?.status;
    return claudeApiKey.isNotEmpty &&
        (status == HealthCheckStatus.valid ||
            status == HealthCheckStatus.warning);
  }

  bool get isStep2Valid => true; // Chat integrations - all optional
  bool get isStep3Valid => true; // Feature flags - always valid
  bool get isStep4Valid => true; // Game settings - always valid
  bool get isStep5Valid => true; // Review - always valid

  // Sentinel used to distinguish "not provided" from "explicitly null" in copyWith.
  static const Object _sentinel = Object();

  SetupWizardState copyWith({
    int? currentStep,
    String? claudeApiKey,
    String? claudeModel,
    Object? claudeHealthCheck = _sentinel,
    bool? enableQuestGeneration,
    String? discordBotToken,
    Object? discordHealthCheck = _sentinel,
    String? slackAppToken,
    Object? slackHealthCheck = _sentinel,
    String? googleChatWebhook,
    Object? googleChatHealthCheck = _sentinel,
    bool? enableChatBots,
    bool? enableNotifications,
    bool? enableRecurringEvents,
    int? maxFellowshipSize,
    double? xpMultiplier,
    int? dailyQuestResetHour,
    bool? isCheckingHealth,
    Object? currentHealthCheckService = _sentinel,
  }) {
    return SetupWizardState(
      currentStep: currentStep ?? this.currentStep,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      claudeModel: claudeModel ?? this.claudeModel,
      claudeHealthCheck: identical(claudeHealthCheck, _sentinel)
          ? this.claudeHealthCheck
          : claudeHealthCheck as HealthCheckResult?,
      enableQuestGeneration:
          enableQuestGeneration ?? this.enableQuestGeneration,
      discordBotToken: discordBotToken ?? this.discordBotToken,
      discordHealthCheck: identical(discordHealthCheck, _sentinel)
          ? this.discordHealthCheck
          : discordHealthCheck as HealthCheckResult?,
      slackAppToken: slackAppToken ?? this.slackAppToken,
      slackHealthCheck: identical(slackHealthCheck, _sentinel)
          ? this.slackHealthCheck
          : slackHealthCheck as HealthCheckResult?,
      googleChatWebhook: googleChatWebhook ?? this.googleChatWebhook,
      googleChatHealthCheck: identical(googleChatHealthCheck, _sentinel)
          ? this.googleChatHealthCheck
          : googleChatHealthCheck as HealthCheckResult?,
      enableChatBots: enableChatBots ?? this.enableChatBots,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableRecurringEvents:
          enableRecurringEvents ?? this.enableRecurringEvents,
      maxFellowshipSize: maxFellowshipSize ?? this.maxFellowshipSize,
      xpMultiplier: xpMultiplier ?? this.xpMultiplier,
      dailyQuestResetHour: dailyQuestResetHour ?? this.dailyQuestResetHour,
      isCheckingHealth: isCheckingHealth ?? this.isCheckingHealth,
      currentHealthCheckService: identical(currentHealthCheckService, _sentinel)
          ? this.currentHealthCheckService
          : currentHealthCheckService as String?,
    );
  }
}

/// Notifier for managing setup wizard state
class SetupWizardNotifier extends StateNotifier<SetupWizardState> {
  final SettingsStorageService _storage;
  final ClaudeHealthCheckService _claudeHealthCheck;
  final DiscordHealthCheckService _discordHealthCheck;
  final SlackHealthCheckService _slackHealthCheck;
  final GoogleChatHealthCheckService _googleChatHealthCheck;
  final Logger _logger;

  SetupWizardNotifier({
    required SettingsStorageService storage,
    required ClaudeHealthCheckService claudeHealthCheck,
    required DiscordHealthCheckService discordHealthCheck,
    required SlackHealthCheckService slackHealthCheck,
    required GoogleChatHealthCheckService googleChatHealthCheck,
    required Logger logger,
  }) : _storage = storage,
       _claudeHealthCheck = claudeHealthCheck,
       _discordHealthCheck = discordHealthCheck,
       _slackHealthCheck = slackHealthCheck,
       _googleChatHealthCheck = googleChatHealthCheck,
       _logger = logger,
       super(SetupWizardState.initial());

  /// Load current settings from AppConfig and storage
  Future<void> loadCurrentSettings() async {
    try {
      _logger.i('Loading current settings into wizard...');

      // Load from AppConfig (which already loaded from storage)
      final claudeApiKey = AppConfig.claudeApiKey;
      final claudeModel = AppConfig.claudeModel;
      final enableQuestGeneration = AppConfig.enableQuestGeneration;
      final googleChatWebhook = AppConfig.googleChatWebhookUrl;
      final discordBotToken = AppConfig.discordBotToken;
      final slackAppToken = AppConfig.slackAppToken;
      final enableChatBots = AppConfig.enableChatBots;
      final enableNotifications = AppConfig.enableNotifications;
      final enableRecurringEvents = AppConfig.enableRecurringEvents;
      final maxFellowshipSize = AppConfig.maxFellowshipSize;
      final xpMultiplier = AppConfig.xpMultiplier;
      final dailyQuestResetHour = AppConfig.dailyQuestResetHour;

      state = state.copyWith(
        claudeApiKey: claudeApiKey,
        claudeModel: claudeModel,
        enableQuestGeneration: enableQuestGeneration,
        googleChatWebhook: googleChatWebhook,
        discordBotToken: discordBotToken,
        slackAppToken: slackAppToken,
        enableChatBots: enableChatBots,
        enableNotifications: enableNotifications,
        enableRecurringEvents: enableRecurringEvents,
        maxFellowshipSize: maxFellowshipSize,
        xpMultiplier: xpMultiplier,
        dailyQuestResetHour: dailyQuestResetHour,
      );

      _logger.i('Settings loaded successfully');
    } catch (e) {
      _logger.e('Error loading settings: $e');
    }
  }

  // ============================================================================
  // FIELD SETTERS
  // ============================================================================

  void setClaudeApiKey(String value) {
    state = state.copyWith(
      claudeApiKey: value,
      claudeHealthCheck: null, // Clear health check when value changes
    );
  }

  void setClaudeModel(String value) {
    state = state.copyWith(claudeModel: value);
  }

  void setEnableQuestGeneration(bool value) {
    state = state.copyWith(enableQuestGeneration: value);
  }

  void setDiscordBotToken(String value) {
    state = state.copyWith(discordBotToken: value, discordHealthCheck: null);
  }

  void setSlackAppToken(String value) {
    state = state.copyWith(slackAppToken: value, slackHealthCheck: null);
  }

  void setGoogleChatWebhook(String value) {
    state = state.copyWith(
      googleChatWebhook: value,
      googleChatHealthCheck: null,
    );
  }

  void setEnableChatBots(bool value) {
    state = state.copyWith(enableChatBots: value);
  }

  void setEnableNotifications(bool value) {
    state = state.copyWith(enableNotifications: value);
  }

  void setEnableRecurringEvents(bool value) {
    state = state.copyWith(enableRecurringEvents: value);
  }

  void setMaxFellowshipSize(int value) {
    state = state.copyWith(maxFellowshipSize: value);
  }

  void setXpMultiplier(double value) {
    state = state.copyWith(xpMultiplier: value);
  }

  void setDailyQuestResetHour(int value) {
    state = state.copyWith(dailyQuestResetHour: value);
  }

  // ============================================================================
  // HEALTH CHECK METHODS
  // ============================================================================

  Future<void> checkClaudeHealth() async {
    if (state.claudeApiKey.isEmpty) {
      state = state.copyWith(
        claudeHealthCheck: HealthCheckResult.invalidFormat(
          'API key is required',
          details: 'Please enter your Claude API key',
        ),
      );
      return;
    }

    state = state.copyWith(
      isCheckingHealth: true,
      currentHealthCheckService: 'Claude',
    );

    try {
      final result = await _claudeHealthCheck.runAllChecks(state.claudeApiKey);
      state = state.copyWith(
        claudeHealthCheck: result,
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    } catch (e) {
      _logger.e('Error checking Claude health: $e');
      state = state.copyWith(
        claudeHealthCheck: HealthCheckResult.connectivityFailed(
          'Health check failed',
          details: e.toString(),
        ),
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    }
  }

  Future<void> checkDiscordHealth() async {
    if (state.discordBotToken.isEmpty) {
      state = state.copyWith(
        discordHealthCheck: HealthCheckResult.invalidFormat(
          'Bot token is required',
          details: 'Please enter your Discord bot token',
        ),
      );
      return;
    }

    state = state.copyWith(
      isCheckingHealth: true,
      currentHealthCheckService: 'Discord',
    );

    try {
      final result = await _discordHealthCheck.runAllChecks(
        state.discordBotToken,
      );
      state = state.copyWith(
        discordHealthCheck: result,
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    } catch (e) {
      _logger.e('Error checking Discord health: $e');
      state = state.copyWith(
        discordHealthCheck: HealthCheckResult.connectivityFailed(
          'Health check failed',
          details: e.toString(),
        ),
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    }
  }

  Future<void> checkSlackHealth() async {
    if (state.slackAppToken.isEmpty) {
      state = state.copyWith(
        slackHealthCheck: HealthCheckResult.invalidFormat(
          'App token is required',
          details: 'Please enter your Slack app token',
        ),
      );
      return;
    }

    state = state.copyWith(
      isCheckingHealth: true,
      currentHealthCheckService: 'Slack',
    );

    try {
      final result = await _slackHealthCheck.runAllChecks(state.slackAppToken);
      state = state.copyWith(
        slackHealthCheck: result,
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    } catch (e) {
      _logger.e('Error checking Slack health: $e');
      state = state.copyWith(
        slackHealthCheck: HealthCheckResult.connectivityFailed(
          'Health check failed',
          details: e.toString(),
        ),
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    }
  }

  Future<void> checkGoogleChatHealth() async {
    if (state.googleChatWebhook.isEmpty) {
      state = state.copyWith(
        googleChatHealthCheck: HealthCheckResult.invalidFormat(
          'Webhook URL is required',
          details: 'Please enter your Google Chat webhook URL',
        ),
      );
      return;
    }

    state = state.copyWith(
      isCheckingHealth: true,
      currentHealthCheckService: 'GoogleChat',
    );

    try {
      final result = await _googleChatHealthCheck.runAllChecks(
        state.googleChatWebhook,
      );
      state = state.copyWith(
        googleChatHealthCheck: result,
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    } catch (e) {
      _logger.e('Error checking Google Chat health: $e');
      state = state.copyWith(
        googleChatHealthCheck: HealthCheckResult.connectivityFailed(
          'Health check failed',
          details: e.toString(),
        ),
        isCheckingHealth: false,
        currentHealthCheckService: null,
      );
    }
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  static const int _maxStep = 5;

  void nextStep() {
    if (_canGoNext() && state.currentStep < _maxStep) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= _maxStep) {
      state = state.copyWith(currentStep: step);
    }
  }

  bool _canGoNext() {
    switch (state.currentStep) {
      case 0:
        return state.isStep0Valid;
      case 1:
        return state.isStep1Valid;
      case 2:
        return state.isStep2Valid;
      case 3:
        return state.isStep3Valid;
      case 4:
        return state.isStep4Valid;
      case 5:
        return state.isStep5Valid;
      default:
        return false;
    }
  }

  bool canGoNext() => _canGoNext();

  // ============================================================================
  // SAVE SETTINGS
  // ============================================================================

  Future<void> saveAllSettings() async {
    try {
      _logger.i('Saving all settings from wizard...');

      // Save all settings to storage
      await _storage.setClaudeApiKey(state.claudeApiKey);
      await _storage.setClaudeModel(state.claudeModel);
      await _storage.setEnableQuestGeneration(state.enableQuestGeneration);

      await _storage.setDiscordBotToken(state.discordBotToken);
      await _storage.setSlackAppToken(state.slackAppToken);
      await _storage.setGoogleChatWebhook(state.googleChatWebhook);
      await _storage.setEnableChatBots(state.enableChatBots);

      await _storage.setEnableNotifications(state.enableNotifications);
      await _storage.setEnableRecurringEvents(state.enableRecurringEvents);

      await _storage.setMaxFellowshipSize(state.maxFellowshipSize);
      await _storage.setXpMultiplier(state.xpMultiplier);
      await _storage.setDailyQuestResetHour(state.dailyQuestResetHour);

      // Reload AppConfig to pick up the changes
      await AppConfig.load();

      _logger.i('All settings saved successfully');
    } catch (e) {
      _logger.e('Error saving settings: $e');
      rethrow;
    }
  }
}

/// Provider for setup wizard state
final setupWizardProvider =
    StateNotifierProvider<SetupWizardNotifier, SetupWizardState>((ref) {
      return SetupWizardNotifier(
        storage: getIt<SettingsStorageService>(),
        claudeHealthCheck: getIt<ClaudeHealthCheckService>(),
        discordHealthCheck: getIt<DiscordHealthCheckService>(),
        slackHealthCheck: getIt<SlackHealthCheckService>(),
        googleChatHealthCheck: getIt<GoogleChatHealthCheckService>(),
        logger: getIt<Logger>(),
      );
    });
