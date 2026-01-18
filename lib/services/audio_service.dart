import 'dart:async';
import 'package:flutter/foundation.dart';

/// Audio service for game sound effects
/// Uses tone synthesis for cross-platform compatibility
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _initialized = false;

  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _initialized;

  /// Initialize audio system
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _initialized = true;
      debugPrint('AudioService: Initialized (simulated sounds for web)');
    } catch (e) {
      debugPrint('AudioService: Failed to initialize: $e');
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Dispose audio resources
  void dispose() {
    _initialized = false;
  }

  // ============ SOUND EFFECT METHODS ============
  // These will be called to trigger sounds
  // For web, we'll use visual feedback instead

  /// Play dice/cowry roll sound
  Future<void> playRollSound() async {
    if (!_soundEnabled) return;
    // Simulated - would play a shell rattling sound
    _logSound('ROLL - shells rattling');
  }

  /// Play shell settle sound
  Future<void> playShellSettle() async {
    if (!_soundEnabled) return;
    _logSound('SETTLE - shells landing');
  }

  /// Play pawn select/tap sound
  Future<void> playPawnSelect() async {
    if (!_soundEnabled) return;
    _logSound('TAP - pawn selected');
  }

  /// Play pawn move sound
  Future<void> playPawnMove() async {
    if (!_soundEnabled) return;
    _logSound('MOVE - pawn sliding');
  }

  /// Play pawn enter board sound
  Future<void> playPawnEnter() async {
    if (!_soundEnabled) return;
    _logSound('ENTER - pawn placed on board');
  }

  /// Play capture/kill sound - dramatic
  Future<void> playCapture() async {
    if (!_soundEnabled) return;
    _logSound('CAPTURE! - opponent taken');
  }

  /// Play CHOWKA (4) or ASHTA (8) sound - victory fanfare
  Future<void> playGraceThrow() async {
    if (!_soundEnabled) return;
    _logSound('GRACE! - Chowka/Ashta rolled');
  }

  /// Play extra turn notification
  Future<void> playExtraTurn() async {
    if (!_soundEnabled) return;
    _logSound('EXTRA TURN - bonus throw');
  }

  /// Play pawn reaching home/center
  Future<void> playPawnFinish() async {
    if (!_soundEnabled) return;
    _logSound('HOME! - pawn finished');
  }

  /// Play win/victory sound
  Future<void> playWin() async {
    if (!_soundEnabled) return;
    _logSound('VICTORY! - player wins');
  }

  /// Play blocked/no moves sound
  Future<void> playBlocked() async {
    if (!_soundEnabled) return;
    _logSound('BLOCKED - no valid moves');
  }

  /// Play invalid move/error sound
  Future<void> playError() async {
    if (!_soundEnabled) return;
    _logSound('ERROR - invalid action');
  }

  /// Play turn change notification
  Future<void> playTurnChange() async {
    if (!_soundEnabled) return;
    _logSound('TURN - next player');
  }

  /// Play double formed sound
  Future<void> playDouble() async {
    if (!_soundEnabled) return;
    _logSound('DOUBLE - pawns paired');
  }

  void _logSound(String soundName) {
    if (kDebugMode) {
      debugPrint('🔊 Sound: $soundName');
    }
  }
}

/// Global audio service instance
final audioService = AudioService();
