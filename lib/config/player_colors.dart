import 'dart:ui';

/// UNIFIED Player Colors - Single Source of Truth
/// Use this class everywhere for player colors to ensure consistency
class PlayerColors {
  // ============ PLAYER COLORS (Consistent across all UI) ============
  
  /// Player 0 - Bottom position (Coral Red)
  static const Color player0 = Color(0xFFE57373);
  
  /// Player 1 - Top position (Green)
  static const Color player1 = Color(0xFF81C784);
  
  /// Player 2 - Left position (Yellow/Amber)
  static const Color player2 = Color(0xFFFFD54F);
  
  /// Player 3 - Right position (Blue)
  static const Color player3 = Color(0xFF64B5F6);
  
  /// List of all player colors for indexed access
  static const List<Color> colors = [
    player0,
    player1,
    player2,
    player3,
  ];
  
  /// Player names corresponding to colors
  static const List<String> names = [
    'Red',
    'Green', 
    'Yellow',
    'Blue',
  ];
  
  /// Get color for player by ID (0-3)
  static Color getColor(int playerId) {
    if (playerId >= 0 && playerId < colors.length) {
      return colors[playerId];
    }
    return player0;
  }
  
  /// Get name for player by ID (0-3)
  static String getName(int playerId) {
    if (playerId >= 0 && playerId < names.length) {
      return names[playerId];
    }
    return 'Player ${playerId + 1}';
  }
  
  /// Get lighter version of player color (for highlights)
  static Color getLightColor(int playerId) {
    final color = getColor(playerId);
    return Color.fromARGB(
      color.a.toInt(),
      _clamp(color.r.toInt() + 40),
      _clamp(color.g.toInt() + 40),
      _clamp(color.b.toInt() + 40),
    );
  }
  
  /// Get darker version of player color (for shadows)
  static Color getDarkColor(int playerId) {
    final color = getColor(playerId);
    return Color.fromARGB(
      color.a.toInt(),
      _clamp(color.r.toInt() - 40),
      _clamp(color.g.toInt() - 40),
      _clamp(color.b.toInt() - 40),
    );
  }
  
  static int _clamp(int value) => value.clamp(0, 255);
}
