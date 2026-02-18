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
        pawns.add(
          Pawn(
            id: Pawn.createId(p, i),
            playerId: p,
            pawnIndex: i,
            state: PawnState.home,
            pathIndex: -1,
            currentPath: PathType.outer,
          ),
        );
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
      return MoveResult.entered(
        killedOpponent: true,
        victims: killResult.victims,
        victimPathIndices: killResult.victimPathIndices,
      );
    }

    return MoveResult.entered();
  }

  /// Move a pawn by given steps
  MoveResult movePawn(Pawn pawn, int steps, {int attackerCount = 1}) {
    if (!pawn.isActive) {
      return MoveResult.failed('Pawn is not active');
    }

    final fromIndex = pawn.pathIndex; // Save for animation
    final newIndex = pawn.pathIndex + steps;
    final pathLength = boardController.getPathLength(pawn.playerId);

    // Check if exceeds path
    if (newIndex > pathLength - 1) {
      return MoveResult.failed('Move exceeds path');
    }

    // Get current and new positions
    final currentPos = boardController.getPositionFromPath(
      pawn.playerId,
      pawn.pathIndex,
    );
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
      return MoveResult.finished(fromIndex: fromIndex, toIndex: newIndex);
    }

    // Check for kills
    final killResult = _resolveCollision(
      pawn,
      destSquare,
      attackerCount: attackerCount,
    );

    // Place pawn on destination
    destSquare.addPawn(pawn);

    if (killResult.killedOpponent) {
      return MoveResult.kill(
        type: killResult.killType,
        victims: killResult.victims,
        fromIndex: fromIndex,
        toIndex: newIndex,
        victimPathIndices: killResult.victimPathIndices,
      );
    }

    return MoveResult.moved(fromIndex: fromIndex, toIndex: newIndex);
  }

  /// Move multiple stacked pawns together
  MoveResult moveStackedPawns(List<Pawn> stackedPawns, int steps) {
    if (stackedPawns.isEmpty) {
      return MoveResult.failed('No pawns to move');
    }

    // All pawns should be at the same position and active
    final firstPawn = stackedPawns.first;
    if (!firstPawn.isActive) {
      return MoveResult.failed('Pawns are not active');
    }

    final fromIndex = firstPawn.pathIndex;
    final newIndex = firstPawn.pathIndex + steps;
    final pathLength = boardController.getPathLength(firstPawn.playerId);

    // Check if exceeds path
    if (newIndex > pathLength - 1) {
      return MoveResult.failed('Move exceeds path');
    }

    // Get current and new positions
    final currentPos = boardController.getPositionFromPath(
      firstPawn.playerId,
      firstPawn.pathIndex,
    );
    final newPos = boardController.getPositionFromPath(
      firstPawn.playerId,
      newIndex,
    );

    if (currentPos == null || newPos == null) {
      return MoveResult.failed('Invalid positions');
    }

    // Remove all stacked pawns from current square
    final currentSquare = boardController.getSquare(currentPos);
    for (final pawn in stackedPawns) {
      currentSquare?.removePawn(pawn);
      // Update pawn positions
      pawn.pathIndex = newIndex;

      // Update path type based on position
      final pathPos = boardController.playerPaths[pawn.playerId]![newIndex];
      if (BoardConfig.isInnerPath(pathPos) || BoardConfig.isCenter(pathPos)) {
        pawn.currentPath = PathType.inner;
      }
    }

    // Get destination square
    final destSquare = boardController.getSquare(newPos);
    if (destSquare == null) {
      return MoveResult.failed('Destination square not found');
    }

    // Check if reached center - all pawns finish
    if (destSquare.type == SquareType.center) {
      for (final pawn in stackedPawns) {
        pawn.finish();
        destSquare.addPawn(pawn);
      }
      return MoveResult.finished(fromIndex: fromIndex, toIndex: newIndex);
    }

    // Check for kills - attackerCount = number of stacked pawns
    final killResult = _resolveCollision(
      firstPawn,
      destSquare,
      attackerCount: stackedPawns.length,
    );

    // Place all pawns on destination
    for (final pawn in stackedPawns) {
      destSquare.addPawn(pawn);
    }

    if (killResult.killedOpponent) {
      return MoveResult.kill(
        type: killResult.killType,
        victims: killResult.victims,
        fromIndex: fromIndex,
        toIndex: newIndex,
        victimPathIndices: killResult.victimPathIndices,
      );
    }

    return MoveResult.moved(fromIndex: fromIndex, toIndex: newIndex);
  }

  /// Resolve collision/kill at destination square
  ///
  /// AUTHENTIC ISTO RULES:
  /// - Safe squares (corners + center): NO kills allowed
  /// - Killing grants EXTRA TURN
  /// - Equal numbers can kill equal numbers (2v2, 3v3, etc.)
  /// - Cannot kill if attacker has fewer pawns than defender
  MoveResult _resolveCollision(
    Pawn attacker,
    Square target, {
    int attackerCount = 1,
  }) {
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

    // ISTO RULE: Equal numbers can kill equal numbers
    // Check if enemies are all same player (forming a stack)
    final samePlayer = enemies.every((e) => e.playerId == enemies[0].playerId);
    if (!samePlayer) {
      // Mixed enemy pawns - shouldn't happen, but treat as multi-kill if possible
      return MoveResult.moved();
    }

    final defenderCount = enemies.length;

    // ISTO RULE: Can only kill if attacker count >= defender count
    // 1 can kill 1, 2 can kill 2, 2 can kill 1, but 1 cannot kill 2
    if (attackerCount < defenderCount) {
      // Cannot kill - not enough attackers
      return MoveResult.moved();
    }

    // Kill all enemy pawns on this square if equal or more attackers
    if (attackerCount >= defenderCount) {
      // Save victim path indices BEFORE sending home (for retreat animation)
      final victimPaths = <String, int>{};
      for (final enemy in enemies) {
        victimPaths[enemy.id] = enemy.pathIndex;
      }

      for (final enemy in enemies) {
        _sendPawnHome(enemy, target);
      }

      final killType = enemies.length > 1 ? KillType.paired : KillType.single;
      return MoveResult.kill(
        type: killType,
        victims: enemies,
        victimPathIndices: victimPaths,
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
    final currentPos = boardController.getPositionFromPath(
      pawn.playerId,
      pawn.pathIndex,
    );
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
