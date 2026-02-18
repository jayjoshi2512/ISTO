import 'dart:math';

import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../theme/isto_tokens.dart';

/// Animated background with floating particles and warm ambient glow.
/// Uses IstoColorsDark tokens for the Terracotta Dusk palette.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showParticles = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final random = Random();
    _particles = List.generate(
      12,
      (_) => _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 2.5,
        speed: 0.005 + random.nextDouble() * 0.015,
        opacity: 0.1 + random.nextDouble() * 0.2,
        phase: random.nextDouble() * 2 * pi,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: DesignSystem.bgGradient),
      child:
          widget.showParticles
              ? GameAnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BackgroundPainter(
                      particles: _particles,
                      time: _controller.value,
                    ),
                    child: child,
                  );
                },
                child: widget.child,
              )
              : widget.child,
    );
  }
}

class _Particle {
  double x, y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

class _BackgroundPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _BackgroundPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Ambient glow spots
    _drawAmbientGlow(canvas, size);

    // Floating particles
    for (final p in particles) {
      final px = (p.x + sin(time * 2 * pi + p.phase) * 0.02) * size.width;
      final py = ((p.y - time * p.speed * 5) % 1.0) * size.height;

      final paint =
          Paint()
            ..color = IstoColorsDark.accentGlow.withValues(
              alpha: p.opacity * 0.5,
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size);

      canvas.drawCircle(Offset(px, py), p.size, paint);
    }

    // Subtle vignette
    _drawVignette(canvas, size);
  }

  void _drawAmbientGlow(Canvas canvas, Size size) {
    // Warm glow at center
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        IstoColorsDark.accentPrimary.withValues(alpha: 0.03),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = gradient.createShader(Offset.zero & size),
    );
  }

  void _drawVignette(Canvas canvas, Size size) {
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = gradient.createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}

/// Glass container with frosted glass effect
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final Color? borderColor;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            IstoColorsDark.bgElevated.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Shimmer effect widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.color = const Color(0x20FFD700),
    this.duration = const Duration(seconds: 2),
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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameAnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + _controller.value * 3, 0),
              end: Alignment(-0.5 + _controller.value * 3, 0),
              colors: [Colors.transparent, widget.color, Colors.transparent],
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
