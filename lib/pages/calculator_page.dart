import "package:flutter/material.dart";

import "../tools/calc_logic.dart";

/// A friendly 4-function calculator (Tools tab).
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expr = "";
  String _result = "";
  String? _error;

  void _press(String key) {
    setState(() {
      switch (key) {
        case "C":
          _expr = "";
          _result = "";
          _error = null;
          return;
        case "⌫":
          if (_expr.isNotEmpty) _expr = _expr.substring(0, _expr.length - 1);
          break;
        case "=":
          _solve();
          return;
        case "(":
        case ")":
          _expr += key;
          break;
        default:
          if (_solved && RegExp(r"[0-9.]").hasMatch(key)) {
            _expr = ""; // start a fresh calculation after "="
          }
          _solved = false;
          _expr += key;
      }
      _preview();
    });
  }

  bool _solved = false;

  void _preview() {
    try {
      final v = CalculatorMath.evaluate(_expr);
      _result = CalculatorMath.format(v);
      _error = null;
    } on CalcError {
      // During typing this is normal (e.g. "2+"), keep it quiet.
      _result = "";
    } catch (_) {
      _result = "";
    }
  }

  void _solve() {
    try {
      final v = CalculatorMath.evaluate(_expr);
      _result = CalculatorMath.format(v);
      _error = null;
      _solved = true;
    } on CalcError catch (e) {
      _result = "";
      _error = e.message;
    } catch (_) {
      _result = "";
      _error = "Something went wrong";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = <String>[
      // ignore: prefer_const_literals_to_create_immutables
      "7", "8", "9", "/",
      "4", "5", "6", "*",
      "1", "2", "3", "-",
      "0", ".", "=", "+",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Calculator")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _error ?? _expr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _error != null
                          ? theme.colorScheme.error
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  if (_result.isNotEmpty)
                    Text(
                      _result,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildKey("(", 1, wide: 1),
                    _buildKey(")", 1, wide: 1),
                    _buildKey("⌫", 1, wide: 1),
                    _buildKey("C", 1, danger: true, wide: 1),
                  ],
                ),
                const SizedBox(height: 8),
                for (final row in [
                  keys.sublist(0, 4),
                  keys.sublist(4, 8),
                  keys.sublist(8, 12),
                  keys.sublist(12, 16),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [for (final k in row) _buildKey(k, 1)],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String k, int flexKey, {bool danger = false, int wide = 1}) {
    final isOp = k == "/" || k == "*" || k == "-" || k == "+";
    final isEquals = k == "=";
    return Expanded(
      flex: wide,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () => _press(k),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(64, 52),
            side: BorderSide(
              color: isEquals
                  ? const Color(0xFFE91E63)
                  : Theme.of(context).dividerTheme.color ??
                        Colors.grey.shade300,
            ),
            backgroundColor: isEquals
                ? const Color(0xFFE91E63)
                : danger
                ? Colors.redAccent.withOpacity(0.08)
                : isOp
                ? Theme.of(context).cardTheme.color
                : Theme.of(context).cardTheme.color,
            foregroundColor: isEquals
                ? Colors.white
                : danger
                ? Colors.redAccent
                : Theme.of(context).textTheme.bodyMedium?.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            k,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
