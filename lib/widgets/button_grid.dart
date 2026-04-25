
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    Widget grid;
    if (calc.mode == CalculatorMode.scientific) {
      grid = _ScientificGrid(key: const ValueKey('sci'));
    } else if (calc.mode == CalculatorMode.programmer) {
      grid = _ProgrammerGrid(key: const ValueKey('prog'));
    } else {
      grid = _BasicGrid(key: const ValueKey('basic'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppLayout.animModeMs),
      child: grid,
    );
  }
}


class _ButtonGrid extends StatelessWidget {
  final List<List<_BtnDef>> rows;

  const _ButtonGrid({required this.rows});

  @override
  Widget build(BuildContext context) {
    final calc     = context.read<CalculatorProvider>();
    final numRows  = rows.length;
    const spacing  = AppLayout.buttonSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveSpacing = (spacing * (5 / numRows)).clamp(4.0, spacing);
        final totalSpacing = effectiveSpacing * numRows;
        final buttonHeight = ((constraints.maxHeight - totalSpacing) / numRows)
            .clamp(0.0, 80.0);

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: EdgeInsets.only(bottom: effectiveSpacing),
              child: Row(
                children: row.map((def) {
                  return Expanded(
                    flex: def.flex,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: effectiveSpacing / 2),
                      child: SizedBox(
                        height: buttonHeight,
                        child: CalculatorButton(
                          label:    def.label,
                          type:     def.type,
                          isActive: def.isActive?.call(calc) ?? false,
                          onTap:    () => calc.onButton(def.action ?? def.label),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BtnDef {
  final String label;
  final ButtonType type;
  final String? action;
  final int flex;
  final bool Function(CalculatorProvider)? isActive;

  const _BtnDef(
    this.label, {
    this.type = ButtonType.number,
    this.action,
    this.flex = 1,
    this.isActive,
  });
}


class _BasicGrid extends StatelessWidget {
  const _BasicGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      [
        _BtnDef('C',  type: ButtonType.function),
        _BtnDef('CE', type: ButtonType.function),
        _BtnDef('%',  type: ButtonType.function),
        _BtnDef('÷',  type: ButtonType.operator),
      ],
      [
        _BtnDef('7'), _BtnDef('8'), _BtnDef('9'),
        _BtnDef('×', type: ButtonType.operator),
      ],
      [
        _BtnDef('4'), _BtnDef('5'), _BtnDef('6'),
        _BtnDef('-', type: ButtonType.operator),
      ],
      [
        _BtnDef('1'), _BtnDef('2'), _BtnDef('3'),
        _BtnDef('+', type: ButtonType.operator),
      ],
      [
        _BtnDef('±', type: ButtonType.function),
        _BtnDef('0'),
        _BtnDef('.'),
        _BtnDef('=', type: ButtonType.accent),
      ],
    ];
    return _ButtonGrid(rows: rows);
  }
}


class _ScientificGrid extends StatelessWidget {
  const _ScientificGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final s2   = calc.showSecond;

    final rows = [
      [
        _BtnDef('2nd',  type: ButtonType.function, isActive: (c) => c.showSecond),
        _BtnDef(s2 ? 'asin' : 'sin',  type: ButtonType.function),
        _BtnDef(s2 ? 'acos' : 'cos',  type: ButtonType.function),
        _BtnDef(s2 ? 'atan' : 'tan',  type: ButtonType.function),
        _BtnDef('Ln',   type: ButtonType.function),
        _BtnDef('log',  type: ButtonType.function),
      ],
      [
        _BtnDef(s2 ? '∛' : 'x²',  type: ButtonType.function),
        _BtnDef(s2 ? 'x³' : '√',  type: ButtonType.function),
        _BtnDef('x^y', type: ButtonType.function, action: '^'),
        _BtnDef('(',   type: ButtonType.function),
        _BtnDef(')',   type: ButtonType.function),
        _BtnDef('÷',   type: ButtonType.operator),
      ],
      [
        _BtnDef('MC', type: ButtonType.memory),
        _BtnDef('7'), _BtnDef('8'), _BtnDef('9'),
        _BtnDef('C',  type: ButtonType.function),
        _BtnDef('×',  type: ButtonType.operator),
      ],
      [
        _BtnDef('MR', type: ButtonType.memory),
        _BtnDef('4'), _BtnDef('5'), _BtnDef('6'),
        _BtnDef('CE', type: ButtonType.function),
        _BtnDef('-',  type: ButtonType.operator),
      ],
      [
        _BtnDef('M+', type: ButtonType.memory),
        _BtnDef('1'), _BtnDef('2'), _BtnDef('3'),
        _BtnDef('%',  type: ButtonType.function),
        _BtnDef('+',  type: ButtonType.operator),
      ],
      [
        _BtnDef('M-', type: ButtonType.memory),
        _BtnDef('±',  type: ButtonType.function),
        _BtnDef('0'),
        _BtnDef('.'),
        _BtnDef('π',  type: ButtonType.function),
        _BtnDef('=',  type: ButtonType.accent),
      ],
    ];
    return _ButtonGrid(rows: rows);
  }
}


class _ProgrammerGrid extends StatelessWidget {
  const _ProgrammerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      [
        _BtnDef('DEC', type: ButtonType.function, isActive: (c) => c.progBase=='DEC'),
        _BtnDef('BIN', type: ButtonType.function, isActive: (c) => c.progBase=='BIN'),
        _BtnDef('OCT', type: ButtonType.function, isActive: (c) => c.progBase=='OCT'),
        _BtnDef('HEX', type: ButtonType.function, isActive: (c) => c.progBase=='HEX'),
      ],
      [
        _BtnDef('AND', type: ButtonType.function),
        _BtnDef('OR',  type: ButtonType.function),
        _BtnDef('XOR', type: ButtonType.function),
        _BtnDef('NOT', type: ButtonType.function),
      ],
      [
        _BtnDef('<<',  type: ButtonType.function),
        _BtnDef('>>',  type: ButtonType.function),
        _BtnDef('C',   type: ButtonType.function),
        _BtnDef('÷',   type: ButtonType.operator),
      ],
      [
        _BtnDef('A', type: ButtonType.function),
        _BtnDef('B', type: ButtonType.function),
        _BtnDef('C', type: ButtonType.function, action: 'HEX_C'),
        _BtnDef('×', type: ButtonType.operator),
      ],
      [
        _BtnDef('7'), _BtnDef('8'), _BtnDef('9'),
        _BtnDef('-', type: ButtonType.operator),
      ],
      [
        _BtnDef('4'), _BtnDef('5'), _BtnDef('6'),
        _BtnDef('+', type: ButtonType.operator),
      ],
      [
        _BtnDef('1'), _BtnDef('2'), _BtnDef('3'),
        _BtnDef('=', type: ButtonType.accent),
      ],
      [
        _BtnDef('0', flex: 2),
        _BtnDef('D', type: ButtonType.function),
        _BtnDef('E', type: ButtonType.function),
        _BtnDef('F', type: ButtonType.function),
      ],
    ];
    return _ButtonGrid(rows: rows);
  }
}
