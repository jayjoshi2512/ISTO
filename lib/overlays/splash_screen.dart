import 'dart:math';
import 'package:flutter/material.dart';
import '../config/design_system.dart';

/// Clean, minimal, elegant splash screen for ISTO game
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _breatheController;
  
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;
  late Animation<double> _logoScale;
  late Animation<double> _titleSlide;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    _breathe = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _breatheController]),
      builder: (context, child) {
        final opacity = _fadeIn.value * _fadeOut.value;

        return Opacity(
          opacity: opacity,
          child: Container(
            decoration: const BoxDecoration(gradient: DesignSystem.bgGradient),
            child: Stack(
              children: [
                // Subtle geometric background pattern
                _buildGeometricPattern(size),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      
                      // Logo section
                      _buildLogo(),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: _buildTitle(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      _buildSubtitle(),
                      
                      const Spacer(flex: 3),
                      
                      // Loading indicator
                      _buildLoadingIndicator(),
                      
                      const SizedBox(height: 48),
                      
                      // Footer
                      _buildFooter(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeometricPattern(Size size) {
    return CustomPaint(
      size: size,
      painter: _GeometricPatternPainter(
        progress: _mainController.value,
        breathe: _breathe.value,
      ),
    );
  }

  Widget _buildLogo() {
    return Transform.scale(
      scale: _logoScale.value,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: DesignSystem.goldGradient,
          boxShadow: [
            BoxShadow(
              color: DesignSystem.accentGold.withAlpha((60 * _breathe.value + 40).toInt()),
              blurRadius: 30 + (_breathe.value * 10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.bgDark.withAlpha(200),
                ),
              ),
              // Cowry shell arrangement
              _buildCowryArrangement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCowryArrangement() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(4, (index) {
          final angle = (index * 90 - 45) * pi / 180;
          final radius = 18.0;
          return Transform.translate(
            offset: Offset(radius * cos(angle), radius * sin(angle)),
            child: Transform.rotate(
              angle: angle + pi / 2,
              child: _buildMinimalCowry(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMinimalCowry() {
    return Container(
      width: 16,
      height: 10,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E7), Color(0xFFE8D5C4)],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFD4C4B0), width: 0.5),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 1.5,
          decoration: BoxDecoration(
            color: const Color(0xFF5D4E37),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          DesignSystem.textPrimary,
          DesignSystem.accentGold,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        'ISTO',
        style: DesignSystem.headingLarge.copyWith(
          fontSize: 56,
          letterSpacing: 12,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    final opacity = ((_mainController.value - 0.3) * 3).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 1,
            color: DesignSystem.border,
          ),
          const SizedBox(width: 12),
          Text(
            'ಚೌಕಾಬಾರ',
            style: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.accentGold.withAlpha(180),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 1,
            color: DesignSystem.border,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          // Progress line
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: DesignSystem.border,
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_mainController.value / 0.85).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: DesignSystem.accentGradient,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.accent.withAlpha(100),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'LOADING',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final opacity = ((_mainController.value - 0.4) * 2).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Text(
        'Traditional Indian Board Game',
        style: DesignSystem.caption.copyWith(
          color: DesignSystem.textMuted.withAlpha(150),
        ),
      ),
    );
  }
}

/// Subtle geometric background pattern
class _GeometricPatternPainter extends CustomPainter {
  final double progress;
  final double breathe;

  _GeometricPatternPainter({required this.progress, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw subtle concentric circles at center
    final center = Offset(size.width / 2, size.height * 0.35);
    
    for (int i = 0; i < 4; i++) {
      final radius = 80.0 + (i * 40) + (breathe * 10);
      final opacity = (0.1 - (i * 0.02)) * progress;
      paint.color = DesignSystem.borderLight.withAlpha((opacity * 255).toInt());
      canvas.drawCircle(center, radius, paint);
    }

    // Draw subtle corner decorations
    final cornerPaint = Paint()
      ..color = DesignSystem.border.withAlpha((30 * progress).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Top left corner
    canvas.drawLine(
      const Offset(20, 40),
      const Offset(20, 70),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(20, 40),
      const Offset(50, 40),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(size.width - 20, 40),
      Offset(size.width - 20, 70),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, 40),
      Offset(size.width - 50, 40),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(20, size.height - 40),
      Offset(20, size.height - 70),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(20, size.height - 40),
      Offset(50, size.height - 40),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(size.width - 20, size.height - 40),
      Offset(size.width - 20, size.height - 70),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, size.height - 40),
      Offset(size.width - 50, size.height - 40),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GeometricPatternPainter old) =>
      old.progress != progress || old.breathe != breathe;
}
