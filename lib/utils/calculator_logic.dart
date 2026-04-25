
import 'dart:math' as math;
import '../models/calculator_mode.dart';

class CalculatorLogic {

  static double evaluate(String expression,
      {AngleMode angleMode = AngleMode.degrees}) {
    final cleaned = _preprocess(expression, angleMode);
    return _parse(cleaned, angleMode);
  }

  static String _preprocess(String expr, AngleMode mode) {
    String e = expr
        .replaceAll(RegExp(r'[\u00A0\u200B\u200C\u200D\uFEFF\u2060]'), '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', '${math.pi}')
        .replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m[1]}*(')
        .replaceAllMapped(RegExp(r'(\d)([a-zA-Z])'), (m) => '${m[1]}*${m[2]}')
        .replaceAllMapped(RegExp(r'\)(\()'), (m) => ')*(')
        .replaceAllMapped(RegExp(r'\)([a-zA-Z])'), (m) => ')*${m[2]}');

    return e;
  }

  static double _parse(String expr, AngleMode angleMode) {
    final tokens = _tokenize(expr.trim());
    int pos = 0;

    late double Function() parseExpr;
    late double Function() parseAddSub;
    late double Function() parseMulDiv;
    late double Function() parsePower;
    late double Function() parseUnary;
    late double Function() parsePrimary;

    final bool isDeg = angleMode == AngleMode.degrees;
    final Map<String, double Function(double)> fnMap = {
      'sin':   (x) => math.sin(isDeg ? x * math.pi / 180 : x),
      'cos':   (x) => math.cos(isDeg ? x * math.pi / 180 : x),
      'tan':   (x) => math.tan(isDeg ? x * math.pi / 180 : x),
      'asin':  (x) => isDeg ? math.asin(x) * 180 / math.pi : math.asin(x),
      'acos':  (x) => isDeg ? math.acos(x) * 180 / math.pi : math.acos(x),
      'atan':  (x) => isDeg ? math.atan(x) * 180 / math.pi : math.atan(x),
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

      'cbrt':  (x) => x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble(),
      'abs':   (x) => x.abs(),
      'ceil':  (x) => x.ceilToDouble(),
      'floor': (x) => x.floorToDouble(),
    };

    parsePrimary = () {
      if (pos >= tokens.length) throw FormatException('Unexpected end of expression');

      final tok = tokens[pos];

      if (tok == '(') {
        pos++;
        final val = parseExpr();
        if (pos >= tokens.length || tokens[pos] != ')') {
          throw FormatException('Missing closing parenthesis');
        }
        pos++;
        double result = val;
        while (pos < tokens.length && tokens[pos] == '!') {
          pos++;
          if (result != result.truncateToDouble() || result < 0) {
            throw FormatException('Factorial requires a non-negative integer');
          }
          result = _factorial(result.toInt()).toDouble();
        }
        return result;
      }

      if (fnMap.containsKey(tok)) {
        pos++;
        if (pos >= tokens.length || tokens[pos] != '(') {
          throw FormatException('Expected "(" after $tok');
        }
        pos++;
        final arg = parseExpr();
        if (pos >= tokens.length || tokens[pos] != ')') {
          throw FormatException('Missing ")" after $tok argument');
        }
        pos++;
        return fnMap[tok]!(arg);
      }

      final value = double.tryParse(tok);
      if (value == null) throw FormatException('Unknown token: $tok');
      pos++;

      double result = value;
      while (pos < tokens.length && tokens[pos] == '!') {
        pos++;
        if (result != result.truncateToDouble() || result < 0) {
          throw FormatException('Factorial requires a non-negative integer');
        }
        result = _factorial(result.toInt()).toDouble();
      }
      return result;
    };

    parseUnary = () {
      if (pos < tokens.length && tokens[pos] == '-') {
        pos++;
        return -parsePower();
      }
      if (pos < tokens.length && tokens[pos] == '+') {
        pos++;
      }
      return parsePrimary();
    };

    parsePower = () {
      double base = parsePrimary();
      if (pos < tokens.length && tokens[pos] == '^') {
        pos++;
        final exp = parseUnary();
        base = math.pow(base, exp).toDouble();
      }
      return base;
    };

    parseMulDiv = () {
      double left = parseUnary();
      while (pos < tokens.length &&
          (tokens[pos] == '*' || tokens[pos] == '/')) {
        final op = tokens[pos++];
        final right = parseUnary();
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

  static List<String> _tokenize(String expr) {
    final tokens = <String>[];
    int i = 0;
    while (i < expr.length) {
      final ch = expr[i];
      if (ch == ' ') { i++; continue; }

      if (RegExp(r'[\d.]').hasMatch(ch)) {
        final match = RegExp(r'\d*\.?\d+(?:[eE][-+]?\d+)?').firstMatch(expr.substring(i));
        if (match != null) {
          tokens.add(match.group(0)!);
          i += match.group(0)!.length;
        } else {
          tokens.add(ch);
          i++;
        }
        continue;
      }

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

  static int _factorial(int n) {
    if (n < 0) throw FormatException('Factorial of negative number');
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
  }

  static double memoryAdd(double current, double value) => current + value;
  static double memorySubtract(double current, double value) => current - value;

  static String toBinary(int value) => value.toRadixString(2).toUpperCase();
  static String toOctal(int value)  => value.toRadixString(8).toUpperCase();
  static String toHex(int value)    => value.toRadixString(16).toUpperCase();

  static int bitwiseAnd(int a, int b) => a & b;
  static int bitwiseOr(int a, int b)  => a | b;
  static int bitwiseXor(int a, int b) => a ^ b;
  static int bitwiseNot(int a)        => ~a;
  static int shiftLeft(int a, int n)  => a << n;
  static int shiftRight(int a, int n) => a >> n;


  static String formatResult(double value, {int precision = 10}) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    if (value == value.truncateToDouble()) {
      final asInt = value.toInt();
      if (asInt.abs() < 100000000000000) return asInt.toString();
    }

    if (value.abs() >= 1e14 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(precision);
    }

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
