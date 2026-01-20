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

  // Overlays
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
    
    // Calculate responsive sizes for the screen
    _calculateSizes();

    // Calculate board position (centered, with space for home areas)
    final boardTotalSize = 5 * squareSize + 4 * 1; // 5 squares + 4 gaps of 1px
    final boardX = (size.x - boardTotalSize) / 2;
    
    // Reserve space for home areas
    // Home area height = boardTotalSize * 0.16, offset = 10
    final homeAreaHeight = boardTotalSize * 0.16 + 10;
    
    // For 3/4 players, we need space both top and bottom
    // For 2 players, only bottom
    // Adjust center point to account for this
    final boardY = (size.y - boardTotalSize) / 2 + homeAreaHeight * 0.3;

    // Create board component
    boardComponent = BoardComponent(
      position: Vector2(boardX, boardY),
      gameManager: gameManager,
      squareSize: squareSize,
      pawnSize: pawnSize,
      onPawnTap: _onPawnTap,
    );
    add(boardComponent);

    // Create cowry display - positioned between board and roll button area
    // More visible position above the bottom UI
    cowryDisplayComponent = CowryDisplayComponent(
      position: Vector2(size.x / 2, size.y - 130),
    );
    add(cowryDisplayComponent);

    // Setup game manager callbacks
    _setupCallbacks();

    // Show menu at start for player selection
    overlays.add(menuOverlay);
  }
  
  void _calculateSizes() {
    // Optimize for mobile screens - MAXIMIZE board size
    final screenWidth = size.x;
    final screenHeight = size.y;
    
    // Reserve space for UI elements:
    // - Top: ~80px for turn indicator
    // - Bottom: ~140px for cowry display + roll button
    // - Sides: ~16px padding each
    final availableWidth = screenWidth - 32;
    final availableHeight = screenHeight - 220; // 80 top + 140 bottom
    
    // Use the smaller dimension for board
    final boardArea = availableWidth < availableHeight ? availableWidth : availableHeight;
    
    // Board is 5 squares + 4 gaps (2px each)
    squareSize = (boardArea - 8) / 5;
    
    // Allow larger squares - up to 100px
    if (squareSize < 40) squareSize = 40;
    if (squareSize > 100) squareSize = 100;
    
    boardSize = squareSize * 5 + 8;
    
    // Pawn size relative to square
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
  }
  
  void _onStackedPawnChoiceNeeded(Pawn pawn, int stackedCount) {
    // Store the pending pawn and show dialog
    _pendingStackedPawn = pawn;
    _pendingStackedPawns = gameManager.getStackedPawns(pawn);
    overlays.add(stackedPawnDialogOverlay);
  }
  
  /// Handle user's choice on stacked pawn movement - now takes count
  void onStackedPawnChoice(int pawnCount) {
    overlays.remove(stackedPawnDialogOverlay);
    
    if (_pendingStackedPawn != null) {
      final pawn = _pendingStackedPawn!;
      _pendingStackedPawn = null;
      _pendingStackedPawns = null;
      
      // Execute move with specified pawn count
      _executeStackedPawnMove(pawn, pawnCount);
    }
  }
  
  void _executeStackedPawnMove(Pawn pawn, int pawnCount) {
    final roll = gameManager.cowryController.lastRoll;
    if (roll == null) return;
    
    _feedback.onPawnSelect();
    gameManager.turnStateMachine.onPawnSelected();
    
    final stackedPawns = gameManager.getStackedPawns(pawn);
    final fromIdx = pawn.pathIndex; // Current position before move
    
    // Calculate steps per pawn: divide roll by number of pawns moving
    final stepsPerPawn = roll.steps ~/ pawnCount;
    
    MoveResult result;
    if (pawnCount > 1 && stackedPawns.length >= pawnCount) {
      // Move specified number of pawns together, each moves stepsPerPawn
      final pawnsToMove = stackedPawns.take(pawnCount).toList();
      result = gameManager.pawnController.moveStackedPawns(pawnsToMove, stepsPerPawn);
      
      // Animate all moving pawns
      for (final p in pawnsToMove) {
        boardComponent.animatePawnMove(p, fromIdx, p.pathIndex);
      }
    } else {
      // Single pawn moves full roll value
      result = gameManager.pawnController.movePawn(pawn, roll.steps, attackerCount: 1);
      boardComponent.animatePawnMove(pawn, fromIdx, pawn.pathIndex);
    }
    
    _feedback.onPawnMove();
    
    // Track capture
    if (result.killedOpponent) {
      gameManager.captureCount[pawn.playerId] = 
          (gameManager.captureCount[pawn.playerId] ?? 0) + result.victims.length;
      _feedback.onCapture();
    }
    
    // Handle move result
    gameManager.turnStateMachine.onMoveComplete(result);
    
    // Check if player finished
    if (gameManager.pawnController.hasPlayerWon(pawn.playerId)) {
      gameManager.turnStateMachine.markPlayerFinished(pawn.playerId);
      gameManager.players[pawn.playerId].rank = gameManager.turnStateMachine.getRank(pawn.playerId);
      _feedback.onWin();
      gameManager.onPlayerFinished?.call(pawn.playerId);
    }
    
    highlightedPawns.clear();
    boardComponent.clearHighlights();
    
    _onMoveComplete(pawn, result);
    
    // CRITICAL: Check game state to handle turn transitions
    // This was missing and caused the game to freeze!
    _checkAndAdvanceTurn(result);
  }
  
  /// Check game state and advance turn after a move
  void _checkAndAdvanceTurn(MoveResult result) {
    if (gameManager.turnStateMachine.isGameOver) {
      // Mark last player
      final lastPlace = gameManager.turnStateMachine.lastPlacePlayerId;
      if (lastPlace != null) {
        gameManager.players[lastPlace].rank = gameManager.playerCount;
      }
      gameManager.onGameOver?.call(gameManager.turnStateMachine.winnerId!);
    } else if (gameManager.turnStateMachine.extraTurnPending ||
        gameManager.currentPhase == TurnPhase.checkingExtraTurn) {
      // Check for extra turn
      if (gameManager.turnStateMachine.extraTurnPending) {
        _feedback.onExtraTurn();
        gameManager.onExtraTurn?.call();
      }
      gameManager.turnStateMachine.endTurn();
      
      // Notify turn change
      if (!gameManager.turnStateMachine.extraTurnPending) {
        _feedback.onTurnStart();
      }
    }
    gameManager.onStateChanged?.call();
  }
  
  /// Get pending stacked pawns for dialog
  List<Pawn>? get pendingStackedPawns => _pendingStackedPawns;
  
  /// Get current roll value for dialog
  int get currentRollValue => gameManager.cowryController.lastRoll?.steps ?? 0;

  void _onGameStateChanged() {
    // Update board display
    boardComponent.updateDisplay();

    // Update overlays based on phase
    if (gameManager.currentPhase == TurnPhase.waitingForRoll) {
      if (!overlays.isActive(rollButtonOverlay)) {
        overlays.add(rollButtonOverlay);
      }
    } else {
      overlays.remove(rollButtonOverlay);
    }
  }

  void _onRollComplete(CowryRoll roll) {
    cowryDisplayComponent.showRoll(roll);
    _feedback.onRoll();
    
    // Extra feedback for grace throws (CHOWKA/ASHTA)
    if (roll.grantsExtraTurn) {
      _feedback.onGraceThrow();
    }
  }

  void _onMoveComplete(Pawn pawn, MoveResult result) {
    highlightedPawns.clear();
    boardComponent.clearHighlights();
    
    // Trigger smooth pawn animation (only for movement, not entry)
    if (result.success) {
      // Skip animation for entry - pawn just appears on start square
      // Only animate for actual movement on board
      if (!result.wasEntry && result.fromPathIndex != null && result.toPathIndex != null) {
        boardComponent.animatePawnMove(pawn, result.fromPathIndex!, result.toPathIndex!);
      }
    }
    
    _feedback.onPawnMove();
    
    // Show capture overlay
    if (result.killedOpponent) {
      overlays.add('capture');
      _feedback.onCapture();
      
      // Animate killed pawns going home
      for (final victim in result.victims) {
        boardComponent.animatePawnSentHome(victim);
      }
    }
    
    // Feedback for finishing (reaching center)
    if (result.reachedCenter) {
      _feedback.onPawnFinish();
    }
  }

  void _onPlayerFinished(int playerId) {
    // Handled by overlay
  }

  void _onGameOver(int winnerId) {
    overlays.add(winOverlay);
    overlays.remove(rollButtonOverlay);
    _feedback.onWin();
  }

  void _onValidMovesCalculated(List<Pawn> validPawns) {
    highlightedPawns = List.from(validPawns);
    boardComponent.highlightValidPawns(validPawns);
    
    if (validPawns.isNotEmpty) {
      _feedback.lightTap();
      
      // AUTO-PLAY: If only one valid move, play it automatically after short delay
      if (validPawns.length == 1) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (highlightedPawns.length == 1 && 
              gameManager.currentPhase == TurnPhase.selectingPawn) {
            _selectPawn(validPawns.first);
          }
        });
      }
    }
  }

  void _onExtraTurn() {
    // Show extra turn overlay
    overlays.add('extraTurn');
    _feedback.onExtraTurn();
  }
  
  void _onNoValidMoves() {
    // Show no moves notification
    overlays.add('noMoves');
    // Auto-remove after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlays.remove('noMoves');
    });
  }

  void _onPawnTap(Pawn pawn) {
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

  /// Start a new game with specified player count
  void startNewGame(int playerCount) {
    overlays.remove(winOverlay);
    overlays.remove(menuOverlay);
    highlightedPawns.clear();
    gameManager.startGame(players: playerCount);
    if (!overlays.isActive(rollButtonOverlay)) {
      overlays.add(rollButtonOverlay);
    }
    if (!overlays.isActive(turnIndicatorOverlay)) {
      overlays.add(turnIndicatorOverlay);
    }
  }

  /// Show menu overlay
  void showMenu() {
    overlays.add(menuOverlay);
  }
}
