enum AchievementCategory { quests, games, exploration, social }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int? progressCurrent;
  final int? progressMax;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.isUnlocked,
    this.unlockedAt,
    this.progressCurrent,
    this.progressMax,
  });

  double get progressPercent {
    if (progressMax == null || progressMax == 0) return 0;
    return ((progressCurrent ?? 0) / progressMax!).clamp(0.0, 1.0);
  }

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progressCurrent,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      category: category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressMax: progressMax,
    );
  }
}

extension AchievementCategoryExt on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.quests:
        return 'Quests';
      case AchievementCategory.games:
        return 'Games';
      case AchievementCategory.exploration:
        return 'Exploration';
      case AchievementCategory.social:
        return 'Social';
    }
  }
}

/// Stub achievements database
List<Achievement> createStubAchievements() {
  return [
    // Quests
    Achievement(
      id: 'first_quest',
      title: 'First Step',
      description: 'Complete your first quest',
      emoji: '⚔️',
      category: AchievementCategory.quests,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    Achievement(
      id: 'quest_master',
      title: 'Quest Master',
      description: 'Complete 10 quests',
      emoji: '👑',
      category: AchievementCategory.quests,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 10,
    ),
    Achievement(
      id: 'difficulty_spike',
      title: 'Difficulty Spike',
      description: 'Complete a hard difficulty quest',
      emoji: '🔥',
      category: AchievementCategory.quests,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    // Games
    Achievement(
      id: 'gamer',
      title: 'Gamer',
      description: 'Win your first mini-game',
      emoji: '🎮',
      category: AchievementCategory.games,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    Achievement(
      id: 'arcade_master',
      title: 'Arcade Master',
      description: 'Win 20 mini-games',
      emoji: '🕹️',
      category: AchievementCategory.games,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 20,
    ),
    Achievement(
      id: 'gem_collector',
      title: 'Gem Collector',
      description: 'Earn 100 gems from mini-games',
      emoji: '💎',
      category: AchievementCategory.games,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 100,
    ),
    // Exploration
    Achievement(
      id: 'level_5',
      title: 'Rising Hero',
      description: 'Reach level 5',
      emoji: '📈',
      category: AchievementCategory.exploration,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    Achievement(
      id: 'level_10',
      title: 'Legendary Adventurer',
      description: 'Reach level 10',
      emoji: '🗻',
      category: AchievementCategory.exploration,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    Achievement(
      id: 'xp_farmer',
      title: 'XP Farmer',
      description: 'Earn 1000 total XP',
      emoji: '🌾',
      category: AchievementCategory.exploration,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1000,
    ),
    // Social
    Achievement(
      id: 'character_created',
      title: 'Identity',
      description: 'Create your first character',
      emoji: '👤',
      category: AchievementCategory.social,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    Achievement(
      id: 'stats_balanced',
      title: 'Balanced Fighter',
      description: 'Allocate stat points to reach 15+ in three stats',
      emoji: '⚖️',
      category: AchievementCategory.social,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
    Achievement(
      id: 'shop_visit',
      title: 'Window Shopper',
      description: 'Visit the cosmetic shop',
      emoji: '🛍️',
      category: AchievementCategory.social,
      isUnlocked: false,
      progressCurrent: 0,
      progressMax: 1,
    ),
  ];
}
