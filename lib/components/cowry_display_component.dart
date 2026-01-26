import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/animation_config.dart';
import '../models/models.dart';

/// Enhanced cowry display with dramatic animations
/// 
/// Features:
/// - Extended roll animation with varied timing
/// - Dramatic reveal pause before showing result
/// - Glowing effect for CHOWKA/ASHTA rolls
/// - Scale pulse on special rolls
/// - More energetic shell bouncing and rotation
class CowryDisplayComponent extends PositionComponent {
  CowryRoll? currentRoll;
  bool _isAnimating = false;
  bool _isRevealing = false;  // Post-roll reveal phase
  double _animationProgress = 0;
  double _revealProgress = 0;  // For dramatic reveal
  double _glowIntensity = 0;  // For grace throw glow
  final Random _random = Random();
  
  // Individual shell animation states
  final List<_ShellState> _shellStates = List.generate(4, (_) => _ShellState());

  // Colors matching new design system
  static const Color bgColor = DesignSystem.surface;
  static const Color shellLight = Color(0xFFF5E6D3); // Light cream shell
  static const Color shellDark = Color(0xFFD4A574); // Spotted shell back
  static const Color spotColor = Color(0xFF8B6914); // Brown spots
  static const Color openingColor = Color(0xFF2D1810); // Dark opening
  static const Color borderColor = DesignSystem.border;
  
  // Grace throw colors
  static const Color chowkaGlow = Color(0xFFFFD700);  // Gold for CHOWKA
  static const Color ashtaGlow = Color(0xFFFF6B6B);   // Red for ASHTA

  CowryDisplayComponent({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(180, 80),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calculate glow color for grace throws
    Color? glowColor;
    if (currentRoll != null && currentRoll!.grantsExtraTurn && _glowIntensity > 0) {
      glowColor = currentRoll!.isChowka ? chowkaGlow : ashtaGlow;
    }

    // Background panel with conditional glow
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    
    // Grace throw glow effect (outer)
    if (glowColor != null && _glowIntensity > 0.1) {
      canvas.drawRRect(
        rect.inflate(4 + (_glowIntensity * 6)),
        Paint()
          ..color = glowColor.withAlpha((_glowIntensity * 80).toInt())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 + (_glowIntensity * 8)),
      );
    }
    
    // Clean dark background
    canvas.drawRRect(
      rect, 
      Paint()..color = DesignSystem.surface,
    );
    
    // Border - glows on grace throws
    canvas.drawRRect(
      rect,
      Paint()
        ..color = glowColor?.withAlpha((_glowIntensity * 200 + 55).toInt()) ?? borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowColor != null ? 1.5 + (_glowIntensity * 0.5) : 1,
    );

    // Calculate panel scale for reveal punch
    double panelScale = 1.0;
    if (_isRevealing && currentRoll != null && currentRoll!.grantsExtraTurn) {
      // Quick punch on reveal
      final revealPunch = sin(_revealProgress * pi * 2) * 0.08 * (1 - _revealProgress);
      panelScale = 1.0 + revealPunch;
    }
    
    // Apply scale for reveal
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(panelScale, panelScale);
    canvas.translate(-size.x / 2, -size.y / 2);

    // Draw cowries (4 shells)
    final shellWidth = 28.0;
    final shellHeight = 18.0;
    final totalWidth = 4 * shellWidth + 3 * 8;
    final startX = (size.x - totalWidth) / 2;
    
    for (int i = 0; i < 4; i++) {
      final x = startX + i * (shellWidth + 8) + shellWidth / 2;
      final y = size.y / 2 - 5;
      
      _drawCowryShell(canvas, Offset(x, y), shellWidth, shellHeight, i);
    }

    // Result text with enhanced styling
    if (currentRoll != null && !_isAnimating) {
      _drawResultText(canvas);
    }
    
    canvas.restore();
  }

