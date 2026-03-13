import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/local/database_helper.dart';
import '../services/settings_storage_service.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../data/repositories/web/character_repository_web.dart';
import '../../domain/repositories/character_repository.dart';
import '../../domain/usecases/character/allocate_stat_points.dart';
import '../../domain/usecases/character/create_character.dart';
import '../../domain/usecases/character/get_player_character.dart';
import 'injection_names.dart';

final getIt = GetIt.instance;
final _logger = Logger();

Future<void> setupDependencies() async {
  _logger.i('Setting up dependency injection...');
  _logger.i('Running on web: $kIsWeb');

  // ============================================================================
  // CORE DEPENDENCIES
  // ============================================================================

  // Logger
  getIt.registerLazySingleton<Logger>(() => Logger());

  // Settings Storage (works on all platforms)
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  getIt.registerSingleton<SettingsStorageService>(
    SettingsStorageService(
      secureStorage: secureStorage,
      prefs: sharedPrefs,
      logger: getIt<Logger>(),
    ),
  );
  _logger.i('Settings storage initialized');

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

  // Character repository
  if (!kIsWeb) {
    getIt.registerLazySingleton<CharacterRepository>(
      () => CharacterRepositoryImpl(databaseHelper: getIt()),
      instanceName: InjectionNames.characterRepository,
    );
    _logger.i('Character repository registered (SQLite)');
  } else {
    getIt.registerLazySingleton<CharacterRepository>(
      () => CharacterRepositoryWeb(),
      instanceName: InjectionNames.characterRepository,
    );
    _logger.i('Character repository registered (Web in-memory)');
  }

  // TODO: Register other repositories as they are implemented
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

  _logger.i('Repositories registered');

  // ============================================================================
  // USE CASES
  // ============================================================================

  // Character use cases (work on both mobile and web)
  getIt.registerLazySingleton(
    () => CreateCharacter(
      getIt(instanceName: InjectionNames.characterRepository),
    ),
    instanceName: InjectionNames.createCharacter,
  );
  getIt.registerLazySingleton(
    () => GetPlayerCharacter(
      getIt(instanceName: InjectionNames.characterRepository),
    ),
    instanceName: InjectionNames.getPlayerCharacter,
  );
  getIt.registerLazySingleton(
    () => AllocateStatPoints(
      getIt(instanceName: InjectionNames.characterRepository),
    ),
    instanceName: InjectionNames.allocateStatPoints,
  );
  _logger.i('Character use cases registered');

  // TODO: Register other use cases as they are implemented
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

  _logger.i('Use cases registered');

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

/// Validate that all required dependencies are registered
///
/// This helps catch registration issues early, especially in web builds
/// where type minification can cause GetIt lookup failures.
void validateDependencies() {
  // Check each dependency with its proper type parameter
  if (!getIt.isRegistered<CharacterRepository>(
    instanceName: InjectionNames.characterRepository,
  )) {
    _logger.e('CharacterRepository not registered');
    throw Exception('Required dependency not registered: CharacterRepository');
  }

  if (!getIt.isRegistered<CreateCharacter>(
    instanceName: InjectionNames.createCharacter,
  )) {
    _logger.e('CreateCharacter not registered');
    throw Exception('Required dependency not registered: CreateCharacter');
  }

  if (!getIt.isRegistered<GetPlayerCharacter>(
    instanceName: InjectionNames.getPlayerCharacter,
  )) {
    _logger.e('GetPlayerCharacter not registered');
    throw Exception('Required dependency not registered: GetPlayerCharacter');
  }

  if (!getIt.isRegistered<AllocateStatPoints>(
    instanceName: InjectionNames.allocateStatPoints,
  )) {
    _logger.e('AllocateStatPoints not registered');
    throw Exception('Required dependency not registered: AllocateStatPoints');
  }

  _logger.i('✓ All 4 required dependencies validated');
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  _logger.w('Resetting dependencies...');
  await getIt.reset();
  _logger.w('Dependencies reset complete');
}
