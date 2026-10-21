/// Pure 2048 game logic. No Flutter.
library;

import "dart:math";

class Game2048 {
  Game2048({int? seed}) : rng = seed == null ? null : Random(seed) {
    reset();
  }

  final Random? rng;

  /// Flat 4x4 board, 0 = empty. Row-major: index = y*4 + x.
  late List<int> board;

  int score = 0;
  bool won = false;

  void reset() {
    board = List<int>.filled(16, 0);
    score = 0;
    won = false;
    _spawn();
    _spawn();
  }

  int _emptyAt() {
    final empty = [
      for (var i = 0; i < 16; i++)
        if (board[i] == 0) i,
    ];
    if (empty.isEmpty) return -1;
    final rng2 = rng ?? Random();
    return empty[rng2.nextInt(empty.length)];
  }

  bool _spawn() {
    final at = _emptyAt();
    if (at < 0) return false;
    board[at] = 2;
    return true;
  }

  /// Slides one row/col of 4 tiles leftward, merging equal neighbours once.
  /// Returns the merged line (values or 0).
  static List<int> _slide(List<int> line) {
    final tiles = [
      for (final v in line)
        if (v != 0) v,
    ];
    final out = List<int>.filled(line.length, 0);
    var o = 0;
    for (var i = 0; i < tiles.length; i++) {
      if (i + 1 < tiles.length && tiles[i] == tiles[i + 1]) {
        out[o++] = tiles[i] * 2;
        i++; // consumed the neighbour too
      } else {
        out[o++] = tiles[i];
      }
    }
    return out;
  }

  /// Directions: 0=left 1=right 2=up 3=down.
  bool move(int dir) {
    final before = List<int>.of(board);
    var gained = 0;

    for (final line in _lines(dir)) {
      final orig = [for (final idx in line) board[idx]];
      final moved = _slide(orig);
      for (var i = 0; i < line.length; i++) {
        board[line[i]] = moved[i];
        if (i < moved.length && orig[i] != moved[i]) {
          // score only counts merges (doubled tiles)
          if (moved[i] > orig[i]) gained += moved[i];
        }
      }
    }

    score += gained;
    if (gained == 0 && _listsEqual(before, board)) return false;
    if (board.contains(2048)) won = true;
    _spawn();
    return true;
  }

  static bool _listsEqual(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// The index path (4 indices) ordering for each of 16 lines so that
  /// "left" slide covers all dirs.
  static List<List<int>> _lines(int dir) {
    return switch (dir) {
      0 => [
        // left: each row left→right
        for (var y = 0; y < 4; y++) [for (var x = 0; x < 4; x++) y * 4 + x],
      ],
      1 => [
        // right: each row right→left
        for (var y = 0; y < 4; y++) [for (var x = 3; x >= 0; x--) y * 4 + x],
      ],
      2 => [
        // up: each col top→bottom
        for (var x = 0; x < 4; x++) [for (var y = 0; y < 4; y++) y * 4 + x],
      ],
      3 => [
        // down: each col bottom→top
        for (var x = 0; x < 4; x++) [for (var y = 3; y >= 0; y--) y * 4 + x],
      ],
      _ => const [],
    };
  }

  bool get over {
    if (board.contains(0)) return false;
    // any adjacent equal pair → still movable
    for (final dir in [0, 1, 2, 3]) {
      for (final line in _lines(dir)) {
        final orig = [for (final idx in line) board[idx]];
        final moved = _slide(orig);
        if (!_listsEqual(orig, moved)) return false;
      }
    }
    return true;
  }

  /// 1-point tiles for rendering: value or empty.
  int valueAt(int x, int y) => board[y * 4 + x];
}
