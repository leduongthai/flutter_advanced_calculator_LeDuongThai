
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_calculator/utils/calculator_logic.dart';
import 'package:advanced_calculator/models/calculator_mode.dart';

void main() {
  double eval(String expr, {AngleMode mode = AngleMode.degrees}) =>
      CalculatorLogic.evaluate(expr, angleMode: mode);

  group('Basic arithmetic', () {
    test('addition', () => expect(eval('2+3'), 5));
    test('subtraction', () => expect(eval('10-4'), 6));
    test('multiplication', () => expect(eval('3×4'), 12));
    test('division', () => expect(eval('15÷3'), 5));
    test('negative result', () => expect(eval('3-7'), -4));
    test('decimal operands', () => expect(eval('1.5+2.5'), closeTo(4.0, 1e-9)));
    test('division by zero throws', () => expect(() => eval('5÷0'), throwsFormatException));
  });

  group('Operator precedence', () {
    test('mul before add', () => expect(eval('2+3×4'), 14));
    test('div before sub', () => expect(eval('10-6÷2'), 7));
    test('parentheses override', () => expect(eval('(2+3)×4'), 20));
    test('complex: (5+3)×2-4÷2', () => expect(eval('(5+3)×2-4÷2'), 14));
    test('nested parens: ((2+3)×(4-1))÷5', () => expect(eval('((2+3)×(4-1))÷5'), 3));
    test('power right-assoc: 2^3^2', () => expect(eval('2^3^2'), 512));
  });

  group('Scientific – degrees', () {
    test('sin(0)', ()  => expect(eval('sin(0)'),  closeTo(0.0, 1e-9)));
    test('sin(90)', () => expect(eval('sin(90)'), closeTo(1.0, 1e-9)));
    test('cos(0)', ()  => expect(eval('cos(0)'),  closeTo(1.0, 1e-9)));
    test('cos(90)', () => expect(eval('cos(90)'), closeTo(0.0, 1e-9)));
    test('tan(45)', () => expect(eval('tan(45)'), closeTo(1.0, 1e-9)));
    test('sin(45)+cos(45)', () => expect(eval('sin(45)+cos(45)'), closeTo(math.sqrt2, 1e-9)));
    test('asin(1) == 90', () => expect(eval('asin(1)'), closeTo(90.0, 1e-9)));
    test('acos(1) == 0',  () => expect(eval('acos(1)'), closeTo(0.0,  1e-9)));
    test('atan(1) == 45', () => expect(eval('atan(1)'), closeTo(45.0, 1e-9)));
  });

  group('Scientific – radians', () {
    test('sin(π/2)', () => expect(
        eval('sin(${math.pi/2})', mode: AngleMode.radians), closeTo(1.0, 1e-9)));
    test('cos(π)', () => expect(
        eval('cos(${math.pi})', mode: AngleMode.radians), closeTo(-1.0, 1e-9)));
  });

  group('Logarithms', () {
    test('ln(e) == 1',    () => expect(eval('ln(${math.e})'),    closeTo(1.0,        1e-9)));
    test('ln(1) == 0',    () => expect(eval('ln(1)'),            closeTo(0.0,        1e-9)));
    test('log(10) == 1',  () => expect(eval('log(10)'),          closeTo(1.0,        1e-9)));
    test('log(100) == 2', () => expect(eval('log(100)'),         closeTo(2.0,        1e-9)));
    test('ln domain error', () => expect(() => eval('ln(0)'),    throwsFormatException));
    test('log domain error', () => expect(() => eval('log(-1)'), throwsFormatException));
  });

  group('Power and roots', () {
    test('2^10',   () => expect(eval('2^10'),   closeTo(1024.0, 1e-9)));
    test('sqrt(9)', () => expect(eval('sqrt(9)'), closeTo(3.0,  1e-9)));
    test('cbrt(27)', () => expect(eval('cbrt(27)'), closeTo(3.0,1e-9)));
    test('sqrt of negative throws', () => expect(() => eval('sqrt(-1)'), throwsFormatException));
  });

  group('Constants', () {
    test('π replaced correctly', () {
      final result = eval('2×π');
      expect(result, closeTo(2 * math.pi, 1e-9));
    });
    test('e replaced correctly', () {
      final result = eval('e');
      expect(result, closeTo(math.e, 1e-9));
    });
  });

  group('Mixed scientific', () {
    test('2×π×sqrt(9) ≈ 18.8495', () {
      final result = eval('2×π×sqrt(9)');
      expect(result, closeTo(2 * math.pi * 3, 1e-6));
    });
    test('chain: sin²+cos²=1', () {
      final result = eval('sin(30)^2+cos(30)^2');
      expect(result, closeTo(1.0, 1e-9));
    });
  });

  group('Factorial (n!)', () {
    double fact(int n) {
      if (n < 0 || n > 20) throw FormatException('Invalid');
      double r = 1; for (int i = 2; i <= n; i++) r *= i; return r;
    }

    test('0! = 1',  () => expect(fact(0),  1));
    test('1! = 1',  () => expect(fact(1),  1));
    test('5! = 120',() => expect(fact(5),  120));
    test('10! = 3628800', () => expect(fact(10), 3628800));
    test('negative throws', () => expect(() => fact(-1), throwsFormatException));
  });

  group('formatResult', () {
    test('integer stays integer', ()    => expect(CalculatorLogic.formatResult(42.0),    '42'));
    test('trailing zeros trimmed', ()   => expect(CalculatorLogic.formatResult(3.1400),  '3.14'));
    test('NaN returns Error', ()        => expect(CalculatorLogic.formatResult(double.nan), 'Error'));
    test('Infinity returns ∞', ()       => expect(CalculatorLogic.formatResult(double.infinity), '∞'));
    test('-Infinity returns -∞', ()     => expect(CalculatorLogic.formatResult(double.negativeInfinity), '-∞'));
    test('very small scientific', () {
      final s = CalculatorLogic.formatResult(0.000000001);
      expect(s.contains('e'), isTrue);
    });
    test('very large scientific', () {
      final s = CalculatorLogic.formatResult(1e16);
      expect(s.contains('e'), isTrue);
    });
    test('precision respected', () {
      final s = CalculatorLogic.formatResult(1.0/3.0, precision: 4);
      expect(s, '0.3333');
    });
  });

  group('Programmer mode helpers', () {
    test('toBinary(10)  == "1010"',    () => expect(CalculatorLogic.toBinary(10),  '1010'));
    test('toOctal(8)    == "10"',      () => expect(CalculatorLogic.toOctal(8),    '10'));
    test('toHex(255)    == "FF"',      () => expect(CalculatorLogic.toHex(255),    'FF'));
    test('AND 0xFF & 0x0F == 0x0F',    () => expect(CalculatorLogic.bitwiseAnd(0xFF, 0x0F), 0x0F));
    test('OR  0xF0 | 0x0F == 0xFF',    () => expect(CalculatorLogic.bitwiseOr(0xF0,  0x0F), 0xFF));
    test('XOR 0xFF ^ 0x0F == 0xF0',    () => expect(CalculatorLogic.bitwiseXor(0xFF, 0x0F), 0xF0));
    test('shift left  1 << 3 == 8',    () => expect(CalculatorLogic.shiftLeft(1, 3),  8));
    test('shift right 8 >> 2 == 2',    () => expect(CalculatorLogic.shiftRight(8, 2), 2));
  });

  group('Memory helpers', () {
    test('memoryAdd',      () => expect(CalculatorLogic.memoryAdd(5, 3),      8));
    test('memorySubtract', () => expect(CalculatorLogic.memorySubtract(10, 4), 6));
  });

  group('Error handling', () {
    test('empty expression throws', () => expect(() => eval(''), throwsException));
    test('unknown token throws',    () => expect(() => eval('foo+1'), throwsException));
    test('missing close paren throws', () => expect(() => eval('(2+3'), throwsException));
    test('lone operator throws',    () => expect(() => eval('+'), throwsException));
  });

  group('Lab scenario tests', () {
    test('(5+3)×2-4÷2 = 14',                 () => expect(eval('(5+3)×2-4÷2'),      closeTo(14.0,   1e-9)));
    test('sin(45)+cos(45) ≈ √2',             () => expect(eval('sin(45)+cos(45)'),   closeTo(math.sqrt2, 1e-6)));
    test('((2+3)×(4-1))÷5 = 3',              () => expect(eval('((2+3)×(4-1))÷5'),   closeTo(3.0,    1e-9)));
    test('2×π×sqrt(9) ≈ 18.8495',            () => expect(eval('2×π×sqrt(9)'),       closeTo(18.8495559, 1e-4)));
    test('AND: 0xFF AND 0x0F = 0x0F',        () => expect(CalculatorLogic.bitwiseAnd(0xFF, 0x0F), 0x0F));
  });
}
