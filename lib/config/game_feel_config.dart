import 'package:flutter/material.dart';

/// Game Feel / Juice Configuration
/// 
/// Controls the intensity and style of feedback, animations, and effects.
/// Based on research showing medium-high juice levels maximize enjoyment
/// while avoiding sensory fatigue.
/// 
/// Three profiles:
/// - Minimal: Clean, focused, low distraction
/// - Moderate (default): Balanced, satisfying feedback
/// - Rich: Full juice experience, highly sensory
class GameFeelConfig {
  // ============ FEEL PROFILE ============
  
  /// Current feel profile (0 = minimal, 1 = moderate, 2 = rich)
  static int _currentProfile = 1; // Default to moderate
  
  static int get currentProfile => _currentProfile;
  
  static void setProfile(int profile) {
    _currentProfile = profile.clamp(0, 2);
  }
  
  static String get profileName {
    switch (_currentProfile) {
      case 0: return 'Minimal';
      case 1: return 'Moderate';
      case 2: return 'Rich';
      default: return 'Moderate';
    }
  }

  // ============ INTENSITY MULTIPLIERS ============
  
  /// Animation intensity (0.5 - 1.5)
  static double get animationIntensity {
    switch (_currentProfile) {
      case 0: return 0.6;
      case 1: return 1.0;
      case 2: return 1.3;
      default: return 1.0;
    }
  }
  
  /// Glow/shadow intensity (0.3 - 1.2)
  static double get glowIntensity {
    switch (_currentProfile) {
      case 0: return 0.4;
      case 1: return 1.0;
      case 2: return 1.3;
      default: return 1.0;
    }
  }
  
  /// Screen shake intensity (0 - 1.5)
  static double get shakeIntensity {
    switch (_currentProfile) {
      case 0: return 0.0;
      case 1: return 1.0;
      case 2: return 1.4;
      default: return 1.0;
    }
  }
  
  /// Particle effect density (0.3 - 1.5)
  static double get particleIntensity {
    switch (_currentProfile) {
      case 0: return 0.3;
      case 1: return 1.0;
      case 2: return 1.5;
      default: return 1.0;
    }
  }

  // ============ PAWN SELECTION FEEL ============
  
  /// Pawn lift height on selection (pixels)
  static double get pawnLiftHeight => 6.0 * animationIntensity;
  
  /// Pawn scale on selection
  static double get pawnSelectScale => 1.0 + (0.12 * animationIntensity);
  
  /// Pawn glow radius on selection
  static double get pawnGlowRadius => 8.0 * glowIntensity;
  
  /// Pawn glow color alpha
  static int get pawnGlowAlpha => (150 * glowIntensity).toInt().clamp(0, 255);
  
  /// Pawn selection pulse speed (cycles per second)
  static double get pawnPulseSpeed => 3.0 + (animationIntensity * 1.5);
  
  /// Pawn bounce amplitude during pulse
  static double get pawnBounceAmplitude => 3.0 * animationIntensity;

  // ============ VALID MOVE HIGHLIGHTING ============
  
  /// Valid square glow radius
  static double get validSquareGlowRadius => 6.0 * glowIntensity;
  
  /// Valid square glow alpha
  static int get validSquareGlowAlpha => (80 * glowIntensity).toInt().clamp(0, 255);
  
  /// Valid square pulse duration (ms)
  static Duration get validSquarePulseDuration => 
    Duration(milliseconds: (800 / animationIntensity).toInt());
  
  /// Valid square border width
  static double get validSquareBorderWidth => 2.0 + (animationIntensity * 0.5);
  
  /// Kill target glow intensity multiplier
  static double get killTargetIntensity => 1.2 + (animationIntensity * 0.3);

  // ============ BOARD FEEL ============
  
  /// Board shadow blur radius
  static double get boardShadowBlur => 8.0 + (glowIntensity * 4.0);
  
  /// Board shadow alpha
  static int get boardShadowAlpha => (100 * glowIntensity).toInt().clamp(0, 255);
  
  /// Vignette intensity (0.0 - 0.3)
  static double get vignetteIntensity => 0.08 + (glowIntensity * 0.08);
  
  /// Ambient glow enabled
  static bool get ambientGlowEnabled => _currentProfile >= 1;
  
  /// Ambient glow intensity
  static double get ambientGlowIntensity => 0.3 + (glowIntensity * 0.2);
  
  /// Subtle board breathing animation enabled
  static bool get boardBreathingEnabled => _currentProfile >= 1;
  
  /// Board breathing speed (slower = more subtle)
  static Duration get boardBreathingDuration => 
    Duration(milliseconds: (4000 / animationIntensity).toInt());

  // ============ TURN CHANGE FEEL ============
  
