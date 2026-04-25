
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';

class DisplayArea extends StatelessWidget {
  const DisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final cs   = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayBg = isDark ? AppColors.darkDisplay : AppColors.lightDisplay;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          calc.onButton('DEL');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: displayBg,
          borderRadius: BorderRadius.circular(AppLayout.displayRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  if (calc.hasMemory)
                    _chip('M', cs.tertiary),
                  const SizedBox(width: 6),
                  _chip(calc.angleMode.label, cs.primary.withOpacity(0.7)),
                ]),
                _chip(calc.mode.label, cs.primary.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 8),
            if (calc.expression.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  calc.expression,
                  style: AppTextStyles.displayHistory.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  calc.display,
                  key: ValueKey(calc.display),
                  style: AppTextStyles.displayExpression.copyWith(
                    fontSize: _displayFontSize(calc.display),
                    color: calc.hasError
                        ? Colors.redAccent
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ),
            if (calc.mode.name == 'programmer') ...[
              const SizedBox(height: 8),
              _progRow('BIN', calc.binaryDisplay, isDark),
              _progRow('OCT', calc.octalDisplay,  isDark),
              _progRow('HEX', calc.hexDisplay,    isDark),
            ],
          ],
        ),
      ),
    );
  }

  double _displayFontSize(String text) {
    if (text.length > 15) return 22;
    if (text.length > 10) return 28;
    return 36;
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      );

  Widget _progRow(String base, String value, bool isDark) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(base, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
            Text(value, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, fontFamily: 'monospace')),
          ],
        ),
      );
}
