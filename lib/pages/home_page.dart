import "package:flutter/material.dart";

import "../theme.dart";

/// Uniroid — home screen showing everything in one grid.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpen});

  /// Opens a section by id from any tile.
  final ValueChanged<String> onOpen;

  static const tiles = <_Tile>[
    _Tile("countdown", "Our Countdown", Icons.favorite, "days, always counted"),
    _Tile("reasons", "65 Reasons", Icons.auto_awesome, "a reason every day"),
    _Tile("diary", "Diary", Icons.menu_book, "one line a day"),
    _Tile("mood", "How are you?", Icons.mood, "a gentle check-in"),
    _Tile("games", "Arcade", Icons.videogame_asset, "little offline games"),
    _Tile(
      "story",
      "Our Story",
      Icons.account_balance_wallet,
      "how it all began",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Uniroid")),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
        children: [
          for (final t in tiles)
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onOpen(t.id),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.icon, color: UniroidTheme.pink, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        t.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onOpen("countdown"),
        backgroundColor: UniroidTheme.pink,
        child: const Icon(Icons.favorite, color: Colors.white),
      ),
      // Keeps the floating button from clashing with grid edges.
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class _Tile {
  const _Tile(this.id, this.title, this.icon, this.subtitle);
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
}

/// Placeholder until sections have real pages.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.title, required this.id});

  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 42, color: scheme.primary),
          const SizedBox(height: 10),
          Text(
            "$title — coming next",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text("step $id", style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
