/// Pure memory-match game logic. No Flutter.
library;

import "dart:math";

class MemoryGame {
  MemoryGame(this.pairCount, {int? seed})
    : _rng = seed == null ? null : Random(seed) {
    _reset();
  }

  final int pairCount;
  final Random? _rng;

  /// Two entries per pair: value = pair id (0..pairCount-1).
  late List<int> board;
  late List<bool> matched;
  int moves = 0;
  int? firstPick;
  int? secondPick;
  bool locked = false;

  void _reset() {
    board = [
      for (var p = 0; p < pairCount; p++) ...[p, p],
    ];
    _shuffle();
    matched = List<bool>.filled(pairCount * 2, false);
    moves = 0;
    firstPick = null;
    secondPick = null;
    locked = false;
  }

  void _shuffle() {
    final rng = _rng ?? Random();
    for (var i = board.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = board[i];
      board[i] = board[j];
      board[j] = tmp;
    }
  }

  bool get done => matched.every((m) => m);

  bool get busy => firstPick != null && matched[firstPick!] == false;

  /// Faces revealed but not yet matched (for rendering).
  bool revealed(int index) =>
      matched[index] || index == firstPick || index == secondPick;

  /// Tapping a card. Returns true when this tap triggered a match+flip step.
  void pick(int index) {
    if (locked || done) return;
    if (matched[index]) return;
    if (index == firstPick || index == secondPick) return;

    if (firstPick == null) {
      firstPick = index;
      return;
    }
    if (secondPick != null) return;
    secondPick = index;
    moves++;
    final a = board[firstPick!];
    final b = board[secondPick!];
    if (a == b) {
      matched[firstPick!] = true;
      matched[secondPick!] = true;
      firstPick = null;
      secondPick = null;
    } else {
      // The page flips these back after showing them.
      locked = true;
    }
  }

  /// Ends a mismatched pair's face-up phase and allows the next pick.
  void clearMismatch() {
    firstPick = null;
    secondPick = null;
    locked = false;
  }
}
