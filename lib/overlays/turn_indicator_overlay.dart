import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme_config.dart';
import '../game/isto_game.dart';
import '../theme/isto_tokens.dart';

/// Top HUD bar — current player, last roll, pawn progress, settings.
/// Terracotta Dusk palette, GoogleFonts Poppins.
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
                IstoColorsDark.bgPrimary.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(IstoRadius.md),
            border: Border.all(
              color: player.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Player indicator dot with glow
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
              // Player name + AI badge
              Expanded(
                child: Row(
                  children: [
                    Text(
                      player.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: IstoColorsDark.textPrimary,
                      ),
                    ),
                    if (isAI) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: IstoColorsDark.accentPrimary.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: IstoColorsDark.accentPrimary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          'AI',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: IstoColorsDark.accentPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Last roll value chip
              if (roll != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        roll.grantsExtraTurn
                            ? IstoColorsDark.accentPrimary.withValues(
                              alpha: 0.15,
                            )
                            : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          roll.grantsExtraTurn
                              ? IstoColorsDark.accentPrimary.withValues(
                                alpha: 0.3,
                              )
                              : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    '${roll.steps}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color:
                          roll.grantsExtraTurn
                              ? IstoColorsDark.accentPrimary
                              : IstoColorsDark.textPrimary,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              _buildPawnProgress(gm),
              const SizedBox(width: 8),
              // Settings gear
              GestureDetector(
                onTap: () => game.overlays.add('settings'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: IstoColorsDark.textMuted,
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
            color:
                isFinished
                    ? IstoColorsDark
                        .accentGlow // Gold for finished per spec §12
                    : isActive
                    ? ThemeConfig.getPlayerColor(playerId)
                    : IstoColorsDark.textMuted.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow:
                isFinished
                    ? [
                      BoxShadow(
                        color: IstoColorsDark.accentGlow.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ]
                    : null,
          ),
        );
      }),
    );
  }
}
