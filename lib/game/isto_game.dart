import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../models/models.dart';
import '../components/components.dart';
import '../services/feedback_service.dart';
import 'game_manager.dart';

/// Main Flame game class for ISTO
class ISTOGame extends FlameGame with TapCallbacks {
  late final GameManager gameManager;
  late BoardComponent boardComponent;
  late CowryDisplayComponent cowryDisplayComponent;
  final FeedbackService _feedback = feedbackService;

  List<Pawn> highlightedPawns = [];

  // Calculated sizes based on screen
  late double squareSize;
  late double boardSize;
  late double pawnSize;

  // Overlay identifiers
  static const String rollButtonOverlay = 'rollButton';
  static const String turnIndicatorOverlay = 'turnIndicator';
  static const String winOverlay = 'win';
  static const String menuOverlay = 'menu';
  static const String stackedPawnDialogOverlay = 'stackedPawnDialog';

  // Stacked pawn selection state
  Pawn? _pendingStackedPawn;
  List<Pawn>? _pendingStackedPawns;

  // ========== EVENT QUEUE ==========
  // Serializes game events so the next one only fires after the previous
  // animation/sound finishes. Prevents overlapping sounds & mixed animations.
  final List<_GameEvent> _eventQueue = [];
  bool _eventRunning = false;

  void _enqueue(_GameEvent event) {
    _eventQueue.add(event);
    _drainQueue();
  }

  void _drainQueue() {
    if (_eventRunning || _eventQueue.isEmpty) return;
    _eventRunning = true;
    final event = _eventQueue.removeAt(0);
    event.run(() {
      _eventRunning = false;
      _drainQueue();
    });
  }

  /// Flush the queue (e.g. when starting a new game)
  void _clearEventQueue() {
    _eventQueue.clear();
    _eventRunning = false;
  }

  ISTOGame() {
    gameManager = GameManager();
  }

  @override
  Color backgroundColor() => DesignSystem.bgDark;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _calculateSizes();

    final boardTotalSize = 5 * squareSize + 4 * 2;
    final boardX = (size.x - boardTotalSize) / 2;

    // Home areas in LayoutConfig use: height = boardTotalSize * 0.16, offset = 10
    // Top areas sit at y = -(height+offset) relative to board origin
    // Bottom areas sit at y = boardTotalSize + offset
    final homeHeight = boardTotalSize * 0.16;
    final homeOffset = 10.0;
    // Label height above top home area (name text + gap)
    final labelAboveHome = 16.0;
    final spaceAboveBoard = labelAboveHome + homeHeight + homeOffset;
    final spaceBelowBoard =
        homeHeight + homeOffset + 16.0; // 16 for label below

    final hudHeight = 60.0;
    final bottomPadding = 12.0;
    final cowryZoneHeight = 100.0;

    // Total content from top to bottom:
    final totalNeeded =
        hudHeight +
        4 +
        spaceAboveBoard +
        boardTotalSize +
        spaceBelowBoard +
        8 +
        cowryZoneHeight +
        bottomPadding;

    // Board Y: ensures top home labels clear HUD
    double boardY;
    if (totalNeeded <= size.y) {
      final extra = size.y - totalNeeded;
      boardY = hudHeight + 4 + spaceAboveBoard + extra * 0.25;
    } else {
      boardY = hudHeight + 4 + spaceAboveBoard;
    }

    // Bottom of the bottom home areas (including label)
    final bottomHomesEnd =
        boardY + boardTotalSize + homeOffset + homeHeight + 16;
    // Cowry zone uses ALL available space below home areas
    final availableCowryHeight = (size.y - bottomPadding - bottomHomesEnd)
        .clamp(60.0, 200.0);
    final cowryY = bottomHomesEnd + availableCowryHeight / 2;
    final cowryWidth = size.x - 16; // Full width with small padding

    boardComponent = BoardComponent(
      position: Vector2(boardX, boardY),
      gameManager: gameManager,
      squareSize: squareSize,
      pawnSize: pawnSize,
      onPawnTap: _onPawnTap,
    );
    add(boardComponent);

    cowryDisplayComponent = CowryDisplayComponent(
      position: Vector2(size.x / 2, cowryY),
      componentSize: Vector2(cowryWidth, availableCowryHeight),
      onAnimationComplete: _onCowryAnimationDone,
      onTap: _onCowryTap,
    );
    add(cowryDisplayComponent);

