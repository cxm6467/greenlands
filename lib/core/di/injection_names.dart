/// Constants for named dependency injection with GetIt
///
/// Using string-based instance names instead of type-based lookup
/// to avoid issues with Flutter web minification where class names
/// get shortened (e.g., CreateCharacter -> aOT)
class InjectionNames {
  // Prevent instantiation
  InjectionNames._();

  // Character use cases
  static const createCharacter = 'CreateCharacter';
  static const getPlayerCharacter = 'GetPlayerCharacter';
  static const allocateStatPoints = 'AllocateStatPoints';

  // Quest use cases
  static const getAvailableQuests = 'GetAvailableQuests';
  static const getActiveQuests = 'GetActiveQuests';
  static const acceptQuest = 'AcceptQuest';
  static const updateQuestObjectives = 'UpdateQuestObjectives';
  static const completeQuest = 'CompleteQuest';

  // Repositories
  static const characterRepository = 'CharacterRepository';
  static const questRepository = 'QuestRepository';

  // Core
  static const logger = 'Logger';
}
