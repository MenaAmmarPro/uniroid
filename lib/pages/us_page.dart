import "package:flutter/material.dart";

import "../main.dart" show UniroidAppState;
import "../theme.dart";
import "countdown_page.dart";
import "memories_page.dart";
import "reasons_page.dart";
import "story_page.dart";

/// "Us" tab — everything about the two of us.
class UsPage extends StatelessWidget {
  const UsPage({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  static const items = <_Item>[
    _Item("memory-jar", "Memory Jar", Icons.local_cafe, "shake for a memory"),
    _Item("story", "Our Story", Icons.book_outlined, "how it all began"),
    _Item("countdown", "Our Countdown", Icons.favorite, "days together"),
    _Item("reasons", "65 Reasons", Icons.auto_awesome, "a reason a day"),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.findAncestorStateOfType<UniroidAppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Us"),
        actions: [
          IconButton(
            icon: Icon(
              appState?.isDark ?? false ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: "Switch day/night",
            onPressed: () => appState?.setDark(!(appState.isDark)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final i in items)
            Card(
              child: ListTile(
                leading: Icon(i.icon, color: UniroidTheme.pink),
                title: Text(i.title, style: theme.textTheme.titleMedium),
                subtitle: Text(i.subtitle, style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpen(i.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _Item {
  const _Item(this.id, this.title, this.icon, this.subtitle);
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
}

/// Pushes a "Us" page for an id (shared by the shell).
void pushUs(BuildContext context, String id) {
  final Widget page;
  switch (id) {
    case "memory-jar":
      page = const MemoriesPage();
    case "story":
      page = const StoryPage();
    case "countdown":
      page = const CountdownPage();
    case "reasons":
      page = const ReasonsPage();
    default:
      return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
