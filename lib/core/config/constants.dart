import 'dart:math';

class GameConstants {
  // Character creation
  static const int STARTING_STAT_POINTS = 10;
  static const int MIN_STAT_VALUE = 1;
  static const int MAX_STAT_VALUE = 20;
  static const int BASE_STAT_VALUE = 5;

  // Leveling
  static const int BASE_XP_FOR_LEVEL_2 = 100;
  static const double XP_SCALING_FACTOR = 1.5;
  static const int MAX_LEVEL = 50;

  // Fellowship
  static const int MAX_FELLOWSHIP_SIZE = 8;
  static const int MIN_RELATIONSHIP_LEVEL = -100;
  static const int MAX_RELATIONSHIP_LEVEL = 100;
  static const int RELATIONSHIP_GAIN_PER_INTERACTION = 5;

  // RAG settings
  static const int MAX_DIALOGUE_HISTORY = 10;
  static const int CLAUDE_MAX_TOKENS_DIALOGUE = 300;
  static const int CLAUDE_MAX_TOKENS_QUEST = 500;
  static const int CLAUDE_MAX_TOKENS_LORE = 400;
  static const double CLAUDE_TEMPERATURE_DIALOGUE = 0.8;
  static const double CLAUDE_TEMPERATURE_QUEST = 0.7;
  static const double CLAUDE_TEMPERATURE_LORE = 0.75;
  static const double CLAUDE_TEMPERATURE_COMMAND = 0.3;

  // Chat bot
  static const int CHAT_API_PORT = 8080;
  static const String CHAT_API_HOST = 'localhost';
  static const int LINK_CODE_LENGTH = 12;

  // UI
  static const int ANIMATION_DURATION_MS = 300;
  static const double CARD_ELEVATION = 4.0;
  static const double BORDER_WIDTH = 3.0;

  // Notifications
  static const int MAX_NOTIFICATIONS_PER_HOUR = 10;
  static const int NOTIFICATION_DISPLAY_DURATION_SECONDS = 5;

  // Database
  static const int MAX_DIALOGUE_HISTORY_DAYS = 30;
  static const int DATABASE_QUERY_TIMEOUT_MS = 5000;

  // Races and their stat bonuses
  static const Map<String, Map<String, int>> RACE_STAT_BONUSES = {
    'Hobbit': {'dexterity': 2, 'wisdom': 1},
    'Human': {'strength': 1, 'wisdom': 1, 'charisma': 1, 'constitution': 1},
    'Elf': {'wisdom': 2, 'dexterity': 1},
    'Dwarf': {'constitution': 2, 'strength': 1},
  };

  // Class base stats
  static const Map<String, Map<String, int>> CLASS_BASE_STATS = {
    'Warrior': {'strength': 8, 'constitution': 7, 'dexterity': 4, 'wisdom': 3},
    'Ranger': {'dexterity': 8, 'wisdom': 6, 'strength': 5, 'constitution': 3},
    'Wizard': {'wisdom': 9, 'constitution': 3, 'dexterity': 4, 'strength': 6},
    'Rogue': {'dexterity': 9, 'wisdom': 5, 'strength': 4, 'constitution': 4},
  };

  // Quest difficulty XP multipliers
  static const Map<String, double> QUEST_DIFFICULTY_XP_MULTIPLIERS = {
    'easy': 1.0,
    'medium': 1.5,
    'hard': 2.0,
  };

  // Item rarity colors
  static const Map<String, int> RARITY_COLORS = {
    'common': 0xFF9E9E9E, // Gray
    'uncommon': 0xFF4CAF50, // Green
    'rare': 0xFF2196F3, // Blue
    'epic': 0xFF9C27B0, // Purple
    'legendary': 0xFFFF9800, // Orange
  };
}

class GameBalanceConfig {
  /// Calculate XP required for the next level
  static int calculateXpForNextLevel(int currentLevel) {
    if (currentLevel >= GameConstants.MAX_LEVEL) {
      return 999999; // Max level reached
    }
    return (GameConstants.BASE_XP_FOR_LEVEL_2 *
            pow(GameConstants.XP_SCALING_FACTOR, currentLevel - 1))
        .toInt();
  }

  /// Calculate XP reward for a quest based on difficulty and player level
  static int calculateQuestXpReward(String difficulty, int playerLevel) {
    final baseReward =
        {'easy': 50, 'medium': 100, 'hard': 200}[difficulty] ?? 100;

    final multiplier =
        GameConstants.QUEST_DIFFICULTY_XP_MULTIPLIERS[difficulty] ?? 1.0;
    final levelBonus = 1 + (playerLevel * 0.1);

    return (baseReward * multiplier * levelBonus).toInt();
  }

  /// Calculate total stats for a character (base + race + equipment)
  static Map<String, int> calculateTotalStats({
    required String race,
    required String characterClass,
    required Map<String, int> baseStats,
    Map<String, int> equipmentModifiers = const {},
  }) {
    final totalStats = Map<String, int>.from(baseStats);

    // Add race bonuses
    final raceBonuses = GameConstants.RACE_STAT_BONUSES[race] ?? {};
    raceBonuses.forEach((stat, bonus) {
      totalStats[stat] = (totalStats[stat] ?? 0) + bonus;
    });

    // Add equipment modifiers
    equipmentModifiers.forEach((stat, modifier) {
      totalStats[stat] = (totalStats[stat] ?? 0) + modifier;
    });

    return totalStats;
  }

  /// Calculate relationship change based on interaction quality
  static int calculateRelationshipChange(String interactionType) {
    final changes = {
      'positive': GameConstants.RELATIONSHIP_GAIN_PER_INTERACTION,
      'neutral': 0,
      'negative': -GameConstants.RELATIONSHIP_GAIN_PER_INTERACTION,
      'quest_complete': GameConstants.RELATIONSHIP_GAIN_PER_INTERACTION * 2,
      'quest_fail': -GameConstants.RELATIONSHIP_GAIN_PER_INTERACTION,
    };

    return changes[interactionType] ?? 0;
  }

  /// Check if a character meets quest requirements
  static bool meetsQuestRequirements(int characterLevel, int requiredLevel) {
    return characterLevel >= requiredLevel;
  }
}
