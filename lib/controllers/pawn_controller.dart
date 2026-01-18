import '../config/board_config.dart';
import '../models/models.dart';
import 'board_controller.dart';

/// Controls pawn state, movement, and collision resolution
/// 
/// AUTHENTIC ISTO RULES:
/// - Safe squares: 4 corners + center (Charkoni) - NO KILLS ALLOWED
/// - Killing opponent sends them home and grants EXTRA TURN
/// - Doubles (2 same-player pawns) block opponent on outer path only
/// - Single pawn cannot kill a double
class PawnController {
  final List<Pawn> pawns = [];
  final BoardController boardController;

  PawnController({required this.boardController});

  /// Initialize pawns for all players
  void initPawns(int playerCount) {
    pawns.clear();
    for (int p = 0; p < playerCount; p++) {
      for (int i = 0; i < 4; i++) {
        pawns.add(Pawn(
          id: Pawn.createId(p, i),
          playerId: p,
          pawnIndex: i,
          state: PawnState.home,
          pathIndex: -1,
          currentPath: PathType.outer,
        ));
      }
    }
  }
  
  /// Check if a position is a safe square (no kills allowed)
  bool isSafeSquare(Position pos) {
    return BoardConfig.isSafeSquare([pos.row, pos.col]);
  }

  /// Get all pawns for a player
  List<Pawn> getPawnsForPlayer(int playerId) =>
      pawns.where((p) => p.playerId == playerId).toList();

  /// Get active pawns for a player
  List<Pawn> getActivePawnsForPlayer(int playerId) =>
      pawns.where((p) => p.playerId == playerId && p.isActive).toList();

  /// Get home pawns for a player
  List<Pawn> getHomePawnsForPlayer(int playerId) =>
      pawns.where((p) => p.playerId == playerId && p.isHome).toList();

  /// Get finished pawns for a player
  List<Pawn> getFinishedPawnsForPlayer(int playerId) =>
      pawns.where((p) => p.playerId == playerId && p.isFinished).toList();

  /// Check if player has won (all pawns finished)
  bool hasPlayerWon(int playerId) {
    return getPawnsForPlayer(playerId).every((p) => p.isFinished);
  }

  /// Enter a pawn onto the board
  MoveResult enterPawn(Pawn pawn) {
    if (!pawn.isHome) {
      return MoveResult.failed('Pawn is not at home');
    }

    pawn.enterBoard();

    // Get starting position and place on board
    final startPos = boardController.getPositionFromPath(pawn.playerId, 0);
    if (startPos == null) {
      return MoveResult.failed('Invalid starting position');
    }

    final startSquare = boardController.getSquare(startPos);
    if (startSquare == null) {
      return MoveResult.failed('Starting square not found');
    }

    // Check for kill at entry point
    final killResult = _resolveCollision(pawn, startSquare);

    // Place pawn on starting square
    startSquare.addPawn(pawn);

    if (killResult.killedOpponent) {
      return killResult;
    }

    return MoveResult.moved();
  }

  /// Move a pawn by given steps
  MoveResult movePawn(Pawn pawn, int steps) {
    if (!pawn.isActive) {
      return MoveResult.failed('Pawn is not active');
    }

    final newIndex = pawn.pathIndex + steps;
    final pathLength = boardController.getPathLength(pawn.playerId);

    // Check if exceeds path
    if (newIndex > pathLength - 1) {
      return MoveResult.failed('Move exceeds path');
    }

    // Get current and new positions
    final currentPos = boardController.getPositionFromPath(pawn.playerId, pawn.pathIndex);
    final newPos = boardController.getPositionFromPath(pawn.playerId, newIndex);

    if (currentPos == null || newPos == null) {
      return MoveResult.failed('Invalid positions');
    }

    // Remove from current square
    final currentSquare = boardController.getSquare(currentPos);
    currentSquare?.removePawn(pawn);

    // Update pawn position
    pawn.pathIndex = newIndex;

    // Update path type based on position
    final pathPos = boardController.playerPaths[pawn.playerId]![newIndex];
    if (BoardConfig.isInnerPath(pathPos) || BoardConfig.isCenter(pathPos)) {
      pawn.currentPath = PathType.inner;
    }

    // Get destination square
    final destSquare = boardController.getSquare(newPos);
    if (destSquare == null) {
      return MoveResult.failed('Destination square not found');
    }

    // Check if reached center
    if (destSquare.type == SquareType.center) {
      pawn.finish();
      destSquare.addPawn(pawn);
      return MoveResult.finished();
    }

    // Check for kills
    final killResult = _resolveCollision(pawn, destSquare);

    // Place pawn on destination
    destSquare.addPawn(pawn);

    if (killResult.killedOpponent) {
      return killResult;
    }

    return MoveResult.moved();
  }

  /// Resolve collision/kill at destination square
  /// 
  /// AUTHENTIC RULES:
  /// - Safe squares (corners + center): NO kills allowed
  /// - Killing grants EXTRA TURN
  /// - Cannot kill a double (2 pawns of same player)
  MoveResult _resolveCollision(Pawn attacker, Square target) {
    // Center/Charkoni is safe - no kills
    if (target.type == SquareType.center) {
      return MoveResult.moved();
    }

    // Check if this is a safe square (player starting positions)
    if (isSafeSquare(target.position)) {
      return MoveResult.moved(); // No kills on safe squares
    }

    // Get enemy pawns on this square
    final enemies = target.getEnemyPawns(attacker.playerId);
    if (enemies.isEmpty) {
      return MoveResult.moved();
    }

    // AUTHENTIC RULE: Cannot kill a double (2+ same-player pawns)
    if (enemies.length >= 2) {
      // Check if they're a double (same player)
      final samePlayer = enemies.every((e) => e.playerId == enemies[0].playerId);
      if (samePlayer) {
        // This is a double - single pawn cannot kill them
        return MoveResult.moved();
      }
    }

    // Single enemy - CAN BE KILLED
    if (enemies.length == 1) {
      _sendPawnHome(enemies[0], target);
      // AUTHENTIC RULE: Killing grants extra turn (handled in MoveResult.grantsExtraTurn)
      return MoveResult.kill(
        type: KillType.single,
        victims: [enemies[0]],
      );
    }

    return MoveResult.moved();
  }

  /// Send a pawn back to home
  void _sendPawnHome(Pawn pawn, Square fromSquare) {
    fromSquare.removePawn(pawn);
    pawn.sendHome();
  }

  /// Send pawn home (public method)
  void sendHome(Pawn pawn) {
    // Find and remove from current square
    final currentPos = boardController.getPositionFromPath(pawn.playerId, pawn.pathIndex);
    if (currentPos != null) {
      final square = boardController.getSquare(currentPos);
      square?.removePawn(pawn);
    }
    pawn.sendHome();
  }

  /// Get current position of a pawn
  Position? getPawnPosition(Pawn pawn) {
    if (pawn.isHome || pawn.pathIndex < 0) return null;
    return boardController.getPositionFromPath(pawn.playerId, pawn.pathIndex);
  }

  /// Reset all pawns to home
  void reset() {
    for (final pawn in pawns) {
      pawn.sendHome();
    }
    boardController.clearAllPawns();
  }
}
