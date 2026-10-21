import "package:flutter/material.dart";

import "../theme.dart";
import "memory_logic.dart";

/// Memory match — find the pairs. Small grid of emoji cards.
class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key, this.pairs = 8});

  final int pairs;

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  static const faces = [
    "❤️",
    "🌟",
    "🌙",
    "🍕",
    "🎈",
    "🎨",
    "🌸",
    "🎧",
    "🐣",
    "🍓",
    "💫",
    "🎁",
  ];

  late MemoryGame _game;
  int _wins = 0;

  @override
  void initState() {
    super.initState();
    _game = MemoryGame(widget.pairs);
  }

  void _onTap(int index) {
    if (_game.done || _game.locked) return;
    setState(() => _game.pick(index));
    if (!_game.locked) {
      if (_game.done) {
        _wins++;
        _celebrate();
      }
      return;
    }
    // Show the mismatch briefly, then flip back.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _game.clearMismatch());
      if (_game.done) {
        _wins++;
        _celebrate();
      }
    });
  }

  void _celebrate() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("You found them all! 💕"),
        content: Text("${_game.moves} moves · wins today: $_wins"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Play again"),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _restart() {
    setState(() {
      _game = MemoryGame(widget.pairs);
      _wins = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Match"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Chip(
              avatar: Icon(
                Icons.track_changes,
                size: 16,
                color: UniroidTheme.pink,
              ),
              label: Text("${_game.moves}"),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "New game",
            onPressed: _restart,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
              children: [
                for (var i = 0; i < _game.board.length; i++)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _game.matched[i]
                          ? UniroidTheme.pink.withOpacity(0.12)
                          : theme.cardTheme.color,
                      foregroundColor: theme.scaffoldBackgroundColor,
                      elevation: 0,
                      side: BorderSide(
                        color: _game.matched[i]
                            ? UniroidTheme.pink
                            : theme.dividerTheme.color ?? Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _onTap(i),
                    child: FittedBox(
                      child: Text(
                        _game.revealed(i)
                            ? faces[_game.board[i] % faces.length]
                            : "🎬",
                        style: TextStyle(
                          fontSize: 30,
                          color: _game.matched[i] ? null : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
