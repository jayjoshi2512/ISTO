import 'enums.dart';
import 'player.dart';
import 'pawn.dart';
import 'square.dart';
import 'cowry_roll.dart';

/// Complete state of the game at any point
class GameState {
  final List<Player> players;
  final List<Pawn> pawns;
  final Map<String, Square> board;
  int currentPlayerId;
  TurnPhase phase;
  CowryRoll? lastRoll;
  bool extraTurnPending;
  final List<int> rankings;
  int nextRank;

  GameState({
    required this.players,
    required this.pawns,
    required this.board,
    this.currentPlayerId = 0,
    this.phase = TurnPhase.waitingForRoll,
    this.lastRoll,
    this.extraTurnPending = false,
    List<int>? rankings,
    this.nextRank = 1,
  }) : rankings = rankings ?? [];

  /// Get current player
  Player get currentPlayer => players[currentPlayerId];

  /// Get all pawns for a specific player
  List<Pawn> getPawnsForPlayer(int playerId) =>
      pawns.where((p) => p.playerId == playerId).toList();

  /// Get all active pawns for current player
  List<Pawn> get currentPlayerActivePawns =>
      getPawnsForPlayer(currentPlayerId).where((p) => p.isActive).toList();

  /// Get all home pawns for current player
  List<Pawn> get currentPlayerHomePawns =>
      getPawnsForPlayer(currentPlayerId).where((p) => p.isHome).toList();

  /// Check if game is over
  bool get isGameOver => rankings.length >= players.length - 1;

  /// Get winner (first in rankings)
  Player? get winner => rankings.isNotEmpty ? players[rankings.first] : null;

  /// Check if a player has finished
  bool hasPlayerFinished(int playerId) => rankings.contains(playerId);

  /// Add player to rankings
  void addToRankings(int playerId) {
    if (!rankings.contains(playerId)) {
      rankings.add(playerId);
      players[playerId].rank = nextRank++;
    }
  }

  @override
  String toString() =>
      'GameState(player: $currentPlayerId, phase: $phase, rankings: $rankings)';
}
