import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/theme_config.dart';
import '../game/isto_game.dart';

/// Top bar showing current player, last roll, and settings access
class TurnIndicatorOverlay extends StatelessWidget {
  final ISTOGame game;

  const TurnIndicatorOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final gm = game.gameManager;
    final player = gm.currentPlayer;
    final roll = gm.cowryController.lastRoll;
    final isAI = gm.isCurrentPlayerAI;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                player.color.withValues(alpha: 0.15),
                DesignSystem.bgDark.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
            border: Border.all(
              color: player.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Player indicator dot
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: player.color.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Player name and AI badge
              Expanded(
                child: Row(
                  children: [
                    Text(
                      player.name,
                      style: DesignSystem.bodyLarge.copyWith(
                        color: DesignSystem.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isAI) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DesignSystem.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: DesignSystem.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'AI',
                          style: DesignSystem.caption.copyWith(
                            color: DesignSystem.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Last roll value
              if (roll != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roll.grantsExtraTurn
                        ? DesignSystem.accent.withValues(alpha: 0.15)
                        : DesignSystem.surfaceGlass,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: roll.grantsExtraTurn
                          ? DesignSystem.accent.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    '${roll.steps}',
                    style: DesignSystem.bodyLarge.copyWith(
                      color: roll.grantsExtraTurn
                          ? DesignSystem.accent
                          : DesignSystem.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              // Player pawns progress
              _buildPawnProgress(gm),
              const SizedBox(width: 8),
              // Settings button
              GestureDetector(
                onTap: () => game.overlays.add('settings'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: DesignSystem.surfaceGlass,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: DesignSystem.textMuted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPawnProgress(dynamic gm) {
    final playerId = gm.turnStateMachine.currentPlayerId as int;
    final pawns = gm.pawnController.getPawnsForPlayer(playerId);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final pawn = pawns.length > i ? pawns[i] : null;
        final isFinished = pawn?.isFinished ?? false;
        final isActive = pawn?.isActive ?? false;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isFinished
                ? DesignSystem.success
                : isActive
                    ? ThemeConfig.getPlayerColor(playerId)
                    : DesignSystem.textMuted.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
