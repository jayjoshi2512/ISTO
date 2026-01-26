/// Animation duration and curve configuration
/// 
/// This config controls timing for all game animations.
/// Adjust these values to tune game feel and pacing.
class AnimationConfig {
  // ============ CORE DURATIONS ============

  /// Cowry roll animation - the dramatic shell toss
  static const Duration cowryRoll = Duration(milliseconds: 900);

  /// Cowry settle after roll - satisfying landing
  static const Duration cowrySettle = Duration(milliseconds: 250);

  /// Pawn movement per square - the hop rhythm
  static const Duration pawnMovePerSquare = Duration(milliseconds: 220);

  /// Kill effect duration - dramatic capture moment
  static const Duration killEffect = Duration(milliseconds: 500);

  /// Paired kill effect (slightly longer for emphasis)
  static const Duration pairedKillEffect = Duration(milliseconds: 600);

  /// Extra turn pulse indicator
  static const Duration extraTurnPulse = Duration(milliseconds: 700);

  /// Win celebration - the climax
  static const Duration winCelebration = Duration(milliseconds: 2500);

  /// Turn transition - player switch
  static const Duration turnTransition = Duration(milliseconds: 350);

  /// Square highlight pulse - valid move indicators
  static const Duration highlightPulse = Duration(milliseconds: 500);

  /// Pawn selection glow - feedback for tap
  static const Duration pawnSelectionGlow = Duration(milliseconds: 350);

  /// Button press feedback - tactile response
  static const Duration buttonFeedback = Duration(milliseconds: 120);

  /// Menu transition - smooth overlays
  static const Duration menuTransition = Duration(milliseconds: 300);

  // ============ DRAMATIC PAUSES ============
  // These pauses create rhythm and let moments land

  /// Pause before revealing roll result (anticipation)
  static const Duration rollRevealPause = Duration(milliseconds: 350);

  /// Pause after CHOWKA/ASHTA before proceeding (celebration)
  static const Duration graceThrowPause = Duration(milliseconds: 600);

  /// Pause on capture (impact moment)
  static const Duration capturePause = Duration(milliseconds: 300);

  /// Pause when pawn reaches center (achievement)
  static const Duration centerReachPause = Duration(milliseconds: 400);

  /// Pause before turn change (breath)
  static const Duration turnChangePause = Duration(milliseconds: 200);

  // ============ DELAYS ============

  /// Delay before auto-moving when only one option
  static const Duration autoMoveDelay = Duration(milliseconds: 600);

  /// Delay between sequential moves in paired movement
  static const Duration pairedMoveDelay = Duration(milliseconds: 150);

  /// Delay before showing win screen
  static const Duration winScreenDelay = Duration(milliseconds: 600);

  /// Duration to show extra turn notification
  static const Duration extraTurnDisplayDuration = Duration(milliseconds: 2000);

  /// Duration to show capture notification
  static const Duration captureDisplayDuration = Duration(milliseconds: 1800);

  /// Duration to show no moves notification
  static const Duration noMovesDisplayDuration = Duration(milliseconds: 1500);

  // ============ REPEAT COUNTS ============

  /// Number of times cowry flips during roll
  static const int cowryFlipCount = 8;

  /// Extra turn pulse repeat count
  static const int extraTurnPulseCount = 3;

  // ============ EFFECT INTENSITIES ============

  /// Screen shake intensity on capture (pixels)
  static const double captureShakeIntensity = 8.0;

  /// Screen shake duration on capture
  static const Duration captureShakeDuration = Duration(milliseconds: 300);

  /// Pawn hop height (relative to pawn size)
  static const double pawnHopHeight = 0.35;

  /// Pawn landing squash amount (scale factor)
  static const double pawnLandingSquash = 0.85;

  /// Grace throw glow intensity (alpha 0-255)
  static const int graceThrowGlowIntensity = 180;
}
