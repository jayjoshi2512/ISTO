import '../models/models.dart';

/// Controls cowry shell rolling mechanics
class CowryController {
  CowryRoll? _lastRoll;

  CowryRoll? get lastRoll => _lastRoll;

  /// Roll all 4 cowries and return result
  CowryRoll roll() {
    _lastRoll = CowryRoll.random();
    return _lastRoll!;
  }

  /// Roll with a specific outcome (for testing/debugging)
  CowryRoll rollWithUpCount(int upCount) {
    _lastRoll = CowryRoll.withUpCount(upCount);
    return _lastRoll!;
  }

  /// Reset the last roll
  void reset() {
    _lastRoll = null;
  }

  /// Check if last roll allows entry
  bool get lastRollAllowsEntry => _lastRoll?.allowsEntry ?? false;

  /// Check if last roll grants extra turn
  bool get lastRollGrantsExtraTurn => _lastRoll?.grantsExtraTurn ?? false;

  /// Get steps from last roll
  int get lastRollSteps => _lastRoll?.steps ?? 0;
}
