// lib/models/calculator_mode.dart

/// The three calculator modes supported by the app.
enum CalculatorMode {
  basic,
  scientific,
  programmer;

  String get label {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }
}

/// Angle unit used for trigonometric calculations.
enum AngleMode {
  degrees,
  radians;

  String get label => this == AngleMode.degrees ? 'DEG' : 'RAD';
}
