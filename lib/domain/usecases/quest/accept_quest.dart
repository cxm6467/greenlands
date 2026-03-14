import '../../entities/quest.dart';
import '../../repositories/quest_repository.dart';

class AcceptQuest {
  final QuestRepository repository;

  AcceptQuest(this.repository);

  Future<Quest> call(String questId) async {
    return await repository.acceptQuest(questId);
  }
}
