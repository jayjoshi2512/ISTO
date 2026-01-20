import 'package:flutter/material.dart';

/// Unified design system for ISTO game
/// Clean, polished, minimal, elegant design language
class DesignSystem {
  // === COLORS ===
  
  /// Primary background gradient
  static const Color bgDark = Color(0xFF0D0A14);
  static const Color bgMedium = Color(0xFF1A1525);
  static const Color bgLight = Color(0xFF251E35);
  
  /// Accent colors
  static const Color accent = Color(0xFF4ECCA3);  // Teal - primary actions
  static const Color accentGold = Color(0xFFD4AF37);  // Gold - highlights
  static const Color accentPurple = Color(0xFF8B5CF6);  // Purple - decorative
  
  /// Text colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textMuted = Color(0xFF6B6B6B);
  
  /// Surface colors
  static const Color surface = Color(0xFF1E1830);
  static const Color surfaceLight = Color(0xFF2A2340);
  static const Color border = Color(0xFF3D3555);
  static const Color borderLight = Color(0xFF524A6A);
  
  // === GRADIENTS ===
  
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDark, bgMedium, bgLight],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceLight, surface],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5CDBB3), accent],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE5C158), accentGold, Color(0xFFB8942F)],
  );
  
  // === TYPOGRAPHY ===
  
  static const TextStyle headingLarge = TextStyle(
    color: textPrimary,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: 4,
  );
  
  static const TextStyle headingMedium = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );
  
  static const TextStyle headingSmall = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    color: textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle caption = TextStyle(
    color: textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
  
  static const TextStyle button = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );
  
  // === SPACING ===
  
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;
  
  // === BORDER RADIUS ===
  
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 999;
  
  // === SHADOWS ===
  
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withAlpha(40),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withAlpha(60),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withAlpha(80),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowAccent = [
    BoxShadow(
      color: accent.withAlpha(60),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> glowGold = [
    BoxShadow(
      color: accentGold.withAlpha(60),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];
  
  // === DECORATIONS ===
  
  static BoxDecoration cardDecoration = BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(radiusL),
    border: Border.all(color: border, width: 1),
    boxShadow: shadowMedium,
  );
  
  static BoxDecoration accentButtonDecoration = BoxDecoration(
    gradient: accentGradient,
    borderRadius: BorderRadius.circular(radiusFull),
    boxShadow: glowAccent,
  );
  
  static BoxDecoration outlineButtonDecoration = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(radiusFull),
    border: Border.all(color: border, width: 1.5),
  );
  
  // === ANIMATIONS ===
  
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Curve animCurve = Curves.easeOutCubic;
}

/// Reusable premium button widget
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;
  final IconData? icon;
  final double? width;
  
  const PremiumButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isPrimary = true,
    this.icon,
    this.width,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: DesignSystem.animFast,
        child: Container(
          width: widget.width,
          padding: EdgeInsets.symmetric(
            horizontal: widget.icon != null ? 20 : 32,
            vertical: 14,
          ),
          decoration: widget.isPrimary
              ? DesignSystem.accentButtonDecoration
              : DesignSystem.outlineButtonDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isPrimary 
                      ? DesignSystem.textPrimary 
                      : DesignSystem.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: DesignSystem.button.copyWith(
                  color: widget.isPrimary 
                      ? DesignSystem.textPrimary 
                      : DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal divider
class MinimalDivider extends StatelessWidget {
  final double? width;
  
  const MinimalDivider({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 60,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            DesignSystem.borderLight,
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
