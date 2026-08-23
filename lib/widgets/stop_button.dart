import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Compact icon button placed next to [RunButton]. Enabled only while a
/// task is running; shows a brief "stopping…" state once pressed so the
/// user gets feedback even though the actual stop is cooperative on the
/// Rust side and may take a moment (see STOP_CANCELLATION.md).
class StopButton extends StatefulWidget {
  const StopButton({
    super.key,
    required this.enabled,
    required this.stopRequested,
    required this.onPressed,
  });

  final bool enabled;
  final bool stopRequested;
  final VoidCallback? onPressed;

  @override
  State<StopButton> createState() => _StopButtonState();
}

class _StopButtonState extends State<StopButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && !widget.stopRequested;

    return Tooltip(
      message: !widget.enabled
          ? 'Nothing running'
          : widget.stopRequested
              ? 'Stopping…'
              : 'Stop the running task',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: active ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: !widget.enabled
                  ? context.cSurface
                  : widget.stopRequested
                      ? AppTheme.warning.withValues(alpha: 0.15)
                      : (_hover
                          ? AppTheme.error.withValues(alpha: 0.16)
                          : AppTheme.error.withValues(alpha: 0.10)),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: !widget.enabled
                    ? context.cBorder
                    : widget.stopRequested
                        ? AppTheme.warning.withValues(alpha: 0.5)
                        : AppTheme.error.withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: widget.stopRequested
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppTheme.warning),
                      ),
                    )
                  : Icon(
                      Icons.stop_rounded,
                      size: 20,
                      color: !widget.enabled
                          ? context.cTextSecondary
                          : AppTheme.error,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
