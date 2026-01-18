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

  const MoveResult({
    this.success = true,
    this.reachedCenter = false,
    this.killedOpponent = false,
    this.killType = KillType.none,
    this.victims = const [],
    this.errorMessage,
  });

  /// Check if this result grants an extra turn
  bool get grantsExtraTurn => reachedCenter || killedOpponent;

  /// Create a failed move result
  factory MoveResult.failed(String message) => MoveResult(
        success: false,
        errorMessage: message,
      );

  /// Create a simple successful move
  factory MoveResult.moved() => const MoveResult(success: true);

  /// Create result for reaching center
  factory MoveResult.finished() => const MoveResult(
        success: true,
        reachedCenter: true,
      );

  /// Create result for a kill
  factory MoveResult.kill({
    required KillType type,
    required List<Pawn> victims,
  }) =>
      MoveResult(
        success: true,
        killedOpponent: true,
        killType: type,
        victims: victims,
      );

  @override
  String toString() =>
      'MoveResult(success: $success, center: $reachedCenter, kill: $killedOpponent)';
}
