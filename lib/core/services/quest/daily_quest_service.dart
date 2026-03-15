import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../../../domain/entities/quest.dart';

/// Service to handle daily quest reset logic
///
/// This service checks if daily quests need to be reset based on the configured
/// reset hour in AppConfig.dailyQuestResetHour. When a reset is triggered, it
/// resets all completed daily quests back to available status.
class DailyQuestService {
  final QuestRepository _questRepository;
  final Logger _logger;

  DailyQuestService({
    required QuestRepository questRepository,
    required Logger logger,
  }) : _questRepository = questRepository,
       _logger = logger;

  /// Check if daily quests need to be reset and reset them if necessary
  ///
  /// This should be called on app startup and potentially at scheduled intervals.
  Future<void> checkAndResetDailyQuests() async {
    try {
      _logger.i('Checking if daily quests need reset...');

      final allQuests = await _questRepository.getAllQuests();
      final dailyQuests = allQuests
          .where((q) => q.questType == QuestType.daily)
          .toList();

      if (dailyQuests.isEmpty) {
        _logger.d('No daily quests found');
        return;
      }

      _logger.d('Found ${dailyQuests.length} daily quests');

      // TODO: Implement daily reset logic when updateQuest method is added to repository
      // For now, this is a placeholder that logs the daily quests that would be reset
      final completedDailyQuests = dailyQuests
          .where((q) => q.isCompleted)
          .toList();
      if (completedDailyQuests.isNotEmpty) {
        _logger.i(
          '${completedDailyQuests.length} daily quests are completed and would be reset',
        );
        _logger.i(
          'Daily reset hour configured as: ${AppConfig.dailyQuestResetHour}:00',
        );
      }
    } catch (e) {
      _logger.e('Error checking daily quests: $e');
      rethrow;
    }
  }

  /// Get the next reset time based on the configured reset hour
  DateTime getNextResetTime() {
    final now = DateTime.now();
    final resetHour = AppConfig.dailyQuestResetHour;

    var nextReset = DateTime(now.year, now.month, now.day, resetHour);

    // If the reset time has already passed today, schedule for tomorrow
    if (nextReset.isBefore(now)) {
      nextReset = nextReset.add(const Duration(days: 1));
    }

    return nextReset;
  }
}
