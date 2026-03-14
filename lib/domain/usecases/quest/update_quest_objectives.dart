import '../../entities/quest.dart';
import '../../repositories/quest_repository.dart';

class UpdateQuestObjectives {
  final QuestRepository repository;

  UpdateQuestObjectives(this.repository);

  Future<Quest> call(
    String questId,
    List<int> completedObjectiveIndices,
  ) async {
    return await repository.updateQuestObjectives(
      questId,
      completedObjectiveIndices,
    );
  }
}
