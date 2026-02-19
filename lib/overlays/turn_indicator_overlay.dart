import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme_config.dart';
import '../game/isto_game.dart';
import '../theme/isto_tokens.dart';

/// Top HUD bar — current player name, color indicator, pawn progress, settings.
/// Navy & Flame palette, GoogleFonts Poppins.
/// No roll number shown — clean player-centric design.
class TurnIndicatorOverlay extends StatelessWidget {
  final ISTOGame game;

  const TurnIndicatorOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final gm = game.gameManager;
    final player = gm.currentPlayer;
    final isAI = gm.isCurrentPlayerAI;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: IstoColorsDark.bgSurface,
            borderRadius: BorderRadius.circular(IstoRadius.md),
            border: Border.all(
              color: player.color.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: player.color.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Player color indicator — glowing dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: player.color.withValues(alpha: 0.7),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Player name (prominent) + AI badge
              Expanded(
                child: Row(
                  children: [
                    Text(
                      player.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: player.color,
                        letterSpacing: 0.5,
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
                          color: player.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: player.color.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'AI',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: player.color,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // "YOUR TURN" / "AI TURN" label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: player.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAI ? 'AI TURN' : 'YOUR TURN',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: player.color,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildPawnProgress(gm),
              const SizedBox(width: 10),
              // Settings gear
              GestureDetector(
                onTap: () => game.overlays.add('settings'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: IstoColorsDark.bgElevated,
                    shape: BoxShape.circle,
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
    final playerColor = ThemeConfig.getPlayerColor(playerId);
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
                    ? IstoColorsDark.centerHomeGlow // Gold for finished
                    : isActive
                    ? playerColor
                    : IstoColorsDark.textMuted.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow:
                isFinished
                    ? [
                      BoxShadow(
                        color: IstoColorsDark.centerHomeGlow.withValues(
                          alpha: 0.5,
                        ),
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
