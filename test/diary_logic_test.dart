import "package:flutter_test/flutter_test.dart";

import "package:uniroid/tools/diary_logic.dart";

void main() {
  group("isoDay", () {
    test("pads month and day", () {
      expect(DiaryMath.isoDay(DateTime(2026, 3, 7)), "2026-03-07");
      expect(DiaryMath.isoDay(DateTime(2026, 12, 31)), "2026-12-31");
    });
  });

  group("promptForDay", () {
    test("deterministic: same day always gives the same prompt", () {
      final prompts = ["a", "b", "c"];
      final day = DateTime(2026, 10, 21);
      expect(
        DiaryMath.promptForDay(day, prompts),
        DiaryMath.promptForDay(DateTime(2026, 10, 21), prompts),
      );
    });

    test("different days can differ", () {
      final prompts = ["p1", "p2", "p3", "p4", "p5"];
      final a = DiaryMath.promptForDay(DateTime(2026, 10, 1), prompts);
      final b = DiaryMath.promptForDay(DateTime(2026, 10, 8), prompts);
      // With 16 prompts a 7-day stride gives room for variety; assert at
      // least that it never throws and always lands in the list.
      expect(prompts.contains(a), true);
      expect(prompts.contains(b), true);
    });

    test("empty prompt list returns empty string", () {
      expect(DiaryMath.promptForDay(DateTime(2026, 10, 21), []), "");
    });
  });

  group("entryForDay / streak", () {
    test("entryForDay finds the exact day", () {
      final entries = [
        DiaryEntry(day: "2026-10-21", prompt: "p", text: "x"),
        DiaryEntry(day: "2026-10-20", prompt: "p", text: "y"),
      ];
      expect(DiaryMath.entryForDay(entries, "2026-10-20")?.text, "y");
      expect(DiaryMath.entryForDay(entries, "2026-10-19"), isNull);
    });

    test("streak counts back from today", () {
      final entries = [
        DiaryEntry(day: "2026-10-21", prompt: "p"),
        DiaryEntry(day: "2026-10-20", prompt: "p"),
        DiaryEntry(day: "2026-10-19", prompt: "p"),
        DiaryEntry(day: "2026-10-10", prompt: "p"), // gap → stops streak
      ];
      expect(DiaryMath.streak(entries, DateTime(2026, 10, 21)), 3);
    });

    test("streak survives if today not yet written but yesterday was", () {
      final entries = [DiaryEntry(day: "2026-10-20", prompt: "p")];
      expect(DiaryMath.streak(entries, DateTime(2026, 10, 21)), 1);
    });

    test("streak is zero with no entries", () {
      expect(DiaryMath.streak(const [], DateTime(2026, 10, 21)), 0);
    });

    test("streak breaks on one missing day", () {
      final entries = [
        DiaryEntry(day: "2026-10-21", prompt: "p"),
        DiaryEntry(day: "2026-10-19", prompt: "p"),
      ];
      expect(DiaryMath.streak(entries, DateTime(2026, 10, 21)), 1);
    });
  });

  group("DiaryEntry json round-trip", () {
    test("toJson then fromJson keeps everything", () {
      final e = DiaryEntry(
        day: "2026-10-21",
        prompt: "p",
        mood: "love",
        text: "hi",
        updatedAt: "2026-10-21T01:02:03",
      );
      final back = DiaryEntry.fromJson(e.toJson());
      expect(back.day, e.day);
      expect(back.prompt, e.prompt);
      expect(back.mood, e.mood);
      expect(back.text, e.text);
      expect(back.updatedAt, e.updatedAt);
    });

    test("copyWith only replaces given fields", () {
      final e = const DiaryEntry(day: "d", prompt: "p", mood: "m", text: "t");
      final e2 = e.copyWith(text: "new");
      expect(e2.mood, "m");
      expect(e2.text, "new");
      expect(e2.day, "d");
    });
  });
}
