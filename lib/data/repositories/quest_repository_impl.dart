import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/quest_model.dart';

class QuestRepositoryImpl implements QuestRepository {
  final DatabaseHelper databaseHelper;
  final Logger logger;

  QuestRepositoryImpl({required this.databaseHelper, required this.logger});

  @override
  Future<List<Quest>> getAvailableQuests(int playerLevel) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quests',
        where: 'status = ? AND required_level <= ?',
        whereArgs: ['available', playerLevel],
        orderBy: 'quest_type, required_level',
      );

      return maps
          .map((map) => QuestModel.fromDatabase(map).toEntity())
          .toList();
    } catch (e) {
      logger.e('Error getting available quests: $e');
      rethrow;
    }
  }

  @override
  Future<List<Quest>> getActiveQuests() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quests',
        where: 'status = ?',
        whereArgs: ['active'],
        orderBy: 'accepted_at DESC',
      );

      return maps
          .map((map) => QuestModel.fromDatabase(map).toEntity())
          .toList();
    } catch (e) {
      logger.e('Error getting active quests: $e');
      rethrow;
    }
  }

  @override
  Future<List<Quest>> getCompletedQuests() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quests',
        where: 'status = ?',
        whereArgs: ['completed'],
        orderBy: 'completed_at DESC',
      );

      return maps
          .map((map) => QuestModel.fromDatabase(map).toEntity())
          .toList();
    } catch (e) {
      logger.e('Error getting completed quests: $e');
      rethrow;
    }
  }

  @override
  Future<Quest?> getQuestById(String questId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quests',
        where: 'id = ?',
        whereArgs: [questId],
        limit: 1,
      );

      if (maps.isEmpty) return null;

      return QuestModel.fromDatabase(maps.first).toEntity();
    } catch (e) {
      logger.e('Error getting quest by ID: $e');
      rethrow;
    }
  }

  @override
  Future<Quest> acceptQuest(String questId) async {
    try {
      final quest = await getQuestById(questId);
      if (quest == null) {
        throw Exception('Quest not found: $questId');
      }

      if (quest.status != QuestStatus.available) {
        throw Exception('Quest is not available to accept');
      }

      // Check prerequisites
      final prereqsMet = await checkPrerequisites(questId);
      if (!prereqsMet) {
        throw Exception('Prerequisites not met for quest: $questId');
      }

      final updatedQuest = quest.copyWith(
        status: QuestStatus.active,
        acceptedAt: DateTime.now(),
      );

      final db = await databaseHelper.database;
      final model = QuestModel.fromEntity(updatedQuest);
      await db.update(
        'quests',
        model.toDatabase(),
        where: 'id = ?',
        whereArgs: [questId],
      );

      logger.i('Quest accepted: $questId');
      return updatedQuest;
    } catch (e) {
      logger.e('Error accepting quest: $e');
      rethrow;
    }
  }

  @override
  Future<Quest> updateQuestObjectives(
    String questId,
    List<int> completedObjectiveIndices,
  ) async {
    try {
      final quest = await getQuestById(questId);
      if (quest == null) {
        throw Exception('Quest not found: $questId');
      }

      if (quest.status != QuestStatus.active) {
        throw Exception('Quest is not active');
      }

      // Update objectives
      final updatedObjectives = List<QuestObjective>.from(quest.objectives);
      for (var index in completedObjectiveIndices) {
        if (index >= 0 && index < updatedObjectives.length) {
          updatedObjectives[index] = updatedObjectives[index].copyWith(
            completed: true,
          );
        }
      }

      final updatedQuest = quest.copyWith(objectives: updatedObjectives);

      final db = await databaseHelper.database;
      final model = QuestModel.fromEntity(updatedQuest);
      await db.update(
        'quests',
        model.toDatabase(),
        where: 'id = ?',
        whereArgs: [questId],
      );

      logger.i('Quest objectives updated: $questId');
      return updatedQuest;
    } catch (e) {
      logger.e('Error updating quest objectives: $e');
      rethrow;
    }
  }

  @override
  Future<Quest> completeQuest(String questId) async {
    try {
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

      final db = await databaseHelper.database;
      final model = QuestModel.fromEntity(updatedQuest);
      await db.update(
        'quests',
        model.toDatabase(),
        where: 'id = ?',
        whereArgs: [questId],
      );

      logger.i('Quest completed: $questId (XP: ${quest.xpReward})');
      return updatedQuest;
    } catch (e) {
      logger.e('Error completing quest: $e');
      rethrow;
    }
  }

  @override
  Future<Quest> failQuest(String questId) async {
    try {
      final quest = await getQuestById(questId);
      if (quest == null) {
        throw Exception('Quest not found: $questId');
      }

      if (quest.status != QuestStatus.active) {
        throw Exception('Quest is not active');
      }

      final updatedQuest = quest.copyWith(status: QuestStatus.failed);

      final db = await databaseHelper.database;
      final model = QuestModel.fromEntity(updatedQuest);
      await db.update(
        'quests',
        model.toDatabase(),
        where: 'id = ?',
        whereArgs: [questId],
      );

      logger.i('Quest failed: $questId');
      return updatedQuest;
    } catch (e) {
      logger.e('Error failing quest: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkPrerequisites(String questId) async {
    try {
      final quest = await getQuestById(questId);
      if (quest == null) return false;

      if (quest.prerequisites.isEmpty) return true;

      for (final prereqId in quest.prerequisites) {
        final prereqQuest = await getQuestById(prereqId);
        if (prereqQuest == null ||
            prereqQuest.status != QuestStatus.completed) {
          return false;
        }
      }

      return true;
    } catch (e) {
      logger.e('Error checking prerequisites: $e');
      return false;
    }
  }

  @override
  Future<void> initializeQuestsFromSeed() async {
    try {
      final db = await databaseHelper.database;

      // Check if quests are already initialized
      final existingQuests = await db.query('quests', limit: 1);
      if (existingQuests.isNotEmpty) {
        logger.i('Quests already initialized, skipping seed');
        return;
      }

      // Load seed data
      final String jsonString = await rootBundle.loadString(
        'assets/data/seed/quests.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> questsJson = jsonData['quests'];

      // Insert quests
      final batch = db.batch();
      for (var questJson in questsJson) {
        final model = QuestModel.fromJson(questJson as Map<String, dynamic>);

        // Set created_at timestamp if not present
        final questData = model.toDatabase();
        if (questData['created_at'] == null ||
            (questData['created_at'] as String).isEmpty) {
          questData['created_at'] = DateTime.now().toIso8601String();
        }

        batch.insert('quests', questData);
      }

      await batch.commit(noResult: true);
      logger.i(
        'Successfully initialized ${questsJson.length} quests from seed',
      );
    } catch (e) {
      logger.e('Error initializing quests from seed: $e');
      rethrow;
    }
  }

  @override
  Future<List<Quest>> getAllQuests() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query('quests', orderBy: 'created_at DESC');
      return maps
          .map((map) => QuestModel.fromDatabase(map).toEntity())
          .toList();
    } catch (e) {
      logger.e('Error getting all quests: $e');
      rethrow;
    }
  }

  @override
  Future<Quest> createQuest(Quest quest) async {
    try {
      final db = await databaseHelper.database;
      final model = QuestModel.fromEntity(quest);
      final questData = model.toDatabase();

      // Ensure created_at timestamp is set
      if (questData['created_at'] == null ||
          (questData['created_at'] as String).isEmpty) {
        questData['created_at'] = DateTime.now().toIso8601String();
      }

      await db.insert('quests', questData);
      logger.i('Created new quest: ${quest.title}');

      return quest;
    } catch (e) {
      logger.e('Error creating quest: $e');
      rethrow;
    }
  }
}
