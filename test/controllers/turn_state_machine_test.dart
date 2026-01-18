import 'package:flutter_test/flutter_test.dart';
import 'package:isto_game/controllers/controllers.dart';
import 'package:isto_game/models/models.dart';

void main() {
  group('TurnStateMachine', () {
    late TurnStateMachine stateMachine;

    setUp(() {
      stateMachine = TurnStateMachine(playerCount: 2);
    });

    test('initializes with correct state', () {
      expect(stateMachine.currentPlayerId, 0);
      expect(stateMachine.phase, TurnPhase.waitingForRoll);
      expect(stateMachine.extraTurnPending, false);
      expect(stateMachine.isGameOver, false);
    });

    test('onRollComplete transitions to selectingPawn', () {
      final roll = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll);
      expect(stateMachine.phase, TurnPhase.selectingPawn);
    });

    test('ISTO roll sets extra turn pending', () {
      final roll = CowryRoll.withUpCount(0); // ISTO
      stateMachine.onRollComplete(roll);
      expect(stateMachine.extraTurnPending, true);
    });

    test('ચોમ roll sets extra turn pending', () {
      final roll = CowryRoll.withUpCount(4); // ચોમ
      stateMachine.onRollComplete(roll);
      expect(stateMachine.extraTurnPending, true);
    });

    test('normal roll does not set extra turn pending', () {
      final roll = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll);
      expect(stateMachine.extraTurnPending, false);
    });

    test('reaching center grants extra turn', () {
      final roll = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll);
      stateMachine.onPawnSelected();
      
      final result = MoveResult.finished();
      stateMachine.onMoveComplete(result);
      
      expect(stateMachine.extraTurnPending, true);
    });

    test('killing opponent grants extra turn', () {
      final roll = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll);
      stateMachine.onPawnSelected();
      
      final result = MoveResult.kill(
        type: KillType.single,
        victims: [Pawn(id: 'P1_0', playerId: 1, pawnIndex: 0)],
      );
      stateMachine.onMoveComplete(result);
      
      expect(stateMachine.extraTurnPending, true);
    });

    test('extra turn keeps same player', () {
      final roll = CowryRoll.withUpCount(0); // ISTO
      stateMachine.onRollComplete(roll);
      stateMachine.onPawnSelected();
      stateMachine.onMoveComplete(MoveResult.moved());
      stateMachine.endTurn();
      
      // Same player should go again
      expect(stateMachine.currentPlayerId, 0);
    });

    test('normal turn advances to next player', () {
      final roll = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll);
      stateMachine.onPawnSelected();
      stateMachine.onMoveComplete(MoveResult.moved());
      stateMachine.endTurn();
      
      expect(stateMachine.currentPlayerId, 1);
    });

    test('multiple triggers grant only one extra turn', () {
      // ISTO roll + kill should still be only one extra turn
      final roll = CowryRoll.withUpCount(0); // ISTO
      stateMachine.onRollComplete(roll);
      expect(stateMachine.extraTurnPending, true);
      
      stateMachine.onPawnSelected();
      final result = MoveResult.kill(
        type: KillType.single,
        victims: [Pawn(id: 'P1_0', playerId: 1, pawnIndex: 0)],
      );
      stateMachine.onMoveComplete(result);
      
      // Extra turn was already granted from ISTO, should not be granted again
      expect(stateMachine.extraTurnPending, true);
      
      stateMachine.endTurn();
      expect(stateMachine.currentPlayerId, 0); // Same player
      
      // Now on the extra turn, use normal roll
      final roll2 = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll2);
      stateMachine.onPawnSelected();
      stateMachine.onMoveComplete(MoveResult.moved());
      stateMachine.endTurn();
      
      // Should advance to next player
      expect(stateMachine.currentPlayerId, 1);
    });

    test('finished players are skipped', () {
      stateMachine = TurnStateMachine(playerCount: 3);
      
      // Finish player 1
      stateMachine.markPlayerFinished(1);
      
      // Player 0's turn ends normally
      final roll = CowryRoll.withUpCount(2);
      stateMachine.onRollComplete(roll);
      stateMachine.onPawnSelected();
      stateMachine.onMoveComplete(MoveResult.moved());
      stateMachine.endTurn();
      
      // Should skip player 1 and go to player 2
      expect(stateMachine.currentPlayerId, 2);
    });

    test('game is over when only one player remains', () {
      stateMachine = TurnStateMachine(playerCount: 3);
      
      stateMachine.markPlayerFinished(0);
      expect(stateMachine.isGameOver, false);
      
      stateMachine.markPlayerFinished(1);
      expect(stateMachine.isGameOver, true);
    });

    test('rankings are recorded correctly', () {
      stateMachine = TurnStateMachine(playerCount: 3);
      
      stateMachine.markPlayerFinished(2);
      stateMachine.markPlayerFinished(0);
      
      expect(stateMachine.rankings, [2, 0]);
      expect(stateMachine.getRank(2), 1); // 1st place
      expect(stateMachine.getRank(0), 2); // 2nd place
      expect(stateMachine.getRank(1), 0); // Not finished
    });
  });
}
