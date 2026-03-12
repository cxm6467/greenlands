import '../../entities/character.dart';
import '../../repositories/character_repository.dart';

class CreateCharacter {
  final CharacterRepository _repository;

  CreateCharacter(this._repository);

  Future<Character> call({
    required String name,
    required CharacterRace race,
    required CharacterClass characterClass,
    required FellowshipRole fellowshipRole,
    required Map<String, int> allocatedStats,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      throw Exception('Character name cannot be empty');
    }

    if (name.length > 50) {
      throw Exception('Character name is too long (max 50 characters)');
    }

    // Validate stat allocation
    final totalPoints = allocatedStats.values.fold(0, (sum, val) => sum + val);
    if (totalPoints > 10) {
      throw Exception('Too many stat points allocated (max 10)');
    }

    // Validate stat values
    for (final entry in allocatedStats.entries) {
      if (entry.value < 0) {
        throw Exception('Cannot allocate negative stat points');
      }
    }

    return _repository.createCharacter(
      name: name,
      race: race,
      characterClass: characterClass,
      fellowshipRole: fellowshipRole,
      allocatedStats: allocatedStats,
    );
  }
}
