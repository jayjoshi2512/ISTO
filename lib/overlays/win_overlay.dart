import 'dart:math';

import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/game_feel_config.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Premium celebratory win overlay with enhanced confetti, fireworks, and animations
class WinOverlay extends StatefulWidget {
  final ISTOGame game;

  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late AnimationController _glowController;
  late AnimationController _starBurstController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _trophyAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _starBurstAnimation;

  // Confetti particles
  late List<_ConfettiParticle> _particles;
  
  // Star burst particles for extra celebration
  late List<_StarBurstParticle> _starBursts;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
      ),
    );

    _trophyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Pulsing glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Star burst animation
    _starBurstController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _starBurstAnimation = CurvedAnimation(
      parent: _starBurstController,
      curve: Curves.easeOut,
    );

    // Initialize particles
    _initParticles();

    _controller.forward();
    _confettiController.repeat();
    _glowController.repeat(reverse: true);
    
    // Delayed star burst
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _starBurstController.forward();
    });
    
    feedbackService.onWin();
  }
  
  void _initParticles() {
    final random = Random();
    final confettiCount = GameFeelConfig.winConfettiCount;
    
    _particles = List.generate(confettiCount, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1 - random.nextDouble() * 0.4,
        size: 6 + random.nextDouble() * 10,
        color: [
          DesignSystem.accentGold,
          Colors.amber,
          Colors.orange,
          Colors.yellow,
          Colors.white,
          DesignSystem.accent,
        ][random.nextInt(6)],
        speed: 0.25 + random.nextDouble() * 0.35,
        rotation: random.nextDouble() * 360,
        rotationSpeed: (random.nextDouble() - 0.5) * 12,
        wobble: random.nextDouble() * 60,
        shape: random.nextInt(3), // 0: rectangle, 1: circle, 2: star
      );
    });
    
    // Star bursts from center
    _starBursts = List.generate(12, (index) {
      final angle = (index / 12) * 2 * pi;
      return _StarBurstParticle(
        angle: angle,
        distance: 80 + random.nextDouble() * 40,
        size: 4 + random.nextDouble() * 4,
        color: DesignSystem.accentGold.withAlpha(200),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _glowController.dispose();
    _starBurstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.game.gameManager.winner;
    if (winner == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _confettiController,
        _glowController,
        _starBurstController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background with radial glow
            Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      winner.color.withAlpha((40 * _glowAnimation.value).toInt()),
                      Colors.black.withAlpha(240),
                      DesignSystem.bgDark,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            
            // Star burst layer
            if (_starBurstAnimation.value > 0)
              ..._buildStarBursts(context, winner.color),

            // Confetti layer
            if (_fadeAnimation.value > 0.5) ..._buildConfetti(context),
          ],
        );
      },
      child: _buildContent(winner),
    );
  }
  
  List<Widget> _buildStarBursts(BuildContext context, Color winnerColor) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 50; // Offset up towards trophy
    final progress = _starBurstAnimation.value;
    
    return _starBursts.map((star) {
      final distance = star.distance * progress;
      final x = centerX + cos(star.angle) * distance;
      final y = centerY + sin(star.angle) * distance;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      
      return Positioned(
        left: x - star.size / 2,
        top: y - star.size / 2,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: star.size,
            height: star.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: winnerColor,
              boxShadow: [
                BoxShadow(
                  color: winnerColor.withAlpha(150),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildConfetti(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = _confettiController.value;

    return _particles.map((particle) {
      final y = particle.y + progress * particle.speed * 1.5;
      if (y > 1.2) return const SizedBox.shrink();

      final x = particle.x + sin(progress * 3 + particle.wobble) * 0.06;
      final rotation =
          particle.rotation + progress * particle.rotationSpeed * 360;
      final fadeOut = y > 0.9 ? (1.2 - y) / 0.3 : 1.0;

      return Positioned(
        left: x * size.width - particle.size / 2,
        top: y * size.height,
        child: Transform.rotate(
          angle: rotation * 3.14159 / 180,
          child: Opacity(
            opacity: (fadeOut * 0.9).clamp(0.0, 1.0),
            child: _buildConfettiShape(particle),
          ),
        ),
      );
    }).toList();
  }
  
  Widget _buildConfettiShape(_ConfettiParticle particle) {
    switch (particle.shape) {
      case 0: // Rectangle
        return Container(
          width: particle.size,
          height: particle.size * 0.5,
          decoration: BoxDecoration(
            color: particle.color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: particle.color.withAlpha(100), blurRadius: 4),
            ],
          ),
        );
      case 1: // Circle
        return Container(
          width: particle.size * 0.7,
          height: particle.size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: particle.color,
            boxShadow: [
              BoxShadow(color: particle.color.withAlpha(100), blurRadius: 4),
            ],
          ),
        );
      case 2: // Star shape (diamond)
      default:
        return Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: particle.size * 0.6,
            height: particle.size * 0.6,
            decoration: BoxDecoration(
              color: particle.color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: particle.color.withAlpha(100), blurRadius: 4),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildContent(dynamic winner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        gradient: DesignSystem.cardGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(color: winner.color.withAlpha(150), width: 2),
        boxShadow: [
          BoxShadow(
            color: winner.color.withAlpha(60),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy with pulsing glow
          AnimatedBuilder(
            animation: Listenable.merge([_trophyAnimation, _glowAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale:
                    _trophyAnimation.value *
                    (0.95 + _glowAnimation.value * 0.1),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: DesignSystem.goldGradient,
                    boxShadow: [
                      ...DesignSystem.glowGold,
                      BoxShadow(
                        color: DesignSystem.accentGold.withAlpha(
                          (100 * _glowAnimation.value).toInt(),
                        ),
                        blurRadius: 30 + 20 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: DesignSystem.bgDark,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Winner announcement
          Text(
            'VICTORY',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.accentGold,
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${winner.name} Wins!',
            style: DesignSystem.headingMedium.copyWith(color: winner.color),
          ),

          const SizedBox(height: 24),

          // Rankings
          _buildRankings(),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildButton('Play Again', DesignSystem.accent, () {
                  feedbackService.mediumTap();
                  widget.game.startNewGame(widget.game.gameManager.playerCount);
                }, isPrimary: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton('Menu', DesignSystem.textMuted, () {
                  feedbackService.lightTap();
                  widget.game.showMenu();
                }, isPrimary: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankings() {
    final rankings = widget.game.gameManager.rankings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.bgDark.withAlpha(150),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rankings.length; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + i * 150),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: i > 0 ? 8 : 0),
                child: Row(
                  children: [
                    // Rank with glow for winner
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color:
                            i == 0
                                ? DesignSystem.accentGold.withAlpha(50)
                                : DesignSystem.surface,
                        shape: BoxShape.circle,
                        boxShadow:
                            i == 0
                                ? [
                                  BoxShadow(
                                    color: DesignSystem.accentGold.withAlpha(
                                      60,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color:
                                i == 0
                                    ? DesignSystem.accentGold
                                    : DesignSystem.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Player dot with glow
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: rankings[i].color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rankings[i].color.withAlpha(150),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Player name
                    Expanded(
                      child: Text(
                        rankings[i].name,
                        style: DesignSystem.bodyMedium.copyWith(
                          color:
                              i == 0
                                  ? DesignSystem.textPrimary
                                  : DesignSystem.textSecondary,
                          fontWeight:
                              i == 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color color,
    VoidCallback onTap, {
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: isPrimary ? null : Border.all(color: DesignSystem.border),
          boxShadow: isPrimary ? DesignSystem.glowAccent : null,
        ),
        child: Center(
          child: Text(
            text,
            style: DesignSystem.button.copyWith(
              color:
                  isPrimary
                      ? DesignSystem.textPrimary
                      : DesignSystem.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Confetti particle data class
class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final double wobble;
  final int shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobble,
    required this.shape,
  });
}

/// Star burst particle for celebration effect
class _StarBurstParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _StarBurstParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}
