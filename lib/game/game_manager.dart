import '../config/theme_config.dart';
import '../models/models.dart';
import '../controllers/controllers.dart';
import '../services/feedback_service.dart';

/// Main game orchestrator - coordinates all controllers
/// 
/// ISTO/Chowka Bhara Rules:
/// - Entry: 1, 4, or 8 releases a pawn from home
/// - Extra turns on CHOWKA (4), ASHTA (8), or capture
/// - Must capture at least one opponent before entering inner ring
/// - Pawns on safe squares cannot be captured
/// - First player to get all 4 pawns to center wins
class GameManager {
  late final BoardController boardController;
  late final PawnController pawnController;
  late final CowryController cowryController;
  late final TurnStateMachine turnStateMachine;

  final List<Player> players = [];
  int playerCount;
  
  /// Track captures per player (needed for inner ring entry rule)
  final Map<int, int> captureCount = {};

  // Callbacks for UI updates
  Function()? onStateChanged;
  Function(CowryRoll roll)? onRollComplete;
  Function(Pawn pawn, MoveResult result)? onMoveComplete;
  Function(int playerId)? onPlayerFinished;
  Function(int winnerId)? onGameOver;
  Function(List<Pawn> validPawns)? onValidMovesCalculated;
  Function()? onExtraTurn;
  Function()? onNoValidMoves;

  GameManager({this.playerCount = 2}) {
    _initControllers();
  }

  void _initControllers() {
    boardController = BoardController();
    pawnController = PawnController(boardController: boardController);
    cowryController = CowryController();
    turnStateMachine = TurnStateMachine(playerCount: playerCount);
  }
  
  /// Check if player has made at least one capture (for inner ring entry)
  bool hasPlayerCaptured(int playerId) {
    return (captureCount[playerId] ?? 0) > 0;
  }

  /// Start a new game
  void startGame({int players = 2}) {
    playerCount = players.clamp(2, 4);

    // Reset controllers
    boardController.reset();
    turnStateMachine.reset(playerCount);
    
    // Reset capture counts
    captureCount.clear();

    // Initialize players
    this.players.clear();
    for (int i = 0; i < playerCount; i++) {
      this.players.add(Player(
        id: i,
        name: ThemeConfig.getPlayerName(i),
        color: ThemeConfig.getPlayerColor(i),
      ));
      captureCount[i] = 0;
    }

    // Initialize pawns
    pawnController.initPawns(playerCount);

    // Start first turn
    turnStateMachine.startTurn();
    feedbackService.onTurnStart();
    onStateChanged?.call();
  }

  /// Get current player
  Player get currentPlayer => players[turnStateMachine.currentPlayerId];

  /// Get current phase
  TurnPhase get currentPhase => turnStateMachine.phase;

  /// Check if game is over
  bool get isGameOver => turnStateMachine.isGameOver;

  /// Get winner
  Player? get winner {
    final winnerId = turnStateMachine.winnerId;
    return winnerId != null ? players[winnerId] : null;
  }

  /// Roll the cowries
  CowryRoll roll() {
    if (currentPhase != TurnPhase.waitingForRoll) {
      throw StateError('Cannot roll in phase: $currentPhase');
    }

    final roll = cowryController.roll();
    
    // Haptic feedback for roll
    if (roll.grantsExtraTurn) {
      feedbackService.onGraceThrow();
    } else {
      feedbackService.onRoll();
    }
    
    turnStateMachine.onRollComplete(roll);

    // Calculate valid moves (pass capture status for inner ring check)
    final validPawns = _getValidPawns(roll);

    if (validPawns.isEmpty) {
      // No valid moves - end turn
      feedbackService.onNoMoves();
      onNoValidMoves?.call();
      turnStateMachine.onNoValidMoves();
      _checkGameState();
    } else {
      onValidMovesCalculated?.call(validPawns);
    }

    onRollComplete?.call(roll);
    onStateChanged?.call();

    return roll;
  }

  /// Get pawns that can make a valid move with current roll
  List<Pawn> _getValidPawns(CowryRoll roll) {
    final playerId = turnStateMachine.currentPlayerId;
    final hasCaptured = hasPlayerCaptured(playerId);
    
    return boardController.getValidMoves(
      playerId,
      roll.steps,
      pawnController.pawns,
      roll.allowsEntry,
      hasCaptured, // Pass capture status for inner ring restriction
    );
  }

  /// Get current valid pawns (based on last roll)
  List<Pawn> get validPawns {
    final roll = cowryController.lastRoll;
    if (roll == null) return [];
    return _getValidPawns(roll);
  }

  /// Get all pawns stacked with a given pawn (same position, same player)
  List<Pawn> getStackedPawns(Pawn pawn) {
    if (pawn.isHome || !pawn.isActive) return [pawn];
    
    final pos = pawnController.getPawnPosition(pawn);
    if (pos == null) return [pawn];
    
    final square = boardController.getSquare(pos);
    if (square == null) return [pawn];
    
    return square.getFriendlyPawns(pawn.playerId);
  }
  
  /// Check if a pawn has stackable pawns (for stacked movement decision)
  bool hasStackedPawns(Pawn pawn) {
    return getStackedPawns(pawn).length > 1;
  }
  
