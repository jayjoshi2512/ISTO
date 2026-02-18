import 'dart:ui';

import '../theme/isto_tokens.dart';

/// UNIFIED Player Colors - Single Source of Truth
/// Heritage tones from ISTO design spec: Crimson, Cobalt, Forest, Saffron
class PlayerColors {
  // ============ PLAYER COLORS (Consistent across all UI) ============

  /// Player 0 - Crimson (heritage red)
  static const Color player0 = Color(0xFFC0392B);

  /// Player 1 - Cobalt (deep blue)
  static const Color player1 = Color(0xFF1B4F9C);

  /// Player 2 - Forest (heritage green)
  static const Color player2 = Color(0xFF2E7D4F);

  /// Player 3 - Saffron (warm gold-orange)
  static const Color player3 = Color(0xFFC07A00);

  /// List of all player colors for indexed access
  static const List<Color> colors = [player0, player1, player2, player3];

  /// Player names corresponding to colors
  static const List<String> names = ['Crimson', 'Cobalt', 'Forest', 'Saffron'];

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
