import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_info.dart';
import 'models/theme_controller.dart';
import 'screens/detect_face_screen.dart';
import 'screens/extract_feature_screen.dart';
import 'screens/match_feature_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/log_console.dart';

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const _items = <_NavItem>[
  _NavItem(icon: Icons.center_focus_strong_rounded, label: 'Detect Face'),
  _NavItem(icon: Icons.blur_on_rounded, label: 'Extract Feature'),
  _NavItem(icon: Icons.compare_arrows_rounded, label: 'Match Feature'),
];

const _digitKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
];

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  /// Console width limits, as a fraction of the available shell width.
  static const _minConsoleFraction = 0.20;
  static const _maxConsoleFraction = 0.60;
  static const _minConsoleWidth = 260.0;

  late final TabController _tabs =
      TabController(length: _items.length, vsync: this);

  double _consoleFraction = 0.28;
  bool _consoleVisible = true;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _toggleConsole() => setState(() => _consoleVisible = !_consoleVisible);

  Map<ShortcutActivator, VoidCallback> get _bindings => {
        for (var i = 0; i < _items.length; i++)
          SingleActivator(_digitKeys[i], control: true): () =>
              _tabs.animateTo(i),
        const SingleActivator(LogicalKeyboardKey.backquote, control: true):
            _toggleConsole,
      };

  void _dragConsole(double deltaX, double shellWidth) {
    // Dragging left grows the console, so the delta is subtracted.
    final current = _consoleFraction * shellWidth;
    final next = (current - deltaX) / shellWidth;
    setState(() {
      _consoleFraction = next.clamp(_minConsoleFraction, _maxConsoleFraction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: CallbackShortcuts(
          bindings: _bindings,
          child: FocusScope(
            autofocus: true,
            child: Column(
              children: [
                _TopBar(
                  controller: _tabs,
                  consoleVisible: _consoleVisible,
                  onToggleConsole: _toggleConsole,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final shellWidth = constraints.maxWidth;
                      final rawWidth = shellWidth * _consoleFraction;
                      final consoleWidth = rawWidth
                          .clamp(_minConsoleWidth,
                              shellWidth * _maxConsoleFraction)
                          .toDouble();
                      // Below this width a side-by-side split is unusable.
                      final canSplit = shellWidth > _minConsoleWidth * 2;
                      final showConsole = _consoleVisible && canSplit;

                      return Row(
                        children: [
                          Expanded(
                            child: TabBarView(
                              controller: _tabs,
                              physics: const NeverScrollableScrollPhysics(),
                              children: const [
                                DetectFaceScreen(),
                                ExtractFeatureScreen(),
                                MatchFeatureScreen(),
                              ],
                            ),
                          ),
                          if (showConsole) ...[
                            _ResizeHandle(
                              onDrag: (dx) => _dragConsole(dx, shellWidth),
                              onReset: () =>
                                  setState(() => _consoleFraction = 0.28),
                            ),
                            SizedBox(
                              width: consoleWidth,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: scheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                                child: const ClipRect(child: LogConsole()),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.controller,
    required this.consoleVisible,
    required this.onToggleConsole,
  });

  final TabController controller;
  final bool consoleVisible;
  final VoidCallback onToggleConsole;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeController = context.watch<ThemeController>();

    return Container(
      decoration: BoxDecoration(
        color: context.cSurface.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const _Brand(),
          const SizedBox(width: 8),
          Container(
            height: 24,
            width: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: TabBar(
              controller: controller,
              tabAlignment: TabAlignment.fill,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2.5,
              indicatorColor: scheme.primary,
              labelColor: scheme.primary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              splashBorderRadius: BorderRadius.circular(8),
              tabs: [
                for (var i = 0; i < _items.length; i++)
                  Tab(
                    height: 56,
                    icon: Tooltip(
                      message: '${_items[i].label}  (Ctrl+${i + 1})',
                      child: Icon(_items[i].icon, size: 20),
                    ),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _items[i].label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: IconButton(
              onPressed: themeController.toggle,
              tooltip: themeController.isDark
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  themeController.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  key: ValueKey(themeController.isDark),
                  size: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: onToggleConsole,
              tooltip: consoleVisible
                  ? 'Hide log console  (Ctrl+`)'
                  : 'Show log console  (Ctrl+`)',
              icon: Icon(
                consoleVisible
                    ? Icons.vertical_split_rounded
                    : Icons.crop_square_rounded,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            child: const Icon(Icons.face_retouching_natural,
                size: 17, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppInfo.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: context.cTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.accentB.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'v${AppInfo.version}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentB,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                AppInfo.subtitle,
                style: TextStyle(fontSize: 10.5, color: context.cTextSecondary),
              ),
            ],
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

/// Draggable splitter between the active screen and the log console.
class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({required this.onDrag, required this.onReset});

  final ValueChanged<double> onDrag;
  final VoidCallback onReset;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
        onDoubleTap: widget.onReset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 5,
          color: _hovered
              ? scheme.primary.withValues(alpha: 0.8)
              : Colors.transparent,
        ),
      ),
    );
  }
}
