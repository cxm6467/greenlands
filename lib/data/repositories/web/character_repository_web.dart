import '../../../core/config/constants.dart';
import '../../../domain/entities/character.dart';
import '../../../domain/repositories/character_repository.dart';

/// Web-compatible character repository using in-memory storage
/// This is a simple implementation for web builds where SQLite isn't available
class CharacterRepositoryWeb implements CharacterRepository {
  Character? _character;

  @override
  Future<Character?> getPlayerCharacter() async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));
    return _character;
  }

  @override
  Future<bool> hasPlayerCharacter() async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));
    return _character != null;
  }

  @override
  Future<Character> createCharacter({
    required String name,
    required CharacterRace race,
    required CharacterClass characterClass,
    required FellowshipRole fellowshipRole,
    required Map<String, int> allocatedStats,
  }) async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));

    // Get race and class bonuses
    final raceBonuses = GameConstants.RACE_STAT_BONUSES[race.displayName] ?? {};
    final classBaseBonuses = GameConstants.CLASS_BASE_STATS[characterClass.displayName] ?? {};

    // Calculate base stats (allocated + race bonuses)
    final baseStats = <String, int>{};
    for (final stat in ['strength', 'agility', 'constitution', 'wisdom']) {
      baseStats[stat] = (allocatedStats[stat] ?? GameConstants.BASE_STAT_VALUE) + (raceBonuses[stat] ?? 0);
    }

    // Calculate total stats (base + class bonuses)
    final totalStats = <String, int>{};
    for (final stat in baseStats.keys) {
      totalStats[stat] = (baseStats[stat]! + (classBaseBonuses[stat] ?? 0));
    }

    _character = Character(
      id: 'web_char_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      race: race,
      characterClass: characterClass,
      fellowshipRole: fellowshipRole,
      level: 1,
      currentXp: 0,
      xpToNextLevel: GameConstants.BASE_XP_FOR_LEVEL_2,
      baseStats: baseStats,
      totalStats: totalStats,
      availableStatPoints: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _character!;
  }

  @override
  Future<Character> updateCharacter(Character character) async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));

    _character = character.copyWith(updatedAt: DateTime.now());
    return _character!;
  }

  @override
  Future<void> deleteCharacter(String characterId) async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));

    if (_character?.id == characterId) {
      _character = null;
    }
  }

  @override
  Future<Character> addXp(String characterId, int xp) async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));

    if (_character?.id != characterId) {
      throw Exception('Character not found');
    }

    var newXp = _character!.currentXp + xp;
    var newLevel = _character!.level;
    var newXpToNextLevel = _character!.xpToNextLevel;
    var newAvailableStatPoints = _character!.availableStatPoints;

    // Handle level ups
    while (newXp >= newXpToNextLevel && newLevel < GameConstants.MAX_LEVEL) {
      newXp -= newXpToNextLevel;
      newLevel++;
      newAvailableStatPoints += 3; // 3 stat points per level
      newXpToNextLevel = _calculateXpForLevel(newLevel + 1);
    }

    _character = _character!.copyWith(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newXpToNextLevel,
      availableStatPoints: newAvailableStatPoints,
      updatedAt: DateTime.now(),
    );

    return _character!;
  }

  @override
  Future<Character> allocateStatPoints(
    String characterId,
    Map<String, int> statAllocations,
  ) async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 100));

    if (_character?.id != characterId) {
      throw Exception('Character not found');
    }

    // Calculate total points being allocated
    final totalPointsAllocated = statAllocations.values.fold(0, (sum, val) => sum + val);

    if (totalPointsAllocated > _character!.availableStatPoints) {
      throw Exception('Not enough available stat points');
    }

    // Update base stats
    final newBaseStats = Map<String, int>.from(_character!.baseStats);
    statAllocations.forEach((stat, points) {
      newBaseStats[stat] = (newBaseStats[stat] ?? 0) + points;
    });

    // Recalculate total stats
    final classBaseBonuses = GameConstants.CLASS_BASE_STATS[_character!.characterClass.displayName] ?? {};
    final newTotalStats = <String, int>{};
    for (final stat in newBaseStats.keys) {
      newTotalStats[stat] = (newBaseStats[stat]! + (classBaseBonuses[stat] ?? 0));
    }

    _character = _character!.copyWith(
      baseStats: newBaseStats,
      totalStats: newTotalStats,
      availableStatPoints: _character!.availableStatPoints - totalPointsAllocated,
      updatedAt: DateTime.now(),
    );

    return _character!;
  }

  int _calculateXpForLevel(int level) {
    return (GameConstants.BASE_XP_FOR_LEVEL_2 * (level - 1) * GameConstants.XP_SCALING_FACTOR).round();
  }
}
