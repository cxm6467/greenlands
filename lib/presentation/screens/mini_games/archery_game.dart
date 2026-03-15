import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class ArcheryGame extends StatefulWidget {
  final MiniGameTheme theme;
  final VoidCallback onGameComplete;

  const ArcheryGame({
    super.key,
    required this.theme,
    required this.onGameComplete,
  });

  @override
  State<ArcheryGame> createState() => _ArcheryGameState();
}

class _ArcheryGameState extends State<ArcheryGame>
    with TickerProviderStateMixin {
  late AnimationController _targetController;
  late AnimationController _arrowController;
  double targetX = 0;
  double targetY = 0;
  int score = 0;
  int round = 1;
  final int maxRounds = 5;
  bool isGameOver = false;
  double aimX = 0;
  double aimY = 0;
  bool isAiming = false;

  @override
  void initState() {
    super.initState();
    _targetController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _newRound();
  }

  @override
  void dispose() {
    _targetController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _newRound() {
    final random = Random();
    targetX = (random.nextDouble() - 0.5) * 200;
    targetY = (random.nextDouble() - 0.5) * 200 - 100;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!mounted) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }

    final localPosition = renderObject.globalToLocal(details.globalPosition);

    setState(() {
      aimX = localPosition.dx;
      aimY = localPosition.dy;
      isAiming = true;
    });
  }

  void _fireArrow() {
    if (isGameOver || round > maxRounds || !mounted) return;

    // Check if arrow hits target (simple distance-based hit detection)
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }
    final renderBox = renderObject;
    final centerX = renderBox.size.width / 2;
    final centerY = renderBox.size.height / 2;

    final distance = sqrt(
      pow(aimX - centerX - targetX, 2) + pow(aimY - centerY - targetY, 2),
    );

    final isHit = distance < 40; // Hit radius

    _arrowController.forward().then((_) {
      if (!mounted) return;
      setState(() {
        if (isHit) {
          score += 20;
        }
        round++;
        isAiming = false;
        aimX = 0;
        aimY = 0;

        if (round > maxRounds) {
          isGameOver = true;
        } else {
          _newRound();
        }

        _arrowController.reset();
      });
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
                    'Archery - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round: $round/$maxRounds',
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
          child: isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return GestureDetector(
      onPanUpdate: _handleDragUpdate,
      onPanEnd: (_) => _fireArrow(),
      child: Container(
        color: GreenlandsTheme.primaryGreen.withValues(alpha: 0.3),
        child: Stack(
          children: [
            // Target (animated)
            AnimatedBuilder(
              animation: _targetController,
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + targetX - 30,
                  top:
                      MediaQuery.of(context).size.height / 2 +
                      targetY -
                      100 -
                      30,
                  child: Transform.rotate(
                    angle: _targetController.value * 2 * pi,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: GreenlandsTheme.errorRed,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: GreenlandsTheme.accentGold,
                          ),
                          child: Center(
                            child: Text(
                              widget.theme == MiniGameTheme.ranger
                                  ? '🌲'
                                  : '🐉',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Crosshair at center
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 15,
              top: MediaQuery.of(context).size.height / 2 - 100 - 15,
              child: const Text('🎯', style: TextStyle(fontSize: 30)),
            ),
            // Instructions
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Drag to aim, release to fire',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = score >= 40; // 2 hits = win
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
