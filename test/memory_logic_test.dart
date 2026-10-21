import "package:flutter_test/flutter_test.dart";

import "package:uniroid/games/memory_logic.dart";

void main() {
  test("board has two of each pair id", () {
    final g = MemoryGame(4, seed: 1);
    final counts = <int, int>{};
    for (final v in g.board) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    expect(counts.length, 4);
    expect(counts.values.every((c) => c == 2), true);
  });

  test("not done at start, no moves", () {
    final g = MemoryGame(4, seed: 2);
    expect(g.done, false);
    expect(g.moves, 0);
  });

  test("matching a real pair marks both matched", () {
    final g = MemoryGame(4, seed: 3);
    // find any two indexes holding the same pair id
    int a = -1, b = -1;
    outer:
    for (var i = 0; i < g.board.length; i++) {
      for (var j = i + 1; j < g.board.length; j++) {
        if (g.board[i] == g.board[j]) {
          a = i;
          b = j;
          break outer;
        }
      }
    }
    g.pick(a);
    g.pick(b);
    expect(g.moves, 1);
    expect(g.matched[a], true);
    expect(g.matched[b], true);
  });

  test("mismatch locks until cleared", () {
    final g = MemoryGame(4, seed: 4);
    // first two cards may or may not match — force distinct pair ids
    int a = 0, b = 1;
    if (g.board[a] == g.board[b]) {
      b = 2;
    }
    expect(g.board[a] != g.board[b], true);
    g.pick(a);
    g.pick(b);
    expect(g.moves, 1);
    if (g.board[a] != g.board[b]) {
      expect(g.locked, true, reason: "mismatch should lock");
      g.clearMismatch();
      expect(g.locked, false);
      expect(g.firstPick, null);
    }
  });

  test("picking same card twice is ignored", () {
    final g = MemoryGame(4, seed: 5);
    g.pick(0);
    g.pick(0);
    expect(g.secondPick, null);
    expect(g.moves, 0);
  });

  test("winning: full playthrough reaches done", () {
    final g = MemoryGame(2, seed: 6);
    // Systematically try every (i, j) combo; every matching pair gets
    // matched along the way.
    for (var i = 0; i < g.board.length; i++) {
      for (var j = i + 1; j < g.board.length; j++) {
        if (g.locked) g.clearMismatch();
        if (g.matched[i] || g.matched[j]) continue;
        g.pick(i);
        g.pick(j);
        if (g.locked) g.clearMismatch();
      }
    }
    expect(g.done, true);
  });
}
