// Game mode and AI difficulty configuration for ISTO

enum GameMode {
  /// Local multiplayer (2-4 humans on same device)
  localMultiplayer,

  /// Play against AI/Robot opponent
  vsAI,
}

enum AIDifficulty {
  /// Random valid moves
  easy,

  /// Mix of strategic and random
  medium,

  /// Full strategic evaluation
  hard,
}

/// Configuration for a game session
class GameConfig {
  final GameMode mode;
  final int playerCount;
  final AIDifficulty aiDifficulty;

  /// Which player indices are controlled by AI (e.g., [1] means player 1 is AI)
  final Set<int> aiPlayers;

  const GameConfig({
    this.mode = GameMode.localMultiplayer,
    this.playerCount = 2,
    this.aiDifficulty = AIDifficulty.medium,
    this.aiPlayers = const {},
  });

  bool isAIPlayer(int playerId) => aiPlayers.contains(playerId);
  bool get hasAIPlayers => aiPlayers.isNotEmpty;

  /// Create config for local multiplayer
  factory GameConfig.local(int playerCount) => GameConfig(
        mode: GameMode.localMultiplayer,
        playerCount: playerCount,
      );

  /// Create config for vs AI (human is always player 0)
  factory GameConfig.vsAI({
    int playerCount = 2,
    AIDifficulty difficulty = AIDifficulty.medium,
  }) {
    // All players except player 0 are AI
    final aiSet = <int>{};
    for (int i = 1; i < playerCount; i++) {
      aiSet.add(i);
    }
    return GameConfig(
      mode: GameMode.vsAI,
      playerCount: playerCount,
      aiDifficulty: difficulty,
      aiPlayers: aiSet,
    );
  }

  @override
  String toString() => 'GameConfig($mode, ${playerCount}P, AI: $aiPlayers)';
}
