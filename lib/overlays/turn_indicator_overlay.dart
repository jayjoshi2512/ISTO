import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../config/game_feel_config.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Clean, minimal turn indicator with integrated controls and enhanced turn-change animation
class TurnIndicatorOverlay extends StatefulWidget {
  final ISTOGame game;

  const TurnIndicatorOverlay({super.key, required this.game});

  @override
  State<TurnIndicatorOverlay> createState() => _TurnIndicatorOverlayState();
}

class _TurnIndicatorOverlayState extends State<TurnIndicatorOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _colorSweepController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _colorSweepAnimation;
  late Animation<double> _glowAnimation;
  int? _lastPlayerId;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for turn change
    _pulseController = AnimationController(
      duration: GameFeelConfig.turnChangeDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: GameFeelConfig.turnPulseScale).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
    
    // Color sweep animation for dramatic turn change
    _colorSweepController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _colorSweepAnimation = CurvedAnimation(
      parent: _colorSweepController,
      curve: Curves.easeInOut,
    );
    
    // Subtle glow breathing animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    if (GameFeelConfig.idleBreathingEnabled) {
      _glowController.repeat(reverse: true);
    }

    _lastPlayerId = widget.game.gameManager.currentPlayer.id;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _colorSweepController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _checkForTurnChange() {
    final currentId = widget.game.gameManager.currentPlayer.id;
    if (_lastPlayerId != currentId) {
      _lastPlayerId = currentId;
      
      // Trigger pulse animation on turn change
      _pulseController.forward(from: 0).then((_) => _pulseController.reverse());
      
      // Trigger color sweep if enabled
      if (GameFeelConfig.turnColorSweepEnabled) {
        _colorSweepController.forward(from: 0);
      }
      
      // Haptic feedback for turn change
      feedbackService.onTurnStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkForTurnChange();

    final player = widget.game.gameManager.currentPlayer;
    final color = PlayerColors.getColor(player.id);
    final lastRoll = widget.game.gameManager.cowryController.lastRoll;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([_colorSweepAnimation, _glowAnimation]),
        builder: (context, child) {
          // Color sweep effect across the header
          final sweepProgress = _colorSweepAnimation.value;
          final glowIntensity = _glowAnimation.value;
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(
                    DesignSystem.bgDark,
                    color.withAlpha(40),
                    sweepProgress * 0.5,
                  )!,
                  DesignSystem.bgDark.withAlpha(200),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Settings button
                    _buildIconButton(
                      icon: Icons.settings_outlined,
                      onTap: () {
                        feedbackService.lightTap();
                        widget.game.overlays.add('settings');
                      },
                      glowIntensity: glowIntensity,
                    ),

                    const Spacer(),

                    // Animated turn indicator chip
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildTurnChip(player.name, color, lastRoll?.steps, glowIntensity),
                    ),

                    const Spacer(),

                    // Menu button
                    _buildIconButton(
                      icon: Icons.menu,
                      onTap: () {
                        feedbackService.lightTap();
                        widget.game.showMenu();
                      },
                      glowIntensity: glowIntensity,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    double glowIntensity = 1.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DesignSystem.surface.withAlpha(180),
          shape: BoxShape.circle,
          border: Border.all(color: DesignSystem.border.withAlpha(100)),
        ),
        child: Icon(icon, color: DesignSystem.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildTurnChip(String playerName, Color playerColor, int? lastRoll, [double glowIntensity = 1.0]) {
    final isGraceThrow = lastRoll == 4 || lastRoll == 8;
    final glowRadius = GameFeelConfig.turnIndicatorGlow * glowIntensity;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: DesignSystem.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(color: playerColor.withAlpha(200), width: 2.0),
        boxShadow: [
          // Player color glow - enhanced with breathing
          BoxShadow(
            color: playerColor.withAlpha((80 * glowIntensity).toInt()),
            blurRadius: glowRadius + 8,
            spreadRadius: 2,
          ),
          // Inner highlight
          BoxShadow(
            color: playerColor.withAlpha((30 * glowIntensity).toInt()),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player color dot with pulsing glow
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: playerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: playerColor.withAlpha((200 * glowIntensity).toInt()),
                  blurRadius: 10 * glowIntensity,
                  spreadRadius: 2 * glowIntensity,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Player name with emphasis
          Text(
            playerName.toUpperCase(),
            style: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),

          // Last roll (if any)
          if (lastRoll != null) ...[
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isGraceThrow
                        ? DesignSystem.accentGold.withAlpha(30)
                        : DesignSystem.bgLight,
                borderRadius: BorderRadius.circular(10),
                border:
                    isGraceThrow
                        ? Border.all(
                          color: DesignSystem.accentGold.withAlpha(100),
                        )
                        : null,
                boxShadow:
                    isGraceThrow
                        ? [
                          BoxShadow(
                            color: DesignSystem.accentGold.withAlpha(60),
                            blurRadius: 8,
                          ),
                        ]
                        : null,
              ),
              child: Text(
                '$lastRoll',
                style: TextStyle(
                  color:
                      isGraceThrow
                          ? DesignSystem.accentGold
                          : DesignSystem.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
