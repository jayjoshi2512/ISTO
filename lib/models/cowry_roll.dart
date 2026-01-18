import 'dart:math';

/// Represents the result of rolling 4 cowrie shells
/// Based on authentic ISTO/Chowka Bhara scoring:
/// - 1 mouth-up → Move 1 square
/// - 2 mouth-up → Move 2 squares
/// - 3 mouth-up → Move 3 squares
/// - 4 mouth-up (CHOWKA) → Move 4 squares + extra turn
/// - 0 mouth-up (ASHTA) → Move 8 squares + extra turn
/// 
/// Entry Rule: A pawn can enter the board on 1, 4, or 8
class CowryRoll {
  final List<bool> cowries; // 4 elements, true = mouth-up

  const CowryRoll({required this.cowries});

  /// Number of cowries facing up (mouth-up)
  int get upCount => cowries.where((c) => c).length;

  /// Number of cowries facing down (mouth-down)
  int get downCount => 4 - upCount;

  /// Steps to move based on authentic scoring
  int get steps {
    switch (upCount) {
      case 0:
        return 8; // ASHTA (all down)
      case 1:
        return 1; // 1 up
      case 2:
        return 2; // 2 up
      case 3:
        return 3; // 3 up
      case 4:
        return 4; // CHOWKA (all up)
      default:
        return 0;
    }
  }

  /// Check if roll is ASHTA (0 up = 8 steps)
  bool get isAshta => upCount == 0;

  /// Check if roll is CHOWKA (4 up = 4 steps)
  bool get isChowka => upCount == 4;

  /// Legacy aliases
  bool get isISTO => isAshta;
  bool get isChamma => isChowka;
  bool get isChom => isChowka;

  /// Check if this roll grants an extra turn (Grace throw)
  /// CHOWKA (4) and ASHTA (8) grant extra turns
  bool get grantsExtraTurn => isAshta || isChowka;

  /// Check if this roll allows a pawn to enter the board
  /// ISTO allows 1, 4, or 8 to release a pawn from home
  bool get allowsEntry => steps == 1 || steps == 4 || steps == 8;

  /// Display name of the roll
  String get displayName {
    if (isAshta) return 'ASHTA';
    if (isChowka) return 'CHOWKA';
    return '$steps';
  }

  /// Description of the roll
  String get description {
    if (isAshta) return 'All 4 down - 8 steps!';
    if (isChowka) return 'All 4 up - 4 steps!';
    return '$upCount up = $steps steps';
  }

  /// Generate a random cowry roll
  factory CowryRoll.random() {
    final random = Random();
    return CowryRoll(
      cowries: List.generate(4, (_) => random.nextBool()),
    );
  }

  /// Create a specific roll (for testing)
  factory CowryRoll.withUpCount(int upCount) {
    assert(upCount >= 0 && upCount <= 4);
    final cowries = List.generate(4, (i) => i < upCount);
    return CowryRoll(cowries: cowries);
  }

  @override
  String toString() => 'CowryRoll($displayName: $steps steps)';
}
