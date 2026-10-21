/// Pure calculator math: tokenize + shunting-yard evaluate. No Flutter.
library;

class CalcError implements Exception {
  const CalcError(this.message);
  final String message;
  @override
  String toString() => message;
}

class CalculatorMath {
  CalculatorMath._();

  /// Evaluates an infix expression with + - * / and precedence.
  /// Unary minus supported. Throws [CalcError] on bad input or /0.
  static double evaluate(String expr) {
    final tokens = _tokenize(expr.replaceAll(",", ""));
    if (tokens.isEmpty) throw const CalcError("Nothing entered");
    final rpn = _toRpn(tokens);
    return _evalRpn(rpn);
  }

  static String format(double v) {
    if (v.isNaN || v.isInfinite) return "∞";
    // Trivial integers print without the decimal tail.
    if (v.round() == v && v.abs() < 1e15) {
      return v.round().toString();
    }
    var s = v.toStringAsFixed(10);
    s = s.replaceFirst(RegExp(r"0+$"), "");
    s = s.replaceFirst(RegExp(r"\.$"), "");
    return s;
  }

  static const _ops = {"+": 1, "-": 1, "*": 2, "/": 2};

  static List<String> _tokenize(String expr) {
    final out = <String>[];
    var i = 0;
    while (i < expr.length) {
      final c = expr[i];
      if (c == " ") {
        i++;
      } else if (_ops.containsKey(c)) {
        // Unary minus: minus at start, or right after an operator or (.
        final prev = out.isEmpty ? null : out.last;
        if (c == "-" &&
            (prev == null || prev == "(" || _ops.containsKey(prev))) {
          out.add("u-");
        } else {
          out.add(c);
        }
        i++;
      } else if ("()".contains(c)) {
        out.add(c);
        i++;
      } else if (RegExp(r"[0-9.]").hasMatch(c)) {
        var j = i;
        while (j < expr.length && RegExp(r"[0-9.]").hasMatch(expr[j])) {
          j++;
        }
        final num = expr.substring(i, j);
        if (RegExp(r"\..*\.").hasMatch(num)) {
          throw const CalcError("Two decimal points in one number");
        }
        out.add(num);
        i = j;
      } else {
        throw CalcError("Unknown symbol: $c");
      }
    }
    return out;
  }

  static List<String> _toRpn(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];
    for (final t in tokens) {
      if (_ops.containsKey(t) || t == "u-") {
        final prec = t == "u-" ? 3 : _ops[t]!;
        while (stack.isNotEmpty) {
          final top = stack.last;
          final topPrec = top == "u-" ? 3 : _ops[top] ?? 0;
          if (top != "(" && topPrec >= prec) {
            output.add(stack.removeLast());
          } else {
            break;
          }
        }
        stack.add(t);
      } else if (t == "(") {
        stack.add(t);
      } else if (t == ")") {
        var found = false;
        while (stack.isNotEmpty) {
          final top = stack.removeLast();
          if (top == "(") {
            found = true;
            break;
          }
          output.add(top);
        }
        if (!found) throw const CalcError("Unbalanced )");
      } else {
        double.tryParse(t) ?? (throw CalcError("Bad number: $t"));
        output.add(t);
      }
    }
    while (stack.isNotEmpty) {
      final top = stack.removeLast();
      if (top == "(") throw const CalcError("Unbalanced (");
      output.add(top);
    }
    return output;
  }

  static double _evalRpn(List<String> rpn) {
    final stack = <double>[];
    for (final t in rpn) {
      if (t == "u-") {
        if (stack.isEmpty) throw const CalcError("Dangling minus");
        stack.add(-stack.removeLast());
      } else if (_ops.containsKey(t)) {
        if (stack.length < 2) throw const CalcError("Expression incomplete");
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (t) {
          case "+":
            stack.add(a + b);
          case "-":
            stack.add(a - b);
          case "*":
            stack.add(a * b);
          case "/":
            if (b == 0) throw const CalcError("Can't divide by 0");
            stack.add(a / b);
        }
      } else {
        final v = double.tryParse(t);
        if (v == null) throw CalcError("Bad number: $t");
        stack.add(v);
      }
    }
    if (stack.length != 1) throw const CalcError("Expression incomplete");
    return stack.single;
  }
}
