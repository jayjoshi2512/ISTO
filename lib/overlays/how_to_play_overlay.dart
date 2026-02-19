import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/isto_game.dart';
import '../theme/isto_tokens.dart';

/// "How to Play" overlay — comprehensive game rules with scrollable sections.
/// Accessible from both the main menu and in-game settings.
class HowToPlayOverlay extends StatefulWidget {
  final ISTOGame? game;
  final VoidCallback? onClose;

  const HowToPlayOverlay({super.key, this.game, this.onClose});

  @override
  State<HowToPlayOverlay> createState() => _HowToPlayOverlayState();
}

class _HowToPlayOverlayState extends State<HowToPlayOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    _ctrl.reverse().then((_) {
      if (!mounted) return;
      if (widget.onClose != null) {
        widget.onClose!();
      } else if (widget.game != null) {
        widget.game!.overlays.remove('howToPlay');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: _close,
            child: FadeTransition(
              opacity: _fade,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          // Panel
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.82),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        IstoColorsDark.bgElevated.withValues(alpha: 0.97),
                        IstoColorsDark.bgSurface.withValues(alpha: 0.97),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(IstoRadius.lg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: IstoColorsDark.accentPrimary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'How to Play',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: IstoColorsDark.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _close,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: IstoColorsDark.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'ISTO (Chowka Bara / Ashta Chamma)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: IstoColorsDark.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _divider(),
                      // Scrollable rules
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _section(
                                '🎯',
                                'Objective',
                                'Be the first player to move all 4 of your pawns '
                                    'from your home base, around the board, and into '
                                    'the center square. The first player to finish all '
                                    '4 pawns wins!',
                              ),
                              _section(
                                '🎲',
                                'Cowry Shells (Dice)',
                                'Instead of dice, this game uses 4 cowry shells. '
                                    'Tap the cowry zone at the bottom to throw them.',
                                bullets: [
                                  _rollRow(
                                    '0 mouth-up',
                                    'ISTO',
                                    '8 steps',
                                    extra: true,
                                    entry: true,
                                  ),
                                  _rollRow('1 mouth-up', '—', '1 step'),
                                  _rollRow('2 mouth-up', '—', '2 steps'),
                                  _rollRow('3 mouth-up', '—', '3 steps'),
                                  _rollRow(
                                    '4 mouth-up',
                                    'Chom',
                                    '4 steps',
                                    extra: true,
                                    entry: true,
                                  ),
                                ],
                              ),
                              _section(
                                '🚪',
                                'Entering the Board',
                                'Your pawns start at home (off the board). '
                                    'A pawn can only enter the board on a special roll:',
                                bullets: [
                                  _bullet('ISTO (0 mouth-up = 8 steps)'),
                                  _bullet('Chom (4 mouth-up = 4 steps)'),
                                  _bullet(
                                    'The pawn enters at your starting X square and '
                                    'moves the rolled steps from there.',
                                  ),
                                ],
                              ),
                              _section(
                                '🔄',
                                'Movement',
                                'Pawns move clockwise around the outer ring of the '
                                    '5×5 board. After completing the outer loop, they '
                                    'enter the inner ring, then finally reach the center.',
                                bullets: [
                                  _bullet(
                                    'Outer ring: 16 squares along the board edges',
                                  ),
                                  _bullet(
                                    'Inner ring: 8 squares around the center',
                                  ),
                                  _bullet(
                                    'Center: The finish — your pawn is home safe!',
                                  ),
                                  _bullet(
                                    'A pawn must land exactly on the center. '
                                    'If the roll exceeds the remaining path, '
                                    'that pawn cannot move.',
                                  ),
                                ],
                              ),
                              _calloutBox(
                                '🚫➡️🔓',
                                'Inner Ring Requirement',
                                'A pawn can ONLY enter the inner ring after you '
                                    'have captured at least one opponent pawn. Until '
                                    'then, your pawns must remain on the outer ring. '
                                    'Look for the colored arrows (➜) on the board '
                                    'showing each player\'s inner ring entry point.',
                              ),
                              _section(
                                '⭐',
                                'Extra Turns',
                                'You get one bonus turn when any of these happen:',
                                bullets: [
                                  _bullet('You roll ISTO (0 mouth-up)'),
                                  _bullet('You roll Chom (4 mouth-up)'),
                                  _bullet('Your pawn reaches the center'),
                                  _bullet('You capture an opponent\'s pawn'),
                                  _bullet(
                                    'Only 1 extra turn per action — multiple '
                                    'triggers in the same move still give just 1.',
                                  ),
                                ],
                              ),
                              _section(
                                '⚔️',
                                'Capturing (Kills)',
                                'Land on a square occupied by an opponent\'s pawn '
                                    'to send it back to their home base.',
                                bullets: [
                                  _bullet(
                                    'Outer ring: You can capture a single enemy pawn. '
                                    'Only 1 pawn per square on the outer ring.',
                                  ),
                                  _bullet(
                                    'Inner ring: You can capture a single enemy, OR '
                                    'use a pair of your stacked pawns to capture '
                                    'an enemy pair.',
                                  ),
                                  _bullet(
                                    'You cannot capture on safe squares (X marks) '
                                    'or the center.',
                                  ),
                                  _bullet(
                                    'Capturing grants you an extra turn!',
                                  ),
                                ],
                              ),
                              _section(
                                '✕',
                                'Safe Squares',
                                'The 4 starting positions (marked with X on the board) '
                                    'and the center square are safe zones — no pawn '
                                    'can be captured while resting on them.',
                              ),
                              _section(
                                '👥',
                                'Stacking (Inner Path)',
                                'On the inner ring, your own pawns can stack on '
                                    'the same square.',
                                bullets: [
                                  _bullet(
                                    'When you move a stacked pawn, you choose '
                                    'how many to move together (1 or more).',
                                  ),
                                  _bullet(
                                    'A pair of stacked pawns can capture an '
                                    'enemy pair on the inner ring.',
                                  ),
                                  _bullet(
                                    'On the outer ring, multiple pawns may rest on '
                                    'safe squares (marked with X), but they move '
                                    'independently — not as a stack.',
                                  ),
                                ],
                              ),
                              _section(
                                '⏭️',
                                'Skipping Turns',
                                'If no valid moves are available with your roll, '
                                    'your turn is automatically skipped and play '
                                    'passes to the next player.',
                              ),
                              _section(
                                '🏆',
                                'Winning',
                                'The game continues until all but one player finishes. '
                                    'Players are ranked in the order they complete.',
                                bullets: [
                                  _bullet(
                                    '1st to finish all 4 pawns = Winner (1st place)',
                                  ),
                                  _bullet(
                                    'Game continues for remaining players',
                                  ),
                                  _bullet('Last remaining player = last place'),
                                ],
                              ),
                              _section(
                                '💡',
                                'Tips & Strategy',
                                null,
                                bullets: [
                                  _bullet(
                                    'Spread your pawns — don\'t bunch up on one.',
                                  ),
                                  _bullet(
                                    'Use safe squares (X) to protect pawns from capture.',
                                  ),
                                  _bullet(
                                    'Prioritize advancing inner-ring pawns toward center.',
                                  ),
                                  _bullet(
                                    'Watch for opponent pawns near your path — '
                                    'choose a pawn that can capture!',
                                  ),
                                  _bullet(
                                    'On the inner ring, stack pawns for paired defense '
                                    'and paired captures.',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _section(
    String emoji,
    String title,
    String? body, {
    List<Widget>? bullets,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: IstoColorsDark.accentPrimary,
                ),
              ),
            ],
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                height: 1.55,
                color: IstoColorsDark.textSecondary,
              ),
            ),
          ],
          if (bullets != null) ...[const SizedBox(height: 8), ...bullets],
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: IstoColorsDark.textMuted.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color: IstoColorsDark.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calloutBox(String emoji, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IstoColorsDark.accentPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: IstoColorsDark.accentPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: IstoColorsDark.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.55,
              color: IstoColorsDark.textPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rollRow(
    String roll,
    String name,
    String steps, {
    bool extra = false,
    bool entry = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            extra
                ? IstoColorsDark.accentPrimary.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(6),
        border:
            extra
                ? Border.all(
                  color: IstoColorsDark.accentPrimary.withValues(alpha: 0.15),
                )
                : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              roll,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: IstoColorsDark.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: extra ? FontWeight.w700 : FontWeight.w400,
                color:
                    extra
                        ? IstoColorsDark.accentPrimary
                        : IstoColorsDark.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              steps,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: IstoColorsDark.textSecondary,
              ),
            ),
          ),
          if (extra)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: IstoColorsDark.accentGlow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'EXTRA',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: IstoColorsDark.accentGlow,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          if (entry)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: IstoColorsDark.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ENTRY',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: IstoColorsDark.safeSquareBorder,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
