/// Animation duration and curve configuration
class AnimationConfig {
  // ============ DURATIONS ============

  /// Cowry roll animation
  static const Duration cowryRoll = Duration(milliseconds: 800);

  /// Cowry settle after roll
  static const Duration cowrySettle = Duration(milliseconds: 200);

  /// Pawn movement per square
  static const Duration pawnMovePerSquare = Duration(milliseconds: 250);

  /// Kill effect duration
  static const Duration killEffect = Duration(milliseconds: 400);

  /// Paired kill effect (slightly longer)
  static const Duration pairedKillEffect = Duration(milliseconds: 500);

  /// Extra turn pulse indicator
  static const Duration extraTurnPulse = Duration(milliseconds: 600);

  /// Win celebration
  static const Duration winCelebration = Duration(milliseconds: 2000);

  /// Turn transition
  static const Duration turnTransition = Duration(milliseconds: 300);

  /// Square highlight pulse
  static const Duration highlightPulse = Duration(milliseconds: 400);

  /// Pawn selection glow
  static const Duration pawnSelectionGlow = Duration(milliseconds: 300);

  /// Button press feedback
  static const Duration buttonFeedback = Duration(milliseconds: 100);

  /// Menu transition
  static const Duration menuTransition = Duration(milliseconds: 250);

  // ============ DELAYS ============

  /// Delay before auto-moving when only one option
  static const Duration autoMoveDelay = Duration(milliseconds: 500);

  /// Delay between sequential moves in paired movement
  static const Duration pairedMoveDelay = Duration(milliseconds: 100);

  /// Delay before showing win screen
  static const Duration winScreenDelay = Duration(milliseconds: 500);

  // ============ REPEAT COUNTS ============

  /// Number of times cowry flips during roll
  static const int cowryFlipCount = 6;

  /// Extra turn pulse repeat count
  static const int extraTurnPulseCount = 2;
}
