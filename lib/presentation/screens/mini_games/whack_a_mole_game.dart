import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class WhackAMoleGame extends StatefulWidget {
  final MiniGameTheme theme;
  final MiniGameType gameType;
  final Function(MiniGameResult) onGameComplete;

  const WhackAMoleGame({
    super.key,
    required this.theme,
    required this.gameType,
    required this.onGameComplete,
  });

  @override
  State<WhackAMoleGame> createState() => _WhackAMoleGameState();
}

class _WhackAMoleGameState extends State<WhackAMoleGame> {
  late Timer _gameTimer;
  int score = 0;
  int timeLeft = 30;
  bool isGameOver = false;
  int activeMoleIndex = -1;
  final int gridSize = 9; // 3x3 grid

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _startGame() {
    _showNextMole();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          isGameOver = true;
          _gameTimer.cancel();
        }
      });
    });
  }

  void _showNextMole() {
    if (isGameOver || !mounted) return;
    setState(() {
      activeMoleIndex = Random().nextInt(gridSize);
    });

    // Hide mole after 1 second if not hit
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || isGameOver) return;
      setState(() {
        if (activeMoleIndex >= 0) {
          activeMoleIndex = -1;
        }
      });
      _showNextMole();
    });
  }

  void _hitMole(int index) {
    if (index == activeMoleIndex && !isGameOver) {
      setState(() {
        score += 10;
        activeMoleIndex = -1;
      });
      _showNextMole();
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
                    'Whack-a-Mole - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${timeLeft}s',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: timeLeft <= 5
                          ? GreenlandsTheme.errorRed
                          : Colors.white,
                    ),
                  ),
                  Text(
                    'Score: $score',
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
          child: isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return Container(
      color: GreenlandsTheme.primaryGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: gridSize,
        itemBuilder: (context, index) {
          final isActive = index == activeMoleIndex;
          return GestureDetector(
            onTap: () => _hitMole(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: isActive ? GreenlandsTheme.errorRed : Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? GreenlandsTheme.accentGold : Colors.grey,
                  width: isActive ? 3 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  isActive ? '🦡' : '🕳️',
                  style: TextStyle(fontSize: isActive ? 48 : 32),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = score >= 50; // Need 5+ hits to win
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
          'Final Score: $score',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: GreenlandsTheme.accentGold,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: () {
            final result = won
                ? MiniGameResult.win(
                    gameType: widget.gameType,
                    theme: widget.theme,
                    score: score,
                  )
                : MiniGameResult.lose(
                    gameType: widget.gameType,
                    theme: widget.theme,
                    score: score,
                  );
            widget.onGameComplete(result);
          },
          icon: const Icon(Icons.check),
          label: const Text('CONTINUE'),
        ),
      ],
    );
  }
}