  void _drawCowryShell(Canvas canvas, Offset center, double width, double height, int index) {
    final state = _shellStates[index];
    bool isUp;
    double bounce = 0;
    double rotation = 0;
    double scale = 1.0;
    
    if (_isAnimating) {
      // Enhanced animation with more energy
      final phase = _animationProgress * AnimationConfig.cowryFlipCount;
      final decay = pow(1 - _animationProgress, 1.5).toDouble();
      
      // Faster, more chaotic flipping during animation
      isUp = sin(phase * 3 + index * 2) > 0;
      
      // More dynamic bounce with individual timing
      bounce = sin(phase * 2 + index * 1.2) * 12 * decay;
      
      // More rotation variety
      rotation = sin(phase * 2.5 + index * 1.8) * 0.7 * decay;
      
      // Scale variation for depth
      scale = 1.0 + sin(phase * 1.5 + index * 0.8) * 0.15 * decay;
    } else if (currentRoll != null) {
      isUp = currentRoll!.cowries[index];
      rotation = state.settledRotation;
      
      // Settled bounce with gentle settle
      if (_isRevealing) {
        // Landing bounce effect
        final settlePhase = _revealProgress;
        if (settlePhase < 0.3) {
          bounce = sin(settlePhase / 0.3 * pi) * 3 * (1 - settlePhase / 0.3);
        }
      }
    } else {
      isUp = false;
      rotation = 0;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy - bounce);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);
    
    // Create shell path
    final shellPath = _createCowryPath(width, height);
    
