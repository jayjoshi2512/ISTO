import '../config/board_config.dart';
import '../models/models.dart';

/// Controls board state, path validation, and square management
class BoardController {
  final Map<String, Square> squares = {};
  late final Map<int, List<List<int>>> playerPaths;

  BoardController() {
    _initPlayerPaths();
    _initBoard();
  }

  void _initPlayerPaths() {
    playerPaths = {
      0: BoardConfig.getPlayerPath(0),
      1: BoardConfig.getPlayerPath(1),
      2: BoardConfig.getPlayerPath(2),
      3: BoardConfig.getPlayerPath(3),
    };
  }

  void _initBoard() {
    for (int r = 0; r < BoardConfig.boardSize; r++) {
      for (int c = 0; c < BoardConfig.boardSize; c++) {
        if (BoardConfig.isValidSquare(r, c)) {
          final pos = Position(r, c);
          squares[pos.id] = Square(position: pos, type: _getSquareType(r, c));
        }
      }
    }
  }

  SquareType _getSquareType(int r, int c) {
    if (r == 2 && c == 2) return SquareType.center;
    if (BoardConfig.isInnerPath([r, c])) return SquareType.inner;
    return SquareType.outer;
  }

  /// Get square at position
  Square? getSquare(Position pos) => squares[pos.id];

  /// Get square from coordinates
  Square? getSquareAt(int row, int col) => squares['$row,$col'];

  /// Get square from path position
  Square? getSquareFromPath(int playerId, int pathIndex) {
    final path = playerPaths[playerId];
    if (path == null || pathIndex < 0 || pathIndex >= path.length) {
      return null;
    }
    final pos = path[pathIndex];
    return getSquareAt(pos[0], pos[1]);
  }

  /// Get position from path index
  Position? getPositionFromPath(int playerId, int pathIndex) {
    final path = playerPaths[playerId];
    if (path == null || pathIndex < 0 || pathIndex >= path.length) {
      return null;
    }
    return Position.fromList(path[pathIndex]);
  }

  /// Get path length for a player
  int getPathLength(int playerId) => playerPaths[playerId]?.length ?? 0;

  /// Check if path index is at center (destination)
  bool isAtCenter(int playerId, int pathIndex) {
    final path = playerPaths[playerId];
    if (path == null) return false;
    return pathIndex == path.length - 1;
  }

  /// Check if a move would exceed the path
  bool wouldExceedPath(int playerId, int currentIndex, int steps) {
    final pathLength = getPathLength(playerId);
    return currentIndex + steps >= pathLength;
  }

  /// Check if a move lands exactly on center
  bool wouldLandOnCenter(int playerId, int currentIndex, int steps) {
    final pathLength = getPathLength(playerId);
    return currentIndex + steps == pathLength - 1;
  }

  /// Get all pawns that can make a valid move
  /// hasCaptured: whether this player has made at least one capture (for inner ring entry)
  List<Pawn> getValidMoves(
    int playerId,
    int steps,
    List<Pawn> allPawns,
    bool allowsEntry, [
    bool hasCaptured = true,
  ]) {
    final playerPawns = allPawns.where((p) => p.playerId == playerId).toList();
    final validPawns = <Pawn>[];
    final addedIds = <String>{};

    for (final pawn in playerPawns) {
      if (addedIds.contains(pawn.id)) continue;
      if (canPawnMove(pawn, steps, allPawns, allowsEntry, hasCaptured)) {
        validPawns.add(pawn);
        addedIds.add(pawn.id);
      } else if (pawn.isActive && !pawn.isFinished) {
        // Also check if this pawn could move as part of a stacked-split.
        // E.g. 2 stacked pawns, roll=2, each moves 1 step to center.
        final pos = getPawnPosition(pawn, allPawns);
        if (pos != null) {
          final square = getSquare(pos);
          if (square != null) {
            final stackCount = square.getFriendlyPawns(pawn.playerId).length;
            if (stackCount > 1 && steps >= stackCount) {
              final splitSteps = steps ~/ stackCount;
              if (canPawnMove(
                pawn,
                splitSteps,
                allPawns,
                allowsEntry,
                hasCaptured,
              )) {
                validPawns.add(pawn);
                addedIds.add(pawn.id);
              }
            }
          }
        }
      }
    }

    return validPawns;
  }

  /// Get a pawn's current board position
  Position? getPawnPosition(Pawn pawn, List<Pawn> allPawns) {
    if (!pawn.isActive) return null;
    final path = playerPaths[pawn.playerId];
    if (path == null || pawn.pathIndex < 0 || pawn.pathIndex >= path.length) {
      return null;
    }
    final coords = path[pawn.pathIndex];
    return Position(coords[0], coords[1]);
  }

  /// Check if a specific pawn can move
  /// hasCaptured: whether this player has made at least one capture (for inner ring entry)
  bool canPawnMove(
    Pawn pawn,
    int steps,
    List<Pawn> allPawns,
    bool allowsEntry, [
    bool hasCaptured = true,
  ]) {
    // Finished pawns can't move
    if (pawn.isFinished) return false;

    // Home pawns can only enter on 1, 4, or 8 (allowsEntry)
    if (pawn.isHome) {
      return allowsEntry;
    }

    // Active pawns
    final newIndex = pawn.pathIndex + steps;
    final pathLength = getPathLength(pawn.playerId);

    // Can't exceed path (must land exactly on center)
    if (newIndex > pathLength - 1) return false;

    // Check if move would enter inner ring
    final destPos = playerPaths[pawn.playerId]![newIndex];
    final wouldEnterInner =
        BoardConfig.isInnerPath(destPos) || BoardConfig.isCenter(destPos);

    // ISTO RULE: Must capture at least one opponent before entering inner ring
    if (wouldEnterInner && !hasCaptured) {
      // Check if pawn is currently on outer path
      final currentPos = playerPaths[pawn.playerId]![pawn.pathIndex];
      final currentlyOnOuter = BoardConfig.isOuterPath(currentPos);
      if (currentlyOnOuter) {
        return false; // Can't enter inner without a capture
      }
    }

    // Check if destination is blocked by own pawn (outer path only, NOT safe squares)
    final destSquare = getSquareFromPath(pawn.playerId, newIndex);
    if (destSquare == null) return false;

    if (destSquare.type == SquareType.outer) {
      // ISTO RULE: Can stack multiple pawns on SAFE squares (starting positions)
      final destPos = playerPaths[pawn.playerId]![newIndex];
      final isSafe = BoardConfig.isSafeSquare(destPos);

      if (!isSafe) {
        // Non-safe outer path: can't land on own pawn
        final friendlyPawns = destSquare.getFriendlyPawns(pawn.playerId);
        if (friendlyPawns.isNotEmpty) return false;
      }
      // Safe squares: stacking allowed - no block
    }

    return true;
  }

  /// Place pawn on board
  void placePawn(Pawn pawn, Position pos) {
    final square = getSquare(pos);
    if (square != null) {
      square.addPawn(pawn);
    }
  }

  /// Remove pawn from current square
  void removePawn(Pawn pawn, Position pos) {
    final square = getSquare(pos);
    if (square != null) {
      square.removePawn(pawn);
    }
  }

  /// Clear all pawns from board
  void clearAllPawns() {
    for (final square in squares.values) {
      square.clearPawns();
    }
  }

  /// Reset board to initial state
  void reset() {
    clearAllPawns();
  }
}
