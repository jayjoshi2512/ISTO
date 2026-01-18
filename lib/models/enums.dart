/// Core enumerations for ISTO game

/// Type of square on the board
enum SquareType {
  outer,  // Outer path squares
  inner,  // Cross interior squares
  center, // Final destination [2,2]
  home,   // Corner home bases
}

/// Current path type for pawn movement
enum PathType {
  outer,
  inner,
}

/// State of a pawn
enum PawnState {
  home,     // In home base, not yet entered
  active,   // On board (outer or inner path)
  finished, // Reached center [2,2]
}

/// Phase of a player's turn
enum TurnPhase {
  waitingForRoll,
  rolled,
  selectingPawn,
  moving,
  resolving,
  checkingExtraTurn,
  turnEnd,
}

/// Type of kill that occurred
enum KillType {
  none,
  single,
  paired,
}
