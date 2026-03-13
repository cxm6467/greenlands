import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../../domain/entities/quest.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../../models/quest_model.dart';

/// In-memory quest repository for web builds (where SQLite doesn't work)
class QuestRepositoryWeb implements QuestRepository {
  final Logger logger;
  final List<Quest> _quests = [];
  bool _initialized = false;

  QuestRepositoryWeb({Logger? logger}) : logger = logger ?? Logger();

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initializeQuestsFromSeed();
      _initialized = true;
    }
  }

  @override
  Future<List<Quest>> getAvailableQuests(int playerLevel) async {
    await _ensureInitialized();
    return _quests
        .where(
          (q) =>
              q.status == QuestStatus.available &&
              q.requiredLevel <= playerLevel,
        )
        .toList()
      ..sort((a, b) {
        final typeCompare = a.questType.index.compareTo(b.questType.index);
        if (typeCompare != 0) return typeCompare;
        return a.requiredLevel.compareTo(b.requiredLevel);
      });
  }

  @override
  Future<List<Quest>> getActiveQuests() async {
    await _ensureInitialized();
    return _quests.where((q) => q.status == QuestStatus.active).toList()
      ..sort((a, b) {
        if (a.acceptedAt == null || b.acceptedAt == null) return 0;
        return b.acceptedAt!.compareTo(a.acceptedAt!);
      });
  }

  @override
  Future<List<Quest>> getCompletedQuests() async {
    await _ensureInitialized();
    return _quests.where((q) => q.status == QuestStatus.completed).toList()
      ..sort((a, b) {
        if (a.completedAt == null || b.completedAt == null) return 0;
        return b.completedAt!.compareTo(a.completedAt!);
      });
  }

  @override
  Future<Quest?> getQuestById(String questId) async {
    await _ensureInitialized();
    try {
      return _quests.firstWhere((q) => q.id == questId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Quest> acceptQuest(String questId) async {
    await _ensureInitialized();

    final quest = await getQuestById(questId);
    if (quest == null) {
      throw Exception('Quest not found: $questId');
    }

    if (quest.status != QuestStatus.available) {
      throw Exception('Quest is not available to accept');
    }

    final prereqsMet = await checkPrerequisites(questId);
    if (!prereqsMet) {
      throw Exception('Prerequisites not met for quest: $questId');
    }

    final updatedQuest = quest.copyWith(
      status: QuestStatus.active,
      acceptedAt: DateTime.now(),
    );

    _quests.removeWhere((q) => q.id == questId);
    _quests.add(updatedQuest);

    logger.i('Quest accepted (web): $questId');
    return updatedQuest;
  }

  @override
  Future<Quest> updateQuestObjectives(
    String questId,
    List<int> completedObjectiveIndices,
  ) async {
    await _ensureInitialized();

    final quest = await getQuestById(questId);
    if (quest == null) {
      throw Exception('Quest not found: $questId');
    }

    if (quest.status != QuestStatus.active) {
      throw Exception('Quest is not active');
    }

    final updatedObjectives = List<QuestObjective>.from(quest.objectives);
    for (var index in completedObjectiveIndices) {
      if (index >= 0 && index < updatedObjectives.length) {
        updatedObjectives[index] = updatedObjectives[index].copyWith(
          completed: true,
        );
      }
    }

    final updatedQuest = quest.copyWith(objectives: updatedObjectives);

    _quests.removeWhere((q) => q.id == questId);
    _quests.add(updatedQuest);

    logger.i('Quest objectives updated (web): $questId');
    return updatedQuest;
  }

  @override
  Future<Quest> completeQuest(String questId) async {
    await _ensureInitialized();

    final quest = await getQuestById(questId);
    if (quest == null) {
      throw Exception('Quest not found: $questId');
    }

    if (quest.status != QuestStatus.active) {
      throw Exception('Quest is not active');
    }

    if (!quest.areAllObjectivesCompleted) {
      throw Exception('Not all objectives are completed');
    }

    final updatedQuest = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
    );

    _quests.removeWhere((q) => q.id == questId);
    _quests.add(updatedQuest);

    logger.i('Quest completed (web): $questId (XP: ${quest.xpReward})');
    return updatedQuest;
  }

  @override
  Future<Quest> failQuest(String questId) async {
    await _ensureInitialized();

    final quest = await getQuestById(questId);
    if (quest == null) {
      throw Exception('Quest not found: $questId');
    }

    if (quest.status != QuestStatus.active) {
      throw Exception('Quest is not active');
    }

    final updatedQuest = quest.copyWith(status: QuestStatus.failed);

    _quests.removeWhere((q) => q.id == questId);
    _quests.add(updatedQuest);

    logger.i('Quest failed (web): $questId');
    return updatedQuest;
  }

  @override
  Future<bool> checkPrerequisites(String questId) async {
    await _ensureInitialized();

    final quest = await getQuestById(questId);
    if (quest == null) return false;

    if (quest.prerequisites.isEmpty) return true;

    for (final prereqId in quest.prerequisites) {
      final prereqQuest = await getQuestById(prereqId);
      if (prereqQuest == null || prereqQuest.status != QuestStatus.completed) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> initializeQuestsFromSeed() async {
    try {
      if (_quests.isNotEmpty) {
        logger.i('Quests already initialized (web), skipping seed');
        return;
      }

      final String jsonString = await rootBundle.loadString(
        'assets/data/seed/quests.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> questsJson = jsonData['quests'];

      for (var questJson in questsJson) {
        final model = QuestModel.fromJson(questJson as Map<String, dynamic>);

        // Set created_at if not present
        var quest = model.toEntity();
        if (model.createdAt.isEmpty) {
          quest = quest.copyWith(createdAt: DateTime.now());
        }

        _quests.add(quest);
      }

      logger.i(
        'Successfully initialized ${_quests.length} quests from seed (web)',
      );
      _initialized = true;
    } catch (e) {
      logger.e('Error initializing quests from seed (web): $e');
      rethrow;
    }
  }
}