  /// Turn change pulse scale
  static double get turnPulseScale => 1.0 + (0.15 * animationIntensity);
  
  /// Turn change color sweep enabled
  static bool get turnColorSweepEnabled => _currentProfile >= 1;
  
  /// Turn change duration
  static Duration get turnChangeDuration =>
    Duration(milliseconds: (400 * animationIntensity).toInt());
  
  /// Turn indicator glow radius
  static double get turnIndicatorGlow => 12.0 * glowIntensity;

  // ============ CAPTURE/IMPACT FEEL ============
  
  /// Screen shake enabled on capture
  static bool get captureShakeEnabled => _currentProfile >= 1;
  
  /// Capture shake magnitude (pixels)
  static double get captureShakeMagnitude => 6.0 * shakeIntensity;
  
  /// Capture shake duration
  static Duration get captureShakeDuration =>
    Duration(milliseconds: (200 * animationIntensity).toInt());
  
  /// Capture particle burst enabled
  static bool get captureParticlesEnabled => _currentProfile >= 2;
  
  /// Capture particle count
  static int get captureParticleCount => (8 * particleIntensity).toInt();
  
  /// Capture flash enabled
  static bool get captureFlashEnabled => _currentProfile >= 1;
  
  /// Capture flash alpha
  static int get captureFlashAlpha => (40 * glowIntensity).toInt().clamp(0, 255);
  
  /// Camera zoom on capture (slight punch-in)
  static double get captureZoomAmount => 1.0 + (0.02 * animationIntensity);

  // ============ DICE/COWRY FEEL ============
  
  /// Dice anticipation pause duration
  static Duration get diceAnticipationPause =>
    Duration(milliseconds: (250 * animationIntensity).toInt());
  
  /// Dice roll drama - how long the roll animation plays
  static Duration get diceRollDuration =>
    Duration(milliseconds: (800 + (200 * animationIntensity)).toInt());
  
  /// Dice bounce intensity
  static double get diceBounceIntensity => 0.8 + (animationIntensity * 0.4);
  
  /// Grace throw celebration intensity (CHOWKA/ASHTA)
  static double get graceThrowIntensity => 1.0 + (animationIntensity * 0.5);

  // ============ MENU/UI FEEL ============
  
  /// Button press depth (scale down)
  static double get buttonPressScale => 0.92 + (0.03 * (1 - animationIntensity));
  
  /// Button press duration
  static Duration get buttonPressDuration =>
    Duration(milliseconds: (100 / animationIntensity).toInt().clamp(50, 150));
  
  /// Panel slide distance
  static double get panelSlideDistance => 30.0 + (10.0 * animationIntensity);
  
  /// Menu transition duration
  static Duration get menuTransitionDuration =>
    Duration(milliseconds: (250 + (50 * animationIntensity)).toInt());
  
  /// Card entrance curve
  static Curve get cardEntranceCurve => 
    _currentProfile >= 1 ? Curves.easeOutBack : Curves.easeOutCubic;

  // ============ WIN CELEBRATION ============
  
  /// Win confetti count
  static int get winConfettiCount => (20 + (15 * particleIntensity)).toInt();
  
  /// Win screen shake enabled
  static bool get winShakeEnabled => _currentProfile >= 2;
  
  /// Win trophy pulse enabled
  static bool get winTrophyPulseEnabled => _currentProfile >= 1;
  
  /// Win trophy glow intensity
  static double get winTrophyGlow => 30.0 * glowIntensity;

  // ============ AMBIENT/IDLE FEEL ============
  
  /// Idle element breathing enabled (subtle scale pulses)
  static bool get idleBreathingEnabled => _currentProfile >= 1;
  
  /// Idle breathing scale range
  static double get idleBreathingScale => 0.02 * animationIntensity;
  
  /// Idle breathing duration
  static Duration get idleBreathingDuration =>
    Duration(milliseconds: (2000 / animationIntensity).toInt());
  
  /// Subtle highlight shimmer on interactive elements
  static bool get highlightShimmerEnabled => _currentProfile >= 2;

  // ============ COLORS FOR EFFECTS ============
  
  /// Selection highlight color
  static const Color selectionColor = Color(0xFFFFD700); // Gold
  
  /// Valid move color
  static const Color validMoveColor = Color(0xFF4ECCA3); // Teal
  
  /// Kill target color
  static const Color killTargetColor = Color(0xFFE85D75); // Red
  
  /// Grace throw color
  static const Color graceThrowColor = Color(0xFFFFD700); // Gold
  
  /// Success color
  static const Color successColor = Color(0xFF4ECCA3); // Teal
  
  /// Warning color  
  static const Color warningColor = Color(0xFFFF9800); // Orange
}
