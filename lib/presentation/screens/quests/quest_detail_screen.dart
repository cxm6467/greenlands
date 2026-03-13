import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/di/injection.dart';
import '../../../core/di/injection_names.dart';
import '../../../domain/entities/quest.dart';
import '../../../domain/repositories/quest_repository.dart';
import '../../providers/quest_provider.dart';

class QuestDetailScreen extends ConsumerStatefulWidget {
  final String questId;

  const QuestDetailScreen({super.key, required this.questId});

  @override
  ConsumerState<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends ConsumerState<QuestDetailScreen> {
  Quest? _quest;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuest();
  }

  Future<void> _loadQuest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questRepo = getIt<QuestRepository>(
        instanceName: InjectionNames.questRepository,
      );
      final quest = await questRepo.getQuestById(widget.questId);

      setState(() {
        _quest = quest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptQuest() async {
    try {
      await ref.read(questActionsProvider).acceptQuest(widget.questId);
      await _loadQuest();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quest accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleObjective(int index) async {
    if (_quest == null || !_quest!.isActive) return;

    try {
      // Toggle the objective
      final objective = _quest!.objectives[index];
      if (!objective.completed) {
        await ref.read(questActionsProvider).updateQuestObjectives(
          widget.questId,
          [index],
        );
        await _loadQuest();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Objective completed!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeQuest() async {
    if (_quest == null) return;

    try {
      final result = await ref
          .read(questActionsProvider)
          .completeQuest(widget.questId);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 QUEST COMPLETED! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _quest!.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '+ ${result.xpAwarded} XP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: GreenlandsTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (result.leveledUp) ...[
                  const SizedBox(height: 16),
                  Text(
                    '⭐ LEVEL UP! ⭐',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: GreenlandsTheme.accentGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'You are now level ${result.newLevel}!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to home
                },
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quest Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quest Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadQuest, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_quest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quest Details')),
        body: const Center(child: Text('Quest not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_quest!.title)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Quest header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _quest!.questType.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _quest!.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildBadge(
                                  _quest!.questType.displayName,
                                  GreenlandsTheme.accentGold,
                                ),
                                _buildBadge(
                                  _quest!.difficulty.displayName,
                                  _getDifficultyColor(_quest!.difficulty),
                                ),
                                _buildBadge(
                                  '${_quest!.xpReward} XP',
                                  GreenlandsTheme.primaryGreen,
                                ),
                                _buildBadge(
                                  _quest!.status.displayName,
                                  _getStatusColor(_quest!.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _quest!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Objectives
          Text(
            'OBJECTIVES',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: GreenlandsTheme.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _quest!.objectives
                    .asMap()
                    .entries
                    .map((entry) => _buildObjectiveItem(entry.key, entry.value))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action button
          if (_quest!.isAvailable)
            ElevatedButton.icon(
              onPressed: _acceptQuest,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('ACCEPT QUEST'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          if (_quest!.isActive && _quest!.areAllObjectivesCompleted)
            ElevatedButton.icon(
              onPressed: _completeQuest,
              icon: const Icon(Icons.emoji_events),
              label: const Text('COMPLETE QUEST'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: GreenlandsTheme.accentGold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(int index, objective) {
    final isActive = _quest!.isActive;
    final isCompleted = objective.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          isActive
              ? Checkbox(
                  value: isCompleted,
                  onChanged: isCompleted
                      ? null
                      : (_) => _toggleObjective(index),
                )
              : Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              objective.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
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

  Color _getStatusColor(QuestStatus status) {
    switch (status) {
      case QuestStatus.available:
        return Colors.blue;
      case QuestStatus.active:
        return Colors.orange;
      case QuestStatus.completed:
        return Colors.green;
      case QuestStatus.failed:
        return Colors.red;
    }
  }
}
