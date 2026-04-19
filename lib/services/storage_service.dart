// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../utils/constants.dart';

/// Wraps SharedPreferences with typed read/write methods.
class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── History ──────────────────────────────────────────────────────────────

  List<CalculationHistory> loadHistory() {
    final raw = _prefs.getString(StorageKeys.history);
    if (raw == null || raw.isEmpty) return [];
    try {
      return CalculationHistory.listFromJsonString(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<CalculationHistory> history) async {
    await _prefs.setString(
      StorageKeys.history,
      CalculationHistory.listToJsonString(history),
    );
  }

  Future<void> clearHistory() async {
    await _prefs.remove(StorageKeys.history);
  }

  // ─── Theme ────────────────────────────────────────────────────────────────

  int loadThemeIndex() => _prefs.getInt(StorageKeys.theme) ?? 0;

  Future<void> saveThemeIndex(int index) async =>
      _prefs.setInt(StorageKeys.theme, index);

  // ─── Calculator Mode ──────────────────────────────────────────────────────

  int loadCalcModeIndex() => _prefs.getInt(StorageKeys.calcMode) ?? 0;

  Future<void> saveCalcModeIndex(int index) async =>
      _prefs.setInt(StorageKeys.calcMode, index);

  // ─── Memory ───────────────────────────────────────────────────────────────

  double loadMemory() => _prefs.getDouble(StorageKeys.memory) ?? 0.0;

  Future<void> saveMemory(double value) async =>
      _prefs.setDouble(StorageKeys.memory, value);

  // ─── Angle Mode ───────────────────────────────────────────────────────────

  int loadAngleModeIndex() => _prefs.getInt(StorageKeys.angleMode) ?? 0;

  Future<void> saveAngleModeIndex(int index) async =>
      _prefs.setInt(StorageKeys.angleMode, index);

  // ─── Precision ────────────────────────────────────────────────────────────

  int loadPrecision() => _prefs.getInt(StorageKeys.precision) ?? 6;

  Future<void> savePrecision(int value) async =>
      _prefs.setInt(StorageKeys.precision, value);

  // ─── Haptic ───────────────────────────────────────────────────────────────

  bool loadHaptic() => _prefs.getBool(StorageKeys.haptic) ?? true;

  Future<void> saveHaptic(bool value) async =>
      _prefs.setBool(StorageKeys.haptic, value);

  // ─── Sound ────────────────────────────────────────────────────────────────

  bool loadSound() => _prefs.getBool(StorageKeys.sound) ?? false;

  Future<void> saveSound(bool value) async =>
      _prefs.setBool(StorageKeys.sound, value);

  // ─── History Size ─────────────────────────────────────────────────────────

  int loadHistorySize() => _prefs.getInt(StorageKeys.historySize) ?? 50;

  Future<void> saveHistorySize(int value) async =>
      _prefs.setInt(StorageKeys.historySize, value);
}
