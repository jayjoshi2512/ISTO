import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

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

  ISTOGame() {
    gameManager = GameManager();
  }

  @override
  Color backgroundColor() => const Color(0xFF1A0F2E);  // Dark purple to match board

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Calculate responsive sizes for the screen
    _calculateSizes();

    // Calculate board position (centered)
    final boardTotalSize = 5 * squareSize + 4 * 1; // 5 squares + 4 gaps of 1px
    final boardX = (size.x - boardTotalSize) / 2;
    // Center vertically with more space for top/bottom player areas
    final boardY = (size.y - boardTotalSize) / 2;

    // Create board component
    boardComponent = BoardComponent(
      position: Vector2(boardX, boardY),
      gameManager: gameManager,
      squareSize: squareSize,
      pawnSize: pawnSize,
      onPawnTap: _onPawnTap,
    );
    add(boardComponent);

    // Create cowry display below board
    cowryDisplayComponent = CowryDisplayComponent(
      position: Vector2(size.x / 2, size.y - 60),
    );
    add(cowryDisplayComponent);

    // Setup game manager callbacks
    _setupCallbacks();

    // Show menu at start for player selection
    overlays.add(menuOverlay);
  }
  
  void _calculateSizes() {
    // Optimize for mobile screens
    // Screen is typically portrait with ~16:9 or taller aspect ratio
    final screenWidth = size.x;
    final screenHeight = size.y;
    
    // Board should fit comfortably with player areas
    // Reserve ~15% on each side for left/right player areas
    // Reserve ~20% on top and bottom for player areas + UI
    final availableWidth = screenWidth * 0.70;
    final availableHeight = screenHeight * 0.50;
    
    // Use the smaller dimension
    final boardArea = availableWidth < availableHeight ? availableWidth : availableHeight;
    
    // Board is 5 squares + 4 gaps (1px each)
    squareSize = (boardArea - 4) / 5;
    
    // Clamp to reasonable range
    if (squareSize < 45) squareSize = 45;
    if (squareSize > 70) squareSize = 70;
    
    boardSize = squareSize * 5 + 4;
    
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
  }

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
    
    _feedback.onPawnMove();
    
    // Show capture overlay
    if (result.killedOpponent) {
      overlays.add('capture');
      _feedback.onCapture();
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
