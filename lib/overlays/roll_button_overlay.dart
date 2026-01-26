import 'dart:math';
import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/animation_config.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Enhanced roll button with satisfying game feel
/// 
/// Features:
/// - Breathing pulse animation when idle (inviting action)
/// - Press-and-hold charge up effect (anticipation)
/// - Shake animation on press (tactile feedback)
/// - Glow intensification during interaction
class RollButtonOverlay extends StatefulWidget {
  final ISTOGame game;

  const RollButtonOverlay({super.key, required this.game});

  @override
  State<RollButtonOverlay> createState() => _RollButtonOverlayState();
}

class _RollButtonOverlayState extends State<RollButtonOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;
  double _chargeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Breathing pulse animation - draws player attention
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Glow animation for emphasis
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Quick shake for tactile feedback
    _shakeController = AnimationController(
      duration: AnimationConfig.buttonFeedback,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _chargeProgress = 0.0;
    });
    _pulseController.stop();
    feedbackService.lightTap();
    
    // Start charge-up animation
    _startChargeAnimation();
  }

  void _startChargeAnimation() async {
    // Quick charge for responsiveness, but enough for anticipation
    const steps = 10;
    const stepDuration = Duration(milliseconds: 15);
    
    for (int i = 0; i <= steps && _isPressed; i++) {
      await Future.delayed(stepDuration);
      if (mounted && _isPressed) {
        setState(() => _chargeProgress = i / steps);
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isPressed) return;
    
    setState(() => _isPressed = false);
    
    // Shake feedback on release
    _shakeController.forward(from: 0);
    feedbackService.mediumTap();
    
    // Resume pulse after brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
    
    // Execute roll
    widget.game.rollCowries();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
      _chargeProgress = 0.0;
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              DesignSystem.bgDark,
              DesignSystem.bgDark.withAlpha(200),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        padding: const EdgeInsets.only(bottom: 32, top: 40),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _shakeController]),
            builder: (context, child) {
              // Calculate shake offset
              double shakeOffset = 0;
              if (_shakeController.isAnimating) {
                shakeOffset = sin(_shakeController.value * pi * 4) * 
                    (1 - _shakeController.value) * 3;
              }
              
              // Scale: pressed shrinks, idle pulses, charged grows slightly
              double scale;
              if (_isPressed) {
                scale = 0.92 + (_chargeProgress * 0.05);
              } else {
                scale = _pulseAnimation.value;
              }
              
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  // Dynamic glow based on state
                  final glowIntensity = _isPressed 
                      ? 0.8 + (_chargeProgress * 0.4)
                      : _glowAnimation.value;
                  final glowSpread = _isPressed ? 4.0 + (_chargeProgress * 4) : 2.0;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: DesignSystem.goldGradient,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                      boxShadow: [
                        // Primary glow - pulsing
                        BoxShadow(
                          color: DesignSystem.accentGold.withAlpha(
                            (100 * glowIntensity).toInt()
                          ),
                          blurRadius: 20 + (glowIntensity * 10),
                          spreadRadius: glowSpread,
                        ),
                        // Ambient glow - subtle
                        BoxShadow(
                          color: const Color(0xFFE5C158).withAlpha(
                            (40 * glowIntensity).toInt()
                          ),
                          blurRadius: 30,
                          spreadRadius: 0,
                        ),
                        // Drop shadow - grounding
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
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
                    // Left cowry icon - animates with button
                    _buildCowryIcon(offset: -1),
                    const SizedBox(width: 12),
                    
                    // Roll text with dynamic styling
                    Text(
                      'ROLL',
                      style: DesignSystem.button.copyWith(
                        fontSize: 18,
                        letterSpacing: _isPressed ? 5 : 4,
                        color: DesignSystem.bgDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Right cowry icon
                    _buildCowryIcon(offset: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCowryIcon({int offset = 0}) {
    // Slight rotation when pressed for liveliness
    final rotation = _isPressed ? (offset * 0.1 * _chargeProgress) : 0.0;
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 20,
        height: 12,
        decoration: BoxDecoration(
          color: DesignSystem.bgDark.withAlpha(_isPressed ? 220 : 180),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF8B7355),
            width: 1,
          ),
          boxShadow: _isPressed ? [
            BoxShadow(
              color: DesignSystem.accentGold.withAlpha(60),
              blurRadius: 4,
            ),
          ] : null,
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 2,
            decoration: BoxDecoration(
              color: _isPressed 
                  ? const Color(0xFFE5C158)
                  : const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
