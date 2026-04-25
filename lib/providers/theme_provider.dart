import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  late ThemeMode _themeMode;

  ThemeProvider(this._storage) {
    final idx = _storage.loadThemeIndex();
    _themeMode = ThemeMode.values[idx.clamp(0, ThemeMode.values.length - 1)];
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _storage.saveThemeIndex(mode.index);
    notifyListeners();
  }

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary:   AppColors.lightPrimary,
          secondary: AppColors.lightSecondary,
          tertiary:  AppColors.lightAccent,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary:   AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          tertiary:  AppColors.darkAccent,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      );
}
