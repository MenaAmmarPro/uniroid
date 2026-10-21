import "package:flutter/material.dart";

import "../theme.dart";

/// "Our Story" — how it all began, as little dated chapters.
class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  static const chapters = <_Chapter>[
    _Chapter(
      "The lobby",
      "Two strangers waiting in a Free Fire lobby. One Pakistani player, "
          "one Romanian player. Nobody planned anything — it was just a match.",
    ),
    _Chapter(
      "First words",
      "“Nice shot.” That was somehow enough. The match ended, the game kept "
          "going in chat long after it needed to.",
    ),
    _Chapter(
      "Different skies",
      "Karachi and Bucharest, two hours apart, same game, same nights. One "
          "of you plays at midnight, the other lives just before breakfast.",
    ),
    _Chapter(
      "Since forever",
      "Neither of you remembers an exact date it started, and that's fine — "
          "it feels like it has been a thing since before you were born.",
    ),
    _Chapter(
      "Uniroid",
      "And now there is a whole little universe with your name on it — "
          "this app — tools, games and stories, all offline, all for Mena.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Our Story")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (var i = 0; i < chapters.length; i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: UniroidTheme.pink,
                          child: Text(
                            "${i + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          chapters[i].title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapters[i].body,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Center(
            child: Icon(Icons.favorite, color: UniroidTheme.pink, size: 30),
          ),
        ],
      ),
    );
  }
}

class _Chapter {
  const _Chapter(this.title, this.body);
  final String title;
  final String body;
}
