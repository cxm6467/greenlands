import 'package:flutter/material.dart';

import '../../../domain/entities/mini_game.dart';
import '../../../presentation/providers/mini_game_provider.dart';
import 'archery_game.dart';
import 'dice_roll_game.dart';
import 'memory_match_game.dart';
import 'ring_toss_game.dart';

class MiniGameLauncher extends StatefulWidget {
  final Function(MiniGameResult)? onGameComplete;
  final bool autoClose;

  const MiniGameLauncher({
    super.key,
    this.onGameComplete,
    this.autoClose = true,
  });

  @override
  State<MiniGameLauncher> createState() => _MiniGameLauncherState();
}

class _MiniGameLauncherState extends State<MiniGameLauncher> {
  late MiniGameType gameType;
  late MiniGameTheme theme;
  MiniGameResult? result;

  @override
  void initState() {
    super.initState();
    final (selectedGame, selectedTheme) = getRandomMiniGame();
    gameType = selectedGame;
    theme = selectedTheme;
  }

  void _onGameComplete() => _handleGameComplete();

  void _handleGameComplete() {
    if (widget.autoClose) {
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${gameType.emoji} ${gameType.displayName}'),
        centerTitle: true,
      ),
      body: _buildGameWidget(),
    );
  }

  Widget _buildGameWidget() {
    switch (gameType) {
      case MiniGameType.ringToss:
        return RingTossGame(theme: theme, onGameComplete: _onGameComplete);
      case MiniGameType.memoryMatch:
        return MemoryMatchGame(theme: theme, onGameComplete: _onGameComplete);
      case MiniGameType.diceRoll:
        return DiceRollGame(theme: theme, onGameComplete: _onGameComplete);
      case MiniGameType.archery:
        return ArcheryGame(theme: theme, onGameComplete: _onGameComplete);
    }
  }
}
