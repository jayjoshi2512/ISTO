import 'package:flutter/material.dart';

import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Player colors matching the board component
Color _getPlayerColor(int playerId) {
  switch (playerId) {
    case 0: return const Color(0xFFE57373); // Red (Bottom)
    case 1: return const Color(0xFF81C784); // Green (Top)
    case 2: return const Color(0xFFFFD54F); // Yellow (Left)
    case 3: return const Color(0xFF64B5F6); // Blue (Right)
    default: return const Color(0xFFE57373);
  }
}

/// Menu overlay for game settings and new game
class MenuOverlay extends StatefulWidget {
  final ISTOGame game;

  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withAlpha((200 * _fadeAnimation.value).toInt()),
            child: SafeArea(
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D1B4E),
                Color(0xFF1A1030),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6B4FA0).withAlpha(100),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4FA0).withAlpha(30),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'ISTO',
                style: TextStyle(
                  color: Color(0xFFE0B0FF),
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Chowka Bhara',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Player count selection
              const Text(
                'SELECT PLAYERS',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Player count buttons in a row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlayerCountButton(2),
                  const SizedBox(width: 12),
                  _buildPlayerCountButton(3),
                  const SizedBox(width: 12),
                  _buildPlayerCountButton(4),
                ],
              ),

              const SizedBox(height: 24),

              // Close button (smaller)
              TextButton(
                onPressed: () {
                  feedbackService.lightTap();
                  widget.game.overlays.remove(ISTOGame.menuOverlay);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCountButton(int count) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          feedbackService.mediumTap();
          widget.game.startNewGame(count);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6B4FA0).withAlpha(50),
                const Color(0xFF6B4FA0).withAlpha(25),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6B4FA0).withAlpha(80),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  count,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getPlayerColor(i),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
