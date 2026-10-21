import "package:flutter/material.dart";

import "../theme.dart";
import "../games/game2048_page.dart";
import "../games/memory_game_page.dart";
import "../games/quiz_game_page.dart";

/// Arcade tab: little offline games.
class GamesPage extends StatelessWidget {
  const GamesPage({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  static const games = <_Game>[
    _Game("memory", "Memory Match", Icons.grid_on, "find the pairs"),
    _Game("quiz", "Our Quiz", Icons.quiz_outlined, "how well do we know us?"),
    _Game("2048", "2048", Icons.apps, "slide, merge, happy"),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Arcade")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final g in games)
            Card(
              child: ListTile(
                leading: Icon(g.icon, color: UniroidTheme.pink),
                title: Text(g.title, style: theme.textTheme.titleMedium),
                subtitle: Text(g.subtitle, style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpen(g.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _Game {
  const _Game(this.id, this.title, this.icon, this.subtitle);
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
}

/// Pushes the right game page for an id (shared by the shell).
void pushGame(BuildContext context, String id) {
  final Widget page;
  switch (id) {
    case "memory":
      page = const MemoryGamePage();
    case "quiz":
      page = const QuizGamePage();
    case "2048":
      page = const Game2048Page();
    default:
      return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

/// Simple placeholder until a game lands.
class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 42, color: scheme.primary),
            const SizedBox(height: 10),
            Text(
              "$title — coming soon",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
