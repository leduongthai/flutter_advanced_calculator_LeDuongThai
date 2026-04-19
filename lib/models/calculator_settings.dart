// lib/models/calculator_settings.dart

import 'package:flutter/material.dart';
import 'calculator_mode.dart';

/// Holds all user-configurable settings.
class CalculatorSettings {
  final ThemeMode themeMode;
  final int decimalPrecision;   // 2–10
  final AngleMode angleMode;
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize;        // 25 | 50 | 100

  const CalculatorSettings({
    this.themeMode       = ThemeMode.system,
    this.decimalPrecision = 6,
    this.angleMode       = AngleMode.degrees,
    this.hapticFeedback  = true,
    this.soundEffects    = false,
    this.historySize     = 50,
  });

  CalculatorSettings copyWith({
    ThemeMode? themeMode,
    int? decimalPrecision,
    AngleMode? angleMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
  }) =>
      CalculatorSettings(
        themeMode:        themeMode        ?? this.themeMode,
        decimalPrecision: decimalPrecision ?? this.decimalPrecision,
        angleMode:        angleMode        ?? this.angleMode,
        hapticFeedback:   hapticFeedback   ?? this.hapticFeedback,
        soundEffects:     soundEffects     ?? this.soundEffects,
        historySize:      historySize      ?? this.historySize,
      );
}
