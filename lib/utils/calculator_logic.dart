// lib/utils/calculator_logic.dart

import 'dart:math' as math;
import '../models/calculator_mode.dart';

/// Pure calculation logic — no Flutter dependencies.
/// All public methods are static so they are easily unit-testable.
class CalculatorLogic {

  /// Evaluates a mathematical expression string and returns a double.
  /// Throws [FormatException] for invalid expressions.
  static double evaluate(String expression,
      {AngleMode angleMode = AngleMode.degrees}) {
    final cleaned = _preprocess(expression, angleMode);
    return _parse(cleaned);
  }

  /// Pre-processes the raw expression string before parsing.
  static String _preprocess(String expr, AngleMode mode) {
    String e = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '${math.pi}')
        // implicit multiplication: digit followed by '('
        .replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m[1]}*(');

    // Do NOT replace bare 'e' — it is a function name suffix or Euler number
    // handled separately via the constants path in the provider.

    // Wrap trig arguments in deg→rad conversion when needed
    if (mode == AngleMode.degrees) {
      final inverseFns = ['asin', 'acos', 'atan'];
      final directFns  = ['sin', 'cos', 'tan'];

      for (final fn in inverseFns) {
        e = e.replaceAllMapped(
          RegExp('$fn\\(([^)]+)\\)'),
          (m) => '(${m[1]}*(${180 / math.pi}))',  // result in degrees
        );
      }
      for (final fn in directFns) {
        e = e.replaceAllMapped(
          RegExp('$fn\\(([^)]+)\\)'),
          (m) => '$fn(${m[1]}*(${math.pi / 180}))',
        );
      }
    }
    return e;
  }

  /// Recursive-descent parser implementing PEMDAS/BODMAS.
  /// Uses `late` function variables so mutually-recursive closures can
  /// reference each other without triggering Dart's
  /// "can't be referenced before it is declared" error.
  static double _parse(String expr) {
    final tokens = _tokenize(expr.trim());
    int pos = 0;

    late double Function() parseExpr;
    late double Function() parseAddSub;
    late double Function() parseMulDiv;
    late double Function() parsePower;
    late double Function() parseUnary;
    late double Function() parsePrimary;

    parsePrimary = () {
      if (pos >= tokens.length) throw FormatException('Unexpected end of expression');

      final tok = tokens[pos];

      // Parenthesised sub-expression
      if (tok == '(') {
        pos++;
        final val = parseExpr();
        if (pos >= tokens.length || tokens[pos] != ')') {
          throw FormatException('Missing closing parenthesis');
        }
        pos++;
        return val;
      }

      // Built-in math functions
      final Map<String, double Function(double)> fnMap = {
        'sin':   (x) => math.sin(x),
        'cos':   (x) => math.cos(x),
        'tan':   (x) => math.tan(x),
        'asin':  (x) => math.asin(x),
        'acos':  (x) => math.acos(x),
        'atan':  (x) => math.atan(x),
        'ln':    (x) {
          if (x <= 0) throw FormatException('ln domain error');
          return math.log(x);
        },
        'log':   (x) {
          if (x <= 0) throw FormatException('log domain error');
          return math.log(x) / math.ln10;
        },
        'log2':  (x) {
          if (x <= 0) throw FormatException('log2 domain error');
          return math.log(x) / math.log2e;
        },
        'sqrt':  (x) {
          if (x < 0) throw FormatException('sqrt of negative');
          return math.sqrt(x);
        },
        'cbrt':  (x) => math.pow(x, 1 / 3).toDouble(),
        'abs':   (x) => x.abs(),
        'ceil':  (x) => x.ceilToDouble(),
        'floor': (x) => x.floorToDouble(),
      };

      if (fnMap.containsKey(tok)) {
        pos++;
        if (pos >= tokens.length || tokens[pos] != '(') {
          throw FormatException('Expected "(" after $tok');
        }
        pos++; // consume '('
        final arg = parseExpr();
        if (pos >= tokens.length || tokens[pos] != ')') {
          throw FormatException('Missing ")" after $tok argument');
        }
        pos++; // consume ')'
        return fnMap[tok]!(arg);
      }

      // Number literal
      final value = double.tryParse(tok);
      if (value == null) throw FormatException('Unknown token: $tok');
      pos++;

      // Factorial '!'
      if (pos < tokens.length && tokens[pos] == '!') {
        pos++;
        return _factorial(value.toInt()).toDouble();
      }
      return value;
    };

    parseUnary = () {
      if (pos < tokens.length && tokens[pos] == '-') {
        pos++;
        return -parsePrimary();
      }
      if (pos < tokens.length && tokens[pos] == '+') {
        pos++;
      }
      return parsePrimary();
    };

    parsePower = () {
      double base = parseUnary();
      if (pos < tokens.length && tokens[pos] == '^') {
        pos++;
        final exp = parsePower(); // right-associative
        base = math.pow(base, exp).toDouble();
      }
      return base;
    };

    parseMulDiv = () {
      double left = parsePower();
      while (pos < tokens.length &&
          (tokens[pos] == '*' || tokens[pos] == '/')) {
        final op = tokens[pos++];
        final right = parsePower();
        if (op == '/' && right == 0) {
          throw FormatException('Division by zero');
        }
        left = op == '*' ? left * right : left / right;
      }
      return left;
    };

    parseAddSub = () {
      double left = parseMulDiv();
      while (pos < tokens.length &&
          (tokens[pos] == '+' || tokens[pos] == '-')) {
        final op = tokens[pos++];
        final right = parseMulDiv();
        left = op == '+' ? left + right : left - right;
      }
      return left;
    };

    parseExpr = () => parseAddSub();

    final result = parseExpr();
    if (pos < tokens.length) {
      throw FormatException('Unexpected token: ${tokens[pos]}');
    }
    return result;
  }

  /// Converts an expression string into a flat list of tokens.
  static List<String> _tokenize(String expr) {
    final tokens = <String>[];
    int i = 0;
    while (i < expr.length) {
      final ch = expr[i];
      if (ch == ' ') { i++; continue; }

      // Number (integer or decimal, possibly with leading minus handled by unary)
      if (RegExp(r'[\d.]').hasMatch(ch)) {
        int j = i;
        while (j < expr.length && RegExp(r'[\d.]').hasMatch(expr[j])) j++;
        tokens.add(expr.substring(i, j));
        i = j;
        continue;
      }

      // Identifier / function name
      if (RegExp(r'[a-zA-Z_]').hasMatch(ch)) {
        int j = i;
        while (j < expr.length && RegExp(r'[a-zA-Z0-9_]').hasMatch(expr[j])) j++;
        tokens.add(expr.substring(i, j));
        i = j;
        continue;
      }

      tokens.add(ch);
      i++;
    }
    return tokens;
  }

  // ── Factorial ─────────────────────────────────────────────────────────────
  static int _factorial(int n) {
    if (n < 0) throw FormatException('Factorial of negative number');
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  // ── Memory helpers ────────────────────────────────────────────────────────
  static double memoryAdd(double current, double value) => current + value;
  static double memorySubtract(double current, double value) => current - value;

  // ── Programmer mode helpers ───────────────────────────────────────────────
  static String toBinary(int value) => value.toRadixString(2).toUpperCase();
  static String toOctal(int value)  => value.toRadixString(8).toUpperCase();
  static String toHex(int value)    => value.toRadixString(16).toUpperCase();

  static int bitwiseAnd(int a, int b) => a & b;
  static int bitwiseOr(int a, int b)  => a | b;
  static int bitwiseXor(int a, int b) => a ^ b;
  static int bitwiseNot(int a)        => ~a;
  static int shiftLeft(int a, int n)  => a << n;
  static int shiftRight(int a, int n) => a >> n;

  // ── Result formatting ─────────────────────────────────────────────────────
  /// Formats a double result, removing trailing zeros.
  static String formatResult(double value, {int precision = 10}) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Integer check
    if (value == value.truncateToDouble()) {
      final asInt = value.toInt();
      if (asInt.abs() < 1000000000000000) return asInt.toString();
    }

    // Scientific notation for very large or very small numbers
    if (value.abs() >= 1e15 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(precision);
    }

    // Fixed point with trimmed trailing zeros
    final formatted = value.toStringAsFixed(precision);
    if (formatted.contains('.')) {
      final trimmed = formatted.replaceAll(RegExp(r'0+$'), '');
      return trimmed.endsWith('.')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed;
    }
    return formatted;
  }
}
