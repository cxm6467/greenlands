import 'package:uuid/uuid.dart';
import '../../core/config/constants.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/character_model.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  CharacterRepositoryImpl({
    required DatabaseHelper databaseHelper,
    Uuid? uuid,
  })  : _databaseHelper = databaseHelper,
        _uuid = uuid ?? const Uuid();

  @override
  Future<Character?> getPlayerCharacter() async {
    final db = await _databaseHelper.database;
    final results = await db.query('characters', limit: 1);

    if (results.isEmpty) return null;

    return CharacterModel.fromDatabase(results.first).toEntity();
  }

  @override
  Future<Character> createCharacter({
    required String name,
    required CharacterRace race,
    required CharacterClass characterClass,
    required FellowshipRole fellowshipRole,
    required Map<String, int> allocatedStats,
  }) async {
    final now = DateTime.now();
    final characterId = _uuid.v4();

    // Calculate base stats from class
    final classBaseStats = GameConstants.CLASS_BASE_STATS[characterClass.displayName] ?? {};

    // Add allocated points
    final baseStats = Map<String, int>.from(classBaseStats);
    allocatedStats.forEach((stat, points) {
      baseStats[stat] = (baseStats[stat] ?? 0) + points;
    });

    // Calculate total stats (includes race bonuses)
    final totalStats = GameBalanceConfig.calculateTotalStats(
      race: race.displayName,
      characterClass: characterClass.displayName,
      baseStats: baseStats,
    );

    // Calculate XP for level 2
    final xpToNextLevel = GameBalanceConfig.calculateXpForNextLevel(1);

    final character = Character(
      id: characterId,
      name: name,
      race: race,
      characterClass: characterClass,
      fellowshipRole: fellowshipRole,
      level: 1,
      currentXp: 0,
      xpToNextLevel: xpToNextLevel,
      baseStats: baseStats,
      totalStats: totalStats,
      availableStatPoints: 0,
      createdAt: now,
      updatedAt: now,
    );

    final model = CharacterModel.fromEntity(character);
    final db = await _databaseHelper.database;

    await db.insert('characters', model.toDatabase());

    return character;
  }

  @override
  Future<Character> updateCharacter(Character character) async {
    final updatedCharacter = character.copyWith(updatedAt: DateTime.now());
    final model = CharacterModel.fromEntity(updatedCharacter);
    final db = await _databaseHelper.database;

    await db.update(
      'characters',
      model.toDatabase(),
      where: 'id = ?',
      whereArgs: [character.id],
    );

    return updatedCharacter;
  }

  @override
  Future<void> deleteCharacter(String characterId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'characters',
      where: 'id = ?',
      whereArgs: [characterId],
    );
  }

  @override
  Future<Character> addXp(String characterId, int xp) async {
    final character = await getPlayerCharacter();
    if (character == null || character.id != characterId) {
      throw Exception('Character not found');
    }

    int newXp = character.currentXp + xp;
    int newLevel = character.level;
    int statPointsGained = 0;

    // Check for level ups
    while (newXp >= character.xpToNextLevel && newLevel < GameConstants.MAX_LEVEL) {
      newXp -= character.xpToNextLevel;
      newLevel++;
      statPointsGained += 3; // Gain 3 stat points per level
    }

    final xpToNextLevel = GameBalanceConfig.calculateXpForNextLevel(newLevel);

    final updatedCharacter = character.copyWith(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: xpToNextLevel,
      availableStatPoints: character.availableStatPoints + statPointsGained,
    );

    return updateCharacter(updatedCharacter);
  }

  @override
  Future<Character> allocateStatPoints(
    String characterId,
    Map<String, int> statAllocations,
  ) async {
    final character = await getPlayerCharacter();
    if (character == null || character.id != characterId) {
      throw Exception('Character not found');
    }

    // Calculate total points to allocate
    final totalPoints = statAllocations.values.fold(0, (sum, val) => sum + val);

    if (totalPoints > character.availableStatPoints) {
      throw Exception('Not enough stat points available');
    }

    // Update base stats
    final newBaseStats = Map<String, int>.from(character.baseStats);
    statAllocations.forEach((stat, points) {
      newBaseStats[stat] = (newBaseStats[stat] ?? 0) + points;
    });

    // Recalculate total stats
    final newTotalStats = GameBalanceConfig.calculateTotalStats(
      race: character.race.displayName,
      characterClass: character.characterClass.displayName,
      baseStats: newBaseStats,
    );

    final updatedCharacter = character.copyWith(
      baseStats: newBaseStats,
      totalStats: newTotalStats,
      availableStatPoints: character.availableStatPoints - totalPoints,
    );

    return updateCharacter(updatedCharacter);
  }

  @override
  Future<bool> hasPlayerCharacter() async {
    final character = await getPlayerCharacter();
    return character != null;
  }
}
