import 'package:flutter_test/flutter_test.dart';
import 'package:isto_game/models/models.dart';

void main() {
  group('CowryRoll', () {
    test('ISTO (0-up) returns 8 steps and grants extra turn', () {
      final roll = CowryRoll.withUpCount(0);
      expect(roll.upCount, 0);
      expect(roll.steps, 8);
      expect(roll.isISTO, true);
      expect(roll.isChom, false);
      expect(roll.grantsExtraTurn, true);
      expect(roll.allowsEntry, true);
      expect(roll.displayName, 'ISTO');
    });

    test('1-up returns 1 step and no extra turn', () {
      final roll = CowryRoll.withUpCount(1);
      expect(roll.upCount, 1);
      expect(roll.steps, 1);
      expect(roll.isISTO, false);
      expect(roll.isChom, false);
      expect(roll.grantsExtraTurn, false);
      expect(roll.allowsEntry, false);
    });

    test('2-up returns 2 steps and no extra turn', () {
      final roll = CowryRoll.withUpCount(2);
      expect(roll.upCount, 2);
      expect(roll.steps, 2);
      expect(roll.grantsExtraTurn, false);
      expect(roll.allowsEntry, false);
    });

    test('3-up returns 3 steps and no extra turn', () {
      final roll = CowryRoll.withUpCount(3);
      expect(roll.upCount, 3);
      expect(roll.steps, 3);
      expect(roll.grantsExtraTurn, false);
      expect(roll.allowsEntry, false);
    });

    test('ચોમ (4-up) returns 4 steps and grants extra turn', () {
      final roll = CowryRoll.withUpCount(4);
      expect(roll.upCount, 4);
      expect(roll.steps, 4);
      expect(roll.isISTO, false);
      expect(roll.isChom, true);
      expect(roll.grantsExtraTurn, true);
      expect(roll.allowsEntry, true);
      expect(roll.displayName, 'ચોમ');
    });

    test('random roll generates valid cowries', () {
      for (int i = 0; i < 100; i++) {
        final roll = CowryRoll.random();
        expect(roll.cowries.length, 4);
        expect(roll.upCount, greaterThanOrEqualTo(0));
        expect(roll.upCount, lessThanOrEqualTo(4));
        expect(roll.steps, greaterThanOrEqualTo(1));
        expect(roll.steps, lessThanOrEqualTo(8));
      }
    });
  });
}
