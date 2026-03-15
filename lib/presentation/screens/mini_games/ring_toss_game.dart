import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class RingTossGame extends StatefulWidget {
  final MiniGameTheme theme;
  final VoidCallback onGameComplete;

  const RingTossGame({
    super.key,
    required this.theme,
    required this.onGameComplete,
  });

  @override
  State<RingTossGame> createState() => _RingTossGameState();
}

class _RingTossGameState extends State<RingTossGame>
    with TickerProviderStateMixin {
  late AnimationController _pegController;
  late AnimationController _ringController;
  int score = 0;
  int rounds = 0;
  final int maxRounds = 5;
  bool isGameOver = false;
  String feedbackText = '';

  @override
  void initState() {
    super.initState();
    _pegController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _ringController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startNewRound();
  }

  @override
  void dispose() {
    _pegController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    if (rounds >= maxRounds) {
      setState(() {
        isGameOver = true;
      });
      return;
    }

    feedbackText = 'Tap when ring aligns!';
    rounds++;
  }

  void _attemptToss() {
    if (isGameOver) return;

    final pegAnimation = _pegController.value;
    // Peg is centered when value is 0.5, ranges from -0.3 to +0.3 of screen width
    final pegPosition = (pegAnimation - 0.5) * 2; // Range: -1 to 1

    // Ring hits if pegPosition is between -0.2 and 0.2
    final hitRange = 0.15;
    final isHit = pegPosition.abs() < hitRange;

    setState(() {
      if (isHit) {
        score += 10;
        feedbackText = 'HIT! +10 points';
      } else {
        feedbackText = 'MISS! Try again';
      }
    });

    // Animate ring throw
    _ringController.forward().then((_) {
      if (!mounted) return;
      _ringController.reset();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (rounds < maxRounds && !isGameOver) {
          setState(() {
            _startNewRound();
          });
        } else if (rounds >= maxRounds) {
          setState(() {
            isGameOver = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
                    'Ring Toss - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round: $rounds/$maxRounds',
                    style: Theme.of(context).textTheme.bodyLarge,
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
          child: Center(
            child: isGameOver
                ? _buildGameOverScreen()
                : _buildGameScreen(isMobile),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          feedbackText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: feedbackText.contains('HIT')
                ? GreenlandsTheme.successGreen
                : feedbackText.contains('MISS')
                ? GreenlandsTheme.errorRed
                : Colors.white,
          ),
        ),
        const SizedBox(height: 48),
        // Peg animation
        SizedBox(
          height: 200,
          child: AnimatedBuilder(
            animation: _pegController,
            builder: (context, child) {
              final pegOffset = (_pegController.value - 0.5) * 300;
              return Center(
                child: Transform.translate(
                  offset: Offset(pegOffset, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GreenlandsTheme.accentGold,
                          border: Border.all(
                            color: GreenlandsTheme.accentGold,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.theme == MiniGameTheme.goblin ? '🗡️' : '🌿',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 48),
        // Ring (static at bottom)
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: GreenlandsTheme.accentBlue, width: 8),
          ),
          child: const Center(
            child: Text('💍', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 48),
        // Tap button
        ElevatedButton(
          onPressed: isGameOver ? null : _attemptToss,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text('TOSS!', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    final won = score >= 30; // Win if >= 3 hits
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
          onPressed: widget.onGameComplete,
          icon: const Icon(Icons.check),
          label: const Text('CONTINUE'),
        ),
      ],
    );
  }
}
