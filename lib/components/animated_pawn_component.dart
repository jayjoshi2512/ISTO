import '../models/models.dart';

/// Manages individual pawn animation state
/// Used by BoardComponent for more complex multi-step animations
class PawnAnimationController {
  final Map<String, PawnAnimState> _states = {};

  void startMoveAnimation(Pawn pawn, List<List<int>> pathPositions) {
    _states[pawn.id] = PawnAnimState(
      pawnId: pawn.id,
      pathPositions: pathPositions,
      type: PawnAnimType.move,
    );
  }

  void startKillAnimation(Pawn pawn) {
    _states[pawn.id] = PawnAnimState(
      pawnId: pawn.id,
      pathPositions: [],
      type: PawnAnimType.kill,
    );
  }

  void startFinishAnimation(Pawn pawn) {
    _states[pawn.id] = PawnAnimState(
      pawnId: pawn.id,
      pathPositions: [],
      type: PawnAnimType.finish,
    );
  }

  void update(double dt) {
    final toRemove = <String>[];
    for (final entry in _states.entries) {
      entry.value.progress += dt * 3;
      if (entry.value.progress >= 1.0) {
        toRemove.add(entry.key);
      }
    }
    for (final key in toRemove) {
      _states.remove(key);
    }
  }

  PawnAnimState? getState(String pawnId) => _states[pawnId];
  bool hasAnimation(String pawnId) => _states.containsKey(pawnId);
  void clear() => _states.clear();
}

enum PawnAnimType { move, kill, finish, enter }

class PawnAnimState {
  final String pawnId;
  final List<List<int>> pathPositions;
  final PawnAnimType type;
  double progress = 0;

  PawnAnimState({
    required this.pawnId,
    required this.pathPositions,
    required this.type,
  });
}
