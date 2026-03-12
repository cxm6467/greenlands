import '../entities/character.dart';

abstract class CharacterRepository {
  /// Get the current player character
  Future<Character?> getPlayerCharacter();

  /// Create a new player character
  Future<Character> createCharacter({
    required String name,
    required CharacterRace race,
    required CharacterClass characterClass,
    required FellowshipRole fellowshipRole,
    required Map<String, int> allocatedStats,
  });

  /// Update an existing character
  Future<Character> updateCharacter(Character character);

  /// Delete a character
  Future<void> deleteCharacter(String characterId);

  /// Add XP to a character and handle level ups
  Future<Character> addXp(String characterId, int xp);

  /// Allocate stat points
  Future<Character> allocateStatPoints(
    String characterId,
    Map<String, int> statAllocations,
  );

  /// Check if a player character exists
  Future<bool> hasPlayerCharacter();
}
