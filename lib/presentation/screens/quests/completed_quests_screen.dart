import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme_config.dart';
import '../../../domain/entities/quest.dart';
import '../../providers/quest_provider.dart';

class CompletedQuestsScreen extends ConsumerWidget {
  const CompletedQuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedQuestsAsync = ref.watch(completedQuestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Completed Quests'), centerTitle: true),
      body: completedQuestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading quests: $error')),
        data: (completedQuests) {
          if (completedQuests.isEmpty) {
            return const Center(
              child: Text(
                'No quests completed yet. Accept and complete quests to see them here!',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedQuests.length,
            itemBuilder: (context, index) {
              final quest = completedQuests[index];
              return _buildQuestCard(context, quest);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, Quest quest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  quest.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GreenlandsTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(quest.difficulty),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    quest.difficulty.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quest.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '✓ Completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: GreenlandsTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: GreenlandsTheme.accentGold,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${quest.xpReward} XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return Colors.green;
      case QuestDifficulty.medium:
        return Colors.orange;
      case QuestDifficulty.hard:
        return Colors.red;
    }
  }
}
