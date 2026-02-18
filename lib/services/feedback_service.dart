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
  // Sound fires FIRST (instant), then haptic (non-blocking).
  // All methods are fire-and-forget — no async chains that delay sound.

  /// Cowry roll sound
  void onRoll() {
    _audio.playRollSound();
    mediumTap();
  }

  /// CHOWKA (4) / ASHTA (8) grace throw
  void onGraceThrow() {
    _audio.playGraceThrow();
    heavyTap();
  }

  /// Pawn selected
  void onPawnSelect() {
    _audio.playPawnSelect();
    lightTap();
  }

  /// Pawn hop sound (called per hop by animation)
  void onPawnMove() {
    _audio.playPawnMove();
    selectionClick();
  }

  /// Pawn enters the board from home
  void onPawnEnter() {
    _audio.playPawnEnter();
    mediumTap();
  }

  /// Opponent captured
  void onCapture() {
    _audio.playCapture();
    heavyTap();
  }

  /// Pawn reaches a safe square
  void onSafeHome() {
    _audio.playSafeHome();
    mediumTap();
  }

  /// Pawn reaches center (finished)
  void onPawnFinish() {
    _audio.playPawnFinish();
    heavyTap();
  }

  /// Player wins the game
  void onWin() {
    _audio.playWin();
    heavyTap();
  }

  /// Turn changes (haptic only — no jarring sound every turn)
  void onTurnStart() {
    selectionClick();
  }

  /// Extra turn granted (haptic only — grace throw sound already played)
  void onExtraTurn() {
    mediumTap();
  }

  /// Invalid move attempt
  void onInvalidMove() {
    _audio.playError();
    vibrate();
  }

  /// No valid moves available
  void onNoMoves() {
    _audio.playBlocked();
    lightTap();
  }
}

/// Global instance for easy access
final feedbackService = FeedbackService();