  /// Check if pawn is on inner path (stacking allowed here)
  bool isPawnOnInnerPath(Pawn pawn) {
    if (!pawn.isActive || pawn.isHome) return false;
    return pawn.currentPath == PathType.inner;
  }
  
  /// Check if current roll allows stacked movement (any roll value in inner path)
  bool rollAllowsStackedMovement() {
    final roll = cowryController.lastRoll;
    return roll != null;
  }

  /// Callback for stacked pawn dialog choice - passes pawn and count of pawns to move
  Function(Pawn pawn, int pawnCount)? onStackedPawnChoice;

  /// Select and move a pawn (optionally with stacked pawns)
  MoveResult selectPawn(Pawn pawn, {int movePawnCount = 1}) {
    if (currentPhase != TurnPhase.selectingPawn) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('Cannot select pawn in phase: $currentPhase');
    }

    final roll = cowryController.lastRoll;
    if (roll == null) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('No roll available');
    }

    // Validate pawn belongs to current player
    if (pawn.playerId != turnStateMachine.currentPlayerId) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('Not your pawn');
    }

    // Validate pawn can move
    final hasCaptured = hasPlayerCaptured(pawn.playerId);
    if (!boardController.canPawnMove(
        pawn, roll.steps, pawnController.pawns, roll.allowsEntry, hasCaptured)) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('Pawn cannot move');
    }

    // Check if this pawn is stacked ON INNER PATH and needs dialog
    final stackedPawns = getStackedPawns(pawn);
    if (stackedPawns.length > 1 && isPawnOnInnerPath(pawn) && movePawnCount == 1) {
      // Audio signal for stacked pawn choice dialog
      feedbackService.mediumTap();
      // Ask user how many pawns to move - callback to UI
      onStackedPawnChoice?.call(pawn, stackedPawns.length);
      return MoveResult.failed('Waiting for stacked pawn choice');
    }

    // Haptic for selection
    feedbackService.onPawnSelect();
    turnStateMachine.onPawnSelected();

    // Execute move
    MoveResult result;
    if (pawn.isHome) {
      result = pawnController.enterPawn(pawn);
      feedbackService.onPawnEnter();
    } else {
      // movePawnCount > 1 means move multiple stacked pawns
      if (movePawnCount > 1 && stackedPawns.length >= movePawnCount) {
        // Move specified number of stacked pawns together
        final pawnsToMove = stackedPawns.take(movePawnCount).toList();
        result = pawnController.moveStackedPawns(pawnsToMove, roll.steps);
      } else {
        result = pawnController.movePawn(pawn, roll.steps, attackerCount: 1);
      }
      feedbackService.onPawnMove();
    }
    
    // Track capture
    if (result.killedOpponent) {
      captureCount[pawn.playerId] = (captureCount[pawn.playerId] ?? 0) + result.victims.length;
      feedbackService.onCapture();
    }
    
    // Check if reached center
    if (result.reachedCenter) {
      feedbackService.onPawnFinish();
    }

    // Handle move result
    turnStateMachine.onMoveComplete(result);

    // Check if player finished
    if (pawnController.hasPlayerWon(pawn.playerId)) {
      turnStateMachine.markPlayerFinished(pawn.playerId);
      players[pawn.playerId].rank = turnStateMachine.getRank(pawn.playerId);
      feedbackService.onWin();
      onPlayerFinished?.call(pawn.playerId);
    }

    onMoveComplete?.call(pawn, result);
    _checkGameState();

    return result;
  }

  void _checkGameState() {
    if (turnStateMachine.isGameOver) {
      // Mark last player
      final lastPlace = turnStateMachine.lastPlacePlayerId;
      if (lastPlace != null) {
        players[lastPlace].rank = playerCount;
      }
      onGameOver?.call(turnStateMachine.winnerId!);
    } else if (turnStateMachine.extraTurnPending ||
        currentPhase == TurnPhase.checkingExtraTurn) {
      // Check for extra turn
      if (turnStateMachine.extraTurnPending) {
        feedbackService.onExtraTurn();
        onExtraTurn?.call();
      }
      turnStateMachine.endTurn();
      
      // Notify turn change
      if (!turnStateMachine.extraTurnPending) {
        feedbackService.onTurnStart();
      }
    }

    onStateChanged?.call();
  }

  /// End current turn manually
  void endTurn() {
    turnStateMachine.endTurn();
    onStateChanged?.call();
  }

  /// Get all pawns
  List<Pawn> get allPawns => pawnController.pawns;

  /// Get pawns for current player
  List<Pawn> get currentPlayerPawns =>
      pawnController.getPawnsForPlayer(turnStateMachine.currentPlayerId);

  /// Get pawn position on board
  Position? getPawnPosition(Pawn pawn) => pawnController.getPawnPosition(pawn);

  /// Get square at position
  Square? getSquare(Position pos) => boardController.getSquare(pos);

  /// Reset game
  void reset() {
    startGame(players: playerCount);
  }

  /// Get rankings
  List<Player> get rankings {
    final ranked = <Player>[];
    for (final playerId in turnStateMachine.rankings) {
      ranked.add(players[playerId]);
    }
    return ranked;
  }
}
