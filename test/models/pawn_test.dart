import 'package:flutter_test/flutter_test.dart';
import 'package:isto/models/models.dart';

void main() {
  group('Pawn', () {
    test('creates pawn with correct initial state', () {
      final pawn = Pawn(id: 'P0_0', playerId: 0, pawnIndex: 0);

      expect(pawn.id, 'P0_0');
      expect(pawn.playerId, 0);
      expect(pawn.pawnIndex, 0);
      expect(pawn.state, PawnState.home);
      expect(pawn.pathIndex, -1);
      expect(pawn.currentPath, PathType.outer);
      expect(pawn.isHome, true);
      expect(pawn.isActive, false);
      expect(pawn.isFinished, false);
    });

    test('enterBoard changes state correctly', () {
      final pawn = Pawn(id: 'P0_0', playerId: 0, pawnIndex: 0);

      pawn.enterBoard();

      expect(pawn.state, PawnState.active);
      expect(pawn.pathIndex, 0);
      expect(pawn.isHome, false);
      expect(pawn.isActive, true);
    });

    test('sendHome resets pawn correctly', () {
      final pawn = Pawn(
        id: 'P0_0',
        playerId: 0,
        pawnIndex: 0,
        state: PawnState.active,
        pathIndex: 5,
        currentPath: PathType.inner,
      );

      pawn.sendHome();

      expect(pawn.state, PawnState.home);
      expect(pawn.pathIndex, -1);
      expect(pawn.currentPath, PathType.outer);
      expect(pawn.isHome, true);
    });

    test('finish marks pawn as finished', () {
      final pawn = Pawn(
        id: 'P0_0',
        playerId: 0,
        pawnIndex: 0,
        state: PawnState.active,
        pathIndex: 10,
      );

      pawn.finish();

      expect(pawn.state, PawnState.finished);
      expect(pawn.isFinished, true);
    });

    test('createId generates correct format', () {
      expect(Pawn.createId(0, 0), 'P0_0');
      expect(Pawn.createId(1, 2), 'P1_2');
      expect(Pawn.createId(3, 3), 'P3_3');
    });
  });
}
