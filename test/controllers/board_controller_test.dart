import 'package:flutter_test/flutter_test.dart';
import 'package:isto_game/controllers/controllers.dart';
import 'package:isto_game/models/models.dart';

void main() {
  group('BoardController', () {
    late BoardController boardController;

    setUp(() {
      boardController = BoardController();
    });

    test('initializes all valid squares', () {
      // Should have 21 squares (cross shape)
      expect(boardController.squares.length, 21);
    });

    test('center square is correctly typed', () {
      final center = boardController.getSquareAt(2, 2);
      expect(center, isNotNull);
      expect(center!.type, SquareType.center);
    });

    test('inner path squares are correctly typed', () {
      final innerSquares = [
        boardController.getSquareAt(1, 2),
        boardController.getSquareAt(2, 1),
        boardController.getSquareAt(2, 3),
        boardController.getSquareAt(3, 2),
      ];

      for (final square in innerSquares) {
        expect(square, isNotNull);
        expect(square!.type, SquareType.inner);
      }
    });

    test('outer path squares are correctly typed', () {
      final outer = boardController.getSquareAt(0, 2);
      expect(outer, isNotNull);
      expect(outer!.type, SquareType.outer);
    });

    test('invalid squares return null', () {
      expect(boardController.getSquareAt(0, 0), isNull);
      expect(boardController.getSquareAt(4, 4), isNull);
    });

    test('getSquareFromPath returns correct square', () {
      final square = boardController.getSquareFromPath(0, 0);
      expect(square, isNotNull);
      // Player 0 starts at [3, 0]
      expect(square!.row, 3);
      expect(square.col, 0);
    });

    test('isAtCenter detects center correctly', () {
      final pathLength = boardController.getPathLength(0);
      expect(boardController.isAtCenter(0, pathLength - 1), true);
      expect(boardController.isAtCenter(0, 0), false);
    });

    group('getValidMoves', () {
      late PawnController pawnController;

      setUp(() {
        pawnController = PawnController(boardController: boardController);
        pawnController.initPawns(2);
      });

      test('home pawns can move on ISTO', () {
        final validMoves = boardController.getValidMoves(
          0, 8, pawnController.pawns, true);
        
        // All 4 home pawns should be able to enter
        expect(validMoves.length, 4);
      });

      test('home pawns cannot move on regular roll', () {
        final validMoves = boardController.getValidMoves(
          0, 2, pawnController.pawns, false);
        
        // No home pawns can move
        expect(validMoves.length, 0);
      });

      test('active pawn can move normally', () {
        final pawn = pawnController.pawns.first;
        pawn.enterBoard();
        
        final validMoves = boardController.getValidMoves(
          0, 2, pawnController.pawns, false);
        
        expect(validMoves.contains(pawn), true);
      });

      test('finished pawns cannot move', () {
        final pawn = pawnController.pawns.first;
        pawn.finish();
        
        final validMoves = boardController.getValidMoves(
          0, 2, pawnController.pawns, true);
        
        expect(validMoves.contains(pawn), false);
      });
    });
  });
}
