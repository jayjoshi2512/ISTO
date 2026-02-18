import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/theme_config.dart';
import '../models/models.dart';
import '../controllers/controllers.dart';
import '../services/feedback_service.dart';

/// Main game orchestrator — coordinates all controllers
///
/// ISTO / Chowka Bhara Rules:
/// - Entry: 1, 4, or 8 releases a pawn from home
/// - Extra turns on CHOWKA (4), ASHTA (8), or capture
/// - Must capture at least one opponent before entering inner ring
/// - Pawns on safe squares cannot be captured
/// - First player to get all 4 pawns to center wins
class GameManager {
  late final BoardController boardController;
  late final PawnController pawnController;
  late final CowryController cowryController;
  late final TurnStateMachine turnStateMachine;
  AIController? aiController;

  final List<Player> players = [];
  int playerCount;
  GameConfig gameConfig;

  /// Track captures per player (needed for inner ring entry rule)
  final Map<int, int> captureCount = {};

  /// Prevent duplicate AI scheduling
  Timer? _aiRollTimer;
  Timer? _aiMoveTimer;
  Timer? _aiWatchdogTimer;

  /// Whether cowry animation is in progress — highlights deferred until done
  bool _cowryAnimating = false;
  List<Pawn>? _pendingHighlights;
  CowryRoll? _pendingHighlightRoll;

  // Callbacks for UI updates
  Function()? onStateChanged;
  Function(CowryRoll roll)? onRollComplete;
  Function(Pawn pawn, MoveResult result)? onMoveComplete;
  Function(int playerId)? onPlayerFinished;
  Function(int winnerId)? onGameOver;
  Function(List<Pawn> validPawns)? onValidMovesCalculated;
  Function()? onExtraTurn;
  Function()? onNoValidMoves;
  Function(Pawn pawn, int stackedCount)? onStackedPawnChoice;

  /// Called when it's AI's turn and AI needs to roll
  Function()? onAIRoll;

  /// Called when AI selects a pawn to move
  Function(Pawn pawn)? onAIMove;

  GameManager({this.playerCount = 2, GameConfig? config})
    : gameConfig = config ?? GameConfig.local(2) {
    _initControllers();
  }

  void _initControllers() {
    boardController = BoardController();
    pawnController = PawnController(boardController: boardController);
    cowryController = CowryController();
    turnStateMachine = TurnStateMachine(playerCount: playerCount);
  }

  /// Check if player has made at least one capture
  bool hasPlayerCaptured(int playerId) {
    return (captureCount[playerId] ?? 0) > 0;
  }

  /// Check if current player is AI
  bool get isCurrentPlayerAI =>
      gameConfig.isAIPlayer(turnStateMachine.currentPlayerId);

  /// Start a new game
  void startGame({int players = 2, GameConfig? config}) {
    // Cancel any pending AI timers
    _cancelAITimers();

    if (config != null) {
      gameConfig = config;
      playerCount = config.playerCount;
    } else {
      playerCount = players.clamp(2, 4);
      gameConfig = GameConfig.local(playerCount);
    }

    // Setup AI if needed
    if (gameConfig.hasAIPlayers) {
      aiController = AIController(difficulty: gameConfig.aiDifficulty);
    } else {
      aiController = null;
    }

    // Reset controllers
    boardController.reset();
    turnStateMachine.reset(playerCount);
    captureCount.clear();
    _cowryAnimating = false;
    _pendingHighlights = null;
    _pendingHighlightRoll = null;

    // Initialize players
    this.players.clear();
    for (int i = 0; i < playerCount; i++) {
      final isAI = gameConfig.isAIPlayer(i);
      this.players.add(
        Player(
          id: i,
          name:
              isAI
                  ? '${ThemeConfig.getPlayerName(i)} (AI)'
                  : ThemeConfig.getPlayerName(i),
          color: ThemeConfig.getPlayerColor(i),
        ),
      );
      captureCount[i] = 0;
    }

    // Initialize pawns
    pawnController.initPawns(playerCount);

    // Start first turn
    turnStateMachine.startTurn();
    feedbackService.onTurnStart();
    onStateChanged?.call();

    // If first player is AI, trigger AI turn
    if (isCurrentPlayerAI) {
      scheduleAIRoll();
    }
  }

