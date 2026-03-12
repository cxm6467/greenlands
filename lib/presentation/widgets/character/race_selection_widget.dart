import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/constants.dart';
import '../../../domain/entities/character.dart';
import '../../providers/character_provider.dart';

class RaceSelectionWidget extends ConsumerWidget {
  const RaceSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRace = ref.watch(characterCreationProvider).race;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🧙‍♂️ Choose Your Race 🧙‍♂️',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: CharacterRace.values.map((race) {
                final isSelected = selectedRace == race;
                final statBonuses = GameConstants.RACE_STAT_BONUSES[race.displayName] ?? {};

                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : null,
                  child: InkWell(
                    onTap: () {
                      ref.read(characterCreationProvider.notifier).setRace(race);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            race.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  race.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  race.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bonuses: ${_formatStatBonuses(statBonuses)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
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

  String _formatStatBonuses(Map<String, int> bonuses) {
    return bonuses.entries
        .map((e) => '${e.key.toUpperCase().substring(0, 3)} +${e.value}')
        .join(', ');
  }
}
