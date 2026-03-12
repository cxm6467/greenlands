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
