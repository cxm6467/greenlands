import '../../entities/quest.dart';
import '../../repositories/quest_repository.dart';

class GetActiveQuests {
  final QuestRepository repository;

  GetActiveQuests(this.repository);

  Future<List<Quest>> call() async {
    return await repository.getActiveQuests();
  }
}
