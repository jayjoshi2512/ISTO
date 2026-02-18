import 'package:flutter_test/flutter_test.dart';
import 'package:isto/config/board_config.dart';

void main() {
  group('BoardConfig', () {
    group('isValidSquare', () {
      test('center square is valid', () {
        expect(BoardConfig.isValidSquare(2, 2), true);
      });

      test('top arm squares are valid', () {
        expect(BoardConfig.isValidSquare(0, 1), true);
        expect(BoardConfig.isValidSquare(0, 2), true);
        expect(BoardConfig.isValidSquare(0, 3), true);
      });

      test('bottom arm squares are valid', () {
        expect(BoardConfig.isValidSquare(4, 1), true);
        expect(BoardConfig.isValidSquare(4, 2), true);
        expect(BoardConfig.isValidSquare(4, 3), true);
      });

      test('left arm squares are valid', () {
        expect(BoardConfig.isValidSquare(1, 0), true);
        expect(BoardConfig.isValidSquare(2, 0), true);
        expect(BoardConfig.isValidSquare(3, 0), true);
      });

      test('right arm squares are valid', () {
        expect(BoardConfig.isValidSquare(1, 4), true);
        expect(BoardConfig.isValidSquare(2, 4), true);
        expect(BoardConfig.isValidSquare(3, 4), true);
      });

      test('center 3x3 squares are valid', () {
        for (int r = 1; r <= 3; r++) {
          for (int c = 1; c <= 3; c++) {
            expect(
              BoardConfig.isValidSquare(r, c),
              true,
              reason: 'Square [$r,$c] should be valid',
            );
          }
        }
      });

      test('corner squares are valid in full 5x5 board', () {
        expect(BoardConfig.isValidSquare(0, 0), true);
        expect(BoardConfig.isValidSquare(0, 4), true);
        expect(BoardConfig.isValidSquare(4, 0), true);
        expect(BoardConfig.isValidSquare(4, 4), true);
      });
    });

    group('isInnerPath', () {
      test('inner path squares are detected', () {
        expect(BoardConfig.isInnerPath([1, 2]), true);
        expect(BoardConfig.isInnerPath([2, 1]), true);
        expect(BoardConfig.isInnerPath([2, 3]), true);
        expect(BoardConfig.isInnerPath([3, 2]), true);
      });

      test('center is not inner path', () {
        expect(BoardConfig.isInnerPath([2, 2]), false);
      });

      test('outer squares are not inner path', () {
        expect(BoardConfig.isInnerPath([0, 2]), false);
        expect(BoardConfig.isInnerPath([2, 0]), false);
        expect(BoardConfig.isInnerPath([4, 2]), false);
        expect(BoardConfig.isInnerPath([2, 4]), false);
      });
    });

    group('isCenter', () {
      test('center is detected', () {
        expect(BoardConfig.isCenter([2, 2]), true);
      });

      test('non-center squares are not center', () {
        expect(BoardConfig.isCenter([1, 2]), false);
        expect(BoardConfig.isCenter([2, 1]), false);
        expect(BoardConfig.isCenter([0, 0]), false);
      });
    });

    group('player paths', () {
      test('all player paths end at center', () {
        for (int p = 0; p < 4; p++) {
          final path = BoardConfig.getPlayerPath(p);
          final lastPos = path.last;
          expect(lastPos[0], 2, reason: 'Player $p path should end at row 2');
          expect(lastPos[1], 2, reason: 'Player $p path should end at col 2');
        }
      });

      test('all player paths have same length', () {
        final lengths = [
          BoardConfig.player0Path.length,
          BoardConfig.player1Path.length,
          BoardConfig.player2Path.length,
          BoardConfig.player3Path.length,
        ];

        expect(
          lengths.every((l) => l == lengths.first),
          true,
          reason: 'All paths should have same length',
        );
      });

      test('all path positions are valid squares', () {
        for (int p = 0; p < 4; p++) {
          final path = BoardConfig.getPlayerPath(p);
          for (final pos in path) {
            expect(
              BoardConfig.isValidSquare(pos[0], pos[1]),
              true,
              reason: 'Player $p path has invalid square [$pos]',
            );
          }
        }
      });
    });

    group('getAllValidSquares', () {
      test('returns correct number of squares', () {
        final squares = BoardConfig.getAllValidSquares();
        // Full 5x5 board = 25 squares
        expect(squares.length, 25);
      });
    });
  });
}
