import "package:flutter/material.dart";

import "../theme.dart";
import "home_page.dart";
import "tools_page.dart";

/// Uniroid shell: bottom navigation with the top-level sections.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  /// Opens a named section from the home grid (or any tile).
  void _open(String id) {
    // Tools push as their own pages.
    if (id == "countdown" || id == "calculator") {
      pushTool(context, id);
      return;
    }
    setState(() {
      switch (id) {
        case "reasons":
        case "diary":
        case "mood":
        case "story":
          _tab = 3; // "Us" holds them all while built step by step.
          break;
        case "games":
          _tab = 2;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onOpen: _open),
      ToolsPage(onOpen: _open),
      const SectionPlaceholder(title: "Arcade", id: "games"),
      const SectionPlaceholder(title: "Us", id: "us"),
    ];

    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: UniroidTheme.pinkSoft,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: "Tools",
          ),
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: "Games",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: "Us",
          ),
        ],
      ),
    );
  }
}
