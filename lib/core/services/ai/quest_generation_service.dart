import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:greenlands/domain/entities/quest.dart';
import 'package:greenlands/domain/entities/character.dart';

class QuestGenerationService {
  final Dio _dio;
  final Logger _logger;
  final String _apiKey;
  final String _model;

  QuestGenerationService({
    required Dio dio,
    required Logger logger,
    required String apiKey,
    required String model,
  })  : _dio = dio,
        _logger = logger,
        _apiKey = apiKey,
        _model = model;

  /// Generate a quest based on player context
  Future<Quest> generateQuest({
    required int playerLevel,
    required String characterName,
    required CharacterRace race,
    required CharacterClass characterClass,
    List<Quest>? completedQuests,
  }) async {
    final prompt = _buildPrompt(
      playerLevel: playerLevel,
      characterName: characterName,
      race: race,
      characterClass: characterClass,
      completedQuests: completedQuests,
    );

    try {
      _logger.i('Generating quest for $characterName (Level $playerLevel)...');

      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        },
      );

      final content = response.data['content'][0]['text'] as String;
      _logger.d('Claude response: $content');

      // Extract JSON from potential markdown code blocks
      final jsonString = _extractJson(content);
      final questJson = jsonDecode(jsonString);

      final quest = _questFromJson(questJson, playerLevel);
      _logger.i('Quest generated successfully: ${quest.title}');

      return quest;
    } on DioException catch (e) {
      _logger.e('API error generating quest: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error generating quest: $e');
      rethrow;
    }
  }

  String _buildPrompt({
    required int playerLevel,
    required String characterName,
    required CharacterRace race,
    required CharacterClass characterClass,
    List<Quest>? completedQuests,
  }) {
    final completedTitles = completedQuests
            ?.where((q) => q.isGenerated)
            .take(5)
            .map((q) => q.title)
            .join(', ') ??
        'None';

    return '''
You are a quest master for The Greenlands RPG, a fantasy adventure inspired by The Lord of the Rings.

Generate a quest for:
- Character: $characterName, Level $playerLevel ${race.displayName} ${characterClass.displayName}
- Previously completed AI quests: $completedTitles

Quest requirements:
1. Appropriate difficulty for level $playerLevel (harder quests for higher levels)
2. 2-4 objectives that fit the character class and race
3. XP reward: ${_calculateXpReward(playerLevel)}
4. Fits Middle-earth style (Greenlands = Shire, Old Woods = Mirkwood, Iron Peak = Lonely Mountain)
5. Quest should be engaging and thematically appropriate
6. Avoid repeating themes from previously completed quests

Return ONLY valid JSON in this exact format (no markdown, no extra text):
{
  "title": "Quest Title",
  "description": "Quest description (2-3 sentences)",
  "difficulty": "easy|medium|hard",
  "xp_reward": ${_calculateXpReward(playerLevel)},
  "objectives": [
    {"text": "Objective 1", "completed": false},
    {"text": "Objective 2", "completed": false}
  ],
  "generation_context": "Brief note about quest theme"
}
''';
  }

  /// Extract JSON from response, handling markdown code blocks
  String _extractJson(String content) {
    // Remove markdown code blocks if present
    final jsonMatch = RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```').firstMatch(content);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!;
    }

    // Try to find raw JSON
    final rawJsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    if (rawJsonMatch != null) {
      return rawJsonMatch.group(0)!;
    }

    // Return as-is and let json decode fail
    return content;
  }

  Quest _questFromJson(Map<String, dynamic> json, int playerLevel) {
    // Determine quest type based on difficulty and objectives
    final difficulty = _parseDifficulty(json['difficulty']);
    final questType = _determineQuestType(difficulty, playerLevel);

    return Quest(
      id: 'generated_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'],
      description: json['description'],
      questType: questType,
      difficulty: difficulty,
      status: QuestStatus.available,
      xpReward: json['xp_reward'],
      objectives: (json['objectives'] as List)
          .map((o) => QuestObjective(
                text: o['text'],
                completed: o['completed'],
              ))
          .toList(),
      requiredLevel: max(1, playerLevel - 2), // Allow some flex
      prerequisites: [],
      isGenerated: true,
      generationContext: json['generation_context'],
      createdAt: DateTime.now(),
    );
  }

  QuestDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty is String) {
      return QuestDifficulty.values.firstWhere(
        (d) => d.name.toLowerCase() == difficulty.toLowerCase(),
        orElse: () => QuestDifficulty.medium,
      );
    }
    return QuestDifficulty.medium;
  }

  QuestType _determineQuestType(QuestDifficulty difficulty, int playerLevel) {
    // Generated quests are either main or side based on difficulty
    if (difficulty == QuestDifficulty.hard && playerLevel >= 5) {
      return QuestType.main;
    }
    return QuestType.side;
  }

  int _calculateXpReward(int playerLevel) {
    // Base XP scales with level: 100 + (level * 50)
    // Range: 50-100 XP above base
    final baseXp = 100 + (playerLevel * 50);
    return baseXp + Random().nextInt(51) + 50; // +50 to +100
  }
}
