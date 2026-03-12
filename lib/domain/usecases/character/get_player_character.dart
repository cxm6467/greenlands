import '../../entities/character.dart';
import '../../repositories/character_repository.dart';

class GetPlayerCharacter {
  final CharacterRepository _repository;

  GetPlayerCharacter(this._repository);

  Future<Character?> call() async {
    return _repository.getPlayerCharacter();
  }
}
