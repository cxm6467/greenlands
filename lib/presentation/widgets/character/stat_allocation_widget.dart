import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme_config.dart';
import '../../providers/character_provider.dart';

class StatAllocationWidget extends ConsumerStatefulWidget {
  const StatAllocationWidget({super.key});

  @override
  ConsumerState<StatAllocationWidget> createState() =>
      _StatAllocationWidgetState();
}

class _StatAllocationWidgetState extends ConsumerState<StatAllocationWidget> {
  final Map<String, int> _allocations = {
    'strength': 0,
    'dexterity': 0,
    'wisdom': 0,
    'constitution': 0,
  };

  static const int maxPoints = 10;

  int get _totalAllocated =>
      _allocations.values.fold(0, (sum, val) => sum + val);
  int get _remainingPoints => maxPoints - _totalAllocated;

  /// Get bonus for a stat from race and class
  int _getBonusFor(String stat) {
    final state = ref.read(characterCreationProvider);
    int bonus = 0;

    // Add racial bonuses
    if (state.race != null) {
      bonus += state.race!.statBonuses[stat] ?? 0;
    }

    // Add class bonuses
    if (state.characterClass != null) {
      bonus += state.characterClass!.statBonuses[stat] ?? 0;
    }

    return bonus;
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(characterCreationProvider);
    if (state.allocatedStats.isNotEmpty) {
      _allocations.addAll(state.allocatedStats);
    }
  }

  void _updateAllocation(String stat, int change) {
    final newValue = _allocations[stat]! + change;

    if (newValue < 0) return;
    if (change > 0 && _remainingPoints <= 0) return;

    setState(() {
      _allocations[stat] = newValue;
      ref
          .read(characterCreationProvider.notifier)
          .setAllocatedStats(_allocations);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '📊 Allocate Stat Points 📊',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Points Remaining: $_remainingPoints / $maxPoints',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _remainingPoints == 0 ? Colors.green : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_remainingPoints > 0)
                    Text(
                      'Allocate all points to continue',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildStatRow(
                  context,
                  'Strength',
                  '⚔️',
                  'strength',
                  'Physical power and melee damage',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Dexterity',
                  '🏃',
                  'dexterity',
                  'Speed, reflexes, and ranged accuracy',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Wisdom',
                  '🧠',
                  'wisdom',
                  'Magical power and knowledge',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  'Constitution',
                  '❤️',
                  'constitution',
                  'Health and endurance',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String statName,
    String emoji,
    String statKey,
    String description,
  ) {
    final baseValue = _allocations[statKey]!;
    final bonus = _getBonusFor(statKey);
    final total = baseValue + bonus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: baseValue > 0
                      ? () => _updateAllocation(statKey, -1)
                      : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 32,
                ),
                // Base allocation cell (gold)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: GreenlandsTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$baseValue',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: GreenlandsTheme.accentGold,
                    ),
                  ),
                ),
                // Bonus cell (green, only if bonus > 0)
                if (bonus > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: GreenlandsTheme.successGreen.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: GreenlandsTheme.successGreen.withValues(
                          alpha: 0.5,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '+$bonus',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: GreenlandsTheme.successGreen,
                              ),
                        ),
                        Text(
                          'bonus',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: GreenlandsTheme.successGreen.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 8,
                              ),
                        ),
                      ],
                    ),
                  ),
                // Total cell (read-only)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '= $total',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _remainingPoints > 0
                      ? () => _updateAllocation(statKey, 1)
                      : null,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
