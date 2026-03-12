import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/character_provider.dart';

class StatAllocationWidget extends ConsumerStatefulWidget {
  const StatAllocationWidget({super.key});

  @override
  ConsumerState<StatAllocationWidget> createState() => _StatAllocationWidgetState();
}

class _StatAllocationWidgetState extends ConsumerState<StatAllocationWidget> {
  final Map<String, int> _allocations = {
    'strength': 0,
    'agility': 0,
    'wisdom': 0,
    'constitution': 0,
  };

  static const int maxPoints = 10;

  int get _totalAllocated =>
      _allocations.values.fold(0, (sum, val) => sum + val);
  int get _remainingPoints => maxPoints - _totalAllocated;

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
      ref.read(characterCreationProvider.notifier).setAllocatedStats(_allocations);
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
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
                  'Agility',
                  '🏃',
                  'agility',
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
    final value = _allocations[statKey]!;

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
                  onPressed: value > 0 ? () => _updateAllocation(statKey, -1) : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 32,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
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
