// lib/providers/calculator_provider.dart

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../services/storage_service.dart';
import '../utils/calculator_logic.dart';

class CalculatorProvider extends ChangeNotifier {
  final StorageService _storage;
  CalculatorProvider(this._storage) {
    _load();
  }

  // ── State ─────────────────────────────────────────────────────────────────
  String _expr     = '';
  String _display  = '0';
  String _lastRes  = '';
  bool   _newNum   = true;
  bool   _hasError = false;
  bool   _show2nd  = false;
  double _memory   = 0.0;
  bool   _hasMem   = false;
  CalculatorMode     _mode     = CalculatorMode.basic;
  CalculatorSettings _settings = const CalculatorSettings();
  List<CalculationHistory> _history = [];
  String _progBase = 'DEC';
  int    _progVal  = 0;

  // ── Getters ───────────────────────────────────────────────────────────────
  String get display       => _display;
  String get expression    => _expr;
  String get lastResult    => _lastRes;
  bool   get hasError      => _hasError;
  bool   get showSecond    => _show2nd;
  double get memory        => _memory;
  bool   get hasMemory     => _hasMem;
  CalculatorMode     get mode     => _mode;
  CalculatorSettings get settings => _settings;
  AngleMode          get angleMode => _settings.angleMode;
  List<CalculationHistory> get history => List.unmodifiable(_history);
  String get progBase      => _progBase;
  String get binaryDisplay => _progVal.toRadixString(2).toUpperCase();
  String get octalDisplay  => _progVal.toRadixString(8).toUpperCase();
  String get hexDisplay    => _progVal.toRadixString(16).toUpperCase();

