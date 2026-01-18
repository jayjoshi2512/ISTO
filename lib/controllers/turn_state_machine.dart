import '../models/models.dart';

/// State machine for managing turn flow and extra turns
/// 
/// AUTHENTIC ISTO RULES FOR EXTRA TURNS:
/// - CHAMMA (4) or ASHTA (8) grants extra turn
/// - Killing an opponent grants extra turn
/// - Both can stack (player keeps rolling until they don't get a grace throw)
class TurnStateMachine {
  int currentPlayerId = 0;
  int playerCount;
  TurnPhase phase = TurnPhase.waitingForRoll;
  bool extraTurnPending = false;

  final List<int> finishedPlayers = [];
  final List<int> rankings = [];
  int nextRank = 1;

  TurnStateMachine({required this.playerCount});

  /// Start a new turn
  void startTurn() {
    phase = TurnPhase.waitingForRoll;
    extraTurnPending = false;
  }

  /// Handle roll completion
  void onRollComplete(CowryRoll roll) {
    phase = TurnPhase.selectingPawn;

    // CHAMMA or ASHTA grants extra turn
    if (roll.grantsExtraTurn) {
      extraTurnPending = true;
    }
  }

  /// Handle when no valid moves are available
  void onNoValidMoves() {
    phase = TurnPhase.checkingExtraTurn;
    _endTurnOrGrantExtra();
  }

  /// Handle pawn selection
  void onPawnSelected() {
    phase = TurnPhase.moving;
  }

  /// Handle move completion
  void onMoveComplete(MoveResult result) {
    phase = TurnPhase.resolving;

    // AUTHENTIC RULE: Killing or finishing grants extra turn
    if (result.reachedCenter || result.killedOpponent) {
      extraTurnPending = true;
    }

    phase = TurnPhase.checkingExtraTurn;
  }

  /// End current turn and advance to next player or grant extra turn
  void endTurn() {
    _endTurnOrGrantExtra();
  }

  void _endTurnOrGrantExtra() {
    if (extraTurnPending) {
      extraTurnPending = false;
      startTurn(); // Same player goes again
    } else {
      _advancePlayer();
      startTurn();
    }
  }

  /// Advance to next player (skip finished players)
  void _advancePlayer() {
    if (isGameOver) return;

    do {
      currentPlayerId = (currentPlayerId + 1) % playerCount;
    } while (finishedPlayers.contains(currentPlayerId) && !isGameOver);
  }

  /// Mark a player as finished
  void markPlayerFinished(int playerId) {
    if (!finishedPlayers.contains(playerId)) {
      finishedPlayers.add(playerId);
      rankings.add(playerId);
    }
  }

  /// Check if game is over
  bool get isGameOver => finishedPlayers.length >= playerCount - 1;

  /// Get current ranking for a player (0 if not finished)
  int getRank(int playerId) {
    final index = rankings.indexOf(playerId);
    return index >= 0 ? index + 1 : 0;
  }

  /// Get winner (first in rankings)
  int? get winnerId => rankings.isNotEmpty ? rankings.first : null;

  /// Get the player who came in last (only valid when game is over)
  int? get lastPlacePlayerId {
    if (!isGameOver) return null;
    for (int i = 0; i < playerCount; i++) {
      if (!finishedPlayers.contains(i)) {
        return i;
      }
    }
    return null;
  }

  /// Reset the state machine
  void reset(int newPlayerCount) {
    playerCount = newPlayerCount;
    currentPlayerId = 0;
    phase = TurnPhase.waitingForRoll;
    extraTurnPending = false;
    finishedPlayers.clear();
    rankings.clear();
    nextRank = 1;
  }

  /// Get current phase as string (for debugging)
  String get phaseString => phase.toString().split('.').last;

  @override
  String toString() =>
      'TurnStateMachine(player: $currentPlayerId, phase: $phaseString, extra: $extraTurnPending)';
}
