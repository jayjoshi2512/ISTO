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
    final homeAreaHeight = boardTotalSize * 0.16 + 10;
    final boardY = (size.y - boardTotalSize) / 2 + homeAreaHeight * 0.3;

    boardComponent = BoardComponent(
      position: Vector2(boardX, boardY),
      gameManager: gameManager,
      squareSize: squareSize,
      pawnSize: pawnSize,
      onPawnTap: _onPawnTap,
    );
    add(boardComponent);

    cowryDisplayComponent = CowryDisplayComponent(
      position: Vector2(size.x / 2, size.y - 130),
      onAnimationComplete: _onCowryAnimationDone,
    );
    add(cowryDisplayComponent);

    _setupCallbacks();
    overlays.add(menuOverlay);
  }

  void _calculateSizes() {
    final screenWidth = size.x;
    final screenHeight = size.y;
    final availableWidth = screenWidth - 32;
    final availableHeight = screenHeight - 240;
    final boardArea =
        availableWidth < availableHeight ? availableWidth : availableHeight;

    squareSize = (boardArea - 8) / 5;
    if (squareSize < 40) squareSize = 40;
    if (squareSize > 100) squareSize = 100;
    boardSize = squareSize * 5 + 8;
    pawnSize = squareSize * 0.5;
  }

  /// Called when cowry roll animation finishes — now show highlights
  void _onCowryAnimationDone() {
    gameManager.onCowryAnimationComplete();
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
  int get currentRollValue =>
      gameManager.cowryController.lastRoll?.steps ?? 0;

  // ========== STATE CHANGE HANDLERS ==========

  void _onGameStateChanged() {
    boardComponent.updateDisplay();

    if (gameManager.currentPhase == TurnPhase.waitingForRoll) {
      // Only show roll button for human players
      if (!gameManager.isCurrentPlayerAI) {
        if (!overlays.isActive(rollButtonOverlay)) {
          overlays.add(rollButtonOverlay);
        }
      } else {
        overlays.remove(rollButtonOverlay);
      }
    } else {
      overlays.remove(rollButtonOverlay);
    }
  }

  void _onRollComplete(CowryRoll roll) {
    cowryDisplayComponent.showRoll(roll);
    if (roll.grantsExtraTurn) {
      _feedback.onGraceThrow();
    }
  }

  void _onMoveComplete(Pawn pawn, MoveResult result) {
    highlightedPawns.clear();
    boardComponent.clearHighlights();

    if (result.success) {
      if (!result.wasEntry &&
          result.fromPathIndex != null &&
          result.toPathIndex != null) {
        boardComponent.animatePawnMove(
            pawn, result.fromPathIndex!, result.toPathIndex!);
      }
    }

    _feedback.onPawnMove();

    if (result.killedOpponent) {
      overlays.add('capture');
      _feedback.onCapture();
      for (final victim in result.victims) {
        boardComponent.animatePawnSentHome(victim);
      }
    }

    if (result.reachedCenter) {
      _feedback.onPawnFinish();
    }
  }

  void _onPlayerFinished(int playerId) {}

  void _onGameOver(int winnerId) {
    overlays.add(winOverlay);
    overlays.remove(rollButtonOverlay);
    _feedback.onWin();
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
    overlays.add('extraTurn');
    _feedback.onExtraTurn();
  }

  void _onNoValidMoves() {
    overlays.add('noMoves');
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlays.remove('noMoves');
    });
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
    overlays.remove(winOverlay);
    overlays.remove(menuOverlay);
    highlightedPawns.clear();
    gameManager.startGame(players: playerCount, config: config);
    if (!gameManager.isCurrentPlayerAI) {
      if (!overlays.isActive(rollButtonOverlay)) {
        overlays.add(rollButtonOverlay);
      }
    }
    if (!overlays.isActive(turnIndicatorOverlay)) {
      overlays.add(turnIndicatorOverlay);
    }
  }

  void showMenu() {
    overlays.add(menuOverlay);
  }
}
