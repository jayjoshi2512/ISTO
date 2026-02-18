import 'package:flutter/material.dart';

/// ============================================================
/// ISTO Design Tokens — "Terracotta Dusk" & "Ivory Noon"
/// ============================================================
/// Single source of truth for all design values.
/// Based on the ISTO Game UI/UX Design Guidelines v1.0.
/// Reference ONLY these tokens in every widget.
/// ============================================================

// ──────────────────────────────────────────────
// COLOR SYSTEM
// ──────────────────────────────────────────────

/// Dark theme — "Terracotta Dusk" (Default)
class IstoColorsDark {
  IstoColorsDark._();

  // Backgrounds
  static const Color bgPrimary = Color(0xFF1A1209);
  static const Color bgSurface = Color(0xFF2B1E0F);
  static const Color bgElevated = Color(0xFF3D2A14);

  // Board
  static const Color boardCell = Color(0xFF4A3320);
  static const Color boardCellAlt = Color(0xFF3C2A18);
  static const Color boardLine = Color(0xFF6B4C2A);
  static const Color boardOuterBorder = Color(0xFF8A6035);

  // Accents
  static const Color accentPrimary = Color(0xFFE8A44A);
  static const Color accentWarm = Color(0xFFD4763A);
  static const Color accentGlow = Color(0xFFFFD98A);

  // Text
  static const Color textPrimary = Color(0xFFF5E6C8);
  static const Color textSecondary = Color(0xFFA8865A);
  static const Color textMuted = Color(0xFF6B5240);

  // Semantic
  static const Color success = Color(0xFF4CAF73);
  static const Color danger = Color(0xFFE05252);

  // Safe squares
  static const Color safeSquare = Color(0xFF2D5A3D);
  static const Color safeSquareBorder = Color(0xFF4CAF73);

  // Center / Home
  static const Color centerHome = Color(0xFF3A1A05);
  static const Color centerHomeGlow = Color(0xFFFFD98A);
}

/// Light theme — "Ivory Noon" (Optional)
class IstoColorsLight {
  IstoColorsLight._();

  static const Color bgPrimary = Color(0xFFFDF6EC);
  static const Color bgSurface = Color(0xFFF0DFC0);
  static const Color boardCell = Color(0xFFE8CFA0);
  static const Color boardCellAlt = Color(0xFFD6BB8A);
  static const Color accentPrimary = Color(0xFFA0530A);
  static const Color textPrimary = Color(0xFF2A1A08);
  static const Color boardLine = Color(0xFFB89060);
}

// ──────────────────────────────────────────────
// PLAYER COLORS
// ──────────────────────────────────────────────

class IstoPlayerColorSet {
  final Color base;
  final Color glow;
  final Color shadow;
  final Color muted;
  final String symbol; // ▲ ○ ◆ +

  const IstoPlayerColorSet({
    required this.base,
    required this.glow,
    required this.shadow,
    required this.muted,
    required this.symbol,
  });
}

class IstoPlayerColors {
  IstoPlayerColors._();

  static const List<IstoPlayerColorSet> _players = [
    // Player 1 — Crimson
    IstoPlayerColorSet(
      base: Color(0xFFC0392B),
      glow: Color(0xFFE85444),
      shadow: Color(0xFF7A2319),
      muted: Color(0xFF6B3A35),
      symbol: '▲',
    ),
    // Player 2 — Cobalt
    IstoPlayerColorSet(
      base: Color(0xFF1B4F9C),
      glow: Color(0xFF3A73D4),
      shadow: Color(0xFF0E2F5E),
      muted: Color(0xFF3A4A5E),
      symbol: '○',
    ),
    // Player 3 — Forest
    IstoPlayerColorSet(
      base: Color(0xFF2E7D4F),
      glow: Color(0xFF4DB377),
      shadow: Color(0xFF1A4A2E),
      muted: Color(0xFF3A5A45),
      symbol: '◆',
    ),
    // Player 4 — Saffron
    IstoPlayerColorSet(
      base: Color(0xFFC07A00),
      glow: Color(0xFFF0A820),
      shadow: Color(0xFF704800),
      muted: Color(0xFF6B5A30),
      symbol: '+',
    ),
  ];

  static const List<String> names = ['Crimson', 'Cobalt', 'Forest', 'Saffron'];

  /// Get full color set for a player by index (0–3)
  static IstoPlayerColorSet of(int playerIndex) {
    return _players[playerIndex.clamp(0, 3)];
  }

  /// Convenience: get base color only
  static Color base(int playerIndex) => of(playerIndex).base;
  static Color glow(int playerIndex) => of(playerIndex).glow;
  static Color shadow(int playerIndex) => of(playerIndex).shadow;
  static Color muted(int playerIndex) => of(playerIndex).muted;
  static String symbol(int playerIndex) => of(playerIndex).symbol;
  static String name(int playerIndex) => names[playerIndex.clamp(0, 3)];
}

// ──────────────────────────────────────────────
// SPACING
// ──────────────────────────────────────────────

class IstoSpacing {
  IstoSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

// ──────────────────────────────────────────────
// BORDER RADIUS
// ──────────────────────────────────────────────

class IstoRadius {
  IstoRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

// ──────────────────────────────────────────────
// ANIMATION DURATIONS
// ──────────────────────────────────────────────

class IstoDurations {
  IstoDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);

  // Cowry throw phases
  static const Duration cowryGather = Duration(milliseconds: 150);
  static const Duration cowryShake = Duration(milliseconds: 400);
  static const Duration cowryScatter = Duration(milliseconds: 350);
  static const Duration cowrySettle = Duration(milliseconds: 200);

