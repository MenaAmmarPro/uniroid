/// Pure reasons logic — one reason a day, deterministic. No Flutter.
library;

class ReasonsMath {
  ReasonsMath._();

  /// Index for a calendar day: rotates through the list day by day
  /// (day 0 → 0, day 1 → 1, … wrapping around the list length).
  static int indexForDay(int listLength, DateTime day) {
    if (listLength <= 0) return 0;
    final epoch = day.year * 10000 + day.month * 100 + day.day;
    // Days since 2000-01-01 keeps the rotation bounded & positive.
    final days = (DateTime(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime(2000, 1, 1))).inDays;
    if (epoch < 0) return 0;
    final idx = days % listLength;
    return idx < 0 ? 0 : idx;
  }

  static String forDay(List<String> reasons, DateTime day) {
    if (reasons.isEmpty) return "";
    return reasons[indexForDay(reasons.length, day)];
  }
}
