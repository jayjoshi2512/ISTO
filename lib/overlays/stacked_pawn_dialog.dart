import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../models/models.dart';

/// Dialog to ask user how many stacked pawns to move
class StackedPawnDialog extends StatelessWidget {
  final ISTOGame game;
  final List<Pawn> stackedPawns;
  final int rollValue;
  final Function(int pawnCount) onChoice;

  const StackedPawnDialog({
    super.key,
    required this.game,
    required this.stackedPawns,
    required this.rollValue,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DesignSystem.surface,
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            border: Border.all(
              color: DesignSystem.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                '${stackedPawns.length} Pawns Stacked',
                style: DesignSystem.headingMedium.copyWith(
                  color: DesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'You rolled $rollValue. How many pawns to move?',
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Info text explaining the rule
              Text(
                'Total steps = $rollValue (divided among pawns)',
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Pawn preview
              _buildPawnPreview(),
              const SizedBox(height: 24),
              
              // Flexible buttons based on valid divisors
              _buildMoveButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoveButtons() {
    final pawnCount = stackedPawns.length;
    
    // Build buttons only for valid divisors
    // Rule: steps_per_pawn = rollValue / pawnCount
    // Only show option if rollValue divides evenly by pawn count
    final validOptions = <int>[];
    
    // Option 1: Always can move 1 pawn (full roll value)
    validOptions.add(1);
    
    // Check which multi-pawn options are valid (roll must divide evenly)
    for (int count = 2; count <= pawnCount; count++) {
      if (rollValue % count == 0) {
        validOptions.add(count);
      }
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: validOptions.map((count) {
        final stepsPerPawn = rollValue ~/ count;
        final isAll = count == pawnCount;
        final label = count == 1 
            ? 'Move 1 ($rollValue steps)'
            : isAll 
                ? 'Move All ($count × $stepsPerPawn steps)'
                : 'Move $count ($stepsPerPawn steps each)';
        
        return _buildButton(
          label,
          isAll ? DesignSystem.accent : DesignSystem.surfaceLight,
          isAll ? Colors.black : DesignSystem.textPrimary,
          () => onChoice(count),
          isAll,
        );
      }).toList(),
    );
  }

  Widget _buildPawnPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stackedPawns.map((pawn) {
        final color = game.gameManager.players[pawn.playerId].color;
        return Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withAlpha(100),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.star,
              size: 16,
              color: Colors.white.withAlpha(180),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text, Color bg, Color textColor, VoidCallback onTap, bool isPrimary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: isPrimary ? 32 : 24,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isPrimary ? DesignSystem.accent : DesignSystem.border,
            width: isPrimary ? 2 : 1,
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: DesignSystem.accent.withAlpha(50),
              blurRadius: 8,
            ),
          ] : null,
        ),
        child: Text(
          text,
          style: DesignSystem.button.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}
