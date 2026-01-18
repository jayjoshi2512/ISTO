/// Board configuration constants and path definitions
/// ISTO/Chowka Bhara 5×5 FULL Board Layout
/// 
/// Based on authentic rules from reference image:
/// - 5 Safe squares (X marks): 4 edge midpoints + center
/// - Players start at edge midpoints, NOT corners
/// - Outer ring: 16 squares (full perimeter)
/// - Inner ring: 8 squares (around center)
/// - Center: 1 square (HOME/finish)
/// - Total path: 25 squares
class BoardConfig {
  static const int boardSize = 5;

  /// Center square - final destination (HOME)
  static const List<int> center = [2, 2];

  /// Safe squares marked with X - cannot be captured here
  /// 4 edge midpoints (START positions) + center = 5 safe squares
  static const List<List<int>> safeSquares = [
    [0, 2], // Top middle - Player 1 START
    [2, 0], // Left middle - Player 2 START
    [4, 2], // Bottom middle - Player 0 START
    [2, 4], // Right middle - Player 3 START
    [2, 2], // CENTER (HOME)
  ];

  /// Starting positions for each player (edge midpoints)
  static const Map<int, List<int>> startPositions = {
    0: [4, 2], // Player 0 - Bottom middle
    1: [0, 2], // Player 1 - Top middle
    2: [2, 0], // Player 2 - Left middle
    3: [2, 4], // Player 3 - Right middle
  };

  /// FULL movement paths for each player
  /// Each player goes CLOCKWISE around the ENTIRE outer ring
  /// When reaching one square before their start, they enter inner ring
  /// Inner ring goes ANTI-CLOCKWISE around center
  /// Finally enters center (HOME)
  /// 
  /// Path index 0 = start position
  /// Path length = 25 (0-24)
  
  /// Player 0 (Bottom middle [4,2]) path
  /// Outer: CLOCKWISE - goes right first
  /// Inner: ANTI-CLOCKWISE
  static const List<List<int>> player0Path = [
    // Index 0: Start position
    [4, 2],
    // Outer ring CLOCKWISE (indices 1-15) - goes right first
    [4, 3], [4, 4], // Bottom-right
    [3, 4], [2, 4], [1, 4], // Right edge up
    [0, 4], // Top-right corner
    [0, 3], [0, 2], [0, 1], // Top edge left
    [0, 0], // Top-left corner
    [1, 0], [2, 0], [3, 0], // Left edge down
    [4, 0], // Bottom-left corner
    [4, 1], // One before start - enters inner
    // Inner ring ANTI-CLOCKWISE (indices 16-23)
    [3, 1], [2, 1], [1, 1], // Left inner column up
    [1, 2], [1, 3], // Top inner row right
    [2, 3], [3, 3], // Right inner column down
    [3, 2], // Bottom inner
    // Center (index 24)
    [2, 2],
  ];

  /// Player 1 (Top middle [0,2]) path
  /// Outer: CLOCKWISE - goes left first
  /// Inner: ANTI-CLOCKWISE
  static const List<List<int>> player1Path = [
    // Index 0: Start position
    [0, 2],
    // Outer ring CLOCKWISE (indices 1-15) - goes left first
    [0, 1], [0, 0], // Top-left
    [1, 0], [2, 0], [3, 0], // Left edge down
    [4, 0], // Bottom-left corner
    [4, 1], [4, 2], [4, 3], // Bottom edge right
    [4, 4], // Bottom-right corner
    [3, 4], [2, 4], [1, 4], // Right edge up
    [0, 4], // Top-right corner
    [0, 3], // One before start - enters inner
    // Inner ring ANTI-CLOCKWISE (indices 16-23)
    [1, 3], [2, 3], [3, 3], // Right inner column down
    [3, 2], [3, 1], // Bottom inner row left
    [2, 1], [1, 1], // Left inner column up
    [1, 2], // Top inner
    // Center (index 24)
    [2, 2],
  ];

