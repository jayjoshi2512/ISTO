import 'dart:ui';

import 'player_colors.dart';

/// Theme configuration for ISTO game
class ThemeConfig {
  // ============ COLORS ============

  /// Board background
  static const Color boardBackground = Color(0xFF1A1A2E);

  /// Default outer path square
  static const Color squareDefault = Color(0xFF16213E);

  /// Inner path square
  static const Color squareInner = Color(0xFF1F3460);

  /// Center square (destination)
  static const Color squareCenter = Color(0xFFE8D5B7);

  /// Highlighted square (valid move)
  static const Color squareHighlight = Color(0xFF4ECCA3);

  /// Kill target highlight
  static const Color squareKillTarget = Color(0xFFE85D75);

  /// Selected square
  static const Color squareSelected = Color(0xFF6C63FF);

  // ============ PLAYER COLORS (Unified - from PlayerColors) ============
  // Use PlayerColors class for consistency across the app

  static Color getPlayerColor(int playerId) => PlayerColors.getColor(playerId);

  // ============ PLAYER NAMES ============

  static String getPlayerName(int playerId) => PlayerColors.getName(playerId);

  // ============ COWRY COLORS ============

  static const Color cowryUp = Color(0xFFF5F0E1); // Cream when up
  static const Color cowryDown = Color(0xFF8B7355); // Brown when down
  static const Color cowryBorder = Color(0xFF5D4E37);

  // ============ UI COLORS ============

  static const Color uiBackground = Color(0xFF0F0F1A);
  static const Color uiSurface = Color(0xFF1A1A2E);
  static const Color uiAccent = Color(0xFF4ECCA3);
  static const Color uiText = Color(0xFFE8E8E8);
  static const Color uiTextSecondary = Color(0xFFA0A0A0);
  static const Color uiButtonPrimary = Color(0xFF4A90D9);
  static const Color uiButtonSecondary = Color(0xFF2D2D44);

  // ============ SIZES ============

  static const double squareSize = 56.0;
  static const double squareGap = 3.0;
  static const double squareBorderRadius = 8.0;
  static const double pawnSize = 28.0;
  static const double pawnBorderWidth = 2.5;
  static const double cowryWidth = 32.0;
  static const double cowryHeight = 18.0;
  static const double boardPadding = 16.0;
  static const double homeBaseSize = 80.0;

  // ============ TYPOGRAPHY ============

  static const String fontFamily = 'Inter';
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeLabel = 16.0;
  static const double fontSizeHeading = 24.0;
  static const double fontSizeTitle = 32.0;
}
