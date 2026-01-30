import 'dart:math';

import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/game_feel_config.dart';
import '../game/isto_game.dart';

/// Clean, minimal toast notifications for game events
class GameToastOverlay extends StatefulWidget {
  final ISTOGame game;
  final String message;
  final Color color;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onDismiss;

  const GameToastOverlay({
    super.key,
    required this.game,
    required this.message,
    this.color = DesignSystem.accent,
    this.icon,
    this.duration = const Duration(seconds: 2),
    this.onDismiss,
  });

  @override
  State<GameToastOverlay> createState() => _GameToastOverlayState();
}

class _GameToastOverlayState extends State<GameToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
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
        return Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 32,
          right: 32,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(child: child),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: Border.all(color: widget.color.withAlpha(100)),
          boxShadow: [
            BoxShadow(color: widget.color.withAlpha(40), blurRadius: 16),
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.color, size: 18),
              const SizedBox(width: 10),
            ],
            Text(
              widget.message,
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced extra turn notification - more prominent and celebratory
class ExtraTurnOverlay extends StatefulWidget {
  final ISTOGame game;

  const ExtraTurnOverlay({super.key, required this.game});

  @override
  State<ExtraTurnOverlay> createState() => _ExtraTurnOverlayState();
}

class _ExtraTurnOverlayState extends State<ExtraTurnOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Pulsing glow animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Longer display duration for visibility
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.game.overlays.remove('extraTurn');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulseController]),
      builder: (context, child) {
        return Positioned(
          // More central positioning for visibility
          top: MediaQuery.of(context).size.height * 0.35,
          left: 32,
          right: 32,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _controller.value.clamp(0.0, 1.0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            decoration: BoxDecoration(
              gradient: DesignSystem.goldGradient,
              borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
              boxShadow: [
                // Pulsing outer glow
                BoxShadow(
                  color: DesignSystem.accentGold.withAlpha(
                    (80 * _pulseAnimation.value).toInt(),
                  ),
                  blurRadius: 24 * _pulseAnimation.value,
                  spreadRadius: 4 * _pulseAnimation.value,
                ),
                // Inner glow
                BoxShadow(
                  color: const Color(0xFFE5C158).withAlpha(100),
                  blurRadius: 16,
                ),
                // Drop shadow for depth
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated star icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 0.5,
                  child: Icon(
                    Icons.auto_awesome,
                    color: DesignSystem.bgDark.withAlpha((255 * value).toInt()),
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'EXTRA TURN!',
              style: DesignSystem.button.copyWith(
                color: DesignSystem.bgDark,
                fontSize: 16,
                letterSpacing: 3,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: -value * 0.5,
                  child: Icon(
                    Icons.auto_awesome,
                    color: DesignSystem.bgDark.withAlpha((255 * value).toInt()),
                    size: 24,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Capture notification overlay with dramatic game feel
class CaptureOverlay extends StatefulWidget {
  final ISTOGame game;

  const CaptureOverlay({super.key, required this.game});

  @override
  State<CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends State<CaptureOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shakeController;
  late AnimationController _flashController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation with game feel config
    _controller = AnimationController(
      duration: Duration(milliseconds: (350 * GameFeelConfig.animationIntensity).toInt()),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Quick shake for impact
    _shakeController = AnimationController(
      duration: GameFeelConfig.captureShakeDuration,
      vsync: this,
    );
    
    // Screen flash for drama
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Pulsing glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _controller.forward();
    _shakeController.forward();
    
    if (GameFeelConfig.captureFlashEnabled) {
      _flashController.forward();
    }
    
    // Start pulsing after entrance
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
    
    // Trigger board shake
    widget.game.boardComponent.triggerShake();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.game.overlays.remove('capture');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    _flashController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _shakeController, _flashController, _pulseController]),
      builder: (context, child) {
        // Calculate shake offset with game feel config
        double shakeOffset = 0;
        if (GameFeelConfig.captureShakeEnabled && _shakeController.isAnimating && _shakeController.value < 0.6) {
          final shakePhase = _shakeController.value / 0.6;
          shakeOffset = sin(shakePhase * 3.14159 * 6) * (1 - shakePhase) * GameFeelConfig.captureShakeMagnitude;
        }
        
        // Pulse effect for glow
        final pulseValue = 0.7 + 0.3 * (_pulseController.value);

        return Stack(
          children: [
            // Screen flash overlay
            if (GameFeelConfig.captureFlashEnabled && _flashController.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: GameFeelConfig.killTargetColor.withAlpha(
                      (GameFeelConfig.captureFlashAlpha * (1 - _flashController.value)).toInt(),
                    ),
                  ),
                ),
              ),
            
            // Main capture badge
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 32,
              right: 32,
              child: Center(
                child: Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _controller.value.clamp(0.0, 1.0),
                      child: _buildCaptureBadge(pulseValue),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCaptureBadge(double pulseValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFE53935), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        boxShadow: [
          // Dramatic red glow - pulsing with game feel
          BoxShadow(
            color: GameFeelConfig.killTargetColor.withAlpha((150 * pulseValue * GameFeelConfig.glowIntensity).toInt()),
            blurRadius: 24 + (8 * pulseValue),
            spreadRadius: 4 * pulseValue,
          ),
          BoxShadow(
            color: const Color(0xFFFF5252).withAlpha((80 * GameFeelConfig.glowIntensity).toInt()),
            blurRadius: 40,
            spreadRadius: 0,
          ),
          // Drop shadow
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lightning bolt icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + value * 0.5,
                child: Transform.rotate(
                  angle: (1 - value) * 0.3,
                  child: Icon(
                    Icons.flash_on,
                    color: Colors.white.withAlpha((255 * value).toInt()),
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            'CAPTURED!',
            style: DesignSystem.button.copyWith(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(color: Colors.black.withAlpha(100), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// No valid moves notification overlay
class NoMovesOverlay extends StatefulWidget {
  final ISTOGame game;

  const NoMovesOverlay({super.key, required this.game});

  @override
  State<NoMovesOverlay> createState() => _NoMovesOverlayState();
}

class _NoMovesOverlayState extends State<NoMovesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.game.overlays.remove('noMoves');
        });
      }
    });
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
        return Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 32,
          right: 32,
          child: Center(
            child: Opacity(opacity: _controller.value, child: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: Border.all(color: Colors.orange.withAlpha(150)),
          boxShadow: [
            BoxShadow(color: Colors.orange.withAlpha(40), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: Colors.orange, size: 18),
            const SizedBox(width: 10),
            Text(
              'No valid moves',
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