  Player get currentPlayer => players[turnStateMachine.currentPlayerId];
  TurnPhase get currentPhase => turnStateMachine.phase;
  bool get isGameOver => turnStateMachine.isGameOver;

  Player? get winner {
    final winnerId = turnStateMachine.winnerId;
    return winnerId != null ? players[winnerId] : null;
  }

  /// Called by UI when cowry roll animation finishes
  void onCowryAnimationComplete() {
    _cowryAnimating = false;
    // Show deferred highlights or handle no-moves
    if (_pendingHighlights != null) {
      if (_pendingHighlights!.isNotEmpty) {
        onValidMovesCalculated?.call(_pendingHighlights!);
        // If AI, schedule move now
        if (isCurrentPlayerAI &&
            aiController != null &&
            _pendingHighlightRoll != null) {
          _scheduleAIMove(_pendingHighlights!, _pendingHighlightRoll!);
        }
      } else {
        // No valid moves — fire now that cowry animation is done
        onNoValidMoves?.call();
        turnStateMachine.onNoValidMoves();
        _checkGameState();
      }
    }
    _pendingHighlights = null;
    _pendingHighlightRoll = null;
  }

  /// Roll the cowries
  CowryRoll roll() {
    if (currentPhase != TurnPhase.waitingForRoll || _cowryAnimating) {
      debugPrint(
        'GameManager: Cannot roll in phase $currentPhase (animating=$_cowryAnimating)',
      );
      return cowryController.lastRoll ?? CowryRoll.withUpCount(1);
    }

    final roll = cowryController.roll();

    // NOTE: Sound is NOT played here — it's played when the cowry animation
    // actually begins visually, to keep sound synced with the visual.

    // Mark cowry animation as in progress
    _cowryAnimating = true;

    turnStateMachine.onRollComplete(roll);

    // Fire roll complete FIRST so UI starts animating cowries
    onRollComplete?.call(roll);

    // Calculate valid moves
    final validPawns = _getValidPawns(roll);

    if (validPawns.isEmpty) {
      // Defer no-moves — handled when cowry animation completes
      _pendingHighlights = [];
      _pendingHighlightRoll = roll;
    } else {
      // Defer highlights until cowry animation completes
      _pendingHighlights = validPawns;
      _pendingHighlightRoll = roll;
    }

    onStateChanged?.call();

    return roll;
  }

  /// Cancel all pending AI timers
  void _cancelAITimers() {
    _aiRollTimer?.cancel();
    _aiRollTimer = null;
    _aiMoveTimer?.cancel();
    _aiMoveTimer = null;
    _aiWatchdogTimer?.cancel();
    _aiWatchdogTimer = null;
  }

  void scheduleAIRoll() {
    if (aiController == null || isGameOver) return;

    // Cancel any existing AI roll timer to prevent duplicates
    _aiRollTimer?.cancel();

    final delay = aiController!.getRollDelay();
    _aiRollTimer = Timer(Duration(milliseconds: delay), () {
      _aiRollTimer = null;
      if (currentPhase == TurnPhase.waitingForRoll &&
          isCurrentPlayerAI &&
          !isGameOver) {
        onAIRoll?.call();
      } else if (isCurrentPlayerAI && !isGameOver) {
        // Phase mismatch — retry after short delay (watchdog)
        _startAIWatchdog();
      }
    });
  }

  /// Watchdog timer that retries AI scheduling if something gets stuck
  void _startAIWatchdog() {
    _aiWatchdogTimer?.cancel();
    _aiWatchdogTimer = Timer(const Duration(milliseconds: 2000), () {
      _aiWatchdogTimer = null;
      if (isGameOver) return;

      if (isCurrentPlayerAI) {
        if (currentPhase == TurnPhase.waitingForRoll) {
          debugPrint('AI Watchdog: Retrying AI roll');
          onAIRoll?.call();
        } else if (currentPhase == TurnPhase.selectingPawn) {
          // AI was supposed to select a pawn but didn't
          debugPrint(
            'AI Watchdog: AI stuck in selectingPawn, forcing roll recalc',
          );
          final roll = cowryController.lastRoll;
          if (roll != null) {
            final validPawns = _getValidPawns(roll);
            if (validPawns.isNotEmpty) {
              _executeAIMove(validPawns, roll);
            } else {
              turnStateMachine.onNoValidMoves();
              _checkGameState();
            }
          }
        } else if (currentPhase == TurnPhase.checkingExtraTurn) {
          debugPrint(
            'AI Watchdog: Stuck in checkingExtraTurn, forcing advance',
          );
          _checkGameState();
        }
      }
    });
  }

