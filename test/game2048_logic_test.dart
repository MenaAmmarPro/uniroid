import "package:flutter_test/flutter_test.dart";

import "package:uniroid/games/game2048_logic.dart";

void main() {
  group("slide + merge", () {
    test("left move merges adjacent equal tiles once", () {
      final g = Game2048(seed: 1);
      g.board = [
        2, 2, 4, 4, // row0 → 4,8,0,0
        0, 2, 2, 2, // row1 → 4,2,0,0
        2, 4, 8, 0, // row2 → 2,4,8,0
        0, 0, 0, 0, // row3 unchanged
      ];
      final beforeScore = g.score;
      final changed = g.move(0);
      expect(changed, true);
      expect(g.valueAt(0, 0), 4);
      expect(g.valueAt(1, 0), 8);
      expect(g.valueAt(0, 1), 4);
      expect(g.valueAt(1, 1), 2);
      expect(g.valueAt(2, 1), 0);
      expect(g.valueAt(0, 2), 2);
      expect(g.valueAt(1, 2), 4);
      expect(g.valueAt(2, 2), 8);
      // score gained: row0: 4 + 8 = 12; row1: 4
      expect(g.score, beforeScore + 16);
    });

    test("no-move returns false and doesn't spawn", () {
      final g = Game2048(seed: 2);
      g.board = [
        2, 4, 8, 16, //
        4, 8, 16, 2, //
        8, 16, 2, 4, //
        16, 2, 4, 8, //
      ];
      expect(g.move(0), false);
      // board unchanged (no extra spawn)
      expect(
        g.board.every((v) => v != 0 && v != 2 && v != 4 && v != 8 && v != 16),
        false,
        reason: "spawned tile appears if it moved; here it shouldn't",
      );
    });

    test("right move slides to the right", () {
      final g = Game2048(seed: 3);
      g.board = [
        2, 0, 0, 2, // → 0,0,0,4
        0, 0, 0, 0, //
        0, 0, 0, 0, //
        2, 2, 0, 0, // → 0,0,0,4
      ];
      g.move(1);
      expect(g.valueAt(3, 0), 4);
      expect(g.valueAt(3, 3), 4);
      expect(g.valueAt(0, 0), 0);
    });

    test("up move slides up", () {
      final g = Game2048(seed: 4);
      g.board = [
        0, 0, 0, 0, //
        2, 0, 0, 0, //
        2, 0, 0, 0, //
        0, 0, 0, 0, //
      ];
      g.move(2);
      expect(g.valueAt(0, 0), 4);
      // one spawned tile joined the board (position is random)
      expect(g.board.where((v) => v != 0).length, 2);
    });

    test("down move slides down", () {
      final g = Game2048(seed: 5);
      g.board = [
        0, 0, 0, 0, //
        2, 0, 0, 0, //
        2, 0, 0, 0, //
        0, 0, 0, 0, //
      ];
      g.move(3);
      expect(g.valueAt(0, 3), 4);
      expect(g.board.where((v) => v != 0).length, 2);
    });

    test("win detection at 2048", () {
      final g = Game2048(seed: 6);
      g.board = [
        1024, 1024, 0, 0, //
        0, 0, 0, 0, //
        0, 0, 0, 0, //
        0, 0, 0, 0, //
      ];
      g.move(0); // merges 1024+1024=2048, then spawns somewhere in empty
      expect(g.won, true);
      expect(g.board.contains(2048), true);
    });
  });

  group("spawns + game over", () {
    test("spawns exactly 2 tiles after reset", () {
      final g = Game2048(seed: 7);
      expect(g.board.where((v) => v != 0).length, 2);
    });

    test("over only when full and stuck", () {
      final g = Game2048(seed: 8);
      g.board = [
        2, 4, 8, 16, //
        4, 8, 16, 2, //
        8, 16, 2, 4, //
        16, 2, 4, 8, //
      ];
      expect(g.over, true);
    });

    test("not over when an empty tile remains", () {
      final g = Game2048(seed: 9);
      g.board = [
        2, 4, 8, 16, //
        4, 8, 16, 2, //
        8, 16, 2, 4, //
        16, 2, 4, 0, //
      ];
      expect(g.over, false);
    });

    test("not over when a merge is possible", () {
      final g = Game2048(seed: 10);
      g.board = [
        2, 2, 8, 16, //
        4, 8, 16, 2, //
        8, 16, 2, 4, //
        16, 2, 4, 8, //
      ];
      expect(g.over, false);
    });
  });
}
