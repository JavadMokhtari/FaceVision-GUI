import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/log_entry.dart';
import '../models/run_controller.dart';
import '../theme/app_theme.dart';
import 'task_progress_bar.dart';

class LogConsole extends StatefulWidget {
  const LogConsole({super.key});

  @override
  State<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> {
  final ScrollController _scroll = ScrollController();

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RunController>();
    _scrollToEnd();

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: context.cSurface,
        border: Border(left: BorderSide(color: context.cBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(controller: controller),
          TaskProgressBar(controller: controller),
          const Divider(height: 1),
          Expanded(
            child: controller.logs.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(14),
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      return _LogLine(entry: controller.logs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final RunController controller;

  @override
  Widget build(BuildContext context) {
    final running = controller.isRunning;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      child: Row(
        children: [
          _PulsingDot(active: running),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Activity Log',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    running ? 'Running: ${controller.currentTask}' : 'IDLE',
                    key: ValueKey(running ? controller.currentTask : 'idle'),
                    style:
                        TextStyle(fontSize: 12, color: context.cTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Clear log',
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: context.cTextSecondary,
            onPressed: controller.logs.isEmpty ? null : controller.clear,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.terminal_rounded, size: 30, color: context.cTextSecondary),
          const SizedBox(height: 10),
          Text('No activity yet',
              style: TextStyle(color: context.cTextSecondary, fontSize: 13)),
          const SizedBox(height: 2),
          Text('Run a task to see live logs here.',
              style: TextStyle(
                  color: context.cTextSecondary.withValues(alpha: 0.7),
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.entry});
  final LogEntry entry;

  Color get _color {
    switch (entry.level) {
      case LogLevel.success:
        return AppTheme.success;
      case LogLevel.warning:
        return AppTheme.warning;
      case LogLevel.error:
        return AppTheme.error;
      case LogLevel.info:
        return AppTheme.accentB;
    }
  }

  IconData get _icon {
    switch (entry.level) {
      case LogLevel.success:
        return Icons.check_circle_rounded;
      case LogLevel.warning:
        return Icons.warning_rounded;
      case LogLevel.error:
        return Icons.cancel_rounded;
      case LogLevel.info:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset((1 - t) * 10, 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(_icon, size: 12, color: _color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: context.cTextPrimary,
                      fontFamily: 'Consolas'),
                  children: [
                    TextSpan(
                      text: '${entry.timeLabel}  ',
                      style: TextStyle(color: context.cTextSecondary),
                    ),
                    TextSpan(text: entry.message),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.active});
  final bool active;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Icon(Icons.circle, size: 10, color: context.cTextSecondary);
    }
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
      child: const Icon(Icons.circle, size: 10, color: AppTheme.success),
    );
  }
}
