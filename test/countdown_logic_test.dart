import "package:flutter_test/flutter_test.dart";

import "package:uniroid/tools/countdown_logic.dart";

void main() {
  group("daysBetween", () {
    test("same day is zero", () {
      expect(CountdownMath.daysBetween("2026-01-01", "2026-01-01"), 0);
    });

    test("one calendar day later is one", () {
      expect(CountdownMath.daysBetween("2026-01-01", "2026-01-02"), 1);
    });

    test("start in the future is negative", () {
      expect(CountdownMath.daysBetween("2026-12-31", "2026-12-30"), -1);
    });

    test("garbage input returns null", () {
      expect(CountdownMath.daysBetween("nope", "2026-01-02"), isNull);
      expect(CountdownMath.daysBetween("2026-01-01", ""), isNull);
    });

    test("a whole year", () {
      expect(CountdownMath.daysBetween("2025-01-01", "2026-01-01"), 365);
    });
  });

  group("milestones", () {
    test("nextMilestone from day 0 is one week", () {
      final m = CountdownMath.nextMilestone(0)!;
      expect(m.key, 7);
      expect(m.value, "One week");
    });

    test("nextMilestone exactly on a mark skips to the next", () {
      final m = CountdownMath.nextMilestone(100)!;
      expect(m.key, 365);
    });

    test("currentMilestone is the largest reached mark", () {
      final m = CountdownMath.currentMilestone(430)!;
      expect(m.key, 365);
      expect(m.value, "One year!");
    });

    test("currentMilestone is null before one week", () {
      expect(CountdownMath.currentMilestone(5), isNull);
    });

    test("progress spans 0..1 clamped", () {
      expect(CountdownMath.progress(0, 100, 50), 0.5);
      expect(CountdownMath.progress(0, 100, -5), 0);
      expect(CountdownMath.progress(0, 100, 250), 1);
      expect(CountdownMath.progress(100, 100, 100), 1);
    });
  });

  group("labels", () {
    test("year labels", () {
      expect(CountdownMath.labelFor(365), "One year!");
      expect(CountdownMath.labelFor(3650), "Ten years!");
      expect(CountdownMath.labelFor(730), "2 years");
    });

    test("day labels", () {
      expect(CountdownMath.labelFor(7), "One week");
      expect(CountdownMath.labelFor(30), "One month");
      expect(CountdownMath.labelFor(100), "100 days");
      expect(CountdownMath.labelFor(999), "999 days");
    });
  });
}
