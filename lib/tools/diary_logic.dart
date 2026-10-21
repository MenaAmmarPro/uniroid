/// Pure diary logic — no Flutter. Prompts are date-seeded, streaks computed.
library;

class DiaryEntry {
  const DiaryEntry({
    required this.day,
    required this.prompt,
    this.mood = "",
    this.text = "",
    this.updatedAt = "",
  });

  /// ISO day this entry belongs to, e.g. "2026-10-21".
  final String day;

  /// The prompt that was seeded for that day.
  final String prompt;

  /// Optional mood label ("","happy","meh","sad",...).
  final String mood;

  final String text;
  final String updatedAt;

  factory DiaryEntry.fromJson(Map<String, dynamic> j) => DiaryEntry(
        day: (j["day"] ?? "").toString(),
        prompt: (j["prompt"] ?? "").toString(),
        mood: (j["mood"] ?? "").toString(),
        text: (j["text"] ?? "").toString(),
        updatedAt: (j["updatedAt"] ?? "").toString(),
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "prompt": prompt,
        "mood": mood,
        "text": text,
        "updatedAt": updatedAt,
      };

  DiaryEntry copyWith({String? mood, String? text, String? updatedAt}) =>
      DiaryEntry(
        day: day,
        prompt: prompt,
        mood: mood ?? this.mood,
        text: text ?? this.text,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class DiaryMath {
  DiaryMath._();

  static String isoDay(DateTime d) =>
      "${d.year.toString().padLeft(4, "0")}-"
      "${d.month.toString().padLeft(2, "0")}-"
      "${d.day.toString().padLeft(2, "0")}";

  /// Deterministic prompt for a calendar day (same day → same prompt).
  static String promptForDay(DateTime day, List<String> prompts) {
    if (prompts.isEmpty) return "";
    final epoch = day.year * 10000 + day.month * 100 + day.day;
    return prompts[(epoch ~/ 7) % prompts.length];
    // (~/7 keeps the prompt stable across the week's rhythm while
    // still rotating over time.)
  }

  /// [entries] is newest-first; finds the entry for [iso], if any.
  static DiaryEntry? entryForDay(
    List<DiaryEntry> entries,
    String iso,
  ) {
    for (final e in entries) {
      if (e.day == iso) return e;
    }
    return null;
  }

  /// Consecutive days with an entry, ending at [today] (or yesterday if
  /// today has none yet — the streak survives until the day closes).
  static int streak(List<DiaryEntry> entries, DateTime today) {
    final written = <String>{for (final e in entries) e.day};
    var cursor = today;
    if (!written.contains(isoDay(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!written.contains(isoDay(cursor))) return 0;
    }
    var n = 0;
    while (written.contains(isoDay(cursor))) {
      n++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return n;
  }
}
