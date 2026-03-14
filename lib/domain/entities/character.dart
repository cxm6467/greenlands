class Character {
  final String id;
  final String name;
  final CharacterRace race;
  final CharacterClass characterClass;
  final FellowshipRole fellowshipRole;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final Map<String, int> baseStats;
  final Map<String, int> totalStats;
  final int availableStatPoints;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.fellowshipRole,
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.baseStats,
    required this.totalStats,
    required this.availableStatPoints,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Character copyWith({
    String? id,
    String? name,
    CharacterRace? race,
    CharacterClass? characterClass,
    FellowshipRole? fellowshipRole,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    Map<String, int>? baseStats,
    Map<String, int>? totalStats,
    int? availableStatPoints,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      fellowshipRole: fellowshipRole ?? this.fellowshipRole,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      baseStats: baseStats ?? this.baseStats,
      totalStats: totalStats ?? this.totalStats,
      availableStatPoints: availableStatPoints ?? this.availableStatPoints,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get combined racial and class bonuses
  Map<String, int> get racialBonuses => race.statBonuses;
  Map<String, int> get classBonuses => characterClass.statBonuses;

  /// Get all stat bonuses combined (racial + class)
  Map<String, int> get allBonuses {
    final combined = <String, int>{};

    // Add racial bonuses
    racialBonuses.forEach((stat, bonus) {
      combined[stat] = (combined[stat] ?? 0) + bonus;
    });

    // Add class bonuses
    classBonuses.forEach((stat, bonus) {
      combined[stat] = (combined[stat] ?? 0) + bonus;
    });

    return combined;
  }

  /// Get formatted text showing all bonuses
  String get allBonusesText {
    if (allBonuses.isEmpty) return 'No bonuses';
    return allBonuses.entries
        .map((e) => '+${e.value} ${e.key.capitalize()}')
        .join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Character && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum CharacterRace {
  hobbit('Hobbit', '🧙‍♂️', 'Small but brave folk with quick reflexes'),
  human('Human', '👤', 'Versatile and adaptable warriors'),
  elf('Elf', '🧝', 'Ancient and wise, graceful in battle'),
  dwarf('Dwarf', '⚔️', 'Sturdy and strong, masters of craft');

  final String displayName;
  final String emoji;
  final String description;

  const CharacterRace(this.displayName, this.emoji, this.description);

  /// Get racial stat bonuses
  Map<String, int> get statBonuses {
    switch (this) {
      case CharacterRace.hobbit:
        return {'dexterity': 2, 'wisdom': 1}; // Nimble and perceptive
      case CharacterRace.human:
        return {
          'strength': 1,
          'constitution': 1,
          'charisma': 1,
        }; // Well-rounded
      case CharacterRace.elf:
        return {'dexterity': 2, 'intelligence': 1}; // Graceful and learned
      case CharacterRace.dwarf:
        return {'strength': 1, 'constitution': 2}; // Strong and hardy
    }
  }

  /// Get formatted bonus display text
  String get bonusText {
    final bonuses = statBonuses.entries
        .map((e) => '+${e.value} ${e.key.capitalize()}')
        .join(', ');
    return bonuses;
  }
}

enum CharacterClass {
  warrior('Warrior', '⚔️', 'Master of melee combat with high strength'),
  ranger('Ranger', '🏹', 'Skilled archer and tracker with keen senses'),
  wizard('Wizard', '🔮', 'Powerful magic user with vast wisdom'),
  rogue('Rogue', '🗡️', 'Swift and cunning, master of stealth');

  final String displayName;
  final String emoji;
  final String description;

  const CharacterClass(this.displayName, this.emoji, this.description);

  /// Get class stat bonuses
  Map<String, int> get statBonuses {
    switch (this) {
      case CharacterClass.warrior:
        return {'strength': 2, 'constitution': 1}; // Powerful and tough
      case CharacterClass.ranger:
        return {'dexterity': 2, 'wisdom': 1}; // Agile and perceptive
      case CharacterClass.wizard:
        return {'intelligence': 2, 'wisdom': 1}; // Brilliant and wise
      case CharacterClass.rogue:
        return {'dexterity': 2, 'charisma': 1}; // Quick and charming
    }
  }

  /// Get formatted bonus display text
  String get bonusText {
    final bonuses = statBonuses.entries
        .map((e) => '+${e.value} ${e.key.capitalize()}')
        .join(', ');
    return bonuses;
  }
}

enum FellowshipRole {
  leader('Leader', '👑', 'Guides and inspires the fellowship'),
  scout('Scout', '🔍', 'Explores ahead and finds the safest paths'),
  healer('Healer', '💚', 'Tends to wounds and ailments'),
  loremaster('Loremaster', '📜', 'Keeper of ancient knowledge and wisdom');

  final String displayName;
  final String emoji;
  final String description;

  const FellowshipRole(this.displayName, this.emoji, this.description);
}

/// String extension for capitalizing text
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