  // ── Load persisted state ──────────────────────────────────────────────────
  void _load() {
    _history = _storage.loadHistory();
    _memory  = _storage.loadMemory();
    _hasMem  = _memory != 0.0;
    _mode = CalculatorMode.values[_storage.loadCalcModeIndex().clamp(0, 2)];
    _settings = _settings.copyWith(
      angleMode:        AngleMode.values[_storage.loadAngleModeIndex().clamp(0, 1)],
      decimalPrecision: _storage.loadPrecision(),
      hapticFeedback:   _storage.loadHaptic(),
      soundEffects:     _storage.loadSound(),
      historySize:      _storage.loadHistorySize(),
    );
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  String _fmt(double v) =>
      CalculatorLogic.formatResult(v, precision: _settings.decimalPrecision);

  void _setVal(double v) {
    _display = _fmt(v);
    _newNum  = true;
  }

  void _appendDigit(String d) {
    if (_newNum || _display == '0') {
      _display = d;
      _newNum  = false;
    } else {
      _display += d;
    }
  }

  void _appendOp(String op) {
    _expr   += _display + op;
    _newNum  = true;
  }

  void _appendFn(String fn) {
    _expr    += '$fn(';
    _display  = '$fn(';
    _newNum   = true;
  }

  void _applyUnary(double Function(double) fn) {
    final v = double.tryParse(_display) ?? 0;
    try {
      _setVal(fn(v));
    } catch (_) {
      _display  = 'Error';
      _hasError = true;
    }
  }

  double _fact(int n) {
    if (n < 0 || n > 20) throw FormatException('Invalid factorial');
    double r = 1;
    for (int i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }

  void _compute() {
    final full = _expr + _display;
    if (full.isEmpty) return;
    try {
      final res = CalculatorLogic.evaluate(full, angleMode: _settings.angleMode);
      final fmt = _fmt(res);
      _history.insert(
        0,
        CalculationHistory(
          expression: full,
          result:     fmt,
          timestamp:  DateTime.now(),
        ),
      );
      if (_history.length > _settings.historySize) {
        _history = _history.sublist(0, _settings.historySize);
      }
      _storage.saveHistory(_history);
      _lastRes = _display;
      _display = fmt;
      _expr    = '';
      _newNum  = true;
      if (_mode == CalculatorMode.programmer) {
        _progVal = res.toInt();
      }
    } catch (_) {
      _display  = 'Error';
      _hasError = true;
      _newNum   = true;
    }
  }

  void _switchBase(String base) {
    _progVal  = (double.tryParse(_display) ?? _progVal.toDouble()).toInt();
    _progBase = base;
    if (base == 'BIN') {
      _display = _progVal.toRadixString(2);
    } else if (base == 'OCT') {
      _display = _progVal.toRadixString(8);
    } else if (base == 'HEX') {
      _display = _progVal.toRadixString(16).toUpperCase();
    } else {
      _display = _progVal.toString();
    }
    _newNum = true;
  }

  // ── Main button handler ───────────────────────────────────────────────────
  void onButton(String label) {
    _hasError = false;

    if (label == 'C') {
      _expr = ''; _display = '0'; _lastRes = ''; _newNum = true;
    } else if (label == 'CE') {
      _display = '0'; _newNum = true;
    } else if (label == '±') {
      if (_display != '0') {
        _display = _display.startsWith('-')
            ? _display.substring(1)
            : '-$_display';
      }
    } else if (label == '.') {
      if (_newNum) {
        _display = '0.'; _newNum = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    } else if (label == 'DEL') {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0'; _newNum = true;
      }
    } else if (label == '=') {
      _compute();
    } else if (label == '+' || label == '-' || label == '×' ||
               label == '÷' || label == '^') {
      _appendOp(label);
    } else if (label == '%') {
      _setVal((double.tryParse(_display) ?? 0) / 100);
    } else if (label == '(') {
      // If there's a pending number, flush it with implicit multiply
      if (!_newNum && _display != '0') {
        _expr += _display + '*';
      }
      _expr   += '(';
      _display = '(';
      _newNum  = true;
    } else if (label == ')') {
      // Flush current display value into expr before closing
      if (!_newNum) {
        _expr += _display;
      }
      _expr   += ')';
      _display = ')';
      _newNum  = true;
    } else if (label == 'π') {
      _setVal(math.pi);
    } else if (label == 'e') {
      _setVal(math.e);
    } else if (label == 'x²') {
      _applyUnary((x) => x * x);
    } else if (label == 'x³') {
      _applyUnary((x) => x * x * x);
    } else if (label == '√') {
      _applyUnary((x) {
        if (x < 0) throw FormatException('sqrt of negative');
        return math.sqrt(x);
      });
    } else if (label == '∛') {
      _applyUnary((x) => math.pow(x, 1 / 3).toDouble());
    } else if (label == '1/x') {
      _applyUnary((x) {
        if (x == 0) throw FormatException('division by zero');
        return 1 / x;
      });
    } else if (label == 'n!') {
      _applyUnary((x) => _fact(x.toInt()));
    } else if (label == 'Ln') {
      _applyUnary((x) {
        if (x <= 0) throw FormatException('ln domain error');
        return math.log(x);
      });
    } else if (label == 'log') {
      _applyUnary((x) {
        if (x <= 0) throw FormatException('log domain error');
        return math.log(x) / math.ln10;
      });
    } else if (label == 'log₂') {
      _applyUnary((x) {
        if (x <= 0) throw FormatException('log₂ domain error');
        return math.log(x) / math.log2e;
      });
    } else if (label == 'sin'  || label == 'cos'  || label == 'tan' ||
               label == 'asin' || label == 'acos' || label == 'atan') {
      _appendFn(label);
    } else if (label == '2nd') {
      _show2nd = !_show2nd;
      notifyListeners();
      return;
    } else if (label == 'MC') {
      _memory = 0; _hasMem = false; _storage.saveMemory(0);
    } else if (label == 'MR') {
      _setVal(_memory);
    } else if (label == 'M+') {
      _memory += double.tryParse(_display) ?? 0;
      _hasMem  = true;
      _storage.saveMemory(_memory);
    } else if (label == 'M-') {
      _memory -= double.tryParse(_display) ?? 0;
      _hasMem  = true;
      _storage.saveMemory(_memory);
    } else if (label == 'DEC' || label == 'BIN' ||
               label == 'OCT' || label == 'HEX') {
      _switchBase(label);
    } else if (label == 'AND') {
      _appendOp('&');
    } else if (label == 'OR') {
      _appendOp('|');
    } else if (label == 'XOR') {
      _appendOp('^');
    } else if (label == 'NOT') {
      _setVal((~(int.tryParse(_display) ?? 0)).toDouble());
    } else if (label == '<<') {
      _appendOp('<<');
    } else if (label == '>>') {
      _appendOp('>>');
    } else if (label == 'HEX_C') {
      _appendDigit('C');
    } else {
      _appendDigit(label);
    }

    notifyListeners();
  }

  // ── Public API ────────────────────────────────────────────────────────────
  void clearHistory() {
    _history = [];
    _storage.clearHistory();
    notifyListeners();
  }

  void useHistoryEntry(CalculationHistory e) {
    _display = e.result;
    _expr    = '';
    _newNum  = true;
    notifyListeners();
  }

  void setMode(CalculatorMode m) {
    _mode = m;
    _storage.saveCalcModeIndex(m.index);
    notifyListeners();
  }

  void setAngleMode(AngleMode a) {
    _settings = _settings.copyWith(angleMode: a);
    _storage.saveAngleModeIndex(a.index);
    notifyListeners();
  }

  void setPrecision(int p) {
    _settings = _settings.copyWith(decimalPrecision: p);
    _storage.savePrecision(p);
    notifyListeners();
  }

  void setHaptic(bool v) {
    _settings = _settings.copyWith(hapticFeedback: v);
    _storage.saveHaptic(v);
    notifyListeners();
  }

  void setSound(bool v) {
    _settings = _settings.copyWith(soundEffects: v);
    _storage.saveSound(v);
    notifyListeners();
  }

  void setHistorySize(int v) {
    _settings = _settings.copyWith(historySize: v);
    _storage.saveHistorySize(v);
    notifyListeners();
  }
}
