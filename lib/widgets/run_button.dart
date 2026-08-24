import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RunButton extends StatefulWidget {
  const RunButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.icon = Icons.play_arrow_rounded,
  });

  final String label;
  final bool loading;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<RunButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_hover && !disabled ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              gradient: disabled ? null : AppTheme.accentGradient,
              color: disabled ? context.cBorder : null,
              borderRadius: BorderRadius.circular(13),
              boxShadow: disabled || !_hover
                  ? []
                  : [
                      BoxShadow(
                        color: AppTheme.accentB.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Colors.white70),
                    ),
                  )
                else
                  Icon(widget.icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  widget.loading ? 'Running…' : widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
