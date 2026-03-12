import '../../entities/character.dart';
import '../../repositories/character_repository.dart';

class AllocateStatPoints {
  final CharacterRepository _repository;

  AllocateStatPoints(this._repository);

  Future<Character> call(
    String characterId,
    Map<String, int> statAllocations,
  ) async {
    // Validate allocations
    final totalPoints = statAllocations.values.fold(0, (sum, val) => sum + val);

    if (totalPoints <= 0) {
      throw Exception('Must allocate at least 1 stat point');
    }

    for (final entry in statAllocations.entries) {
      if (entry.value < 0) {
        throw Exception('Cannot allocate negative stat points');
      }
    }

    return _repository.allocateStatPoints(characterId, statAllocations);
  }
}
