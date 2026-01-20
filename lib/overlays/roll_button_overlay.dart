import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Clean, elegant roll button overlay
class RollButtonOverlay extends StatefulWidget {
  final ISTOGame game;

  const RollButtonOverlay({super.key, required this.game});

  @override
  State<RollButtonOverlay> createState() => _RollButtonOverlayState();
}

class _RollButtonOverlayState extends State<RollButtonOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    feedbackService.lightTap();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.game.rollCowries();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
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
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPressed ? 0.95 : _pulseAnimation.value,
                child: child,
              );
            },
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                decoration: BoxDecoration(
                  gradient: DesignSystem.goldGradient,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.accentGold.withAlpha(100),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
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
                    // Cowry icon
                    _buildCowryIcon(),
                    const SizedBox(width: 12),
                    
                    // Roll text
                    Text(
                      'ROLL',
                      style: DesignSystem.button.copyWith(
                        fontSize: 18,
                        letterSpacing: 4,
                        color: DesignSystem.bgDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    _buildCowryIcon(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCowryIcon() {
    return Container(
      width: 20,
      height: 12,
      decoration: BoxDecoration(
        color: DesignSystem.bgDark.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
