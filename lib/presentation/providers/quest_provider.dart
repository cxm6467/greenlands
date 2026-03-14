import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../core/di/injection_names.dart';
import '../../domain/entities/quest.dart';
import '../../domain/usecases/quest/accept_quest.dart';
import '../../domain/usecases/quest/complete_quest.dart';
import '../../domain/usecases/quest/get_active_quests.dart';
import '../../domain/usecases/quest/get_available_quests.dart';
import '../../domain/usecases/quest/update_quest_objectives.dart';
import 'character_provider.dart';

/// Provider for available quests based on player level
final availableQuestsProvider =
    StateNotifierProvider<AvailableQuestsNotifier, AsyncValue<List<Quest>>>((
      ref,
    ) {
      // Watch character to get player level
      final characterAsync = ref.watch(characterProvider);

      return AvailableQuestsNotifier(
        getAvailableQuests: getIt<GetAvailableQuests>(
          instanceName: InjectionNames.getAvailableQuests,
        ),
        characterAsync: characterAsync,
      );
    });

class AvailableQuestsNotifier extends StateNotifier<AsyncValue<List<Quest>>> {
  final GetAvailableQuests _getAvailableQuests;
  final AsyncValue characterAsync;

  AvailableQuestsNotifier({
    required GetAvailableQuests getAvailableQuests,
    required this.characterAsync,
  }) : _getAvailableQuests = getAvailableQuests,
       super(const AsyncValue.loading()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    state = const AsyncValue.loading();
    try {
      // Default to level 1 if character not loaded
      final playerLevel = characterAsync.value?.level ?? 1;
      final quests = await _getAvailableQuests(playerLevel);
      state = AsyncValue.data(quests);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for active quests
final activeQuestsProvider =
    StateNotifierProvider<ActiveQuestsNotifier, AsyncValue<List<Quest>>>((ref) {
      return ActiveQuestsNotifier(
        getActiveQuests: getIt<GetActiveQuests>(
          instanceName: InjectionNames.getActiveQuests,
        ),
      );
    });

class ActiveQuestsNotifier extends StateNotifier<AsyncValue<List<Quest>>> {
  final GetActiveQuests _getActiveQuests;

  ActiveQuestsNotifier({required GetActiveQuests getActiveQuests})
    : _getActiveQuests = getActiveQuests,
      super(const AsyncValue.loading()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    state = const AsyncValue.loading();
    try {
      final quests = await _getActiveQuests();
      state = AsyncValue.data(quests);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for quest actions (accept, update, complete)
final questActionsProvider = Provider<QuestActions>((ref) {
  return QuestActions(
    acceptQuest: getIt<AcceptQuest>(instanceName: InjectionNames.acceptQuest),
    updateQuestObjectives: getIt<UpdateQuestObjectives>(
      instanceName: InjectionNames.updateQuestObjectives,
    ),
    completeQuest: getIt<CompleteQuest>(
      instanceName: InjectionNames.completeQuest,
    ),
    availableQuestsNotifier: ref.watch(availableQuestsProvider.notifier),
    activeQuestsNotifier: ref.watch(activeQuestsProvider.notifier),
    characterNotifier: ref.watch(characterProvider.notifier),
  );
});

class QuestActions {
  final AcceptQuest _acceptQuest;
  final UpdateQuestObjectives _updateQuestObjectives;
  final CompleteQuest _completeQuest;
  final AvailableQuestsNotifier _availableQuestsNotifier;
  final ActiveQuestsNotifier _activeQuestsNotifier;
  final CharacterNotifier _characterNotifier;

  QuestActions({
    required AcceptQuest acceptQuest,
    required UpdateQuestObjectives updateQuestObjectives,
    required CompleteQuest completeQuest,
    required AvailableQuestsNotifier availableQuestsNotifier,
    required ActiveQuestsNotifier activeQuestsNotifier,
    required CharacterNotifier characterNotifier,
  }) : _acceptQuest = acceptQuest,
       _updateQuestObjectives = updateQuestObjectives,
       _completeQuest = completeQuest,
       _availableQuestsNotifier = availableQuestsNotifier,
       _activeQuestsNotifier = activeQuestsNotifier,
       _characterNotifier = characterNotifier;

  Future<Quest> acceptQuest(String questId) async {
    final quest = await _acceptQuest(questId);

    // Refresh quest lists
    await Future.wait([
      _availableQuestsNotifier.loadQuests(),
      _activeQuestsNotifier.loadQuests(),
    ]);

    return quest;
  }

  Future<Quest> updateQuestObjectives(
    String questId,
    List<int> completedObjectiveIndices,
  ) async {
    final quest = await _updateQuestObjectives(
      questId,
      completedObjectiveIndices,
    );

    // Refresh active quests
    await _activeQuestsNotifier.loadQuests();

    return quest;
  }

  Future<QuestCompletionResult> completeQuest(String questId) async {
    final result = await _completeQuest(questId);

    // Award XP to character (this handles level-ups automatically)
    await _characterNotifier.awardQuestXp(result.xpAwarded);

    // Refresh quest lists
    await Future.wait([
      _availableQuestsNotifier.loadQuests(),
      _activeQuestsNotifier.loadQuests(),
    ]);

    return result;
  }
}
