import "package:flutter/material.dart";

/// Neumorphic-style elevation shared by [ThreeDPillButton] and listing-detail tiles.
abstract final class ThreeDSurfaceStyle {
  ThreeDSurfaceStyle._();

  static Color _darkShadowColor(BuildContext context) => Colors.black.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.20,
      );

  static Color _lightShadowColor(BuildContext context) => Colors.white.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.65,
      );

  static List<BoxShadow> elevatedShadows(BuildContext context) => [
        BoxShadow(
          color: _lightShadowColor(context),
          offset: const Offset(-3, -3),
          blurRadius: 10,
        ),
        BoxShadow(
          color: _darkShadowColor(context),
          offset: const Offset(6, 6),
          blurRadius: 14,
        ),
      ];

  static List<BoxShadow> pressedShadows(BuildContext context) => [
        BoxShadow(
          color: _darkShadowColor(context),
          offset: const Offset(2, 2),
          blurRadius: 8,
        ),
      ];

  /// Recessed / “pressed” look (e.g. selected language card). Uses negative
  /// [BoxShadow.spreadRadius] so shadows read as inside the rounded rect.
  static List<BoxShadow> insetRecessedShadows(BuildContext context) => [
        BoxShadow(
          color: _darkShadowColor(context),
          offset: const Offset(4, 4),
          blurRadius: 12,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: _lightShadowColor(context),
          offset: const Offset(-4, -4),
          blurRadius: 12,
          spreadRadius: -6,
        ),
      ];

  /// Softer dual-shadow for flat “soft UI” buttons that match [ColorScheme.surface].
  static List<BoxShadow> neumorphicSoftRaisedShadows(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.72),
        offset: const Offset(-4, -4),
        blurRadius: 10,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.18),
        offset: const Offset(5, 5),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }

  static LinearGradient surfaceGradient(BuildContext context, Color bg) {
    final scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          bg,
          scheme.onSurface,
          Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.03,
        )!,
        bg,
      ],
    );
  }

  /// Soft colored glow behind circular “orb” controls (search FAB, curved nav).
  static List<BoxShadow> floatingOrbHaloShadows(
    BuildContext context,
    Color base, {
    double depthScale = 1.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cool = Color.lerp(base, const Color(0xFF9EB7E8), 0.42)!;
    return [
      BoxShadow(
        color: cool.withValues(alpha: isDark ? 0.38 : 0.22),
        blurRadius: 26 * depthScale,
        spreadRadius: 1.8 * depthScale,
        offset: Offset(-5 * depthScale, -5 * depthScale),
      ),
      BoxShadow(
        color: Color.lerp(base, Colors.white, 0.5)!
            .withValues(alpha: isDark ? 0.16 : 0.12),
        blurRadius: 16 * depthScale,
        spreadRadius: 0.5 * depthScale,
        offset: Offset(-2 * depthScale, -3 * depthScale),
      ),
    ];
  }

  /// Base fill + neumorphic shadows for a raised circular face (matches search FAB).
  static BoxDecoration circularElevatedOrbDecoration(
    BuildContext context,
    Color base, {
    double depthScale = 1.0,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: surfaceGradient(context, base),
      boxShadow: [
        ...floatingOrbHaloShadows(context, base, depthScale: depthScale),
        ...elevatedShadows(context),
      ],
    );
  }

  /// Top-left specular wash on dark orb surfaces ([SearchFloatingActionButton]).
  static Gradient surfaceRadialHighlightGradient(Brightness brightness) {
    return RadialGradient(
      center: const Alignment(-0.55, -0.62),
      radius: 1.05,
      colors: [
        Colors.white.withValues(
          alpha: brightness == Brightness.dark ? 0.22 : 0.45,
        ),
        Colors.white.withValues(alpha: 0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.28, 0.52],
    );
  }

  /// Same corner radius as [ThreeDAppBarIconButton.kDefaultSquareRadius].
  static const double wheelPickerCornerRadius = 12;

  static const BorderRadius wheelPickerPlateRadius = BorderRadius.all(
    Radius.circular(wheelPickerCornerRadius),
  );

  /// Right strip inside wheel rows (arrow column) — matches plate corners.
  static const BorderRadius wheelPickerPlateArrowStripBorderRadius =
      BorderRadius.only(
        topRight: Radius.circular(wheelPickerCornerRadius),
        bottomRight: Radius.circular(wheelPickerCornerRadius),
      );

  /// Outer chrome for [CupertinoPicker] wheels: same gradient + shadows as [ThreeDPillButton].
  ///
  /// When [showErrorBorder] is true and [errorPulseT] is set (typically `0`–`1` from an
  /// [Animation]), the error outline and a soft glow pulse for attention. When
  /// [errorPulseT] is null, the border is a steady [ColorScheme.error] stroke (legacy).
  static BoxDecoration wheelPickerPlateDecoration(
    BuildContext context, {
    ThemeData? theme,
    bool showErrorBorder = false,
    double? errorPulseT,
    Color? dirtyOutlineColor,
  }) {
    final t = theme ?? Theme.of(context);
    final plateBase = t.colorScheme.surface;
    final shadows = List<BoxShadow>.from(elevatedShadows(context));
    Border? border;
    if (showErrorBorder) {
      final error = t.colorScheme.error;
      if (errorPulseT == null) {
        border = Border.all(color: error, width: 1.5);
      } else {
        final p = errorPulseT.clamp(0.0, 1.0);
        border = Border.all(
          color: Color.lerp(
            error.withValues(alpha: 0.38),
            error,
            p,
          )!,
          width: 1.2 + 0.9 * p,
        );
        shadows.add(
          BoxShadow(
            color: error.withValues(alpha: 0.07 + 0.26 * p),
            blurRadius: 2 + 14 * p,
            spreadRadius: 0.2 + 1.1 * p,
          ),
        );
      }
    } else if (dirtyOutlineColor != null) {
      border = Border.all(color: dirtyOutlineColor, width: 1.5);
    }
    return BoxDecoration(
      borderRadius: wheelPickerPlateRadius,
      gradient: surfaceGradient(context, plateBase),
      boxShadow: shadows,
      border: border,
    );
  }
}

/// Raised listing “plate” with optional validation styling. When [showErrorBorder] is
/// true, the error outline gently pulses.
class WheelPickerPlateContainer extends StatefulWidget {
  const WheelPickerPlateContainer({
    required this.child,
    super.key,
    this.showErrorBorder = false,
    this.dirtyOutlineColor,
    this.theme,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final bool showErrorBorder;

  /// When non-null (and [showErrorBorder] is false), draws a steady outline for
  /// fields that differ from their original values (edit flows).
  final Color? dirtyOutlineColor;
  final ThemeData? theme;
  final Clip clipBehavior;

  @override
  State<WheelPickerPlateContainer> createState() =>
      _WheelPickerPlateContainerState();
}

class _WheelPickerPlateContainerState extends State<WheelPickerPlateContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.showErrorBorder) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WheelPickerPlateContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showErrorBorder != oldWidget.showErrorBorder) {
      if (widget.showErrorBorder) {
        _controller.repeat(reverse: true);
      } else {
        _controller
          ..stop()
          ..reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showErrorBorder) {
      return Container(
        clipBehavior: widget.clipBehavior,
        decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
          context,
          theme: widget.theme,
          showErrorBorder: false,
          dirtyOutlineColor: widget.dirtyOutlineColor,
        ),
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Container(
          clipBehavior: widget.clipBehavior,
          decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
            context,
            theme: widget.theme,
            showErrorBorder: true,
            errorPulseT: _pulse.value,
            dirtyOutlineColor: null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 3D plate behind wheel pickers: keeps chrome out of the picker subtree and uses
/// [Stack.clipBehavior] none so ListWheelScrollView paint is not hard-clipped.
///
/// When [showErrorBorder] is true, the error outline gently pulses.
class WheelPickerPlateChrome extends StatefulWidget {
  const WheelPickerPlateChrome({
    required this.height,
    required this.child,
    super.key,
    this.showErrorBorder = false,
    this.theme,
  });

  final double height;
  final Widget child;
  final bool showErrorBorder;
  final ThemeData? theme;

  @override
  State<WheelPickerPlateChrome> createState() => _WheelPickerPlateChromeState();
}

class _WheelPickerPlateChromeState extends State<WheelPickerPlateChrome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.showErrorBorder) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WheelPickerPlateChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showErrorBorder != oldWidget.showErrorBorder) {
      if (widget.showErrorBorder) {
        _controller.repeat(reverse: true);
      } else {
        _controller
          ..stop()
          ..reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme ?? Theme.of(context);

    BoxDecoration decorationFor(double? pulseT) =>
        ThreeDSurfaceStyle.wheelPickerPlateDecoration(
          context,
          theme: t,
          showErrorBorder: widget.showErrorBorder,
          errorPulseT: widget.showErrorBorder ? pulseT : null,
        );

    Widget chrome(BoxDecoration decoration) {
      return SizedBox(
        height: widget.height,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: decoration,
              child: const SizedBox.expand(),
            ),
            widget.child,
          ],
        ),
      );
    }

    if (!widget.showErrorBorder) {
      return chrome(decorationFor(null));
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => chrome(decorationFor(_pulse.value)),
    );
  }
}
