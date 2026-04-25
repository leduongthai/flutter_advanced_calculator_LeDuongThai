import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';
import '../widgets/button_grid.dart';
import '../widgets/display_area.dart';
import '../widgets/mode_selector.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc   = context.watch<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'History',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              if (calc.history.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenPadding,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ModeSelector(),
                const SizedBox(height: 8),

                const DisplayArea(),
                const SizedBox(height: 8),

                if (calc.history.isNotEmpty) ...[
                  _HistoryPreview(calc: calc),
                  const SizedBox(height: 8),
                ],

                const Expanded(child: ButtonGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _HistoryPreview extends StatelessWidget {
  final CalculatorProvider calc;
  const _HistoryPreview({required this.calc});

  @override
  Widget build(BuildContext context) {
    final recent  = calc.history.take(3).toList();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final textClr = isDark ? Colors.white60 : Colors.black45;

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recent.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final entry = recent[i];
          return GestureDetector(
            onTap: () => calc.useHistoryEntry(entry),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${entry.expression} = ${entry.result}',
                style: TextStyle(fontSize: 11, color: textClr),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