    _setupCallbacks();
    overlays.add(menuOverlay);
  }

  void _calculateSizes() {
    final screenWidth = size.x;
    final screenHeight = size.y;
    final availableWidth = screenWidth - 32;
    // Reserve height for: HUD(60) + gap(8) + topHome + board + bottomHome + gap(12) + cowry(100) + padding(16)
    // topHome + bottomHome = 2 * (board * 0.16 + 10)
    // So total non-board = 60 + 8 + 2*(board*0.16+10) + 12 + 100 + 16 = 216 + 0.32*board
    // board + 0.32*board = 1.32*board = screenHeight - 216
    // board = (screenHeight - 216) / 1.32
    // Account for: HUD(60) + gap(4) + labelAbove(16) + topHome(board*0.16+10) + board
    // + bottomHome(board*0.16+10+16) + gap(8) + cowry(100) + padding(12)
    // Non-board = 60+4+16+10+10+16+8+100+12 = 236 + 0.32*board
    // 1.32*board = screenHeight - 236
    final availableForBoard = (screenHeight - 236) / 1.32;
    final boardArea =
        availableWidth < availableForBoard ? availableWidth : availableForBoard;

    squareSize = (boardArea - 8) / 5;
    if (squareSize < 40) squareSize = 40;
    if (squareSize > 80) squareSize = 80;
    boardSize = squareSize * 5 + 8;
    pawnSize = squareSize * 0.5;
  }

  void _setupCallbacks() {
    gameManager.onStateChanged = _onGameStateChanged;
    gameManager.onRollComplete = _onRollComplete;
    gameManager.onMoveComplete = _onMoveComplete;
    gameManager.onPlayerFinished = _onPlayerFinished;
    gameManager.onGameOver = _onGameOver;
    gameManager.onValidMovesCalculated = _onValidMovesCalculated;
    gameManager.onExtraTurn = _onExtraTurn;
    gameManager.onNoValidMoves = _onNoValidMoves;
    gameManager.onStackedPawnChoice = _onStackedPawnChoiceNeeded;

    // AI callbacks
    gameManager.onAIRoll = _onAIRoll;
    gameManager.onAIMove = _onAIMove;
  }

  // ========== AI HANDLERS ==========

  void _onAIRoll() {
    // AI automatically rolls
    if (gameManager.currentPhase == TurnPhase.waitingForRoll &&
        gameManager.isCurrentPlayerAI) {
      rollCowries();
    }
  }

  void _onAIMove(Pawn pawn) {
    // Visual feedback that AI is selecting this pawn
    boardComponent.flashPawn(pawn);
  }

  // ========== STACKED PAWN HANDLERS ==========

  void _onStackedPawnChoiceNeeded(Pawn pawn, int stackedCount) {
    _pendingStackedPawn = pawn;
    _pendingStackedPawns = gameManager.getStackedPawns(pawn);
    overlays.add(stackedPawnDialogOverlay);
  }

  void onStackedPawnChoice(int pawnCount) {
    overlays.remove(stackedPawnDialogOverlay);

    if (_pendingStackedPawn != null) {
      final pawn = _pendingStackedPawn!;
      _pendingStackedPawn = null;
      _pendingStackedPawns = null;

      // Use GameManager.selectPawn with movePawnCount
      // This avoids duplicate logic
      gameManager.selectPawn(pawn, movePawnCount: pawnCount);
      highlightedPawns.clear();
      boardComponent.clearHighlights();
    }
  }

  List<Pawn>? get pendingStackedPawns => _pendingStackedPawns;
  int get currentRollValue => gameManager.cowryController.lastRoll?.steps ?? 0;

  // ========== COWRY TAP (replaces roll button) ==========

  void _onCowryTap() {
    if (gameManager.currentPhase == TurnPhase.waitingForRoll &&
        !gameManager.isCurrentPlayerAI) {
      rollCowries();
    }
  }

  // ========== STATE CHANGE HANDLERS ==========

  void _onGameStateChanged() {
    boardComponent.updateDisplay();
  }

  void _onRollComplete(CowryRoll roll) {
    _enqueue(
      _GameEvent(
        name: 'roll',
        run: (done) {
          cowryDisplayComponent.showRoll(roll);
          // Sound fires at animation start
          if (roll.grantsExtraTurn) {
            _feedback.onGraceThrow();
          } else {
            _feedback.onRoll();
          }
          // Cowry animation is ~1.3s. onCowryAnimationDone fires when it ends.
          // The queue event completes when cowry animation callback fires.
          _pendingRollDone = done;
        },
      ),
    );
  }

  VoidCallback? _pendingRollDone;

  /// Called when cowry roll animation finishes — now show highlights
  void _onCowryAnimationDone() {
    gameManager.onCowryAnimationComplete();
    // Complete the queued roll event
    final done = _pendingRollDone;
    _pendingRollDone = null;
    done?.call();
  }

  void _onMoveComplete(Pawn pawn, MoveResult result) {
    highlightedPawns.clear();
    boardComponent.clearHighlights();

    if (result.success) {
      if (!result.wasEntry &&
          result.fromPathIndex != null &&
          result.toPathIndex != null) {
        final fromIdx = result.fromPathIndex!;
        final toIdx = result.toPathIndex!;
        final hopCount = (toIdx - fromIdx).abs();
        // Estimate hop animation duration: hops * hopDuration + landing buffer
        final hopMs = hopCount <= 2 ? 360 : (hopCount <= 4 ? 315 : 265);
        final totalMs = hopCount * hopMs + 200; // +200ms landing settle

        _enqueue(
          _GameEvent(
            name: 'pawnMove',
            run: (done) {
              boardComponent.animatePawnMove(pawn, fromIdx, toIdx);
              // Complete after animation duration
              Future.delayed(Duration(milliseconds: totalMs), done);
            },
          ),
        );
      } else if (result.wasEntry) {
        _enqueue(
          _GameEvent(
            name: 'pawnEnter',
            run: (done) {
              _feedback.onPawnEnter();
              Future.delayed(const Duration(milliseconds: 450), done);
            },
          ),
        );
      }
    }

    if (result.killedOpponent) {
      _enqueue(
        _GameEvent(
          name: 'capture',
          run: (done) {
            overlays.add('capture');
            _feedback.onCapture();
            for (final victim in result.victims) {
              final idx = result.victimPathIndices[victim.id] ?? 0;
              boardComponent.animatePawnSentHome(victim, idx);
            }
            // Poll until all retreat animations finish, then proceed
            void waitForRetreats() {
              if (boardComponent.hasActiveRetreatAnims) {
                Future.delayed(
                  const Duration(milliseconds: 80),
                  waitForRetreats,
                );
              } else {
                Future.delayed(const Duration(milliseconds: 300), done);
              }
            }

            // Give a small initial delay for the overlay to show
            Future.delayed(const Duration(milliseconds: 200), waitForRetreats);
          },
        ),
      );
    }

    if (result.reachedCenter) {
      _enqueue(
        _GameEvent(
          name: 'reachCenter',
          run: (done) {
            _feedback.onPawnFinish();
            Future.delayed(const Duration(milliseconds: 1400), done);
          },
        ),
      );
    }
  }

  void _onPlayerFinished(int playerId) {}

  void _onGameOver(int winnerId) {
    _enqueue(
      _GameEvent(
        name: 'gameOver',
        run: (done) {
          overlays.add(winOverlay);
          _feedback.onWin();
          // Don't call done — game is over, queue should stop
        },
      ),
    );
  }

  void _onValidMovesCalculated(List<Pawn> validPawns) {
    highlightedPawns = List.from(validPawns);
    boardComponent.highlightValidPawns(validPawns);

    if (validPawns.isNotEmpty && !gameManager.isCurrentPlayerAI) {
      _feedback.lightTap();
      // Auto-play if only one valid move (human players only) — wait 600ms
      if (validPawns.length == 1) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (highlightedPawns.length == 1 &&
              gameManager.currentPhase == TurnPhase.selectingPawn &&
              !gameManager.isCurrentPlayerAI) {
            _selectPawn(validPawns.first);
          }
        });
      }
    }
  }

  void _onExtraTurn() {
    _enqueue(
      _GameEvent(
        name: 'extraTurn',
        run: (done) {
          overlays.add('extraTurn');
          _feedback.onExtraTurn();
          Future.delayed(const Duration(milliseconds: 1200), done);
        },
      ),
    );
  }

  void _onNoValidMoves() {
    _enqueue(
      _GameEvent(
        name: 'noMoves',
        run: (done) {
          _feedback.onNoMoves();
          overlays.add('noMoves');
          Future.delayed(const Duration(milliseconds: 1500), () {
            overlays.remove('noMoves');
            done();
          });
        },
      ),
    );
  }

  // ========== PAWN INTERACTION ==========

  void _onPawnTap(Pawn pawn) {
    // Don't allow tapping during AI turn
    if (gameManager.isCurrentPlayerAI) return;

    if (highlightedPawns.any((p) => p.id == pawn.id)) {
      _selectPawn(pawn);
    }
  }

  void _selectPawn(Pawn pawn) {
    _feedback.onPawnSelect();
    final result = gameManager.selectPawn(pawn);
    if (result.success) {
      highlightedPawns.clear();
      boardComponent.clearHighlights();
    }
  }

  /// Roll the cowries (called from overlay)
  void rollCowries() {
    if (gameManager.currentPhase == TurnPhase.waitingForRoll) {
      _feedback.mediumTap();
      gameManager.roll();
    }
  }

  /// Start a new game with config
  void startNewGame(int playerCount, {GameConfig? config}) {
    _clearEventQueue();
    overlays.remove(winOverlay);
    overlays.remove(menuOverlay);
    highlightedPawns.clear();
    gameManager.startGame(players: playerCount, config: config);
    if (!overlays.isActive(turnIndicatorOverlay)) {
      overlays.add(turnIndicatorOverlay);
    }
  }

  void showMenu() {
    overlays.add(menuOverlay);
  }
}

// =============================================================================
// Event queue item — wraps a game event with a completion callback.
// =============================================================================
class _GameEvent {
  final String name;
  final void Function(VoidCallback done) run;
  _GameEvent({required this.name, required this.run});
}
