import 'enums.dart';
import 'pawn.dart';

/// Result of executing a pawn move
class MoveResult {
  final bool success;
  final bool reachedCenter;
  final bool killedOpponent;
  final KillType killType;
  final List<Pawn> victims;
  final String? errorMessage;
  
  /// Path indices for animation purposes
  final int? fromPathIndex;
  final int? toPathIndex;
  final bool wasEntry;

  const MoveResult({
    this.success = true,
    this.reachedCenter = false,
    this.killedOpponent = false,
    this.killType = KillType.none,
    this.victims = const [],
    this.errorMessage,
    this.fromPathIndex,
    this.toPathIndex,
    this.wasEntry = false,
  });

  /// Check if this result grants an extra turn
  bool get grantsExtraTurn => reachedCenter || killedOpponent;

  /// Create a failed move result
  factory MoveResult.failed(String message) => MoveResult(
        success: false,
        errorMessage: message,
      );

  /// Create a simple successful move with path info
  factory MoveResult.moved({int? fromIndex, int? toIndex}) => MoveResult(
        success: true,
        fromPathIndex: fromIndex,
        toPathIndex: toIndex,
      );

  /// Create result for entering the board
  factory MoveResult.entered({bool killedOpponent = false, List<Pawn>? victims}) => MoveResult(
        success: true,
        wasEntry: true,
        killedOpponent: killedOpponent,
        killType: killedOpponent ? KillType.single : KillType.none,
        victims: victims ?? const [],
        toPathIndex: 0,
      );

  /// Create result for reaching center
  factory MoveResult.finished({int? fromIndex, int? toIndex}) => MoveResult(
        success: true,
        reachedCenter: true,
        fromPathIndex: fromIndex,
        toPathIndex: toIndex,
      );

  /// Create result for a kill
  factory MoveResult.kill({
    required KillType type,
    required List<Pawn> victims,
    int? fromIndex,
    int? toIndex,
  }) =>
      MoveResult(
        success: true,
        killedOpponent: true,
        killType: type,
        victims: victims,
        fromPathIndex: fromIndex,
        toPathIndex: toIndex,
      );

  @override
  String toString() =>
      'MoveResult(success: $success, center: $reachedCenter, kill: $killedOpponent)';
}
