import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";
import "quiz_logic.dart";

/// Our Quiz — 8 questions about "us", all offline.
class QuizGamePage extends StatefulWidget {
  const QuizGamePage({super.key});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  List<QuizQuestion> _questions = const [];
  QuizGame? _game;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _questions = [
      for (final j in await DataStore.loadMaps("quiz")) QuizQuestion.fromJson(j),
    ];
    setState(() {
      _game = QuizGame(_questions);
      _loaded = true;
    });
  }

  void _pick(int option) {
    setState(() => _game!.answer(option));
  }

  void _restart() {
    setState(() => _game = QuizGame(_questions));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text("Our Quiz")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final game = _game!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Quiz"),
        actions: [
          if (!game.done)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Chip(
                label: Text("${game.index + 1}/${game.questions.length}"),
                visualDensity: VisualDensity.compact,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Restart",
            onPressed: _restart,
          ),
        ],
      ),
      body: game.done
          ? _resultView(theme, game)
          : _questionView(theme, game),
    );
  }

  Widget _questionView(ThemeData theme, QuizGame game) {
    final q = game.current!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(
          value: game.questions.isEmpty
              ? 0
              : game.index / game.questions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          backgroundColor: theme.colorScheme.surface,
          color: UniroidTheme.pink,
        ),
        const SizedBox(height: 18),
        Text(q.q, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    game.answered && i == q.answer
                        ? UniroidTheme.pink
                        : game.answered && i == game.picked
                            ? theme.colorScheme.error.withOpacity(0.7)
                            : theme.cardTheme.color,
                foregroundColor: game.answered
                    ? theme.colorScheme.onSurface
                    : Colors.white,
                side: BorderSide(
                  color: game.answered
                      ? (i == q.answer
                          ? UniroidTheme.pink
                          : theme.dividerTheme.color ?? Colors.grey)
                      : Colors.transparent,
                ),
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: game.answered ? null : () => _pick(i),
              child: Text(
                q.options[i],
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (game.answered) ...[
          const SizedBox(height: 6),
          FilledButton(
            onPressed: () => setState(() => game.next()),
            child: const Text("Next"),
          ),
        ],
      ],
    );
  }

  Widget _resultView(ThemeData theme, QuizGame game) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: UniroidTheme.pink, size: 44),
            const SizedBox(height: 12),
            Text(
              "${game.score}/${game.questions.length}",
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(game.verdict(), style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _restart,
              child: const Text("Play again"),
            ),
          ],
        ),
      ),
    );
  }
}
