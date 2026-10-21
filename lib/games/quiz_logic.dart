/// Pure quiz game logic. No Flutter.
library;

class QuizQuestion {
  const QuizQuestion({
    required this.q,
    required this.options,
    required this.answer,
  });

  final String q;
  final List<String> options;

  /// Index of the correct option.
  final int answer;

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
    q: (j["q"] ?? "").toString(),
    options: [
      for (final o in (j["options"] ?? const []) as List<dynamic>) o.toString(),
    ],
    answer: (j["answer"] is num) ? (j["answer"] as num).toInt() : 0,
  );
}

class QuizGame {
  QuizGame(this.questions);

  final List<QuizQuestion> questions;
  int _index = 0;
  int score = 0;
  int? picked;

  bool get done => _index >= questions.length;
  int get index => _index;

  QuizQuestion? get current => done ? null : questions[_index];

  bool get answered => picked != null;

  /// Records a pick at the current question. Returns whether it was right.
  bool answer(int option) {
    if (done || answered) return false;
    final q = questions[_index];
    picked = option;
    final right = option == q.answer;
    if (right) score++;
    return right;
  }

  /// Advances to the next question; resets the pick.
  void next() {
    if (done) return;
    _index++;
    picked = null;
  }

  /// Best possible message for the score.
  String verdict() {
    final total = questions.length;
    if (total == 0) return "";
    final ratio = score / total;
    if (ratio == 1) return "Perfect score — you know us best! 💕";
    if (ratio >= 0.75) return "So good! Almost perfect.";
    if (ratio >= 0.5) return "More than half — the heart knows.";
    return "A chance to re-read our story together.";
  }
}
