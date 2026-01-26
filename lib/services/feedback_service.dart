import 'package:flutter/services.dart';

import 'audio_service.dart';

/// Service for haptic feedback and sound effects
/// Provides tactile and audio feedback for game events
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  bool _hapticsEnabled = true;
  bool _soundEnabled = true;
  final AudioService _audio = audioService;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundEnabled => _soundEnabled;

  /// Initialize the feedback service
  Future<void> initialize() async {
    await _audio.initialize();
  }

  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _audio.setSoundEnabled(enabled);
  }

  /// Light haptic feedback - for UI interactions
  Future<void> lightTap() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback - for pawn selection
  Future<void> mediumTap() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback - for captures/kills
  Future<void> heavyTap() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection changed feedback
  Future<void> selectionClick() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for special events
  Future<void> vibrate() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.vibrate();
  }

  // === Game Event Feedback ===

  /// Called when cowries are rolled
  Future<void> onRoll() async {
    await mediumTap();
    await _audio.playRollSound();
  }

  /// Called when rolling CHOWKA (4) or ASHTA (8) - GRACE THROW CELEBRATION
  Future<void> onGraceThrow() async {
    await heavyTap();
    await _audio.playGraceThrow();
    // Triple-tap for emphasis on this celebratory moment
    await Future.delayed(const Duration(milliseconds: 80));
    await mediumTap();
    await Future.delayed(const Duration(milliseconds: 80));
    await mediumTap();
  }

  /// Called when a pawn is selected
  Future<void> onPawnSelect() async {
    await lightTap();
    await _audio.playPawnSelect();
  }

  /// Called when a pawn moves
  Future<void> onPawnMove() async {
    await selectionClick();
    await _audio.playPawnMove();
  }

  /// Called when a pawn enters the board
  Future<void> onPawnEnter() async {
    await mediumTap();
    await _audio.playPawnEnter();
  }

  /// Called when an opponent pawn is captured - DRAMATIC
  Future<void> onCapture() async {
    await heavyTap();
    await _audio.playCapture();
    await Future.delayed(const Duration(milliseconds: 80));
    await heavyTap();
  }

  /// Called when a pawn reaches HOME (center)
  Future<void> onPawnFinish() async {
    await heavyTap();
    await _audio.playPawnFinish();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumTap();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightTap();
  }

  /// Called when player wins
  Future<void> onWin() async {
    await _audio.playWin();
    for (int i = 0; i < 3; i++) {
      await heavyTap();
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  /// Called when turn changes to this player
  Future<void> onTurnStart() async {
    await selectionClick();
    await _audio.playTurnChange();
  }

  /// Called when extra turn is granted - CELEBRATORY
  Future<void> onExtraTurn() async {
    await mediumTap();
    await _audio.playExtraTurn();
    // Two taps to celebrate getting another turn
    await Future.delayed(const Duration(milliseconds: 50));
    await mediumTap();
  }

  /// Called on invalid move attempt
  Future<void> onInvalidMove() async {
    await vibrate();
    await _audio.playError();
  }

  /// Called when no valid moves available
  Future<void> onNoMoves() async {
    await lightTap();
    await _audio.playBlocked();
  }
}

/// Global instance for easy access
final feedbackService = FeedbackService();
