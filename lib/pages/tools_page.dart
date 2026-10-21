import "package:flutter/material.dart";

import "../theme.dart";
import "calculator_page.dart";
import "countdown_page.dart";
import "diary_page.dart";

/// Tools tab: a task list of little everyday helpers.
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  static const tools = <_Tool>[
    _Tool(
      "countdown",
      "Our Countdown",
      Icons.favorite,
      "days together, always counted",
    ),
    _Tool(
      "calculator",
      "Calculator",
      Icons.calculate_outlined,
      "quick little sums",
    ),
    _Tool("diary", "Our Diary", Icons.menu_book, "one line a day"),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Tools")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final t in tools)
            Card(
              child: ListTile(
                leading: Icon(t.icon, color: UniroidTheme.pink),
                title: Text(t.title, style: theme.textTheme.titleMedium),
                subtitle: Text(t.subtitle, style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onOpen(t.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tool {
  const _Tool(this.id, this.title, this.icon, this.subtitle);
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
}

/// Pushes the right tool page for an id (shared by the shell).
void pushTool(BuildContext context, String id) {
  final Widget page;
  switch (id) {
    case "countdown":
      page = const CountdownPage();
    case "calculator":
      page = const CalculatorPage();
    case "diary":
      page = const DiaryPage();
    default:
      return;
  }
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
