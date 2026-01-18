import 'enums.dart';

/// Represents a player's pawn
class Pawn {
  final String id;
  final int playerId;
  final int pawnIndex; // 0-3 for each player
  
  PawnState state;
  int pathIndex;
  PathType currentPath;

  Pawn({
    required this.id,
    required this.playerId,
    required this.pawnIndex,
    this.state = PawnState.home,
    this.pathIndex = -1,
    this.currentPath = PathType.outer,
  });

  bool get isHome => state == PawnState.home;
  bool get isActive => state == PawnState.active;
  bool get isFinished => state == PawnState.finished;

  /// Create pawn ID from player and index
  static String createId(int playerId, int pawnIndex) => 'P${playerId}_$pawnIndex';

  /// Reset pawn to home state
  void sendHome() {
    state = PawnState.home;
    pathIndex = -1;
    currentPath = PathType.outer;
  }

  /// Enter the board at starting position
  void enterBoard() {
    state = PawnState.active;
    pathIndex = 0;
    currentPath = PathType.outer;
  }

  /// Mark pawn as finished (reached center)
  void finish() {
    state = PawnState.finished;
  }

  /// Copy pawn with optional overrides
  Pawn copyWith({
    PawnState? state,
    int? pathIndex,
    PathType? currentPath,
  }) {
    return Pawn(
      id: id,
      playerId: playerId,
      pawnIndex: pawnIndex,
      state: state ?? this.state,
      pathIndex: pathIndex ?? this.pathIndex,
      currentPath: currentPath ?? this.currentPath,
    );
  }

  @override
  String toString() => 'Pawn($id, $state, pathIndex: $pathIndex)';
}
