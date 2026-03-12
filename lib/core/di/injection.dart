import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/local/database_helper.dart';
// Note: Additional imports will be added as we implement more features

final getIt = GetIt.instance;
final _logger = Logger();

Future<void> setupDependencies() async {
  _logger.i('Setting up dependency injection...');

  // ============================================================================
  // CORE DEPENDENCIES
  // ============================================================================

  // Logger
  getIt.registerLazySingleton<Logger>(() => Logger());

  // Database (skip on web - SQLite doesn't work in browsers)
  if (!kIsWeb) {
    try {
      final database = await DatabaseHelper.instance.database;
      getIt.registerSingleton<Database>(database);
      getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);
      _logger.i('Database initialized successfully');
    } catch (e) {
      _logger.w('Database initialization failed (expected on web): $e');
    }
  } else {
    _logger.i('Running on web - database features disabled');
  }

  _logger.i('Core dependencies registered');

  // ============================================================================
  // DATA SOURCES
  // ============================================================================

  // TODO: Register data sources as they are implemented
  // Local data sources
  // getIt.registerLazySingleton<CharacterLocalDataSource>(
  //   () => CharacterLocalDataSourceImpl(getIt()),
  // );
  // getIt.registerLazySingleton<QuestLocalDataSource>(
  //   () => QuestLocalDataSourceImpl(getIt()),
  // );
  // getIt.registerLazySingleton<FellowshipLocalDataSource>(
  //   () => FellowshipLocalDataSourceImpl(getIt()),
  // );
  // getIt.registerLazySingleton<InventoryLocalDataSource>(
  //   () => InventoryLocalDataSourceImpl(getIt()),
  // );
  // getIt.registerLazySingleton<NotificationLocalDataSource>(
  //   () => NotificationLocalDataSourceImpl(getIt()),
  // );

  // Remote data sources
  // getIt.registerLazySingleton<ClaudeApiClient>(
  //   () => ClaudeApiClient(AppConfig.claudeApiKey),
  // );
  // getIt.registerLazySingleton<MCPChatClient>(
  //   () => MCPChatClient(AppConfig.mcpServerUrl),
  // );

  _logger.i('Data sources will be registered as implemented');

  // ============================================================================
  // REPOSITORIES
  // ============================================================================

  // TODO: Register repositories as they are implemented
  // getIt.registerLazySingleton<CharacterRepository>(
  //   () => CharacterRepositoryImpl(getIt()),
  // );
  // getIt.registerLazySingleton<QuestRepository>(
  //   () => QuestRepositoryImpl(getIt()),
  // );
  // getIt.registerLazySingleton<FellowshipRepository>(
  //   () => FellowshipRepositoryImpl(getIt()),
  // );
  // getIt.registerLazySingleton<InventoryRepository>(
  //   () => InventoryRepositoryImpl(getIt()),
  // );
  // getIt.registerLazySingleton<RagRepository>(
  //   () => RagRepositoryImpl(getIt()),
  // );
  // getIt.registerLazySingleton<NotificationRepository>(
  //   () => NotificationRepositoryImpl(getIt()),
  // );

  _logger.i('Repositories will be registered as implemented');

  // ============================================================================
  // USE CASES
  // ============================================================================

  // TODO: Register use cases as they are implemented

  // Character use cases
  // getIt.registerLazySingleton(() => CreateCharacter(getIt()));
  // getIt.registerLazySingleton(() => GetCharacter(getIt()));
  // getIt.registerLazySingleton(() => UpdateCharacterStats(getIt()));
  // getIt.registerLazySingleton(() => AddXp(getIt()));
  // getIt.registerLazySingleton(() => LevelUpCharacter(getIt()));

  // Quest use cases
  // getIt.registerLazySingleton(() => GetAvailableQuests(getIt()));
  // getIt.registerLazySingleton(() => AcceptQuest(getIt()));
  // getIt.registerLazySingleton(() => CompleteQuest(getIt()));
  // getIt.registerLazySingleton(() => GenerateDynamicQuest(getIt()));

  // Fellowship use cases
  // getIt.registerLazySingleton(() => GetFellowshipMembers(getIt()));
  // getIt.registerLazySingleton(() => InteractWithNpc(getIt()));
  // getIt.registerLazySingleton(() => UpdateRelationship(getIt()));

  // RAG use cases
  // getIt.registerLazySingleton(() => ChatWithGaladriel(getIt()));
  // getIt.registerLazySingleton(() => ParseNaturalCommand(getIt()));
  // getIt.registerLazySingleton(() => GenerateNpcResponse(getIt()));

  // Notification use cases
  // getIt.registerLazySingleton(() => QueueNotification(getIt()));
  // getIt.registerLazySingleton(() => SendNotification(getIt()));

  _logger.i('Use cases will be registered as implemented');

  // ============================================================================
  // SERVICES
  // ============================================================================

  // TODO: Register services as they are implemented
  // getIt.registerLazySingleton<GameEngineService>(
  //   () => GameEngineService(getIt(), getIt()),
  // );
  // getIt.registerLazySingleton<ClaudeService>(
  //   () => ClaudeService(getIt()),
  // );
  // getIt.registerLazySingleton<NotificationService>(
  //   () => NotificationService(getIt()),
  // );
  // getIt.registerLazySingleton<RecurringEventService>(
  //   () => RecurringEventService(getIt()),
  // );

  // if (AppConfig.enableChatBots) {
  //   getIt.registerLazySingleton<MCPChatService>(
  //     () => MCPChatService(getIt()),
  //   );
  // }

  _logger.i('Services will be registered as implemented');

  _logger.i('Dependency injection setup complete');
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  _logger.w('Resetting dependencies...');
  await getIt.reset();
  _logger.w('Dependencies reset complete');
}
