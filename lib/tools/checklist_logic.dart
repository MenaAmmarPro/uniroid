/// Pure checklist logic. No Flutter.
library;

class ChecklistItem {
  const ChecklistItem({
    required this.text,
    this.done = false,
    this.createdAt = "",
  });

  final String text;
  final bool done;
  final String createdAt;

  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
    text: (j["text"] ?? "").toString(),
    done: j["done"] == true,
    createdAt: (j["createdAt"] ?? "").toString(),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "done": done,
    "createdAt": createdAt,
  };

  ChecklistItem copyWith({String? text, bool? done}) => ChecklistItem(
    text: text ?? this.text,
    done: done ?? this.done,
    createdAt: createdAt,
  );
}

class ChecklistMath {
  ChecklistMath._();

  /// Done count over total, "+2/5" style. Empty list → "".
  static String count(List<ChecklistItem> items) {
    final total = items.length;
    if (total == 0) return "";
    final done = items.where((i) => i.done).length;
    return "$done/$total";
  }

  /// Fraction 0..1 done, for progress bars.
  static double progress(List<ChecklistItem> items) {
    if (items.isEmpty) return 0;
    return items.where((i) => i.done).length / items.length;
  }

  /// Sorts: not-done first in insertion order, done last.
  static List<ChecklistItem> ordered(List<ChecklistItem> items) {
    final open = [
      for (final i in items)
        if (!i.done) i,
    ];
    final closed = [
      for (final i in items)
        if (i.done) i,
    ];
    return [...open, ...closed];
  }
}
