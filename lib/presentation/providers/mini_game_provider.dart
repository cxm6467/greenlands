import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mini_game.dart';

/// Gems balance for cosmetic purchases and mini-game rewards
final gemsProvider = StateNotifierProvider<GemsNotifier, int>((ref) {
  return GemsNotifier(initialGems: 0);
});

class GemsNotifier extends StateNotifier<int> {
  GemsNotifier({int initialGems = 0}) : super(initialGems);

  void addGems(int amount) {
    if (amount > 0) {
      state += amount;
    }
  }

  void removeGems(int amount) {
    if (amount > 0 && state >= amount) {
      state -= amount;
    }
  }

  bool canAfford(int cost) => state >= cost;
}

/// Determines if a mini-game should be triggered (30% chance)
bool shouldTriggerMiniGame() {
  return Random().nextInt(100) < 30;
}

/// Selects a random mini-game type and theme
(MiniGameType, MiniGameTheme) getRandomMiniGame() {
  final types = MiniGameType.values;
  final gameType = types[Random().nextInt(types.length)];

  // Pair games with appropriate themes
  final theme = _selectThemeForGame(gameType);

  return (gameType, theme);
}

MiniGameTheme _selectThemeForGame(MiniGameType gameType) {
  final themeMap = {
    MiniGameType.ringToss: [MiniGameTheme.goblin, MiniGameTheme.elf],
    MiniGameType.memoryMatch: [MiniGameTheme.undead, MiniGameTheme.wizard],
    MiniGameType.diceRoll: [MiniGameTheme.tavern, MiniGameTheme.warrior],
    MiniGameType.archery: [MiniGameTheme.ranger, MiniGameTheme.dragon],
  };

  final themes = themeMap[gameType] ?? [MiniGameTheme.wizard];
  return themes[Random().nextInt(themes.length)];
}

/// Provider for mini-game results (future-based for async games)
final miniGameResultProvider =
    StateNotifierProvider<MiniGameResultNotifier, MiniGameResult?>((ref) {
      return MiniGameResultNotifier();
    });

class MiniGameResultNotifier extends StateNotifier<MiniGameResult?> {
  MiniGameResultNotifier() : super(null);

  void setResult(MiniGameResult result) {
    state = result;
  }

  void clearResult() {
    state = null;
  }
}
