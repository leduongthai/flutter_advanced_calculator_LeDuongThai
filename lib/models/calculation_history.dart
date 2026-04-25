
import 'dart:convert';

class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  const CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) =>
      CalculationHistory(
        expression: json['expression'] as String,
        result: json['result'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static List<CalculationHistory> listFromJsonString(String src) {
    final list = jsonDecode(src) as List<dynamic>;
    return list
        .map((e) => CalculationHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<CalculationHistory> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  @override
  String toString() => '$expression = $result';
}
