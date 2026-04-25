import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculation_history.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calc    = context.watch<CalculatorProvider>();
    final history = calc.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear history',
              onPressed: () => _confirmClear(context, calc),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _HistoryTile(
                item:    history[i],
                onTap:   () {
                  calc.useHistoryEntry(history[i]);
                  Navigator.pop(ctx);
                },
              ),
            ),
    );
  }

  void _confirmClear(BuildContext ctx, CalculatorProvider calc) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all calculation history?'),
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

class _HistoryTile extends StatelessWidget {
  final CalculationHistory item;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final time = '${item.timestamp.hour.toString().padLeft(2,'0')}:'
        '${item.timestamp.minute.toString().padLeft(2,'0')}';
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      title: Text(item.expression, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text('= ${item.result}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}
