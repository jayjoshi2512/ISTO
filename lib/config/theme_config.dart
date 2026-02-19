import 'dart:ui';

import '../theme/isto_tokens.dart';
import 'player_colors.dart';

/// Theme configuration — colors, sizes, and player theming
/// All colors derived from IstoColorsDark (Navy & Flame) tokens.
class ThemeConfig {
  // ======= BOARD COLORS =======
  static const Color boardBackground = IstoColorsDark.bgSurface;
  static const Color boardBorder = IstoColorsDark.boardLine;
  static const Color outerSquare = IstoColorsDark.boardCell;
  static const Color outerSquareBorder = IstoColorsDark.boardLine;
  static const Color innerSquare = IstoColorsDark.boardCellAlt;
  static const Color innerSquareBorder = IstoColorsDark.boardLine;
  static const Color centerSquare = IstoColorsDark.centerHomeGlow;
  static const Color centerSquareGlow = IstoColorsDark.centerHomeGlow;
  static const Color safeSquareMark = IstoColorsDark.safeSquareBorder;

  // ======= COWRY COLORS =======
  static const Color cowryUp = Color(0xFFE8E7DF); // Cream mouth-up
  static const Color cowryDown = Color(0xFF064DAC); // Navy shell back
  static const Color cowryBorder = Color(0xFF032655); // Navy edge

  // ======= UI COLORS =======
  static const Color textPrimary = IstoColorsDark.textPrimary;
  static const Color textSecondary = IstoColorsDark.textSecondary;
  static const Color textMuted = IstoColorsDark.textMuted;
  static const Color goldAccent = IstoColorsDark.centerHomeGlow;
  static const Color goldDark = Color(0xFF8A7800);
  static const Color dangerRed = IstoColorsDark.danger;
  static const Color successGreen = IstoColorsDark.success;

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
