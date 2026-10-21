import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";
import "../tools/diary_logic.dart";

/// "Our Diary" — one small dated entry a day, with a gentle prompt.
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  static const _entriesKey = "diary.entries";

  final _controller = TextEditingController();
  List<String> _prompts = const [];
  String _today = "";
  List<DiaryEntry> _entries = const [];
  String _mood = "";
  bool _loaded = false;

  static const _moods = <String, IconData>{
    "": Icons.circle_outlined,
    "happy": Icons.sentiment_very_satisfied,
    "love": Icons.favorite,
    "meh": Icons.sentiment_neutral,
    "sad": Icons.sentiment_very_dissatisfied,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _prompts = await DataStore.loadStrings("prompts");
    _entries = _decode(DataStore.getList(_entriesKey));
    final today = DateTime.now();
    setState(() {
      _today = DiaryMath.isoDay(today);
      _loaded = true;
    });
    final todayEntry = DiaryMath.entryForDay(_entries, _today);
    if (todayEntry != null && mounted) {
      setState(() {
        _controller.text = todayEntry.text;
        _mood = todayEntry.mood;
      });
    }
  }

  String get _prompt {
    final seeded = DiaryMath.promptForDay(DateTime.now(), _prompts);
    if (seeded.isNotEmpty) return seeded;
    return "How was today, little by little?";
  }

  Future<void> _save() async {
    final nowIso = DateTime.now().toIso8601String();
    final text = _controller.text.trim();
    final existing = List<DiaryEntry>.from(_entries);
    final idx = existing.indexWhere((e) => e.day == _today);
    if (idx >= 0) {
      final old = existing[idx];
      existing[idx] = old.copyWith(text: text, mood: _mood, updatedAt: nowIso);
    } else {
      existing.insert(
        0,
        DiaryEntry(
          day: _today,
          prompt: _prompt,
          mood: _mood,
          text: text,
          updatedAt: nowIso,
        ),
      );
    }
    existing.sort((a, b) => b.day.compareTo(a.day));
    await DataStore.setList(_entriesKey, [
      for (final e in existing) e.toJson(),
    ]);
    setState(() => _entries = existing);
  }

  Future<void> _delete(String day) async {
    final remaining = _entries.where((e) => e.day != day).toList();
    await DataStore.setList(_entriesKey, [
      for (final e in remaining) e.toJson(),
    ]);
    setState(() => _entries = remaining);
    if (day == _today) {
      _controller.clear();
      setState(() => _mood = "");
    }
  }

  static List<DiaryEntry> _decode(List<dynamic> raw) => [
    for (final j in raw.whereType<Map<String, dynamic>>())
      DiaryEntry.fromJson(j),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = DiaryMath.streak(_entries, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Diary"),
        actions: [
          if (streak > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Chip(
                avatar: Icon(
                  Icons.local_fire_department,
                  size: 18,
                  color: UniroidTheme.pink,
                ),
                label: Text("$streak"),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _today + " — today",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(_prompt, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final m in _moods.keys)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Icon(
                                    _moods[m]!,
                                    size: 18,
                                    color: _mood == m
                                        ? Colors.white
                                        : UniroidTheme.pink,
                                  ),
                                  selected: _mood == m,
                                  onSelected: (v) =>
                                      setState(() => _mood = v ? m : ""),
                                  selectedColor: UniroidTheme.pink,
                                  showCheckmark: false,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controller,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Write to me, Mena…",
                          ),
                          onChanged: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_entries.length >
                    (_entries.any((e) => e.day == _today) ? 1 : 0)) ...[
                  Text("Earlier pages", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  for (final e in _entries.where((e) => e.day != _today))
                    Card(
                      child: ListTile(
                        title: Text(
                          e.text.isEmpty ? "—" : e.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          "${e.day} · ${e.mood == "" ? "no mood" : e.mood}",
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _delete(e.day),
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}
