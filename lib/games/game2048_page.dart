import "package:flutter/material.dart";

import "../theme.dart";
import "game2048_logic.dart";

/// 2048 — swipe or use the buttons. Small, offline, pink-flavoured.
class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  late Game2048 _g;

  @override
  void initState() {
    super.initState();
    _g = Game2048();
  }

  void _move(int dir) {
    setState(() => _g.move(dir));
    if (_g.over) {
      Future.delayed(const Duration(milliseconds: 300), _showOver);
    }
  }

  void _showOver() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_g.won ? "2048 reached! 💕" : "Board is full"),
        content: Text("Score: ${_g.score}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _g.reset());
            },
            child: const Text("Play again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget tile(int x, int y) {
      final v = _g.valueAt(x, y);
      final color = switch (v) {
        0 => theme.colorScheme.surface,
        2 => const Color(0xFFFCE4EC),
        4 => const Color(0xFFF8BBD0),
        8 => UniroidTheme.pinkSoft,
        16 => const Color(0xFFF06292),
        32 => UniroidTheme.pink,
        64 => UniroidTheme.pinkDeep,
        _ => UniroidTheme.pinkDeep,
      };
      final onColor = v >= 8 ? Colors.white : theme.colorScheme.onSurface;
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: v == 0
              ? Border.all(color: theme.dividerTheme.color ?? Colors.grey)
              : null,
        ),
        alignment: Alignment.center,
        child: v == 0
            ? null
            : Text(
                "$v",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: onColor,
                ),
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("2048"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Chip(
              label: Text("${_g.score}"),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "New game",
            onPressed: () => setState(() => _g.reset()),
          ),
        ],
      ),
      body: GestureDetector(
        onPanEnd: (d) {
          final v = d.velocity.pixelsPerSecond;
          if (dxAbs(v) < 30 && dyAbs(v) < 30) return;
          if (dxAbs(v) > dyAbs(v)) {
            _move(v.dx > 0 ? 1 : 0);
          } else {
            _move(v.dy > 0 ? 3 : 2);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.dividerTheme.color ?? Colors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    for (var y = 0; y < 4; y++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var x = 0; x < 4; x++)
                              Expanded(child: tile(x, y)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () => _move(2),
                    child: const Icon(Icons.arrow_upward, size: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => _move(0),
                        child: const Icon(Icons.arrow_back, size: 18),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _move(3),
                        child: const Icon(Icons.arrow_downward, size: 18),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _move(1),
                        child: const Icon(Icons.arrow_forward, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double dxAbs(Offset v) => v.dx.abs();
  static double dyAbs(Offset v) => v.dy.abs();
}
