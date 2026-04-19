// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc  = context.watch<CalculatorProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Theme ──────────────────────────────────────────────────────
          _sectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(theme.themeMode.name.toUpperCase()),
            trailing: DropdownButton<ThemeMode>(
              value: theme.themeMode,
              onChanged: (v) { if (v != null) theme.setTheme(v); },
              items: ThemeMode.values.map((m) =>
                  DropdownMenuItem(value: m, child: Text(m.name.toUpperCase()))
              ).toList(),
            ),
          ),

          // ── Calculation ────────────────────────────────────────────────
          _sectionHeader('Calculation'),
          ListTile(
            title: const Text('Decimal Precision'),
            subtitle: Text('${calc.settings.decimalPrecision} decimal places'),
            trailing: DropdownButton<int>(
              value: calc.settings.decimalPrecision,
              onChanged: (v) { if (v != null) calc.setPrecision(v); },
              items: List.generate(9, (i) => i + 2).map((n) =>
                  DropdownMenuItem(value: n, child: Text('$n'))
              ).toList(),
            ),
          ),
          ListTile(
            title: const Text('Angle Mode'),
            trailing: ToggleButtons(
              isSelected: AngleMode.values.map((a) => a == calc.angleMode).toList(),
              onPressed: (i) => calc.setAngleMode(AngleMode.values[i]),
              borderRadius: BorderRadius.circular(8),
              children: AngleMode.values
                  .map((a) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(a.label),
                      ))
                  .toList(),
            ),
          ),

          // ── History ────────────────────────────────────────────────────
          _sectionHeader('History'),
          ListTile(
            title: const Text('History Size'),
            trailing: DropdownButton<int>(
              value: calc.settings.historySize,
              onChanged: (v) { if (v != null) calc.setHistorySize(v); },
              items: [25, 50, 100].map((n) =>
                  DropdownMenuItem(value: n, child: Text('$n entries'))
              ).toList(),
            ),
          ),
          ListTile(
            title: const Text('Clear History'),
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () => _confirmClear(context, calc),
          ),

          // ── Feedback ───────────────────────────────────────────────────
          _sectionHeader('Feedback'),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            value: calc.settings.hapticFeedback,
            onChanged: calc.setHaptic,
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: calc.settings.soundEffects,
            onChanged: calc.setSound,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      );

  void _confirmClear(BuildContext ctx, CalculatorProvider calc) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will delete all saved calculations.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { calc.clearHistory(); Navigator.pop(ctx); },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
