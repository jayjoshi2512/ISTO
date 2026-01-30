import 'dart:math';
import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../config/game_feel_config.dart';

/// Reusable animated background with floating particles and ambient effects
/// Used across splash, menu, and other overlay screens for consistency
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final bool showGradientAnimation;
  final bool showAmbientGlow;
  final Color? accentColor;
  final double particleDensity;
  
  const AnimatedBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.showGradientAnimation = true,
    this.showAmbientGlow = true,
    this.accentColor,
    this.particleDensity = 1.0,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _gradientController;
  late List<_FloatingParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Particle animation - continuous loop
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Ambient glow pulsing
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Gradient shift animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    
    _initParticles();
  }
  
  void _initParticles() {
    final baseCount = (15 * widget.particleDensity * GameFeelConfig.particleIntensity).toInt();
    _particles = List.generate(baseCount, (index) {
      return _FloatingParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 4,
        speed: 0.02 + _random.nextDouble() * 0.03,
        opacity: 0.1 + _random.nextDouble() * 0.3,
        phase: _random.nextDouble() * 2 * pi,
        wobbleAmount: 0.02 + _random.nextDouble() * 0.04,
        type: _random.nextInt(3), // 0: circle, 1: diamond, 2: star
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _particleController,
        _glowController,
        _gradientController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Animated gradient background
            if (widget.showGradientAnimation)
              _buildAnimatedGradient()
            else
              Container(decoration: const BoxDecoration(gradient: DesignSystem.bgGradient)),
            
            // Ambient glow spots
            if (widget.showAmbientGlow) _buildAmbientGlow(),
            
            // Floating particles
            if (widget.showParticles) _buildParticles(),
            
            // Child content
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
  
  Widget _buildAnimatedGradient() {
    final progress = _gradientController.value;
    final accentColor = widget.accentColor ?? DesignSystem.accentPurple;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignSystem.bgDark,
            Color.lerp(DesignSystem.bgMedium, accentColor.withAlpha(30), progress * 0.3)!,
            DesignSystem.bgLight,
          ],
          stops: [
            0.0,
            0.5 + progress * 0.1,
            1.0,
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmbientGlow() {
    final glowValue = _glowController.value;
    final accentColor = widget.accentColor ?? DesignSystem.accentGold;
    
    return Positioned.fill(
      child: CustomPaint(
        painter: _AmbientGlowPainter(
          glowIntensity: glowValue,
          accentColor: accentColor,
        ),
      ),
    );
  }
  
  Widget _buildParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ParticlePainter(
          particles: _particles,
          progress: _particleController.value,
        ),
      ),
    );
  }
}

class _FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;
  final double wobbleAmount;
  final int type;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
    required this.wobbleAmount,
    required this.type,
  });
}

class _AmbientGlowPainter extends CustomPainter {
  final double glowIntensity;
  final Color accentColor;

  _AmbientGlowPainter({
    required this.glowIntensity,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Top-right glow
    final gradient1 = RadialGradient(
      center: const Alignment(0.8, -0.5),
      radius: 0.8,
      colors: [
        accentColor.withAlpha((25 * glowIntensity).toInt()),
        Colors.transparent,
      ],
    );
    paint.shader = gradient1.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
    
    // Bottom-left glow with accent color
    final gradient2 = RadialGradient(
      center: const Alignment(-0.7, 0.6),
      radius: 0.7,
      colors: [
        DesignSystem.accentPurple.withAlpha((20 * glowIntensity).toInt()),
        Colors.transparent,
      ],
    );
    paint.shader = gradient2.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
    
    // Center subtle glow
    final gradient3 = RadialGradient(
      center: Alignment.center,
      radius: 0.6,
      colors: [
        DesignSystem.accent.withAlpha((10 * (1 - glowIntensity)).toInt()),
        Colors.transparent,
      ],
    );
    paint.shader = gradient3.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter old) => 
      old.glowIntensity != glowIntensity;
}

class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate position with upward drift and wobble
      final yOffset = (particle.y - progress * particle.speed) % 1.0;
      final xWobble = sin((progress * 2 * pi) + particle.phase) * particle.wobbleAmount;
      final x = (particle.x + xWobble) * size.width;
      final y = yOffset * size.height;
      
      // Fade near edges
      final edgeFade = _calculateEdgeFade(yOffset);
      final alpha = (particle.opacity * edgeFade * 255).toInt();
      
      final paint = Paint()
        ..color = Colors.white.withAlpha(alpha)
        ..style = PaintingStyle.fill;
      
      // Draw based on type
      switch (particle.type) {
        case 0: // Circle
          canvas.drawCircle(Offset(x, y), particle.size / 2, paint);
          break;
        case 1: // Diamond
          _drawDiamond(canvas, x, y, particle.size, paint);
          break;
        case 2: // Small star/sparkle
          _drawSparkle(canvas, x, y, particle.size, paint);
          break;
      }
    }
  }
  
  double _calculateEdgeFade(double y) {
    if (y < 0.1) return y / 0.1;
    if (y > 0.9) return (1 - y) / 0.1;
    return 1.0;
  }
  
  void _drawDiamond(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path()
      ..moveTo(x, y - size / 2)
      ..lineTo(x + size / 2, y)
      ..lineTo(x, y + size / 2)
      ..lineTo(x - size / 2, y)
      ..close();
    canvas.drawPath(path, paint);
  }
  
  void _drawSparkle(Canvas canvas, double x, double y, double size, Paint paint) {
    final halfSize = size / 2;
    // Vertical line
    canvas.drawLine(
      Offset(x, y - halfSize),
      Offset(x, y + halfSize),
      paint..strokeWidth = 1,
    );
    // Horizontal line
    canvas.drawLine(
      Offset(x - halfSize, y),
      Offset(x + halfSize, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => 
      old.progress != progress;
}

/// Shimmer effect widget for buttons and cards
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color shimmerColor;
  
  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.shimmerColor = Colors.white,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                widget.shimmerColor.withAlpha(30),
                Colors.transparent,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              transform: const GradientRotation(0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Glassmorphism container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double blur;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderColor,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(15),
            Colors.white.withAlpha(5),
          ],
        ),
        border: Border.all(
          color: borderColor ?? Colors.white.withAlpha(20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DesignSystem.surface.withAlpha(200),
                DesignSystem.surface.withAlpha(240),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Animated glow border effect
class GlowBorder extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final double glowSize;
  
  const GlowBorder({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF4ECCA3),
    this.borderRadius = 16,
    this.glowSize = 2,
  });

  @override
  State<GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<GlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withAlpha((80 * _controller.value).toInt()),
                blurRadius: 12 + (8 * _controller.value),
                spreadRadius: widget.glowSize * _controller.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