    // Enhanced drop shadow
    canvas.drawPath(
      shellPath.shift(Offset(2, 3 + bounce * 0.1)),
      Paint()
        ..color = Colors.black.withAlpha(50 + (bounce.abs() * 2).toInt())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + bounce.abs() * 0.2),
    );
    
    if (isUp) {
      _drawShellOpening(canvas, width, height);
    } else {
      _drawShellBack(canvas, width, height);
    }
    
    canvas.restore();
  }

  Path _createCowryPath(double width, double height) {
    final path = Path();
    final w = width / 2;
    final h = height / 2;
    
    path.moveTo(-w, 0);
    path.cubicTo(-w, -h * 1.1, -w * 0.3, -h * 1.3, 0, -h);
    path.cubicTo(w * 0.3, -h * 1.3, w, -h * 1.1, w, 0);
    path.cubicTo(w, h * 1.1, w * 0.3, h * 1.3, 0, h);
    path.cubicTo(-w * 0.3, h * 1.3, -w, h * 1.1, -w, 0);
    path.close();
    
    return path;
  }

  void _drawShellOpening(Canvas canvas, double width, double height) {
    final path = _createCowryPath(width, height);
    
    canvas.drawPath(path, Paint()..color = shellLight);
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-width * 0.1, -height * 0.1), width: width * 0.5, height: height * 0.4),
      Paint()..color = Colors.white.withAlpha(120),
    );
    
    final openingPath = Path();
    openingPath.moveTo(-width * 0.35, 0);
    openingPath.quadraticBezierTo(0, -height * 0.1, width * 0.35, 0);
    openingPath.quadraticBezierTo(0, height * 0.1, -width * 0.35, 0);
    canvas.drawPath(openingPath, Paint()..color = openingColor);
    
    for (int i = 0; i < 8; i++) {
      final t = (i + 0.5) / 8;
      final x = width * 0.35 * (1 - 2 * t);
      canvas.drawLine(
        Offset(x, -height * 0.05),
        Offset(x, height * 0.05),
        Paint()
          ..color = Colors.brown.shade300
          ..strokeWidth = 1,
      );
    }
    
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.brown.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawShellBack(Canvas canvas, double width, double height) {
    final path = _createCowryPath(width, height);
    
    canvas.drawPath(path, Paint()..color = shellDark);
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 3.14159 * 2 / 12) + _random.nextDouble() * 0.3;
      final radius = width * 0.25 * (0.4 + _random.nextDouble() * 0.4);
      final x = cos(angle) * radius * 0.8;
      final y = sin(angle) * radius * 0.5;
      
      canvas.drawCircle(
        Offset(x, y),
        2 + _random.nextDouble() * 2,
        Paint()..color = spotColor.withAlpha(150 + _random.nextInt(80)),
      );
    }
    
    final highlightPath = Path();
    highlightPath.addOval(Rect.fromCenter(
      center: Offset(-width * 0.15, -height * 0.15),
      width: width * 0.4,
      height: height * 0.3,
    ));
    canvas.drawPath(highlightPath, Paint()..color = Colors.white.withAlpha(50));
    
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.brown.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawResultText(Canvas canvas) {
    final roll = currentRoll!;
    String label;
    Color labelColor;
    double fontSize;
    List<Shadow> shadows;
    
    if (roll.isChowka) {
      label = 'CHOWKA';
      labelColor = chowkaGlow;
      fontSize = 15;
      shadows = [
        Shadow(color: chowkaGlow.withAlpha(180), blurRadius: 12),
        Shadow(color: chowkaGlow.withAlpha(100), blurRadius: 20),
      ];
    } else if (roll.isAshta) {
      label = 'ASHTA';
      labelColor = ashtaGlow;
      fontSize = 15;
      shadows = [
        Shadow(color: ashtaGlow.withAlpha(180), blurRadius: 12),
        Shadow(color: ashtaGlow.withAlpha(100), blurRadius: 20),
      ];
    } else {
      label = '${roll.steps}';
      labelColor = Colors.white;
      fontSize = 18;
      shadows = [
        Shadow(color: Colors.white.withAlpha(60), blurRadius: 6),
      ];
    }
    
    // Apply reveal scale for dramatic entrance
    final textScale = _isRevealing ? 0.8 + (_revealProgress * 0.2) : 1.0;
    final textAlpha = _isRevealing ? (_revealProgress * 255).toInt() : 255;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor.withAlpha(textAlpha),
          fontSize: fontSize * textScale,
          fontWeight: FontWeight.w800,
          letterSpacing: roll.grantsExtraTurn ? 3 : 1,
          shadows: shadows,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, size.y - 22),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Main roll animation
    if (_isAnimating) {
      _animationProgress += dt * 1.2;  // Slightly slower for drama
      if (_animationProgress >= 1.0) {
        _isAnimating = false;
        _animationProgress = 1.0;
        
        // Start reveal phase
        _isRevealing = true;
        _revealProgress = 0;
        
        // Set settled positions
        for (int i = 0; i < 4; i++) {
          _shellStates[i].settledRotation = (_random.nextDouble() - 0.5) * 0.15;
        }
      }
    }
    
    // Reveal phase - includes dramatic pause
    if (_isRevealing) {
      _revealProgress += dt * 2.5;
      
      // Glow builds up for grace throws
      if (currentRoll != null && currentRoll!.grantsExtraTurn) {
        _glowIntensity = min(1.0, _revealProgress * 1.5);
      }
      
      if (_revealProgress >= 1.0) {
        _isRevealing = false;
        _revealProgress = 1.0;
      }
    }
    
    // Glow pulse for grace throws (after reveal)
    if (!_isAnimating && !_isRevealing && currentRoll != null && currentRoll!.grantsExtraTurn) {
      // Gentle pulse
      _glowIntensity = 0.6 + sin(dt * 1000 % (2 * pi)) * 0.4;
    }
  }

  void showRoll(CowryRoll roll) {
    _isAnimating = true;
    _isRevealing = false;
    _animationProgress = 0;
    _revealProgress = 0;
    _glowIntensity = 0;
    currentRoll = roll;
    
    for (final state in _shellStates) {
      state.randomize(_random);
    }
  }

  void reset() {
    currentRoll = null;
    _isAnimating = false;
    _isRevealing = false;
    _animationProgress = 0;
    _revealProgress = 0;
    _glowIntensity = 0;
  }
}

/// Individual shell animation state
class _ShellState {
  double settledRotation = 0;
  double bounceOffset = 0;
  
  void randomize(Random random) {
    settledRotation = (random.nextDouble() - 0.5) * 0.2;
    bounceOffset = random.nextDouble() * 0.5;
  }
}
