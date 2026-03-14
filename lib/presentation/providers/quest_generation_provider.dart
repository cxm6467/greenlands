import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:greenlands/core/services/ai/quest_generation_service.dart';
import 'package:greenlands/core/config/app_config.dart';
import 'package:greenlands/core/di/injection.dart';
import 'package:greenlands/core/di/injection_names.dart';
import 'package:greenlands/domain/entities/quest.dart';
import 'package:greenlands/domain/repositories/quest_repository.dart';
import 'package:greenlands/presentation/providers/character_provider.dart';

/// Provider for the quest generation service
final questGenerationServiceProvider = Provider<QuestGenerationService>((ref) {
  return QuestGenerationService(
    dio: Dio(), // Create new Dio instance for quest generation
    logger: getIt<Logger>(instanceName: InjectionNames.logger),
    apiKey: AppConfig.claudeApiKey,
    model: AppConfig.claudeModel,
  );
});

/// State provider to track if a quest is currently being generated
final isGeneratingQuestProvider = StateProvider<bool>((ref) => false);

/// State provider to track the last generation error
final questGenerationErrorProvider = StateProvider<String?>((ref) => null);

/// Provider to generate a new quest
/// Returns the generated quest or throws an error
final generateQuestProvider = FutureProvider.autoDispose<Quest>((ref) async {
  final service = ref.watch(questGenerationServiceProvider);
  final characterAsync = ref.watch(characterProvider);

  // Extract character from AsyncValue
  final character = characterAsync.value;

  if (character == null) {
    throw Exception('No character found. Please create a character first.');
  }

  if (!AppConfig.enableQuestGeneration) {
    throw Exception('Quest generation is disabled in settings.');
  }

  if (AppConfig.claudeApiKey.isEmpty) {
    throw Exception('Claude API key not configured. Please add it in settings.');
  }

  // Set generating state
  ref.read(isGeneratingQuestProvider.notifier).state = true;
  ref.read(questGenerationErrorProvider.notifier).state = null;

  try {
    // Get completed quests for context using injection
    final questRepository = getIt<QuestRepository>(instanceName: InjectionNames.questRepository);
    final allQuests = await questRepository.getAllQuests();
    final completedQuests = allQuests.where((q) => q.status == QuestStatus.completed).toList();

    // Generate the quest
    final quest = await service.generateQuest(
      playerLevel: character.level,
      characterName: character.name,
      race: character.race,
      characterClass: character.characterClass,
      completedQuests: completedQuests,
    );

    // Save to repository
    await questRepository.createQuest(quest);

    return quest;
  } catch (e) {
    ref.read(questGenerationErrorProvider.notifier).state = e.toString();
    rethrow;
  } finally {
    ref.read(isGeneratingQuestProvider.notifier).state = false;
  }
});
