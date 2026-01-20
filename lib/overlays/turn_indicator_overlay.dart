import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Clean, minimal turn indicator with integrated controls
class TurnIndicatorOverlay extends StatelessWidget {
  final ISTOGame game;

  const TurnIndicatorOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final player = game.gameManager.currentPlayer;
    final color = PlayerColors.getColor(player.id);
    final lastRoll = game.gameManager.cowryController.lastRoll;
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DesignSystem.bgDark,
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
                    game.overlays.add('settings');
                  },
                ),
                
                const Spacer(),
                
                // Turn indicator chip
                _buildTurnChip(player.name, color, lastRoll?.steps),
                
                const Spacer(),
                
                // Menu button
                _buildIconButton(
                  icon: Icons.menu,
                  onTap: () {
                    feedbackService.lightTap();
                    game.showMenu();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DesignSystem.surface.withAlpha(180),
          shape: BoxShape.circle,
          border: Border.all(
            color: DesignSystem.border.withAlpha(100),
          ),
        ),
        child: Icon(
          icon,
          color: DesignSystem.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTurnChip(String playerName, Color playerColor, int? lastRoll) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: DesignSystem.surface.withAlpha(200),
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
        border: Border.all(
          color: playerColor.withAlpha(150),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: playerColor.withAlpha(40),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player color dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: playerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: playerColor.withAlpha(150),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Player name
          Text(
            playerName,
            style: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Last roll (if any)
          if (lastRoll != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DesignSystem.bgLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$lastRoll',
                style: TextStyle(
                  color: lastRoll == 4 || lastRoll == 8
                      ? DesignSystem.accentGold
                      : DesignSystem.textSecondary,
                  fontSize: 12,
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
