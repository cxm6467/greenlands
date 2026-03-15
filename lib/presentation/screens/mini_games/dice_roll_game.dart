import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class DiceRollGame extends StatefulWidget {
  final MiniGameTheme theme;
  final VoidCallback onGameComplete;

  const DiceRollGame({
    super.key,
    required this.theme,
    required this.onGameComplete,
  });

  @override
  State<DiceRollGame> createState() => _DiceRollGameState();
}

class _DiceRollGameState extends State<DiceRollGame>
    with TickerProviderStateMixin {
  late AnimationController _diceController;
  List<int> heldDice = [];
  List<int> currentRoll = [0, 0, 0];
  int round = 1;
  int totalScore = 0;
  bool isRolling = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rollDice();
  }

  @override
  void dispose() {
    _diceController.dispose();
    super.dispose();
  }

  void _rollDice() async {
    setState(() {
      isRolling = true;
    });

    _diceController.forward().then((_) {
      if (!mounted) return;
      setState(() {
        // Roll all non-held dice
        for (int i = 0; i < 3; i++) {
          if (!heldDice.contains(i)) {
            currentRoll[i] = Random().nextInt(6) + 1;
          }
        }
        isRolling = false;
      });
      _diceController.reset();
    });
  }

  void _toggleHold(int index) {
    setState(() {
      if (heldDice.contains(index)) {
        heldDice.remove(index);
      } else if (heldDice.length < 2) {
        heldDice.add(index);
      }
    });
  }

  void _submitRound() {
    final score = currentRoll.fold(0, (a, b) => a + b);
    bool shouldRollNextRound = false;

    setState(() {
      totalScore += score;
      round++;

      if (round > 3) {
        isGameOver = true;
      } else {
        heldDice = [];
        shouldRollNextRound = true;
      }
    });

    if (shouldRollNextRound) {
      _rollDice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.theme.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dice Roll - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round: $round/3',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Score: $totalScore',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: GreenlandsTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        // Game area
        Expanded(
          child: Center(
            child: isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Round Total: ${currentRoll.fold(0, (a, b) => a + b)}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: GreenlandsTheme.accentGold),
        ),
        const SizedBox(height: 48),
        // Dice
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isHeld = heldDice.contains(index);
            return GestureDetector(
              onTap: () => _toggleHold(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isHeld
                      ? GreenlandsTheme.accentGold.withValues(alpha: 0.3)
                      : GreenlandsTheme.surfaceDark,
                  border: Border.all(
                    color: isHeld
                        ? GreenlandsTheme.accentGold
                        : GreenlandsTheme.borderColor,
                    width: isHeld ? 3 : 2,
                  ),
                ),
                child: Column(
                  children: [
                    if (isRolling)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${currentRoll[index]}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      isHeld ? 'HELD' : 'tap',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        color: isHeld
                            ? GreenlandsTheme.accentGold
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isRolling ? null : _rollDice,
              icon: const Icon(Icons.refresh),
              label: const Text('RE-ROLL'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: isRolling ? null : _submitRound,
              icon: const Icon(Icons.check),
              label: const Text('SUBMIT'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    final won = totalScore >= 20;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          won ? 'YOU WIN! 🎉' : 'GAME OVER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: won
                ? GreenlandsTheme.successGreen
                : GreenlandsTheme.errorRed,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Final Score: $totalScore',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: GreenlandsTheme.accentGold,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: widget.onGameComplete,
          icon: const Icon(Icons.check),
          label: const Text('CONTINUE'),
        ),
      ],
    );
  }
}
