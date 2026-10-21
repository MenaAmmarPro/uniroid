import "package:flutter_test/flutter_test.dart";

import "package:uniroid/tools/reasons_logic.dart";

void main() {
  test("index rotates day by day", () {
    final a = ReasonsMath.indexForDay(65, DateTime(2026, 10, 21));
    final b = ReasonsMath.indexForDay(65, DateTime(2026, 10, 22));
    expect(a, greaterThanOrEqualTo(0));
    expect(a, lessThan(65));
    expect(a + 1, b, reason: "consecutive days step one reason forward");
  });

  test("wraps around the list length", () {
    final d1 = ReasonsMath.indexForDay(3, DateTime(2026, 10, 21));
    final d4 = ReasonsMath.indexForDay(3, DateTime(2026, 10, 24));
    expect(d1, d4, reason: "3-day list wraps every 3 days");
  });

  test("forDay returns a real list member", () {
    final reasons = ["r1", "r2", "r3", "r4", "r5"];
    for (var offset = 0; offset < 10; offset++) {
      final r = ReasonsMath.forDay(reasons, DateTime(2026, 10, 21 + offset));
      expect(reasons.contains(r), true);
    }
  });

  test("deterministic: same day twice = same reason", () {
    final reasons = List.generate(65, (i) => "reason $i");
    final r1 = ReasonsMath.forDay(reasons, DateTime(2026, 10, 21));
    final r2 = ReasonsMath.forDay(reasons, DateTime(2026, 10, 21));
    expect(r1, r2);
  });

  test("empty list → empty string, no crash", () {
    expect(ReasonsMath.forDay(const [], DateTime(2026, 10, 21)), "");
    expect(ReasonsMath.indexForDay(0, DateTime(2026, 10, 21)), 0);
  });
}
