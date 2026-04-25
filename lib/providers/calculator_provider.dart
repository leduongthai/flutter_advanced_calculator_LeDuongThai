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

  String _expr       = '';
  String _display    = '0';
  String _lastRes    = '';
  bool   _justEvaled = false;
  bool   _hasError   = false;
  bool   _show2nd    = false;
  double _memory     = 0.0;
  bool   _hasMem     = false;
  CalculatorMode     _mode     = CalculatorMode.basic;
  CalculatorSettings _settings = const CalculatorSettings();
  List<CalculationHistory> _history = [];
  String _progBase = 'DEC';
  int    _progVal  = 0;

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

  String _fmt(double v) =>
      CalculatorLogic.formatResult(v, precision: _settings.decimalPrecision);

  void _syncDisplay() {
    _display = _expr.isEmpty ? '0' : _expr;
  }

  bool get _endsWithOp {
    if (_expr.isEmpty) return true;
    final last = _expr[_expr.length - 1];
    return '+-×÷^*/%(&|'.contains(last);
  }

  bool get _endsWithValue {
    if (_expr.isEmpty) return false;
    final last = _expr[_expr.length - 1];
    return RegExp(r'[\d).πe]').hasMatch(last);
  }

  void _replaceTrailingOp(String newOp) {
    if (_expr.isNotEmpty && '+-×÷^'.contains(_expr[_expr.length - 1])) {
      _expr = _expr.substring(0, _expr.length - 1) + newOp;
    } else {
      _expr += newOp;
    }
  }

  double _fact(int n) {
    if (n < 0 || n > 170) throw FormatException('Invalid factorial');
    double r = 1;
    for (int i = 2; i <= n; i++) r *= i;
    return r;
  }

  void _compute() {
    if (_expr.isEmpty) return;
    final open    = '('.allMatches(_expr).length;
    final close   = ')'.allMatches(_expr).length;
    final toClose = open - close;
    final full    = _expr + (toClose > 0 ? ')' * toClose : '');
    try {
      final res = CalculatorLogic.evaluate(full, angleMode: _settings.angleMode);
      final fmt = _fmt(res);
      _history.insert(0, CalculationHistory(
        expression: full,
        result:     fmt,
        timestamp:  DateTime.now(),
      ));
      if (_history.length > _settings.historySize) {
        _history = _history.sublist(0, _settings.historySize);
      }
      _storage.saveHistory(_history);
      _lastRes    = fmt;
      _display    = fmt;
      _expr       = fmt;
      _justEvaled = true;
      if (_mode == CalculatorMode.programmer) _progVal = res.toInt();
    } catch (_) {
      _display    = 'Error';
      _hasError   = true;
      _expr       = '';
      _justEvaled = true;
    }
  }

  void _switchBase(String base) {
    _progVal  = (double.tryParse(_expr) ?? _progVal.toDouble()).toInt();
    _progBase = base;
    switch (base) {
      case 'BIN': _expr = _progVal.toRadixString(2); break;
      case 'OCT': _expr = _progVal.toRadixString(8); break;
      case 'HEX': _expr = _progVal.toRadixString(16).toUpperCase(); break;
      default:    _expr = _progVal.toString();
    }
    _justEvaled = true;
    _syncDisplay();
  }

  void onButton(String label) {
    _hasError = false;

    if (label == 'C') {
      _expr = ''; _display = '0'; _lastRes = ''; _justEvaled = false;
      notifyListeners(); return;
    }

    if (label == 'CE') {
      if (_expr.isNotEmpty) {
        _expr = _expr.replaceFirst(RegExp(r'[\d.]+$'), '');
      }
      _justEvaled = false;
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == '2nd') {
      _show2nd = !_show2nd;
      notifyListeners(); return;
    }

    if (label == 'DEL') {
      if (_justEvaled) {
        _expr = ''; _justEvaled = false;
      } else if (_expr.isNotEmpty) {
        _expr = _expr.substring(0, _expr.length - 1);
      }
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == '=') {
      _compute();
      notifyListeners(); return;
    }

    if (_justEvaled) {
      final isOp = '+-×÷^'.contains(label) && label.length == 1;
      if (!isOp) _expr = '';
      _justEvaled = false;
    }

    if (RegExp(r'^[0-9A-F]$').hasMatch(label) || label == 'HEX_C') {
      _expr += (label == 'HEX_C' ? 'C' : label);
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == '.') {
      final lastNum = RegExp(r'[\d.]+$').stringMatch(_expr) ?? '';
      if (!lastNum.contains('.')) {
        if (_expr.isEmpty || _endsWithOp) _expr += '0';
        _expr += '.';
      }
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == '±') {
      final m = RegExp(r'(-?\d+\.?\d*)$').firstMatch(_expr);
      if (m != null) {
        final num     = m.group(1)!;
        final negated = num.startsWith('-') ? num.substring(1) : '-$num';
        _expr = _expr.substring(0, m.start) + negated;
      } else if (_expr.isEmpty) {
        _expr = '-';
      }
      _syncDisplay();
      notifyListeners(); return;
    }

    if ('+-×÷^'.contains(label) && label.length == 1) {
      if (_expr.isEmpty) {
        if (label == '-') _expr = '-';
      } else {
        _replaceTrailingOp(label);
      }
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == '%') {
      if (_endsWithValue) _expr += '%';
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == '(') {
      if (_endsWithValue) _expr += '×';
      _expr += '(';
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == ')') {
      final open  = '('.allMatches(_expr).length;
      final close = ')'.allMatches(_expr).length;
      if (open > close) {
        _expr += ')';
        _syncDisplay();
      }
      notifyListeners(); return;
    }

    if (label == 'π' || label == 'e') {
      if (_endsWithValue) _expr += '×';
      _expr += label;
      _syncDisplay();
      notifyListeners(); return;
    }

    const fnLabels = <String, String>{
      'sin': 'sin', 'cos': 'cos', 'tan': 'tan',
      'asin': 'asin', 'acos': 'acos', 'atan': 'atan',
      '√': 'sqrt', '∛': 'cbrt',
      'Ln': 'ln', 'log': 'log', 'log₂': 'log2',
    };
    if (fnLabels.containsKey(label)) {
      if (_endsWithValue) _expr += '×';
      _expr += '${fnLabels[label]}(';
      _syncDisplay();
      notifyListeners(); return;
    }

    if (label == 'x²' || label == 'x³' || label == '1/x' || label == 'n!') {
      if (_expr.isEmpty) { notifyListeners(); return; }
      try {
        final cur = CalculatorLogic.evaluate(_expr, angleMode: _settings.angleMode);
        final res = switch (label) {
          'x²'  => cur * cur,
          'x³'  => cur * cur * cur,
          '1/x' => 1.0 / cur,
          'n!'  => _fact(cur.toInt()),
          _     => cur,
        };
        _expr    = _fmt(res);
        _display = _expr;
      } catch (_) {
        _display  = 'Error';
        _hasError = true;
      }
      notifyListeners(); return;
    }

    if (label == 'MC') {
      _memory = 0; _hasMem = false; _storage.saveMemory(0);
      notifyListeners(); return;
    }
    if (label == 'MR') {
      if (_endsWithValue) _expr += '×';
      _expr += _fmt(_memory);
      _syncDisplay();
      notifyListeners(); return;
    }
    if (label == 'M+' || label == 'M-') {
      try {
        final v = CalculatorLogic.evaluate(
          _expr.isNotEmpty ? _expr : '0', angleMode: _settings.angleMode);
        if (label == 'M+') _memory += v; else _memory -= v;
        _hasMem = true;
        _storage.saveMemory(_memory);
      } catch (_) {}
      notifyListeners(); return;
    }

    if (label == 'DEC' || label == 'BIN' || label == 'OCT' || label == 'HEX') {
      _switchBase(label); notifyListeners(); return;
    }
    if (label == 'AND') { _replaceTrailingOp('&');  _syncDisplay(); notifyListeners(); return; }
    if (label == 'OR')  { _replaceTrailingOp('|');  _syncDisplay(); notifyListeners(); return; }
    if (label == 'XOR') { _replaceTrailingOp('^');  _syncDisplay(); notifyListeners(); return; }
    if (label == 'NOT') {
      try {
        final v = CalculatorLogic.evaluate(
          _expr.isNotEmpty ? _expr : '0', angleMode: _settings.angleMode);
        _expr = _fmt((~v.toInt()).toDouble());
        _syncDisplay();
      } catch (_) { _display = 'Error'; _hasError = true; }
      notifyListeners(); return;
    }
    if (label == '<<') { _replaceTrailingOp('<<'); _syncDisplay(); notifyListeners(); return; }
    if (label == '>>') { _replaceTrailingOp('>>'); _syncDisplay(); notifyListeners(); return; }

    notifyListeners();
  }

  void clearHistory() {
    _history = [];
    _storage.clearHistory();
    notifyListeners();
  }

  void useHistoryEntry(CalculationHistory e) {
    _expr       = e.result;
    _display    = e.result;
    _justEvaled = true;
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
