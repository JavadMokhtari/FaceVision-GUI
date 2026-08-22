import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A frosted-glass card: blurred backdrop + translucent fill + soft
/// border, with a gentle hover lift. Drop-in replacement for [Card] /
/// [SectionCard] wherever the app should feel a bit more "glassy".
class GlassPanel extends StatefulWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 18,
    this.blur = 22,
    this.opacity = 0.55,
    this.hoverLift = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final double opacity;
  final bool hoverLift;

  @override
  State<GlassPanel> createState() => _GlassPanelState();
}

class _GlassPanelState extends State<GlassPanel> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);

    return MouseRegion(
      onEnter: (_) => widget.hoverLift ? setState(() => _hover = true) : null,
      onExit: (_) => widget.hoverLift ? setState(() => _hover = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
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
                        .withValues(alpha: _hover ? 0.28 : 0.14),
                    blurRadius: _hover ? 30 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
