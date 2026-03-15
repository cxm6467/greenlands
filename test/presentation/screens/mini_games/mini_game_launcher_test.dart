import 'package:flutter_test/flutter_test.dart';
import 'package:greenfield/domain/entities/mini_game.dart';
import 'package:greenfield/presentation/providers/mini_game_provider.dart';

void main() {
  group('MiniGameLauncher game selection', () {
    test('getRandomMiniGame returns valid tuple', () {
      final (gameType, theme) = getRandomMiniGame();
      expect(gameType, isNotNull);
      expect(theme, isNotNull);
    });

    test('getRandomMiniGame returns MiniGameType', () {
      final (gameType, _) = getRandomMiniGame();
      expect(MiniGameType.values, contains(gameType));
    });

    test('getRandomMiniGame returns MiniGameTheme', () {
      final (_, theme) = getRandomMiniGame();
      expect(MiniGameTheme.values, contains(theme));
    });

    test('getRandomMiniGame can be called repeatedly', () {
      for (int i = 0; i < 20; i++) {
        final (gameType, theme) = getRandomMiniGame();
        expect(MiniGameType.values, contains(gameType));
        expect(MiniGameTheme.values, contains(theme));
      }
    });
  });

  group('MiniGameResult creation', () {
    test('win result has correct properties', () {
      final result = MiniGameResult.win(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.goblin,
        score: 100,
      );

      expect(result.won, isTrue);
      expect(result.gameType, equals(MiniGameType.ringToss));
      expect(result.theme, equals(MiniGameTheme.goblin));
      expect(result.score, equals(100));
    });

    test('lose result has correct properties', () {
      final result = MiniGameResult.lose(
        gameType: MiniGameType.memoryMatch,
        theme: MiniGameTheme.wizard,
        score: 40,
      );

      expect(result.won, isFalse);
      expect(result.gameType, equals(MiniGameType.memoryMatch));
      expect(result.theme, equals(MiniGameTheme.wizard));
      expect(result.score, equals(40));
    });
  });

  group('Game type routing', () {
    test('all 9 game types can create results', () {
      for (final gameType in MiniGameType.values) {
        final winResult = MiniGameResult.win(
          gameType: gameType,
          theme: MiniGameTheme.goblin,
          score: 100,
        );
        expect(winResult.gameType, equals(gameType));

        final loseResult = MiniGameResult.lose(
          gameType: gameType,
          theme: MiniGameTheme.goblin,
          score: 50,
        );
        expect(loseResult.gameType, equals(gameType));
      }
    });

    test('all 8 themes can create results', () {
      for (final theme in MiniGameTheme.values) {
        final winResult = MiniGameResult.win(
          gameType: MiniGameType.ringToss,
          theme: theme,
          score: 100,
        );
        expect(winResult.theme, equals(theme));

        final loseResult = MiniGameResult.lose(
          gameType: MiniGameType.ringToss,
          theme: theme,
          score: 50,
        );
        expect(loseResult.theme, equals(theme));
      }
    });
  });

  group('Theme selection for games', () {
    test('random game selections are valid combinations', () {
      for (int i = 0; i < 50; i++) {
        final (gameType, theme) = getRandomMiniGame();
        // All combinations should be valid
        expect(MiniGameType.values, contains(gameType));
        expect(MiniGameTheme.values, contains(theme));
      }
    });
  });

  group('Game result gem rewards', () {
    test('win results in launcher have 10-20 gems', () {
      for (int i = 0; i < 20; i++) {
        final (gameType, theme) = getRandomMiniGame();
        final result = MiniGameResult.win(
          gameType: gameType,
          theme: theme,
          score: 100,
        );
        expect(result.gemsEarned, greaterThanOrEqualTo(10));
        expect(result.gemsEarned, lessThanOrEqualTo(20));
      }
    });

    test('lose results in launcher have 2 gems', () {
      for (int i = 0; i < 10; i++) {
        final (gameType, theme) = getRandomMiniGame();
        final result = MiniGameResult.lose(
          gameType: gameType,
          theme: theme,
          score: 50,
        );
        expect(result.gemsEarned, equals(2));
      }
    });
  });

  group('MiniGameResultNotifier', () {
    test('initializes with null result', () {
      final notifier = MiniGameResultNotifier();
      expect(notifier.state, isNull);
    });

    test('setResult updates state', () {
      final notifier = MiniGameResultNotifier();
      final result = MiniGameResult.win(
        gameType: MiniGameType.flappyBird,
        theme: MiniGameTheme.elf,
        score: 35,
      );
      notifier.setResult(result);
      expect(notifier.state, equals(result));
    });

    test('clearResult resets to null', () {
      final notifier = MiniGameResultNotifier();
      final result = MiniGameResult.win(
        gameType: MiniGameType.diceRoll,
        theme: MiniGameTheme.tavern,
        score: 60,
      );
      notifier.setResult(result);
      notifier.clearResult();
      expect(notifier.state, isNull);
    });
  });
}
