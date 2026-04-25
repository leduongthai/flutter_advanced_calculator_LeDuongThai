

import 'package:flutter/material.dart';

class AppColors {
  static const Color lightPrimary   = Color(0xFF1E1E1E);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent    = Color(0xFFFF6B6B);
  static const Color lightBg        = Color(0xFFF5F5F5);
  static const Color lightDisplay   = Color(0xFFFFFFFF);

  static const Color darkPrimary   = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent    = Color(0xFF4ECDC4);
  static const Color darkBg        = Color(0xFF121212);
  static const Color darkDisplay   = Color(0xFF1E1E1E);
}

class AppTextStyles {
  static const String fontFamily = 'Roboto';

  static const TextStyle displayExpression = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );

  static const TextStyle displayHistory = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    fontFamily: fontFamily,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );
}

class AppLayout {
  static const double buttonSpacing    = 12.0;
  static const double buttonRadius     = 16.0;
  static const double displayRadius    = 24.0;
  static const double screenPadding   = 24.0;
  static const int    animButtonMs    = 200;
  static const int    animModeMs      = 300;
}

class StorageKeys {
  static const String history      = 'calculation_history';
  static const String theme        = 'theme_mode';
  static const String calcMode     = 'calculator_mode';
  static const String memory       = 'memory_value';
  static const String angleMode    = 'angle_mode';
  static const String precision    = 'decimal_precision';
  static const String haptic       = 'haptic_feedback';
  static const String sound        = 'sound_effects';
  static const String historySize  = 'history_size';
}
