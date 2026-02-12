import 'dart:ui';

import 'player_colors.dart';

/// Theme configuration — colors, sizes, and player theming
class ThemeConfig {
  // ======= BOARD COLORS =======
  static const Color boardBackground = Color(0xFF1A0F06);  // Deep mahogany  
  static const Color boardBorder = Color(0xFF3D2B18);       // Wood frame
  static const Color outerSquare = Color(0xFF28180A);       // Dark teak
  static const Color outerSquareBorder = Color(0xFF4D3620);  // Bronze border
  static const Color innerSquare = Color(0xFF382412);       // Rich walnut
  static const Color innerSquareBorder = Color(0xFF5E4430); // Warm bronze
  static const Color centerSquare = Color(0xFFF2C94C);      // Antique gold
  static const Color centerSquareGlow = Color(0x50F2C94C);  // Gold glow
  static const Color safeSquareMark = Color(0x70F2C94C);    // Gold X marks

  // ======= COWRY COLORS =======
  static const Color cowryUp = Color(0xFFF5EDDB);           // Ivory mouth-up
  static const Color cowryDown = Color(0xFF8B7050);          // Brown shell back
  static const Color cowryBorder = Color(0xFF6B5840);        // Shell edge

  // ======= UI COLORS =======
  static const Color textPrimary = Color(0xFFF0E6D2);
  static const Color textSecondary = Color(0xFFC4AE92);
  static const Color textMuted = Color(0xFF786858);
  static const Color goldAccent = Color(0xFFF2C94C);
  static const Color goldDark = Color(0xFFAA8A2E);
  static const Color dangerRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF2ECC71);

  // ======= SIZES =======
  static const double squareSize = 56.0;
  static const double pawnSize = 28.0;
  static const double cowryWidth = 32.0;
  static const double cowryHeight = 20.0;

  // ======= PLAYER ACCESS =======
  static Color getPlayerColor(int id) => PlayerColors.getColor(id);
  static String getPlayerName(int id) => PlayerColors.getName(id);
  static Color getPlayerLightColor(int id) => PlayerColors.getLightColor(id);
  static Color getPlayerDarkColor(int id) => PlayerColors.getDarkColor(id);
}
