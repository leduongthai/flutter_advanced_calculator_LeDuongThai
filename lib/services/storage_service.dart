
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../utils/constants.dart';


class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


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


  int loadThemeIndex() => _prefs.getInt(StorageKeys.theme) ?? 0;

  Future<void> saveThemeIndex(int index) async =>
      _prefs.setInt(StorageKeys.theme, index);


  int loadCalcModeIndex() => _prefs.getInt(StorageKeys.calcMode) ?? 0;

  Future<void> saveCalcModeIndex(int index) async =>
      _prefs.setInt(StorageKeys.calcMode, index);

  double loadMemory() => _prefs.getDouble(StorageKeys.memory) ?? 0.0;

  Future<void> saveMemory(double value) async =>
      _prefs.setDouble(StorageKeys.memory, value);

  int loadAngleModeIndex() => _prefs.getInt(StorageKeys.angleMode) ?? 0;

  Future<void> saveAngleModeIndex(int index) async =>
      _prefs.setInt(StorageKeys.angleMode, index);

  int loadPrecision() => _prefs.getInt(StorageKeys.precision) ?? 6;

  Future<void> savePrecision(int value) async =>
      _prefs.setInt(StorageKeys.precision, value);


  bool loadHaptic() => _prefs.getBool(StorageKeys.haptic) ?? true;

  Future<void> saveHaptic(bool value) async =>
      _prefs.setBool(StorageKeys.haptic, value);


  bool loadSound() => _prefs.getBool(StorageKeys.sound) ?? false;

  Future<void> saveSound(bool value) async =>
      _prefs.setBool(StorageKeys.sound, value);


  int loadHistorySize() => _prefs.getInt(StorageKeys.historySize) ?? 50;

  Future<void> saveHistorySize(int value) async =>
      _prefs.setInt(StorageKeys.historySize, value);
}
