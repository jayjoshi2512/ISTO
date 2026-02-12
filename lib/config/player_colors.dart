import 'dart:ui';

/// UNIFIED Player Colors - Single Source of Truth
/// Rich jewel-toned colors inspired by Indian textiles and gemstones 
class PlayerColors {
  // ============ PLAYER COLORS (Consistent across all UI) ============
  
  /// Player 0 - Bottom position (Ruby Red — like a garnet gemstone)
  static const Color player0 = Color(0xFFD94B4B);
  
  /// Player 1 - Top position (Emerald Green — deep lush green)
  static const Color player1 = Color(0xFF27AE60);
  
  /// Player 2 - Left position (Saffron Gold — warm amber-gold)
  static const Color player2 = Color(0xFFE6A817);
  
  /// Player 3 - Right position (Royal Blue — deep sapphire)
  static const Color player3 = Color(0xFF3498DB);
  
  /// List of all player colors for indexed access
  static const List<Color> colors = [
    player0,
    player1,
    player2,
    player3,
  ];
  
  /// Player names corresponding to colors
  static const List<String> names = [
    'Ruby',
    'Emerald', 
    'Saffron',
    'Sapphire',
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
      _clamp(color.r.toInt() + 45),
      _clamp(color.g.toInt() + 45),
      _clamp(color.b.toInt() + 45),
    );
  }
  
  /// Get darker version of player color (for shadows)
  static Color getDarkColor(int playerId) {
    final color = getColor(playerId);
    return Color.fromARGB(
      color.a.toInt(),
      _clamp(color.r.toInt() - 50),
      _clamp(color.g.toInt() - 50),
      _clamp(color.b.toInt() - 50),
    );
  }
  
  static int _clamp(int value) => value.clamp(0, 255);
}
