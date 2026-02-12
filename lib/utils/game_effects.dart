import 'dart:math';
import 'package:flutter/material.dart';

import '../config/animation_config.dart';
import '../config/design_system.dart';

/// Visual effects utilities for game feel enhancement
/// 
/// This class provides reusable screen effects like shake, flash, glow,
/// and particles to make game moments feel impactful.
class GameEffects {
  /// Create a screen shake effect widget
  /// Wrap your game content in this during capture/impact moments
  static Widget screenShake({
    required Widget child,
    required AnimationController controller,
    double intensity = 8.0,
  }) {
    return GameAnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isAnimating) return child;
        
        final random = Random();
        final dx = (random.nextDouble() - 0.5) * 2 * intensity * (1 - controller.value);
        final dy = (random.nextDouble() - 0.5) * 2 * intensity * (1 - controller.value);
        
        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Create a screen flash overlay
  /// Shows a brief color flash for impact moments
  static Widget screenFlash({
    required AnimationController controller,
    Color color = Colors.white,
  }) {
    return GameAnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Flash peaks at 30% then fades out
        final progress = controller.value;
        final opacity = progress < 0.3
            ? progress / 0.3  // Fade in
            : 1 - ((progress - 0.3) / 0.7);  // Fade out
        
        return IgnorePointer(
          child: Container(
            color: color.withAlpha((opacity * 100).toInt()),
          ),
        );
      },
    );
  }

  /// Create a pulsing glow effect
  static BoxDecoration pulsingGlow({
    required Color color,
    required double phase,  // 0-1 for pulse cycle
    double minBlur = 8,
    double maxBlur = 20,
    double minSpread = 0,
    double maxSpread = 4,
  }) {
    final t = (sin(phase * pi * 2) + 1) / 2;  // Smooth 0-1
    final blur = minBlur + (maxBlur - minBlur) * t;
    final spread = minSpread + (maxSpread - minSpread) * t;
    
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color.withAlpha((120 + 80 * t).toInt()),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ],
    );
  }

  /// Create a celebration burst effect (radial lines)
  static Widget celebrationBurst({
    required AnimationController controller,
    Color color = const Color(0xFFFFD700),
    int rayCount = 12,
  }) {
    return GameAnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BurstPainter(
            progress: controller.value,
            color: color,
            rayCount: rayCount,
          ),
        );
      },
    );
  }

  /// Easing function for satisfying bouncy landing
  static double bounceOut(double t) {
    const n1 = 7.5625;
    const d1 = 2.75;
    
    if (t < 1 / d1) {
      return n1 * t * t;
    } else if (t < 2 / d1) {
      t -= 1.5 / d1;
      return n1 * t * t + 0.75;
    } else if (t < 2.5 / d1) {
      t -= 2.25 / d1;
      return n1 * t * t + 0.9375;
    } else {
      t -= 2.625 / d1;
      return n1 * t * t + 0.984375;
    }
  }

  /// Easing for quick start, slow end (satisfying movement)
  static double easeOutCubic(double t) => 1 - pow(1 - t, 3).toDouble();

  /// Easing for dramatic reveals
  static double easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2);
  }

  /// Create squash-and-stretch scale for pawn landing
  static Matrix4 squashStretch(double landingProgress) {
    // landingProgress: 0 = in air, 1 = landed
    if (landingProgress < 0.7) {
      // In air - slight stretch vertically
      return Matrix4.diagonal3Values(0.95, 1.1, 1.0);
    } else if (landingProgress < 0.85) {
      // Impact - squash horizontally
      final t = (landingProgress - 0.7) / 0.15;
      final squash = 1 - (0.15 * t);
      final stretch = 1 + (0.1 * t);
      return Matrix4.diagonal3Values(stretch, squash, 1.0);
    } else {
      // Recovery - back to normal with slight overshoot
      final t = (landingProgress - 0.85) / 0.15;
      final scale = AnimationConfig.pawnLandingSquash + 
          (1 - AnimationConfig.pawnLandingSquash) * bounceOut(t);
      return Matrix4.diagonal3Values(1 + (1 - scale) * 0.5, scale, 1.0);
    }
  }
}

/// Painter for celebration burst rays
class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int rayCount;

  _BurstPainter({
    required this.progress,
    required this.color,
    required this.rayCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.6;
    
    final paint = Paint()
      ..color = color.withAlpha(((1 - progress) * 200).toInt())
      ..strokeWidth = 2 + (1 - progress) * 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi / rayCount) + (progress * pi * 0.3);
      final innerRadius = maxRadius * 0.2 * progress;
      final outerRadius = maxRadius * (0.3 + 0.7 * progress);
      
      final start = center + Offset(
        cos(angle) * innerRadius,
        sin(angle) * innerRadius,
      );
      final end = center + Offset(
        cos(angle) * outerRadius,
        sin(angle) * outerRadius,
      );
      
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.progress != progress;
}

/// Color utilities for game effects
extension GameEffectColors on Color {
  /// Create a glow-friendly version of this color
  Color get forGlow => withAlpha(180);
  
  /// Create a flash-friendly version (brighter)
  Color get forFlash => Color.lerp(this, Colors.white, 0.3)!;
  
  /// Create a darker version for shadows
  Color get forShadow => Color.lerp(this, Colors.black, 0.4)!;
}

/// Decoration helpers for game feel
class GameDecorations {
  /// Golden glow for CHOWKA celebrations
  static List<BoxShadow> get chowkaGlow => [
    BoxShadow(
      color: DesignSystem.accent.withAlpha(AnimationConfig.graceThrowGlowIntensity),
      blurRadius: 24,
      spreadRadius: 4,
    ),
    BoxShadow(
      color: DesignSystem.accent.withAlpha(100),
      blurRadius: 40,
      spreadRadius: 8,
    ),
  ];

  /// Fiery glow for ASHTA celebrations
  static List<BoxShadow> get ashtaGlow => [
    BoxShadow(
      color: const Color(0xFFFF6B6B).withAlpha(AnimationConfig.graceThrowGlowIntensity),
      blurRadius: 24,
      spreadRadius: 4,
    ),
    BoxShadow(
      color: const Color(0xFFFF4444).withAlpha(100),
      blurRadius: 40,
      spreadRadius: 8,
    ),
  ];

  /// Impact glow for captures
  static List<BoxShadow> get captureGlow => [
    BoxShadow(
      color: const Color(0xFFE53935).withAlpha(150),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Victory glow for winning
  static List<BoxShadow> victoryGlow(Color playerColor) => [
    BoxShadow(
      color: playerColor.withAlpha(180),
      blurRadius: 30,
      spreadRadius: 6,
    ),
    BoxShadow(
      color: DesignSystem.accent.withAlpha(100),
      blurRadius: 50,
      spreadRadius: 10,
    ),
  ];
}
