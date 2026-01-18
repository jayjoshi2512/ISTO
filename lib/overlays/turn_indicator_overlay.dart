import 'package:flutter/material.dart';

import '../game/isto_game.dart';

/// Player colors matching board
Color _getPlayerColor(int playerId) {
  switch (playerId) {
    case 0: return const Color(0xFFE57373); // Red (Bottom)
    case 1: return const Color(0xFF81C784); // Green (Top)
    case 2: return const Color(0xFFFFD54F); // Yellow (Left)
    case 3: return const Color(0xFF64B5F6); // Blue (Right)
    default: return const Color(0xFFE57373);
  }
}

/// Turn indicator overlay showing current player
class TurnIndicatorOverlay extends StatelessWidget {
  final ISTOGame game;

  const TurnIndicatorOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final player = game.gameManager.currentPlayer;
    final color = _getPlayerColor(player.id);
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2D1B4E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(60),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${player.name}'s Turn",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
