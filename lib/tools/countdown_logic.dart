/// Pure countdown math — no Flutter imports, fully unit-testable.
library;

class CountdownMath {
  CountdownMath._();

  static const defaultStart = "2026-01-01";

  /// Whole days from [startIso] (YYYY-MM-DD) to [nowIso]. Negative if start
  /// is in the future. Returns null when unparseable.
  static int? daysBetween(String startIso, String nowIso) {
    final a = DateTime.tryParse(startIso)?.toLocal();
    final b = DateTime.tryParse(nowIso)?.toLocal();
    if (a == null || b == null) return null;
    final start = DateTime(a.year, a.month, a.day);
    final now = DateTime(b.year, b.month, b.day);
    return now.difference(start).inDays;
  }

  /// Classic couple milestones, in whole days together.
  static const milestoneMarks = [7, 30, 100, 365, 500, 1000, 1500, 2000, 3650];

  /// The next milestone strictly greater than [days], or null when beyond
  /// the last mark.
  static MapEntry<int, String>? nextMilestone(int days) {
    for (final mark in milestoneMarks) {
      if (mark > days) return MapEntry(mark, labelFor(mark));
    }
    return null;
  }

  /// The milestone just reached (<= days), or null when day 0-6.
  static MapEntry<int, String>? currentMilestone(int days) {
    MapEntry<int, String>? best;
    for (final mark in milestoneMarks) {
      if (mark <= days) best = MapEntry(mark, labelFor(mark));
    }
    return best;
  }

  /// 0.0..1.0 progress through the span [from,to] at [days]; clamped.
  static double progress(int from, int to, int days) {
    if (to <= from) return 1.0;
    final v = (days - from) / (to - from);
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }

  /// Human label for a milestone day count.
  static String labelFor(int mark) {
    if (mark == 365) return "One year!";
    if (mark == 3650) return "Ten years!";
    if (mark % 365 == 0) return "${mark ~/ 365} years";
    if (mark == 7) return "One week";
    if (mark == 30) return "One month";
    if (mark == 100) return "100 days";
    return "$mark days";
  }
}