  /// Player 2 (Left middle [2,0]) path
  /// Outer: CLOCKWISE - goes down first
  /// Inner: ANTI-CLOCKWISE
  static const List<List<int>> player2Path = [
    // Index 0: Start position
    [2, 0],
    // Outer ring CLOCKWISE (indices 1-15) - goes down first
    [3, 0], [4, 0], // Down to bottom-left
    [4, 1], [4, 2], [4, 3], // Bottom edge right
    [4, 4], // Bottom-right corner
    [3, 4], [2, 4], [1, 4], // Right edge up
    [0, 4], // Top-right corner
    [0, 3], [0, 2], [0, 1], // Top edge left
    [0, 0], // Top-left corner
    [1, 0], // One before start - enters inner
    // Inner ring ANTI-CLOCKWISE (indices 16-23)
    [1, 1], [1, 2], [1, 3], // Top inner row right
    [2, 3], [3, 3], // Right inner column down
    [3, 2], [3, 1], // Bottom inner row left
    [2, 1], // Left inner
    // Center (index 24)
    [2, 2],
  ];

  /// Player 3 (Right middle [2,4]) path
  /// Outer: CLOCKWISE - goes up first
  /// Inner: ANTI-CLOCKWISE
  static const List<List<int>> player3Path = [
    // Index 0: Start position
    [2, 4],
    // Outer ring CLOCKWISE (indices 1-15) - goes up first
    [1, 4], [0, 4], // Up to top-right
    [0, 3], [0, 2], [0, 1], // Top edge left
    [0, 0], // Top-left corner
    [1, 0], [2, 0], [3, 0], // Left edge down
    [4, 0], // Bottom-left corner
    [4, 1], [4, 2], [4, 3], // Bottom edge right
    [4, 4], // Bottom-right corner
    [3, 4], // One before start - enters inner
    // Inner ring ANTI-CLOCKWISE (indices 16-23)
    [3, 3], [3, 2], [3, 1], // Bottom inner row left
    [2, 1], [1, 1], // Left inner column up
    [1, 2], [1, 3], // Top inner row right
    [2, 3], // Right inner
    // Center (index 24)
    [2, 2],
  ];

  /// Get path for a specific player
  static List<List<int>> getPlayerPath(int playerId) {
    switch (playerId) {
      case 0:
        return player0Path;
      case 1:
        return player1Path;
      case 2:
        return player2Path;
      case 3:
        return player3Path;
      default:
        throw ArgumentError('Invalid player ID: $playerId');
    }
  }

  /// Check if a position is a safe square (5 total: 4 edge midpoints + center)
  static bool isSafeSquare(List<int> pos) {
    for (var safe in safeSquares) {
      if (safe[0] == pos[0] && safe[1] == pos[1]) return true;
    }
    return false;
  }

  /// Check if a position is the center
  static bool isCenter(List<int> pos) {
    return pos[0] == center[0] && pos[1] == center[1];
  }

  /// Check if a position is on the inner ring (the 8 squares around center)
  static bool isInnerPath(List<int> pos) {
    final r = pos[0];
    final c = pos[1];
    if (r == 2 && c == 2) return false; // center itself
    // Inner ring: the 8 squares directly around center
    return r >= 1 && r <= 3 && c >= 1 && c <= 3;
  }

  /// Check if a position is on the outer ring (perimeter)
  static bool isOuterPath(List<int> pos) {
    final r = pos[0];
    final c = pos[1];
    // Outer ring: edges of 5x5 board
    return r == 0 || r == 4 || c == 0 || c == 4;
  }

  /// All squares are valid in full 5x5 board
  static bool isValidSquare(int row, int col) {
    return row >= 0 && row < 5 && col >= 0 && col < 5;
  }

  /// Get all valid board squares (full 5x5 = 25 squares)
  static List<List<int>> getAllValidSquares() {
    List<List<int>> squares = [];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        squares.add([r, c]);
      }
    }
    return squares;
  }

  /// Check if position is a starting position for any player
  static int? getPlayerAtStart(List<int> pos) {
    for (var entry in startPositions.entries) {
      if (entry.value[0] == pos[0] && entry.value[1] == pos[1]) {
        return entry.key;
      }
    }
    return null;
  }
}
