import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A translucent card with a soft border and drop shadow, plus a gentle
/// hover lift. Drop-in replacement for [Card] / [SectionCard] wherever
/// the app should feel a bit more "glassy".
///
/// Deliberately does NOT use `BackdropFilter` — that was the single
/// biggest GPU cost in this app (a blur pass that resamples the
/// framebuffer, repeated per panel, on every frame it's on screen).
/// Translucency here is just alpha blending via [AppTheme.glassDecoration]
/// — a normal, cheap paint operation, the same cost as any other
/// semi-transparent background.
class GlassPanel extends StatefulWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 18,
    this.opacity = 0.55,
    this.hoverLift = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double opacity;
  final bool hoverLift;

  @override
  State<GlassPanel> createState() => _GlassPanelState();
}

class _GlassPanelState extends State<GlassPanel> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.hoverLift ? setState(() => _hover = true) : null,
      onExit: (_) => widget.hoverLift ? setState(() => _hover = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: widget.padding,
        decoration: AppTheme.glassDecoration(
          context,
          radius: widget.radius,
          opacity: _hover ? widget.opacity + 0.12 : widget.opacity,
        ).copyWith(
          boxShadow: [
            BoxShadow(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : AppTheme.accentA)
                  .withValues(alpha: _hover ? 0.22 : 0.10),
              blurRadius: _hover ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
