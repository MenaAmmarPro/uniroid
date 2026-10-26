import "package:flutter/material.dart";

import "../theme.dart";
import "../updater.dart";
import "games_page.dart";
import "home_page.dart";
import "tools_page.dart";
import "us_page.dart";

/// Uniroid shell: bottom navigation with the top-level sections.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    try {
      final latest = await Updater.latestVersion();
      if (latest == null || latest == '1.2.0') return;
      final file = await Updater.downloadApk(
          'https://github.com/MenaAmmarPro/uniroid/releases/latest/download/app-release.apk');
      await Updater.install(file);
    } catch (_) {}
  }

  /// Opens a named section from the home grid (or any tile).
  void _open(String id) {
    // Tools push as their own pages.
    const pushable = {
      "countdown",
      "calculator",
      "diary",
      "checklist",
      "mood",
      "reasons",
    };
    if (pushable.contains(id)) {
      pushTool(context, id);
      return;
    }
    // Story is a "Us" page but pushes directly from the home grid.
    if (id == "story" || id == "memory-jar") {
      pushUs(context, id);
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
        case "memory":
        case "quiz":
        case "2048":
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
      GamesPage(onOpen: _open),
      UsPage(onOpen: _open),
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
