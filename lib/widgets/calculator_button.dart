
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

enum ButtonType { number, operator, accent, function, memory }

class CalculatorButton extends StatefulWidget {
  final String label;
  final ButtonType type;
  final VoidCallback onTap;
  final double? flex;
  final bool isActive;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = ButtonType.number,
    this.flex,
    this.isActive = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppLayout.animButtonMs),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();

  void _onTapUp(_) {
    _ctrl.reverse();
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  Color _bgColor(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (widget.isActive) return cs.tertiary;
    switch (widget.type) {
      case ButtonType.number:    return cs.secondary;
      case ButtonType.operator:  return cs.primary;
      case ButtonType.accent:    return cs.tertiary;
      case ButtonType.function:  return cs.primary.withOpacity(0.8);
      case ButtonType.memory:    return cs.primary.withOpacity(0.6);
    }
  }

  Color _fgColor(BuildContext ctx) {
    final bright = Theme.of(ctx).brightness;
    if (widget.type == ButtonType.accent || widget.isActive) return Colors.white;
    return bright == Brightness.dark ? Colors.white : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(context);
    final fg = _fgColor(context);
    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
            boxShadow: [
              BoxShadow(
                color:   Colors.black.withOpacity(0.15),
                blurRadius:   4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: AppTextStyles.buttonLabel.copyWith(color: fg, fontSize: 17),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
