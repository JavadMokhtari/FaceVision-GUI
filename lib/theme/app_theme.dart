import 'package:flutter/material.dart';

/// Central place for the app's visual identity. Provides both a dark and a
/// light theme built from the same violet -> cyan accent, plus a couple of
/// small helpers ([glassDecoration], [AuroraBackground]) used to give
/// screens a soft frosted-glass, gradient-lit feel.
class AppTheme {
  AppTheme._();

  // ---- Dark palette --------------------------------------------------
  static const Color bgDark = Color(0xFF0B0D14);
  static const Color surfaceDark = Color(0xFF151826);
  static const Color surfaceElevatedDark = Color(0xFF1C2033);
  static const Color borderDark = Color(0xFF2A2F45);
  static const Color textPrimaryDark = Color(0xFFEDEFF7);
  static const Color textSecondaryDark = Color(0xFF9CA3B8);

  // ---- Light palette ---------------------------------------------------
  static const Color bgLight = Color(0xFFF3F4FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE1E3F0);
  static const Color textPrimaryLight = Color(0xFF1B1D2A);
  static const Color textSecondaryLight = Color(0xFF666C85);

  // ---- Shared accents ---------------------------------------------------
  static const Color accentA = Color(0xFF7C6BFF); // violet
  static const Color accentB = Color(0xFF34D9C9); // cyan
  static const Color success = Color(0xFF3FD68C);
  static const Color warning = Color(0xFFF3B44C);
  static const Color error = Color(0xFFFF5C7A);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentA, accentB],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: bgDark,
        surface: surfaceDark,
        surfaceElevated: surfaceElevatedDark,
        border: borderDark,
        textPrimary: textPrimaryDark,
        textSecondary: textSecondaryDark,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: bgLight,
        surface: surfaceLight,
        surfaceElevated: surfaceElevatedLight,
        border: borderLight,
        textPrimary: textPrimaryLight,
        textSecondary: textSecondaryLight,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceElevated,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accentA,
        onPrimary: Colors.white,
        secondary: accentB,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceElevated,
        outline: border,
        outlineVariant: border,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      dividerColor: border,
      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentB, width: 1.4),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentB,
        inactiveTrackColor: border,
        thumbColor: brightness == Brightness.dark ? Colors.white : accentA,
        overlayColor: const Color(0x2234D9C9),
        trackHeight: 3,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accentB : border,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(border),
        radius: const Radius.circular(8),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        labelColor: accentA,
        unselectedLabelColor: textSecondary,
        indicatorColor: accentB,
      ),
    );
  }

  /// Frosted-glass-*look* panel fill/border/shadow — translucent color,
  /// soft border, drop shadow. No blur: [GlassPanel] just paints this
  /// directly (alpha-blended against whatever's beneath), which is a
  /// normal cheap paint op — unlike an actual `BackdropFilter` blur,
  /// which resamples the framebuffer and is what used to make this app
  /// GPU-heavy.
  static BoxDecoration glassDecoration(
    BuildContext context, {
    double radius = 18,
    double opacity = 0.55,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: (dark ? surfaceElevatedDark : surfaceLight)
          .withValues(alpha: opacity),
      border: Border.all(
        color: (dark ? Colors.white : accentA)
            .withValues(alpha: dark ? 0.08 : 0.10),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

/// Semantic colors that adapt to the current theme (light or dark).
/// Prefer these over the raw `AppTheme.xxxDark` constants in widgets, so
/// everything follows [ThemeController] automatically.
extension AppColors on BuildContext {
  ColorScheme get _scheme => Theme.of(this).colorScheme;
  bool get _dark => Theme.of(this).brightness == Brightness.dark;

  Color get cBg => Theme.of(this).scaffoldBackgroundColor;
  Color get cSurface => _scheme.surface;
  Color get cSurfaceElevated => _scheme.surfaceContainerHighest;
  Color get cBorder => _scheme.outlineVariant;
  Color get cTextPrimary => _scheme.onSurface;
  Color get cTextSecondary =>
      _scheme.onSurface.withValues(alpha: _dark ? 0.62 : 0.58);
}

/// A static, lightweight backdrop: a couple of large soft-edged color
/// blobs (rendered as radial gradients, not a blurred backdrop) sitting
/// behind screen content. Deliberately NOT animated and does NOT use
/// `BackdropFilter` — that combination (continuous animation driving a
/// full-screen backdrop blur, every frame, forever) was the single
/// biggest GPU cost in the app. A gradient fill is a normal, cheap paint
/// operation; it costs about the same as any other static background.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: dark ? AppTheme.bgDark : AppTheme.bgLight),
        Positioned(
          top: -160,
          right: -120,
          child: _SoftBlob(
            color: AppTheme.accentA,
            size: 460,
            opacity: dark ? 0.16 : 0.12,
          ),
        ),
        Positioned(
          bottom: -180,
          left: -140,
          child: _SoftBlob(
            color: AppTheme.accentB,
            size: 420,
            opacity: dark ? 0.13 : 0.10,
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

/// A circle with a soft radial falloff, done with a gradient (cheap
/// GPU-wise) instead of a solid shape plus a separate blur pass.
class _SoftBlob extends StatelessWidget {
  const _SoftBlob({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
