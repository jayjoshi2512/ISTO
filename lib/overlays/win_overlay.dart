import 'package:flutter/material.dart';

import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Win overlay shown when a player wins
class WinOverlay extends StatefulWidget {
  final ISTOGame game;

  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    
    // Trigger haptic feedback on win
    feedbackService.onWin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.game.gameManager.winner;
    if (winner == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withAlpha((200 * _fadeAnimation.value).toInt()),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: winner.color,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: winner.color.withAlpha(100),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Icon(
              Icons.emoji_events,
              size: 64,
              color: winner.color,
            ),
            const SizedBox(height: 16),

            // Winner text
            Text(
              '${winner.name} Wins!',
              style: TextStyle(
                color: winner.color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Rankings
            ..._buildRankings(),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  'Play Again',
                  const Color(0xFF4ECCA3),
                  () => widget.game.startNewGame(
                      widget.game.gameManager.playerCount),
                ),
                const SizedBox(width: 16),
                _buildButton(
                  'Menu',
                  const Color(0xFF8B0000),
                  () => widget.game.showMenu(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRankings() {
    final rankings = widget.game.gameManager.rankings;
    final widgets = <Widget>[];

    for (int i = 0; i < rankings.length; i++) {
      final player = rankings[i];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${i + 1}.',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                player.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