  void _scheduleAIMove(List<Pawn> validPawns, CowryRoll roll) {
    if (aiController == null || isGameOver) return;

    // Cancel existing to prevent duplicates
    _aiMoveTimer?.cancel();

    final delay = aiController!.getMoveDelay();
    _aiMoveTimer = Timer(Duration(milliseconds: delay), () {
      _aiMoveTimer = null;
      if (currentPhase == TurnPhase.selectingPawn &&
          isCurrentPlayerAI &&
          !isGameOver) {
        _executeAIMove(validPawns, roll);
      } else if (isCurrentPlayerAI && !isGameOver) {
        // Phase mismatch — start watchdog
        _startAIWatchdog();
      }
    });
  }

  void _executeAIMove(List<Pawn> validPawns, CowryRoll roll) {
    if (validPawns.isEmpty) return;

    // Re-validate valid pawns in case board state changed
    final freshValidPawns = _getValidPawns(roll);
    if (freshValidPawns.isEmpty) {
      turnStateMachine.onNoValidMoves();
      _checkGameState();
      return;
    }

    final playerId = turnStateMachine.currentPlayerId;
    final hasCaptured = hasPlayerCaptured(playerId);

    final selectedPawn = aiController!.selectPawn(
      freshValidPawns,
      roll.steps,
      roll,
      boardController,
      pawnController.pawns,
      playerId,
      hasCaptured,
    );

    onAIMove?.call(selectedPawn);

    final stacked = getStackedPawns(selectedPawn);
    if (stacked.length > 1 && isPawnOnInnerPath(selectedPawn)) {
      final count = aiController!.selectStackedPawnCount(
        stacked,
        roll.steps,
        boardController,
        pawnController.pawns,
        playerId,
      );
      selectPawn(selectedPawn, movePawnCount: count);
    } else {
      selectPawn(selectedPawn);
    }
  }

  List<Pawn> _getValidPawns(CowryRoll roll) {
    final playerId = turnStateMachine.currentPlayerId;
    final hasCaptured = hasPlayerCaptured(playerId);
    return boardController.getValidMoves(
      playerId,
      roll.steps,
      pawnController.pawns,
      roll.allowsEntry,
      hasCaptured,
    );
  }

  List<Pawn> get validPawns {
    final roll = cowryController.lastRoll;
    if (roll == null) return [];
    return _getValidPawns(roll);
  }

  List<Pawn> getStackedPawns(Pawn pawn) {
    if (pawn.isHome || !pawn.isActive) return [pawn];
    final pos = pawnController.getPawnPosition(pawn);
    if (pos == null) return [pawn];
    final square = boardController.getSquare(pos);
    if (square == null) return [pawn];
    return square.getFriendlyPawns(pawn.playerId);
  }

  bool hasStackedPawns(Pawn pawn) => getStackedPawns(pawn).length > 1;

  bool isPawnOnInnerPath(Pawn pawn) {
    if (!pawn.isActive || pawn.isHome) return false;
    return pawn.currentPath == PathType.inner;
  }

  /// Select and move a pawn
  /// movePawnCount: 0 = not yet decided (show dialog if stacked)
  ///               1+ = confirmed choice from dialog or default single pawn
  MoveResult selectPawn(Pawn pawn, {int movePawnCount = 0}) {
    if (currentPhase != TurnPhase.selectingPawn) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('Cannot select pawn in phase: $currentPhase');
    }

