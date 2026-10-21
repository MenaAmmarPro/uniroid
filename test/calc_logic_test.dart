import "package:flutter_test/flutter_test.dart";

import "package:uniroid/tools/calc_logic.dart";

void main() {
  group("CalculatorMath.evaluate", () {
    test("single number", () {
      expect(CalculatorMath.evaluate("7"), 7.0);
      expect(CalculatorMath.evaluate("3.14"), closeTo(3.14, 1e-9));
    });

    test("add and subtract", () {
      expect(CalculatorMath.evaluate("2+3"), 5.0);
      expect(CalculatorMath.evaluate("10-4-3"), 3.0);
      expect(CalculatorMath.evaluate("1.5+2.25"), closeTo(3.75, 1e-9));
    });

    test("precedence: * / before + -", () {
      expect(CalculatorMath.evaluate("2+3*4"), 14.0);
      expect(CalculatorMath.evaluate("20/2/5"), 2.0);
      expect(CalculatorMath.evaluate("8+6/2-3"), 8.0);
    });

    test("parentheses", () {
      expect(CalculatorMath.evaluate("(2+3)*4"), 20.0);
      expect(CalculatorMath.evaluate("10/(2+3)"), 2.0);
    });

    test("unary minus", () {
      expect(CalculatorMath.evaluate("-5+3"), -2.0);
      expect(CalculatorMath.evaluate("2*-3"), -6.0);
      expect(CalculatorMath.evaluate("2-3"), -1.0);
      expect(CalculatorMath.evaluate("(-2)*3"), -6.0);
    });

    test("multiply by negative result", () {
      expect(CalculatorMath.evaluate("4*-2"), closeTo(-8, 1e-9));
    });

    test("errors", () {
      expect(() => CalculatorMath.evaluate("5/0"), throwsA(isA<CalcError>()));
      expect(() => CalculatorMath.evaluate("2+"), throwsA(isA<CalcError>()));
      expect(() => CalculatorMath.evaluate("(2+3"), throwsA(isA<CalcError>()));
      expect(
        () => CalculatorMath.evaluate("2..5+1"),
        throwsA(isA<CalcError>()),
      );
      expect(() => CalculatorMath.evaluate("2?3"), throwsA(isA<CalcError>()));
    });
  });

  group("CalculatorMath.format", () {
    test("integers print clean", () {
      expect(CalculatorMath.format(7.0), "7");
      expect(CalculatorMath.format(-102.0), "-102");
    });

    test("fractions trim trailing zeros", () {
      expect(CalculatorMath.format(0.5), "0.5");
      // float noise: 1.2 + tiny epsilon → rounds away at 10 decimals
      expect(CalculatorMath.format(1.2 + 1e-12), "1.2");
    });

    test("infinity shows symbol", () {
      expect(CalculatorMath.format(double.infinity), "∞");
    });
  });
}
