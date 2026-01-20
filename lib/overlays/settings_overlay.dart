import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Clean, minimal settings overlay
class SettingsOverlay extends StatefulWidget {
  final ISTOGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = feedbackService.soundEnabled;
    _hapticsEnabled = feedbackService.hapticsEnabled;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSound() {
    setState(() {
      _soundEnabled = !_soundEnabled;
      feedbackService.setSoundEnabled(_soundEnabled);
    });
    feedbackService.lightTap();
  }

  void _toggleHaptics() {
    setState(() {
      _hapticsEnabled = !_hapticsEnabled;
      feedbackService.setHapticsEnabled(_hapticsEnabled);
    });
    if (_hapticsEnabled) {
      feedbackService.lightTap();
    }
  }

  void _close() {
    feedbackService.lightTap();
    _controller.reverse().then((_) {
      widget.game.overlays.remove('settings');
    });
  }

  void _showHowToPlay() {
    feedbackService.lightTap();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildHowToPlaySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withAlpha((180 * _fadeAnimation.value).toInt()),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: DesignSystem.cardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            const Divider(color: DesignSystem.border, height: 1),
            
            // Settings items
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: _soundEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                    label: 'Sound',
                    value: _soundEnabled,
                    onToggle: _toggleSound,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildToggleItem(
                    icon: _hapticsEnabled ? Icons.vibration : Icons.smartphone_outlined,
                    label: 'Haptics',
                    value: _hapticsEnabled,
                    onToggle: _toggleHaptics,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Divider(color: DesignSystem.border),
                  
                  const SizedBox(height: 12),
                  
                  // How to play button
                  GestureDetector(
                    onTap: _showHowToPlay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: DesignSystem.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to Play',
                            style: DesignSystem.bodyMedium.copyWith(
                              color: DesignSystem.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SETTINGS',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: DesignSystem.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(color: DesignSystem.border.withAlpha(100)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: value ? DesignSystem.accent : DesignSystem.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.textPrimary,
                ),
              ),
            ),
            // Toggle switch
            AnimatedContainer(
              duration: DesignSystem.animFast,
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: value 
                    ? DesignSystem.accent.withAlpha(80) 
                    : DesignSystem.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value ? DesignSystem.accent : DesignSystem.border,
                ),
              ),
              child: AnimatedAlign(
                duration: DesignSystem.animFast,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: value ? DesignSystem.accent : DesignSystem.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlaySheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: DesignSystem.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOW TO PLAY',
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textMuted,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _buildRuleItem('🎲', 'Roll cowry shells to move'),
                _buildRuleItem('⭐', 'Roll 4 or 8 to enter pawns'),
                _buildRuleItem('🏠', 'Safe squares protect pawns'),
                _buildRuleItem('⚔️', 'Capture opponents on same square'),
                _buildRuleItem('🎯', 'Get all 4 pawns to center to win'),
                _buildRuleItem('✨', 'Roll 4 or 8 for extra turn'),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
