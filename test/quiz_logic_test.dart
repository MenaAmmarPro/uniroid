import "package:flutter_test/flutter_test.dart";

import "package:uniroid/games/quiz_logic.dart";

void main() {
  const questions = [
    QuizQuestion(q: "q1", options: ["a", "b", "c"], answer: 2),
    QuizQuestion(q: "q2", options: ["x", "y"], answer: 0),
    QuizQuestion(q: "q3", options: ["n1", "n2"], answer: 1),
    QuizQuestion(q: "q4", options: ["p", "q"], answer: 0),
  ];

  test("fromJson parses all fields", () {
    final q = QuizQuestion.fromJson({
      "q": "test?",
      "options": ["1", "2"],
      "answer": 1,
    });
    expect(q.q, "test?");
    expect(q.options.length, 2);
    expect(q.answer, 1);
  });

  test("answered false before pick, right pick counts", () {
    final g = QuizGame(questions);
    expect(g.answered, false);
    expect(g.index, 0);
    expect(g.answer(2), true);
    expect(g.answered, true);
    expect(g.score, 1);
  });

  test("second answer on same question ignored", () {
    final g = QuizGame(questions);
    g.answer(0);
    expect(g.answer(2), false, reason: "already answered");
    expect(g.score, 0);
  });

  test("wrong answer scores nothing and moves on", () {
    final g = QuizGame(questions);
    g.answer(0);
    g.next();
    expect(g.index, 1);
    expect(g.score, 0);
    expect(g.answer(0), true);
  });

  test("full run to done + perfect verdict", () {
    final g = QuizGame(questions);
    while (!g.done) {
      g.answer(g.current!.answer);
      g.next();
    }
    expect(g.score, 4);
    expect(g.verdict(), contains("Perfect"));
  });

  test("score 1/4 gives gentle verdict, no crash", () {
    final g = QuizGame(questions);
    g.answer(2);
    g.next();
    g.answer(1); // wrong
    g.next();
    g.answer(0); // wrong
    g.next();
    g.answer(1); // wrong
    g.next();
    expect(g.done, true);
    expect(g.verdict(), isNotEmpty);
  });
}
