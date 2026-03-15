import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/achievement.dart';

/// Provider for managing achievements (stub implementation, in-memory)
final achievementsProvider =
    StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
      return AchievementNotifier();
    });

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier() : super(createStubAchievements());

  /// Unlock an achievement by ID
  void unlockAchievement(String achievementId) {
    state = state.map((achievement) {
      if (achievement.id == achievementId && !achievement.isUnlocked) {
        return achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
      return achievement;
    }).toList();
  }

  /// Update progress on an achievement
  void updateProgress(String achievementId, int current) {
    state = state.map((achievement) {
      if (achievement.id == achievementId) {
        final newAchievement = achievement.copyWith(progressCurrent: current);
        // Auto-unlock if progress reaches max
        if (newAchievement.progressMax != null &&
            current >= newAchievement.progressMax! &&
            !achievement.isUnlocked) {
          return newAchievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
        return newAchievement;
      }
      return achievement;
    }).toList();
  }

  /// Get achievement by ID
  Achievement? getAchievementById(String id) {
    try {
      return state.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return state.where((a) => a.isUnlocked).toList();
  }

  /// Get all locked achievements
  List<Achievement> getLockedAchievements() {
    return state.where((a) => !a.isUnlocked).toList();
  }
}
