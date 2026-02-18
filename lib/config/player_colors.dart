import 'dart:ui';

import '../theme/isto_tokens.dart';

/// UNIFIED Player Colors - Single Source of Truth
/// Slate & Persimmon palette: Persimmon, Jade, Steel Blue, Amber
class PlayerColors {
  // ============ PLAYER COLORS (Consistent across all UI) ============

  /// Player 0 - Persimmon (primary accent)
  static const Color player0 = Color(0xFFFF5733);

  /// Player 1 - Jade Green (supporting accent)
  static const Color player1 = Color(0xFF00A86B);

  /// Player 2 - Steel Blue (cool contrast)
  static const Color player2 = Color(0xFF4A90D9);

  /// Player 3 - Amber (warm gold)
  static const Color player3 = Color(0xFFE8A44A);

  /// List of all player colors for indexed access
  static const List<Color> colors = [player0, player1, player2, player3];

  /// Player names corresponding to colors
  static const List<String> names = ['Persimmon', 'Jade', 'Steel', 'Amber'];

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

  /// Get lighter/glow version of player color
  static Color getLightColor(int playerId) {
    return IstoPlayerColors.glow(playerId);
  }

  /// Get darker/shadow version of player color
  static Color getDarkColor(int playerId) {
    return IstoPlayerColors.shadow(playerId);
  }

  /// Get muted/disabled version of player color
  static Color getMutedColor(int playerId) {
    return IstoPlayerColors.muted(playerId);
  }
}
