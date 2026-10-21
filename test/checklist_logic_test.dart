import "package:flutter_test/flutter_test.dart";

import "package:uniroid/tools/checklist_logic.dart";

void main() {
  final items = [
    const ChecklistItem(text: "a", done: false),
    const ChecklistItem(text: "b", done: true),
    const ChecklistItem(text: "c", done: false),
  ];

  test("count shows done/total", () {
    expect(ChecklistMath.count(items), "1/3");
    expect(ChecklistMath.count(const []), "");
  });

  test("progress fraction", () {
    expect(ChecklistMath.progress(items), closeTo(1 / 3, 1e-9));
    expect(ChecklistMath.progress(const []), 0);
  });

  test("ordered puts not-done first, done last (order kept)", () {
    final o = ChecklistMath.ordered(items);
    expect(o.map((i) => i.text).toList(), ["a", "c", "b"]);
    expect(o.length, 3);
  });

  test("copyWith replaces only given fields", () {
    final c = items[0].copyWith(done: true);
    expect(c.done, true);
    expect(c.text, "a");
    expect(c.createdAt, "");
  });

  test("json round trip", () {
    const i = ChecklistItem(text: "x", done: true, createdAt: "t");
    final back = ChecklistItem.fromJson(i.toJson());
    expect(back.text, "x");
    expect(back.done, true);
    expect(back.createdAt, "t");
  });
}
