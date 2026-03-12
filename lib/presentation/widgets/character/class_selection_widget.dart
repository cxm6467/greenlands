import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/constants.dart';
import '../../../domain/entities/character.dart';
import '../../providers/character_provider.dart';

class ClassSelectionWidget extends ConsumerWidget {
  const ClassSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClass = ref.watch(characterCreationProvider).characterClass;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '⚔️ Choose Your Class ⚔️',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: CharacterClass.values.map((characterClass) {
                final isSelected = selectedClass == characterClass;
                final baseStats = GameConstants.CLASS_BASE_STATS[characterClass.displayName] ?? {};

                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : null,
                  child: InkWell(
                    onTap: () {
                      ref.read(characterCreationProvider.notifier).setClass(characterClass);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            characterClass.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  characterClass.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  characterClass.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Base Stats: ${_formatBaseStats(baseStats)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBaseStats(Map<String, int> stats) {
    final order = ['strength', 'agility', 'wisdom', 'constitution'];
    return order
        .map((stat) => '${stat.toUpperCase().substring(0, 3)}: ${stats[stat] ?? 0}')
        .join(', ');
  }
}
