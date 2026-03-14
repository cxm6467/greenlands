import '../entities/quest.dart';

abstract class QuestRepository {
  /// Get all available quests for the player's current level
  Future<List<Quest>> getAvailableQuests(int playerLevel);

  /// Get all active quests
  Future<List<Quest>> getActiveQuests();

  /// Get all completed quests
  Future<List<Quest>> getCompletedQuests();

  /// Get a quest by ID
  Future<Quest?> getQuestById(String questId);

  /// Accept a quest (change status to active)
  Future<Quest> acceptQuest(String questId);

  /// Update quest objectives
  Future<Quest> updateQuestObjectives(
    String questId,
    List<int> completedObjectiveIndices,
  );

  /// Complete a quest
  Future<Quest> completeQuest(String questId);

  /// Fail a quest
  Future<Quest> failQuest(String questId);

  /// Check if prerequisites are met for a quest
  Future<bool> checkPrerequisites(String questId);

  /// Initialize quests from seed data (first launch)
  Future<void> initializeQuestsFromSeed();

  /// Get all quests (for quest generation context)
  Future<List<Quest>> getAllQuests();

  /// Create a new quest (for AI-generated quests)
  Future<Quest> createQuest(Quest quest);
}
