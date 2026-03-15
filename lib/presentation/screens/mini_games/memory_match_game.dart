import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class MemoryMatchGame extends StatefulWidget {
  final MiniGameTheme theme;
  final VoidCallback onGameComplete;

  const MemoryMatchGame({
    super.key,
    required this.theme,
    required this.onGameComplete,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<String> cards;
  late List<bool> flipped;
  late List<bool> matched;
  int? firstFlipped;
  int? secondFlipped;
  int moves = 0;
  bool canTap = true;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final emojis = widget.theme == MiniGameTheme.undead
        ? ['🧟', '🧟', '💀', '💀', '🦴', '🦴', '⚰️', '⚰️']
        : ['🎭', '🎭', '✨', '✨', '🌙', '🌙', '⭐', '⭐'];

    cards = (emojis..shuffle()).toList();
    flipped = List.filled(8, false);
    matched = List.filled(8, false);
    firstFlipped = null;
    secondFlipped = null;
    moves = 0;
    canTap = true;
    isGameOver = false;
  }

  void _flipCard(int index) {
    if (!canTap || flipped[index] || matched[index]) return;

    setState(() {
      flipped[index] = true;

      if (firstFlipped == null) {
        firstFlipped = index;
      } else if (secondFlipped == null) {
        secondFlipped = index;
        canTap = false;
        moves++;

        // Check for match
        if (cards[firstFlipped!] == cards[secondFlipped!]) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              matched[firstFlipped!] = true;
              matched[secondFlipped!] = true;
              firstFlipped = null;
              secondFlipped = null;
              canTap = true;

              // Check if all matched
              if (matched.every((m) => m)) {
                isGameOver = true;
              }
            });
          });
        } else {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            setState(() {
              flipped[firstFlipped!] = false;
              flipped[secondFlipped!] = false;
              firstFlipped = null;
              secondFlipped = null;
              canTap = true;
            });
          });
        }
      }
    });
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
                    'Memory Match - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Moves: $moves',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GreenlandsTheme.accentGold,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // Game grid
        Expanded(child: isGameOver ? _buildGameOverScreen() : _buildGameGrid()),
      ],
    );
  }

  Widget _buildGameGrid() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return _buildCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = flipped[index] || matched[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isFlipped
              ? GreenlandsTheme.accentGold.withValues(alpha: 0.2)
              : GreenlandsTheme.surfaceDark,
          border: Border.all(
            color: isFlipped
                ? GreenlandsTheme.accentGold
                : GreenlandsTheme.borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            isFlipped ? cards[index] : '?',
            style: TextStyle(
              fontSize: isFlipped ? 32 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = moves <= 10; // Win if <= 10 moves
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          won ? 'YOU WIN! 🎉' : 'COMPLETED!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: won ? GreenlandsTheme.successGreen : Colors.orange,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Moves: $moves',
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
