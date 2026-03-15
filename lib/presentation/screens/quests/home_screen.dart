import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/theme_config.dart';
import '../../../domain/entities/quest.dart';
import '../../providers/character_provider.dart';
import '../../providers/quest_provider.dart';
import '../../providers/quest_generation_provider.dart';
import '../../widgets/character/pixel_art_avatar.dart';
import '../settings/admin_settings_screen.dart';
import '../achievements/achievements_screen.dart';
import '../shop/cosmetic_shop_screen.dart';
import '../mini_games/mini_game_launcher.dart';
import 'quest_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterProvider);
    final activeQuestsAsync = ref.watch(activeQuestsProvider);
    final availableQuestsAsync = ref.watch(availableQuestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GREENFIELD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(activeQuestsProvider.notifier).loadQuests(),
            ref.read(availableQuestsProvider.notifier).loadQuests(),
            ref.read(characterProvider.notifier).loadCharacter(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Character info card
            characterAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $error'),
                ),
              ),
              data: (character) {
                if (character == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No character found'),
                    ),
                  );
                }
                return _buildCharacterCard(context, character);
              },
            ),
            const SizedBox(height: 24),

            // Game navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(context, '🎮', 'GAMES', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MiniGameLauncher()),
                  );
                }),
                _buildNavButton(context, '🏆', 'ACHIEVEMENTS', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AchievementsScreen(),
                    ),
                  );
                }),
                _buildNavButton(context, '💎', 'SHOP', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CosmeticShopScreen(),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Active quests section
            _buildSectionHeader(context, '🔥 ACTIVE QUESTS'),
            const SizedBox(height: 8),
            activeQuestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
              data: (quests) {
                if (quests.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No active quests. Accept a quest below to begin!',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: quests
                      .map((quest) => _buildQuestCard(context, ref, quest))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Available quests section
            _buildSectionHeader(context, '📋 AVAILABLE QUESTS'),
            const SizedBox(height: 8),
            availableQuestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
              data: (quests) {
                if (quests.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No available quests at your level.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: quests
                      .map((quest) => _buildQuestCard(context, ref, quest))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: AppConfig.enableQuestGeneration && !kIsWeb
          ? _buildGenerateQuestButton(context, ref)
          : null,
    );
  }

  Widget _buildGenerateQuestButton(BuildContext context, WidgetRef ref) {
    final isGenerating = ref.watch(isGeneratingQuestProvider);

    return FloatingActionButton.extended(
      onPressed: isGenerating ? null : () => _generateQuest(context, ref),
      backgroundColor: isGenerating
          ? Colors.grey[700]
          : GreenlandsTheme.accentGold,
      icon: isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.auto_awesome, color: Colors.black),
      label: Text(
        isGenerating ? 'GENERATING...' : 'GENERATE QUEST',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _generateQuest(BuildContext context, WidgetRef ref) async {
    if (!AppConfig.enableQuestGeneration) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quest generation is disabled. Enable it in settings!',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (AppConfig.claudeApiKey.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claude API key not configured. Add it in settings!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Trigger quest generation
      final quest = await ref.refresh(generateQuestProvider.future);

      // Refresh quest lists
      await Future.wait([
        ref.read(activeQuestsProvider.notifier).loadQuests(),
        ref.read(availableQuestsProvider.notifier).loadQuests(),
      ]);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quest generated: ${quest.title}!'),
            backgroundColor: GreenlandsTheme.successGreen,
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuestDetailScreen(questId: quest.id),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quest: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildCharacterCard(BuildContext context, character) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PixelArtAvatar(
                  race: character.race,
                  characterClass: character.characterClass,
                  size: 96,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${character.race.displayName} ${character.characterClass.displayName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${character.level} • ${character.currentXp}/${character.xpToNextLevel} XP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GreenlandsTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // XP Progress bar
            LinearProgressIndicator(
              value: character.currentXp / character.xpToNextLevel,
              backgroundColor: Colors.grey[800],
              color: GreenlandsTheme.accentGold,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: GreenlandsTheme.accentGold,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, WidgetRef ref, Quest quest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuestDetailScreen(questId: quest.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quest header
              Row(
                children: [
                  Text(
                    quest.questType.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quest info
              Row(
                children: [
                  _buildQuestBadge(
                    quest.questType.displayName,
                    GreenlandsTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  _buildQuestBadge(
                    quest.difficulty.displayName,
                    _getDifficultyColor(quest.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildQuestBadge(
                    '${quest.xpReward} XP',
                    GreenlandsTheme.primaryGreen,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                quest.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Progress indicator for active quests
              if (quest.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: quest.progressPercent,
                        backgroundColor: Colors.grey[800],
                        color: GreenlandsTheme.accentGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${quest.completedObjectivesCount}/${quest.objectives.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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

  Widget _buildNavButton(
    BuildContext context,
    String emoji,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Text(emoji, style: const TextStyle(fontSize: 20)),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
