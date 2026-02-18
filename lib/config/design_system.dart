import 'package:flutter/material.dart';

import '../theme/isto_tokens.dart';

/// Premium design system for ISTO — Chowka Bhara
///
/// "Terracotta Dusk" — warm, cultural, heritage Indian board game aesthetic.
/// Colors derived from IstoColorsDark tokens.
class DesignSystem {
  // ========== CORE COLORS (mapped from IstoColorsDark) ==========
  static const Color bgDark = IstoColorsDark.bgPrimary;
  static const Color bgMedium = IstoColorsDark.bgSurface;
  static const Color bgLight = IstoColorsDark.bgElevated;
  static const Color surface = IstoColorsDark.bgSurface;
  static const Color surfaceLight = IstoColorsDark.bgElevated;
  static final Color surfaceGlass = Colors.white.withValues(alpha: 0.06);

  static const Color accent = IstoColorsDark.accentPrimary;
  static const Color accentLight = IstoColorsDark.accentGlow;
  static const Color accentDark = IstoColorsDark.accentWarm;

  static const Color textPrimary = IstoColorsDark.textPrimary;
  static const Color textSecondary = IstoColorsDark.textSecondary;
  static const Color textMuted = IstoColorsDark.textMuted;

  static const Color success = IstoColorsDark.success;
  static const Color danger = IstoColorsDark.danger;
  static const Color warning = IstoColorsDark.accentWarm;

  // ========== GRADIENTS ==========
  static const LinearGradient bgGradient = IstoGradients.bgDark;

  static const LinearGradient goldGradient = IstoGradients.accentGold;

  static const LinearGradient surfaceGradient = IstoGradients.surfaceCard;

  static const RadialGradient goldRadialGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [Color(0x40E8A44A), Color(0x00E8A44A)],
  );

  // ========== TYPOGRAPHY ==========
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: 4,
    height: 1.1,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: 1.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 0.8,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A0E04),
    letterSpacing: 1.2,
  );

  // ========== SPACING ==========
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // ========== BORDER RADIUS ==========
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 100;

  // ========== SHADOWS ==========
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: accent.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> playerGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  // ========== DECORATIONS ==========
  static BoxDecoration get glassSurface => BoxDecoration(
    color: surfaceGlass,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
  );

  static BoxDecoration get glassCard => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.03),
      ],
    ),
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration goldButton({bool pressed = false}) => BoxDecoration(
    gradient:
        pressed
            ? const LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
            )
            : goldGradient,
    borderRadius: BorderRadius.circular(radiusFull),
    boxShadow:
        pressed
            ? []
            : [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
  );
}

/// Premium button widget used across the app
class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final IconData? icon;
  final double? width;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.icon,
    this.width,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameAnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPrimary && !_pressed ? _pulseAnim.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration:
              widget.isPrimary
                  ? DesignSystem.goldButton(pressed: _pressed)
                  : BoxDecoration(
                    color:
                        _pressed
                            ? DesignSystem.surfaceLight
                            : DesignSystem.surface,
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusFull,
                    ),
                    border: Border.all(
                      color: DesignSystem.textMuted.withValues(alpha: 0.3),
                    ),
                  ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color:
                      widget.isPrimary
                          ? const Color(0xFF1A0E04)
                          : DesignSystem.textPrimary,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style:
                    widget.isPrimary
                        ? DesignSystem.buttonText
                        : DesignSystem.bodyLarge.copyWith(
                          color: DesignSystem.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple animated builder helper
class GameAnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const GameAnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _GameAnimatedBuilderInner(
      listenable: animation,
      builder: builder,
      child: child,
    );
  }
}

class _GameAnimatedBuilderInner extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const _GameAnimatedBuilderInner({
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

/// Minimal divider with gold center accent
class MinimalDivider extends StatelessWidget {
  const MinimalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  DesignSystem.textMuted.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DesignSystem.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.accent.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignSystem.textMuted.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
