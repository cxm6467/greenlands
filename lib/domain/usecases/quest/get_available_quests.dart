import '../../entities/quest.dart';
import '../../repositories/quest_repository.dart';

class GetAvailableQuests {
  final QuestRepository repository;

  GetAvailableQuests(this.repository);

  Future<List<Quest>> call(int playerLevel) async {
    return await repository.getAvailableQuests(playerLevel);
  }
}
