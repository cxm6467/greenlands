import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/achievement.dart';
import '../../providers/achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final progressPercentage = achievements.isEmpty
        ? 0.0
        : (unlockedCount / achievements.length) * 100;

    // Group by category
    final grouped = <AchievementCategory, List<Achievement>>{};
    for (final achievement in achievements) {
      grouped.putIfAbsent(achievement.category, () => []).add(achievement);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ACHIEVEMENTS'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$unlockedCount',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: GreenlandsTheme.accentGold),
                      ),
                      Text(
                        'Unlocked',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${achievements.length}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: GreenlandsTheme.accentGold),
                      ),
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${progressPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: GreenlandsTheme.successGreen),
                      ),
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Achievements by category
          ...grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: GreenlandsTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...entry.value.map((achievement) {
                  return _buildAchievementCard(context, achievement);
                }),
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    final opacity = achievement.isUnlocked ? 1.0 : 0.4;
    final bgColor = achievement.isUnlocked
        ? GreenlandsTheme.surfaceDark
        : GreenlandsTheme.primaryGreen;

    return Card(
      color: bgColor.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Opacity(
          opacity: opacity,
          child: Row(
            children: [
              Text(achievement.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (achievement.progressMax != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                            value: achievement.progressPercent,
                            backgroundColor: Colors.grey[800],
                            color: achievement.isUnlocked
                                ? GreenlandsTheme.successGreen
                                : GreenlandsTheme.accentGold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (achievement.isUnlocked)
                Text(
                  '✓',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: GreenlandsTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
