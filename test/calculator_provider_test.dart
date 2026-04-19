// test/calculator_provider_test.dart
//
// Tests for CalculatorProvider button logic (state machine).
// Uses a real StorageService backed by a fresh SharedPreferences instance
// provided by the flutter_test in-memory mock.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advanced_calculator/models/calculator_mode.dart';
import 'package:advanced_calculator/providers/calculator_provider.dart';
import 'package:advanced_calculator/services/storage_service.dart';

// ─── Helper ──────────────────────────────────────────────────────────────────

Future<CalculatorProvider> _makeProvider() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  await storage.init();
  return CalculatorProvider(storage);
}

void _press(CalculatorProvider c, List<String> buttons) {
  for (final b in buttons) c.onButton(b);
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Basic mode calculations', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('initial display is 0', () => expect(calc.display, '0'));

    test('simple addition 5+3=8', () {
      _press(calc, ['5', '+', '3', '=']);
      expect(calc.display, '8');
    });

    test('simple subtraction 9-4=5', () {
      _press(calc, ['9', '-', '4', '=']);
      expect(calc.display, '5');
    });

    test('multiplication 6×7=42', () {
      _press(calc, ['6', '×', '7', '=']);
      expect(calc.display, '42');
    });

    test('division 15÷3=5', () {
      _press(calc, ['1', '5', '÷', '3', '=']);
      expect(calc.display, '5');
    });

    test('decimal: 1.5+2.5=4', () {
      _press(calc, ['1', '.', '5', '+', '2', '.', '5', '=']);
      expect(calc.display, '4');
    });

    test('C clears display', () {
      _press(calc, ['5', '+', 'C']);
      expect(calc.display, '0');
      expect(calc.expression, '');
    });

    test('CE clears only current number', () {
      _press(calc, ['5', '+', '3', 'CE']);
      expect(calc.display, '0');
      expect(calc.expression, isNotEmpty);
    });

    test('± toggles sign', () {
      _press(calc, ['5', '±']);
      expect(calc.display, '-5');
      calc.onButton('±');
      expect(calc.display, '5');
    });

    test('% divides by 100', () {
      _press(calc, ['5', '0', '%']);
      expect(calc.display, '0.5');
    });

    test('DEL removes last digit', () {
      _press(calc, ['1', '2', '3', 'DEL']);
      expect(calc.display, '12');
    });

    test('chain: 5+3=+2=+1=11', () {
      _press(calc, ['5', '+', '3', '=']);
      _press(calc, ['+', '2', '=']);
      _press(calc, ['+', '1', '=']);
      expect(calc.display, '11');
    });
  });

  group('Memory operations', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('M+ then MR recalls value', () {
      _press(calc, ['5', 'M+', 'C']);
      calc.onButton('MR');
      expect(calc.display, '5');
    });

    test('M+ accumulates: 5 M+ 3 M+ MR=8', () {
      _press(calc, ['5', 'M+', 'C', '3', 'M+', 'C']);
      calc.onButton('MR');
      expect(calc.display, '8');
    });

    test('M- subtracts from memory', () {
      _press(calc, ['1', '0', 'M+', 'C', '3', 'M-', 'C']);
      calc.onButton('MR');
      expect(calc.display, '7');
    });

    test('MC clears memory', () {
      _press(calc, ['5', 'M+', 'MC']);
      expect(calc.hasMemory, isFalse);
      expect(calc.memory, 0.0);
    });
  });

  group('Mode switching', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('default mode is basic', () => expect(calc.mode, CalculatorMode.basic));

    test('switch to scientific', () {
      calc.setMode(CalculatorMode.scientific);
      expect(calc.mode, CalculatorMode.scientific);
    });

    test('switch to programmer', () {
      calc.setMode(CalculatorMode.programmer);
      expect(calc.mode, CalculatorMode.programmer);
    });
  });

  group('Scientific functions', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('x² squares the value', () {
      _press(calc, ['4', 'x²']);
      expect(calc.display, '16');
    });

    test('√ computes square root', () {
      _press(calc, ['9', '√']);
      expect(calc.display, '3');
    });

    test('1/x computes reciprocal', () {
      _press(calc, ['4', '1/x']);
      expect(calc.display, '0.25');
    });

    test('1/0 shows Error', () {
      _press(calc, ['0', '1/x']);
      expect(calc.display, 'Error');
      expect(calc.hasError, isTrue);
    });

    test('√ of negative shows Error', () {
      _press(calc, ['9', '±', '√']);
      expect(calc.display, 'Error');
    });

    test('x³ cubes the value', () {
      _press(calc, ['3', 'x³']);
      expect(calc.display, '27');
    });
  });

  group('History management', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('history is empty initially', () => expect(calc.history, isEmpty));

    test('calculation adds to history', () {
      _press(calc, ['3', '+', '4', '=']);
      expect(calc.history, isNotEmpty);
      expect(calc.history.first.result, '7');
    });

    test('clearHistory empties the list', () {
      _press(calc, ['3', '+', '4', '=']);
      calc.clearHistory();
      expect(calc.history, isEmpty);
    });

    test('useHistoryEntry restores result', () {
      _press(calc, ['3', '+', '4', '=']);
      final entry = calc.history.first;
      calc.onButton('C');
      calc.useHistoryEntry(entry);
      expect(calc.display, '7');
    });
  });

  group('Settings persistence', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('setAngleMode changes mode', () {
      calc.setAngleMode(AngleMode.radians);
      expect(calc.angleMode, AngleMode.radians);
    });

    test('setPrecision changes precision', () {
      calc.setPrecision(4);
      expect(calc.settings.decimalPrecision, 4);
    });

    test('setHistorySize changes size', () {
      calc.setHistorySize(25);
      expect(calc.settings.historySize, 25);
    });

    test('setHaptic changes haptic', () {
      calc.setHaptic(false);
      expect(calc.settings.hapticFeedback, isFalse);
    });
  });

  group('Angle mode – trig via expression', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('2nd toggle flips showSecond', () {
      expect(calc.showSecond, isFalse);
      calc.onButton('2nd');
      expect(calc.showSecond, isTrue);
      calc.onButton('2nd');
      expect(calc.showSecond, isFalse);
    });
  });

  group('Parentheses', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('(2+3)×4=20', () {
      _press(calc, ['(', '2', '+', '3', ')', '×', '4', '=']);
      expect(calc.display, '20');
    });
  });

  group('Constants', () {
    late CalculatorProvider calc;
    setUp(() async => calc = await _makeProvider());

    test('π button sets display to pi', () {
      calc.onButton('π');
      expect(double.parse(calc.display), closeTo(3.14159265, 1e-5));
    });

    test('e button sets display to e', () {
      calc.onButton('e');
      expect(double.parse(calc.display), closeTo(2.71828182, 1e-5));
    });
  });
}
