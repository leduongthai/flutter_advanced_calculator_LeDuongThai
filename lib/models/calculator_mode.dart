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

enum AngleMode {
  degrees,
  radians;

  String get label => this == AngleMode.degrees ? 'DEG' : 'RAD';
}
