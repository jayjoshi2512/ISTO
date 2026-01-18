import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

/// Displays cowry shells with realistic animation
/// Based on authentic cowry/kauri shell appearance
class CowryDisplayComponent extends PositionComponent {
  CowryRoll? currentRoll;
  bool _isAnimating = false;
  double _animationProgress = 0;
  final Random _random = Random();
  
  // Individual shell animation states
  final List<_ShellState> _shellStates = List.generate(4, (_) => _ShellState());

  // Colors matching real cowry shells (from reference image)
  static const Color bgColor = Color(0xFF1A3A2A);
  static const Color shellLight = Color(0xFFF5E6D3); // Light cream shell
  static const Color shellDark = Color(0xFFD4A574); // Spotted shell back
  static const Color spotColor = Color(0xFF8B6914); // Brown spots
  static const Color openingColor = Color(0xFF2D1810); // Dark opening
  static const Color borderColor = Color(0xFF2E7D32);

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

    // Background panel (wooden/natural feel)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    
    // Gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF2A4A3A),
        const Color(0xFF1A3A2A),
        const Color(0xFF152A20),
      ],
    );
    canvas.drawRRect(
      rect, 
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    );
    
    // Border
    canvas.drawRRect(
      rect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

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

    // Result text
    if (currentRoll != null && !_isAnimating) {
      _drawResultText(canvas);
    }
  }

  void _drawCowryShell(Canvas canvas, Offset center, double width, double height, int index) {
    final state = _shellStates[index];
    bool isUp;
    double bounce = 0;
    double rotation = 0;
    double scale = 1.0;
    
    if (_isAnimating) {
      // During animation, shells flip and bounce
      isUp = _random.nextBool();
      bounce = sin(_animationProgress * 12 + index * 1.5) * 8 * (1 - _animationProgress);
      rotation = sin(_animationProgress * 20 + index * 2.5) * 0.5 * (1 - _animationProgress);
      scale = 1.0 + sin(_animationProgress * 6 + index) * 0.1 * (1 - _animationProgress);
    } else if (currentRoll != null) {
      isUp = currentRoll!.cowries[index];
      // Settled slight rotation for natural look
      rotation = state.settledRotation;
      bounce = 0;
    } else {
      isUp = false;
      rotation = 0;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy - bounce);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);
    
    // Create shell path (more realistic cowry shape)
    final shellPath = _createCowryPath(width, height);
    
    // Drop shadow
    canvas.drawPath(
      shellPath.shift(const Offset(2, 4)),
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    
    if (isUp) {
      // Shell opening visible (white/cream inside)
      _drawShellOpening(canvas, width, height);
    } else {
      // Shell back visible (spotted pattern)
      _drawShellBack(canvas, width, height);
    }
    
    canvas.restore();
  }

  Path _createCowryPath(double width, double height) {
    final path = Path();
    final w = width / 2;
    final h = height / 2;
    
    // Cowry shape (elliptical with pointed ends)
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
    
    // Base cream color
    canvas.drawPath(path, Paint()..color = shellLight);
    
    // Inner highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-width * 0.1, -height * 0.1), width: width * 0.5, height: height * 0.4),
      Paint()..color = Colors.white.withAlpha(120),
    );
    
    // Opening line (dark slit in the middle)
    final openingPath = Path();
    openingPath.moveTo(-width * 0.35, 0);
    openingPath.quadraticBezierTo(0, -height * 0.1, width * 0.35, 0);
    openingPath.quadraticBezierTo(0, height * 0.1, -width * 0.35, 0);
    canvas.drawPath(openingPath, Paint()..color = openingColor);
    
    // Teeth/ridges along opening
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
    
    // Border
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
    
    // Base spotted color
    canvas.drawPath(path, Paint()..color = shellDark);
    
    // Add spotted pattern (like real cowry shells)
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
    
    // Highlight on top
    final highlightPath = Path();
    highlightPath.addOval(Rect.fromCenter(
      center: Offset(-width * 0.15, -height * 0.15),
      width: width * 0.4,
      height: height * 0.3,
    ));
    canvas.drawPath(highlightPath, Paint()..color = Colors.white.withAlpha(50));
    
    // Border
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
    
    if (roll.steps == 4) {
      label = 'CHOWKA (4)';
      labelColor = const Color(0xFFFFD700);
    } else if (roll.steps == 8) {
      label = 'ASHTA (8)';
      labelColor = const Color(0xFFFF6B6B);
    } else {
      label = '${roll.steps}';
      labelColor = Colors.white;
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: roll.grantsExtraTurn ? 14 : 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: labelColor.withAlpha(100),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, size.y - 22),
    );
    
    // Extra turn indicator
    if (roll.grantsExtraTurn) {
      final extraPainter = TextPainter(
        text: TextSpan(
          text: '+ EXTRA TURN',
          style: TextStyle(
            color: const Color(0xFF4CAF50),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      extraPainter.layout();
      extraPainter.paint(
        canvas,
        Offset((size.x - extraPainter.width) / 2, size.y - 10),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isAnimating) {
      _animationProgress += dt * 1.5;
      if (_animationProgress >= 1.0) {
        _isAnimating = false;
        _animationProgress = 1.0;
        
        // Set settled positions
        for (int i = 0; i < 4; i++) {
          _shellStates[i].settledRotation = (_random.nextDouble() - 0.5) * 0.15;
        }
      }
    }
  }

  void showRoll(CowryRoll roll) {
    _isAnimating = true;
    _animationProgress = 0;
    currentRoll = roll;
    
    // Randomize shell states
    for (final state in _shellStates) {
      state.randomize(_random);
    }
  }

  void reset() {
    currentRoll = null;
    _isAnimating = false;
    _animationProgress = 0;
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