  // Piece movement
  static const Duration hopShort = Duration(milliseconds: 220);
  static const Duration hopLong = Duration(milliseconds: 170);

  // Kill animation
  static const Duration killImpact = Duration(milliseconds: 100);
  static const Duration killScatter = Duration(milliseconds: 300);
  static const Duration killReturn = Duration(milliseconds: 300);

  // Splash phases
  static const Duration splashTotal = Duration(milliseconds: 2200);
  static const Duration splashFadeOut = Duration(milliseconds: 300);
}

// ──────────────────────────────────────────────
// SHADOWS
// ──────────────────────────────────────────────

class IstoShadows {
  IstoShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 6,
      color: Colors.black.withValues(alpha: 0.3),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 12,
      color: Colors.black.withValues(alpha: 0.4),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 24,
      color: Colors.black.withValues(alpha: 0.5),
    ),
  ];

  /// Board floating shadows (two-layer per spec)
  static List<BoxShadow> get board => [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 24,
      color: Colors.black.withValues(alpha: 0.5),
    ),
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 6,
      color: Colors.black.withValues(alpha: 0.3),
    ),
  ];

  /// Glow shadow for accents
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}

// ──────────────────────────────────────────────
// TYPOGRAPHY (style factories, to be used with GoogleFonts)
// ──────────────────────────────────────────────

/// Typography tokens. These return base TextStyles.
/// In widgets, wrap with GoogleFonts.poppins(...) or GoogleFonts.lora(...)
/// or use IstoTypography helpers directly.
class IstoTypography {
  IstoTypography._();

  // ── Headings (Lora for cultural accents) ──

  /// App title on splash — Lora 40sp 600
  static TextStyle get appTitle => const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    color: IstoColorsDark.accentGlow,
    letterSpacing: 2.5,
    height: 1.1,
  );

  /// Screen title — Poppins 24sp 700
  static TextStyle get screenTitle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: IstoColorsDark.textPrimary,
    letterSpacing: 0.5,
  );

  /// Section label — Poppins 16sp 600
  static TextStyle get sectionLabel => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: IstoColorsDark.textPrimary,
    letterSpacing: 0.5,
  );

  /// Body / Rules text — Poppins 14sp 400
  static TextStyle get body => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: IstoColorsDark.textSecondary,
    letterSpacing: 0.2,
  );

  /// Score / Big number — Poppins 32sp 700
  static TextStyle get scoreBig => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: IstoColorsDark.accentPrimary,
  );

  /// Cowry count display — Poppins 28sp 700
  static TextStyle get cowryCount => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: IstoColorsDark.accentGlow,
  );

  /// Player name label — Poppins 12sp 600
  static TextStyle get playerName => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Small caption / note — Poppins 11sp 400
  static TextStyle get caption => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: IstoColorsDark.textMuted,
    letterSpacing: 0.5,
  );

  /// Button label — Poppins 14sp 700
  static TextStyle get button => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
  );

  /// Regional subtitle on splash — Poppins 12sp 400
  static TextStyle get subtitle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: IstoColorsDark.textMuted,
    letterSpacing: 2.0,
  );

  /// Victory message — Lora 36sp italic
  static TextStyle get victory => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: IstoColorsDark.accentGlow,
    letterSpacing: 1.0,
  );
}

// ──────────────────────────────────────────────
// GRADIENTS
// ──────────────────────────────────────────────

class IstoGradients {
  IstoGradients._();

  static const LinearGradient bgDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [IstoColorsDark.bgPrimary, Color(0xFF130E06), Color(0xFF0D0904)],
  );

  static const LinearGradient accentGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      IstoColorsDark.accentGlow,
      IstoColorsDark.accentPrimary,
      Color(0xFFB8862A),
    ],
  );

  static const LinearGradient surfaceCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [IstoColorsDark.bgElevated, IstoColorsDark.bgSurface],
  );
}

// ──────────────────────────────────────────────
// DECORATIONS (common reusable)
// ──────────────────────────────────────────────

class IstoDecorations {
  IstoDecorations._();

  /// Primary CTA button (filled gold)
  static BoxDecoration primaryButton({bool pressed = false}) => BoxDecoration(
    gradient:
        pressed
            ? const LinearGradient(
              colors: [Color(0xFFA07830), Color(0xFFC89040)],
            )
            : IstoGradients.accentGold,
    borderRadius: BorderRadius.circular(IstoRadius.md),
    boxShadow:
        pressed
            ? []
            : [
              BoxShadow(
                color: IstoColorsDark.accentPrimary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
  );

  /// Secondary button (outlined)
  static BoxDecoration secondaryButton({bool pressed = false}) => BoxDecoration(
    color:
        pressed
            ? IstoColorsDark.accentPrimary.withValues(alpha: 0.15)
            : Colors.transparent,
    borderRadius: BorderRadius.circular(IstoRadius.md),
    border: Border.all(color: IstoColorsDark.accentPrimary, width: 1.5),
  );

  /// Glass card surface
  static BoxDecoration get glassCard => BoxDecoration(
    color: IstoColorsDark.bgElevated.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(IstoRadius.xl),
    border: Border.all(
      color: IstoColorsDark.boardLine.withValues(alpha: 0.3),
      width: 1,
    ),
    boxShadow: IstoShadows.lg,
  );

  /// Toast container
  static BoxDecoration toast({Color? tint}) => BoxDecoration(
    color:
        tint != null
            ? tint.withValues(alpha: 0.3)
            : IstoColorsDark.bgElevated.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color:
          tint?.withValues(alpha: 0.5) ??
          IstoColorsDark.boardLine.withValues(alpha: 0.3),
    ),
  );
}
