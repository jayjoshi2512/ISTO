import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio service using a **pooled** player architecture.
///
/// One [AudioPlayer] is pre-created per sound key during [initialize].
/// Calling a play method stops any current playback of that same sound
/// and replays it instantly — no overlapping of the same clip, no
/// expensive player creation at runtime.
///
/// Different sound keys CAN overlap (e.g. cowry_roll + pawn_move).
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _initialized = false;
  double _volume = 0.8;

  /// One AudioPlayer per sound key — pre-warmed for instant replay.
  final Map<String, AudioPlayer> _pool = {};

  // Available sound files (matching assets/sounds/)
  static const Map<String, String> _soundFiles = {
    'cowry_roll': 'sounds/cowery_roll.mp3',
    'pawn_move': 'sounds/pawn_move.mp3',
    'tap': 'sounds/tap.mp3',
    'pawn_enter': 'sounds/pawn_enter_board.mp3',
    'pawn_capture': 'sounds/pawn_captures.mp3',
    'safe_home': 'sounds/pawn_reach_at_safe_home.mp3',
    'reach_center': 'sounds/pawn_reach_center.mp3',
    'isto_chome': 'sounds/for_isto_chome.mp3',
  };

  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _initialized;
  double get volume => _volume;

  /// Pre-warm one [AudioPlayer] per sound so first play is instant.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      for (final entry in _soundFiles.entries) {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(_volume);
        _pool[entry.key] = player;
      }
      _initialized = true;
      debugPrint('AudioService: Pool warmed with ${_pool.length} players');
    } catch (e) {
      debugPrint('AudioService: Init error: $e');
      _initialized = true;
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) stopAll();
    debugPrint('AudioService: Sound ${enabled ? "enabled" : "disabled"}');
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    for (final p in _pool.values) {
      p.setVolume(_volume);
    }
  }

  /// Stop every active player.
  void stopAll() {
    for (final p in _pool.values) {
      p.stop();
    }
  }

  /// Dispose all pooled players.
  void dispose() {
    for (final p in _pool.values) {
      p.dispose();
    }
    _pool.clear();
    _initialized = false;
  }

  /// Core playback — stops previous instance of [name], then replays.
  /// Fully fire-and-forget; callers never need to await.
  void _playSound(String name) {
    if (!_soundEnabled) return;
    final file = _soundFiles[name];
    if (file == null) return;

    var player = _pool[name];
    if (player == null) {
      // Pool wasn't warmed — create on demand
      player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      player.setVolume(_volume);
      _pool[name] = player;
    }

    // Stop current playback (if any) then replay
    player
        .stop()
        .then((_) {
          player!.play(AssetSource(file));
        })
        .catchError((e) {
          debugPrint('AudioService: play error ($name): $e');
        });
  }

  // ============ FIRE-AND-FORGET SOUND METHODS ============

  void playRollSound() => _playSound('cowry_roll');
  void playPawnSelect() => _playSound('tap');
  void playPawnMove() => _playSound('pawn_move');
  void playPawnEnter() => _playSound('pawn_enter');
  void playCapture() => _playSound('pawn_capture');
  void playGraceThrow() => _playSound('isto_chome');
  void playSafeHome() => _playSound('safe_home');
  void playPawnFinish() => _playSound('reach_center');
  void playWin() => _playSound('reach_center');
  void playBlocked() => _playSound('tap');
  void playError() => _playSound('tap');
}

/// Global audio service instance
final audioService = AudioService();
