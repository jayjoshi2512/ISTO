import 'package:flutter/material.dart';

/// ============================================================
/// ISTO Design Tokens — "Slate & Persimmon" & "Ivory Slate"
/// ============================================================
/// Single source of truth for all design values.
/// Based on the ISTO Game UI/UX Design Guidelines v1.0.
/// Reference ONLY these tokens in every widget.
/// ============================================================

// ──────────────────────────────────────────────
// COLOR SYSTEM
// ──────────────────────────────────────────────

/// Dark theme — "Slate & Persimmon" (Default)
class IstoColorsDark {
  IstoColorsDark._();

  // Backgrounds — Deep Ink base
  static const Color bgPrimary = Color(0xFF101014);
  static const Color bgSurface = Color(0xFF1A1A1E);
  static const Color bgElevated = Color(0xFF252528);

  // Board — Slate tones
  static const Color boardCell = Color(0xFF2E2E32);
  static const Color boardCellAlt = Color(0xFF262629);
  static const Color boardLine = Color(0xFF4A4A4E);
  static const Color boardOuterBorder = Color(0xFF5A5A5E);

  // Accents — Persimmon
  static const Color accentPrimary = Color(0xFFFF5733);
  static const Color accentWarm = Color(0xFFFF7043);
  static const Color accentGlow = Color(0xFFFF8A65);

  // Text — Arctic White
  static const Color textPrimary = Color(0xFFF9F9F9);
  static const Color textSecondary = Color(0xFFA0A0A4);
  static const Color textMuted = Color(0xFF6B6B6F);

  // Semantic
  static const Color success = Color(0xFF00A86B);
  static const Color danger = Color(0xFFE05252);

  // Safe squares — Jade Green
  static const Color safeSquare = Color(0xFF1A4D3A);
  static const Color safeSquareBorder = Color(0xFF00A86B);

  // Center / Home
  static const Color centerHome = Color(0xFF1A1014);
  static const Color centerHomeGlow = Color(0xFFFF8A65);
}

/// Light theme — "Ivory Slate" (Optional)
class IstoColorsLight {
  IstoColorsLight._();

  static const Color bgPrimary = Color(0xFFF5F5F7);
  static const Color bgSurface = Color(0xFFE8E8EC);
  static const Color boardCell = Color(0xFFD0D0D5);
  static const Color boardCellAlt = Color(0xFFC0C0C5);
  static const Color accentPrimary = Color(0xFFE04520);
  static const Color textPrimary = Color(0xFF101014);
  static const Color boardLine = Color(0xFF8A8A8E);
}

// ──────────────────────────────────────────────
// PLAYER COLORS
// ──────────────────────────────────────────────

class IstoPlayerColorSet {
  final Color base;
  final Color glow;
  final Color shadow;
  final Color muted;
  final String symbol; // Empty — clean modern look

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
    // Player 1 — Persimmon
    IstoPlayerColorSet(
      base: Color(0xFFFF5733),
      glow: Color(0xFFFF8A65),
      shadow: Color(0xFF992E1A),
      muted: Color(0xFF6B4040),
      symbol: '',
    ),
    // Player 2 — Jade
    IstoPlayerColorSet(
      base: Color(0xFF00A86B),
      glow: Color(0xFF33CC8E),
      shadow: Color(0xFF006440),
      muted: Color(0xFF3A5A4A),
      symbol: '',
    ),
    // Player 3 — Steel Blue
    IstoPlayerColorSet(
      base: Color(0xFF4A90D9),
      glow: Color(0xFF7AB3EE),
      shadow: Color(0xFF2A5580),
      muted: Color(0xFF3A4A5E),
      symbol: '',
    ),
    // Player 4 — Amber
    IstoPlayerColorSet(
      base: Color(0xFFE8A44A),
      glow: Color(0xFFF0C870),
      shadow: Color(0xFF8A6020),
      muted: Color(0xFF6B5A30),
      symbol: '',
    ),
  ];

  static const List<String> names = ['Persimmon', 'Jade', 'Steel', 'Amber'];

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

  /// App title on splash — Lora 48sp 600
  static TextStyle get appTitle => const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: IstoColorsDark.accentGlow,
    letterSpacing: 3.0,
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

  /// Regional subtitle on splash — Poppins 16sp 400
  static TextStyle get subtitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: IstoColorsDark.textMuted,
    letterSpacing: 2.5,
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
    colors: [IstoColorsDark.bgPrimary, Color(0xFF0C0C0F), Color(0xFF080810)],
  );

  static const LinearGradient accentGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      IstoColorsDark.accentGlow,
      IstoColorsDark.accentPrimary,
      Color(0xFFCC4425),
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

  /// Primary CTA button (filled persimmon)
  static BoxDecoration primaryButton({bool pressed = false}) => BoxDecoration(
    gradient:
        pressed
            ? const LinearGradient(
              colors: [Color(0xFFCC4425), Color(0xFFFF5733)],
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
