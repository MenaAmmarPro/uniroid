import "package:flutter/material.dart";

import "../data_store.dart";
import "../theme.dart";
import "../tools/diary_logic.dart";

/// "How are you?" — a gentle daily check-in with a history strip.
class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  static const _logKey = "mood.log";

  static const _moods = <String, IconData>{
    "happy": Icons.sentiment_very_satisfied,
    "love": Icons.favorite,
    "meh": Icons.sentiment_neutral,
    "tired": Icons.timelapse,
    "sad": Icons.sentiment_very_dissatisfied,
  };

  final _note = TextEditingController();
  List<Map<String, dynamic>> _log = const [];
  String _mood = "";
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = DataStore.getList(_logKey);
    final today = DiaryMath.isoDay(DateTime.now());
    final existing = List<Map<String, dynamic>>.from(raw);
    final idx = existing.indexWhere((j) => j["day"] == today);
    if (idx >= 0) {
      _mood = (existing[idx]["mood"] ?? "").toString();
      _note.text = (existing[idx]["note"] ?? "").toString();
    }
    setState(() {
      _log = existing;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final today = DiaryMath.isoDay(DateTime.now());
    final entries = List<Map<String, dynamic>>.from(_log);
    final entry = {"day": today, "mood": _mood, "note": _note.text.trim()};
    final idx = entries.indexWhere((j) => j["day"] == today);
    if (idx >= 0) {
      entries[idx] = entry;
    } else {
      entries.insert(0, entry);
    }
    await DataStore.setList(_logKey, entries);
    setState(() => _log = entries);
  }

  Map<String, dynamic>? _entryFor(String day) {
    for (final j in _log) {
      if (j["day"] == day) return j;
    }
    return null;
  }

  IconData _iconOf(String? mood) => _moods[mood] ?? Icons.circle_outlined;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("How are you?")),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DiaryMath.isoDay(DateTime.now()) + " — today",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final m in _moods.keys)
                              ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _moods[m]!,
                                      size: 18,
                                      color: _mood == m
                                          ? Colors.white
                                          : UniroidTheme.pink,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(m),
                                  ],
                                ),
                                selected: _mood == m,
                                onSelected: (v) {
                                  setState(() => _mood = v ? m : "");
                                  _save();
                                },
                                selectedColor: UniroidTheme.pink,
                                showCheckmark: false,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _note,
                          decoration: const InputDecoration(
                            hintText: "Tell me why (optional)…",
                          ),
                          maxLines: 2,
                          onChanged: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Last two weeks", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var back = 13; back >= 0; back--)
                          _dayDot(
                            theme,
                            DateTime.now().subtract(Duration(days: back)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Notes", style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                for (final j in _log.where(
                  (j) =>
                      (j["note"] ?? "").toString().isNotEmpty &&
                      j["day"] != DiaryMath.isoDay(DateTime.now()),
                ))
                  Card(
                    child: ListTile(
                      title: Text(
                        (j["note"] ?? "").toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        (j["day"] ?? "").toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _dayDot(ThemeData theme, DateTime day) {
    final entry = _entryFor(DiaryMath.isoDay(day));
    final mood = entry == null ? null : (entry["mood"] ?? "").toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _iconOf(mood),
          size: 22,
          color: mood == null ? theme.dividerTheme.color : UniroidTheme.pink,
        ),
        const SizedBox(height: 4),
        Text("${day.day}", style: theme.textTheme.bodySmall),
      ],
    );
  }
}