    final roll = cowryController.lastRoll;
    if (roll == null) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('No roll available');
    }

    if (pawn.playerId != turnStateMachine.currentPlayerId) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('Not your pawn');
    }

    final hasCaptured = hasPlayerCaptured(pawn.playerId);
    // Check full-step move first
    bool canMove = boardController.canPawnMove(
      pawn,
      roll.steps,
      pawnController.pawns,
      roll.allowsEntry,
      hasCaptured,
    );
    // Also allow if stacked split would work (e.g. 2 pawns, roll=2, each 1 step)
    if (!canMove && pawn.isActive && !pawn.isFinished) {
      final stackedPawns = getStackedPawns(pawn);
      if (stackedPawns.length > 1 && roll.steps >= stackedPawns.length) {
        final splitSteps = roll.steps ~/ stackedPawns.length;
        canMove = boardController.canPawnMove(
          pawn,
          splitSteps,
          pawnController.pawns,
          roll.allowsEntry,
          hasCaptured,
        );
      }
    }
    if (!canMove) {
      feedbackService.onInvalidMove();
      return MoveResult.failed('Pawn cannot move');
    }

    // Check for stacked pawn dialog (human players only)
    // Only show when movePawnCount == 0 (not yet decided)
    final stackedPawns = getStackedPawns(pawn);
    if (stackedPawns.length > 1 &&
        isPawnOnInnerPath(pawn) &&
        movePawnCount == 0 &&
        !isCurrentPlayerAI) {
      // Check if a single-pawn full-step move is even possible
      final singleCanMove = boardController.canPawnMove(
        pawn,
        roll.steps,
        pawnController.pawns,
        roll.allowsEntry,
        hasCaptured,
      );
      if (!singleCanMove) {
        // Single pawn can't use full steps (would overshoot).
        // Auto-select "move all together" — no dialog needed.
        movePawnCount = stackedPawns.length;
      } else {
        feedbackService.mediumTap();
        onStackedPawnChoice?.call(pawn, stackedPawns.length);
        return MoveResult.failed('Waiting for stacked pawn choice');
      }
    }

    feedbackService.onPawnSelect();
    turnStateMachine.onPawnSelected();

    MoveResult result;
    if (pawn.isHome) {
      result = pawnController.enterPawn(pawn);
    } else {
      if (movePawnCount > 1 && stackedPawns.length >= movePawnCount) {
        final pawnsToMove = stackedPawns.take(movePawnCount).toList();
        // Stacked pawn rule: total steps divided among pawns
        // e.g., roll=2, 2 pawns → each moves 1 cell together
        final stepsPerGroup = roll.steps ~/ movePawnCount;
        result = pawnController.moveStackedPawns(pawnsToMove, stepsPerGroup);
      } else {
        result = pawnController.movePawn(pawn, roll.steps, attackerCount: 1);
      }
    }

    if (result.killedOpponent) {
      captureCount[pawn.playerId] =
          (captureCount[pawn.playerId] ?? 0) + result.victims.length;
    }

    turnStateMachine.onMoveComplete(result);

    if (pawnController.hasPlayerWon(pawn.playerId)) {
      turnStateMachine.markPlayerFinished(pawn.playerId);
      players[pawn.playerId].rank = turnStateMachine.getRank(pawn.playerId);
      onPlayerFinished?.call(pawn.playerId);
    }

    onMoveComplete?.call(pawn, result);
    _checkGameState();

    return result;
  }

  void _checkGameState() {
    if (turnStateMachine.isGameOver) {
      _cancelAITimers();
      final lastPlace = turnStateMachine.lastPlacePlayerId;
      if (lastPlace != null) {
        players[lastPlace].rank = playerCount;
      }
      onGameOver?.call(turnStateMachine.winnerId!);
    } else if (turnStateMachine.extraTurnPending ||
        currentPhase == TurnPhase.checkingExtraTurn) {
      if (turnStateMachine.extraTurnPending) {
        onExtraTurn?.call();
      }
      turnStateMachine.endTurn();

      // Schedule AI roll if next turn is AI
      if (isCurrentPlayerAI && !isGameOver) {
        scheduleAIRoll();
      }
    }
    onStateChanged?.call();
  }

  void endTurn() {
    turnStateMachine.endTurn();
    if (isCurrentPlayerAI && !isGameOver) {
      scheduleAIRoll();
    }
    onStateChanged?.call();
  }

  List<Pawn> get allPawns => pawnController.pawns;

  List<Pawn> get currentPlayerPawns =>
      pawnController.getPawnsForPlayer(turnStateMachine.currentPlayerId);

  Position? getPawnPosition(Pawn pawn) => pawnController.getPawnPosition(pawn);
  Square? getSquare(Position pos) => boardController.getSquare(pos);

  void reset() => startGame(players: playerCount, config: gameConfig);

  List<Player> get rankings {
    final ranked = <Player>[];
    for (final playerId in turnStateMachine.rankings) {
      ranked.add(players[playerId]);
    }
    return ranked;
  }
}
