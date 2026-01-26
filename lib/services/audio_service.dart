import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio service for game sound effects
/// Uses audioplayers for cross-platform audio playback
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _initialized = false;
  double _volume = 0.8;

  // Single audio player that we reuse
  AudioPlayer? _player;
  
  // Available sound files (matching what exists in assets/sounds/)
  static const Map<String, String> _soundFiles = {
    'roll': 'sounds/roll.mp3',
    'move': 'sounds/move.mp3',
    'tap': 'sounds/tap.mp3',
    'enter': 'sounds/enter.mp3',
    'blocked': 'sounds/blocked.mp3',
  };

  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _initialized;
  double get volume => _volume;

  /// Initialize audio system
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _player = AudioPlayer();
      await _player!.setVolume(_volume);
      await _player!.setReleaseMode(ReleaseMode.stop);
      
      _initialized = true;
      debugPrint('AudioService: Initialized successfully');
    } catch (e) {
      debugPrint('AudioService: Failed to initialize: $e');
      _initialized = true; // Still mark as initialized to prevent retries
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    debugPrint('AudioService: Sound ${enabled ? "enabled" : "disabled"}');
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _player?.setVolume(_volume);
  }

  /// Dispose audio resources
  void dispose() {
    _player?.dispose();
    _player = null;
    _initialized = false;
  }

  /// Play a sound by name
  Future<void> _playSound(String name) async {
    if (!_soundEnabled) {
      debugPrint('AudioService: Sound disabled, skipping $name');
      return;
    }
    
    final soundFile = _soundFiles[name];
    if (soundFile == null) {
      debugPrint('AudioService: Unknown sound: $name');
      return;
    }
    
    try {
      // Create a new player for each sound to allow overlapping
      final player = AudioPlayer();
      await player.setVolume(_volume);
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(soundFile));
      debugPrint('AudioService: Playing $name');
      
      // Auto dispose after playback
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('AudioService: Error playing $name: $e');
    }
  }

  // ============ SOUND EFFECT METHODS ============

  /// Play dice/cowry roll sound
  Future<void> playRollSound() async {
    await _playSound('roll');
  }

  /// Play shell settle sound
  Future<void> playShellSettle() async {
    await _playSound('roll');
  }

  /// Play pawn select/tap sound
  Future<void> playPawnSelect() async {
    await _playSound('tap');
  }

  /// Play pawn move sound
  Future<void> playPawnMove() async {
    await _playSound('move');
  }

  /// Play pawn enter board sound
  Future<void> playPawnEnter() async {
    await _playSound('enter');
  }

  /// Play capture/kill sound - DRAMATIC using blocked for sharp impact
  Future<void> playCapture() async {
    await _playSound('blocked');
  }

  /// Play CHOWKA (4) or ASHTA (8) sound - celebratory roll
  Future<void> playGraceThrow() async {
    await _playSound('roll');
  }

  /// Play extra turn notification - celebratory
  Future<void> playExtraTurn() async {
    await _playSound('roll');
  }

  /// Play pawn reaching home/center - triumphant
  Future<void> playPawnFinish() async {
    await _playSound('enter');
  }

  /// Play win/victory sound - triumphant
  Future<void> playWin() async {
    await _playSound('enter');
  }

  /// Play blocked/no moves sound
  Future<void> playBlocked() async {
    await _playSound('blocked');
  }

  /// Play invalid move/error sound
  Future<void> playError() async {
    await _playSound('blocked');
  }

  /// Play turn change notification
  Future<void> playTurnChange() async {
    await _playSound('tap');
  }

  /// Play double formed sound
  Future<void> playDouble() async {
    await _playSound('move');
  }
}

/// Global audio service instance
final audioService = AudioService();
