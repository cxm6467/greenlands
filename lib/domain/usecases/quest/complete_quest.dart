import '../../entities/quest.dart';
import '../../repositories/character_repository.dart';
import '../../repositories/quest_repository.dart';

class CompleteQuest {
  final QuestRepository questRepository;
  final CharacterRepository characterRepository;

  CompleteQuest({
    required this.questRepository,
    required this.characterRepository,
  });

  Future<QuestCompletionResult> call(String questId) async {
    // Complete the quest
    final quest = await questRepository.completeQuest(questId);

    // Award XP to the player
    final character = await characterRepository.getPlayerCharacter();
    if (character == null) {
      throw Exception('No player character found');
    }

    final updatedCharacter = await characterRepository.addXp(
      character.id,
      quest.xpReward,
    );

    return QuestCompletionResult(
      quest: quest,
      xpAwarded: quest.xpReward,
      newLevel: updatedCharacter.level,
      leveledUp: updatedCharacter.level > character.level,
    );
  }
}

class QuestCompletionResult {
  final Quest quest;
  final int xpAwarded;
  final int newLevel;
  final bool leveledUp;

  const QuestCompletionResult({
    required this.quest,
    required this.xpAwarded,
    required this.newLevel,
    required this.leveledUp,
  });
}
