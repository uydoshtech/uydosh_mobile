import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// Visualizes a widget's on-screen bounds (useful to tune tap targets).
///
/// By default only shows in debug builds. Set [enabled] to override.
class DebugTapBounds extends StatelessWidget {
  const DebugTapBounds({
    required this.child,
    super.key,
    this.enabled,
    this.color = const Color(0xFFFF2D55), // iOS system pink-ish
    this.borderWidth = 1.0,
    this.borderRadius = 6.0,
    this.fillOpacity = 0.06,
  });

  final Widget child;

  /// When null, enabled only in debug mode.
  final bool? enabled;
  final Color color;
  final double borderWidth;
  final double borderRadius;
  final double fillOpacity;

  bool get _isEnabled => enabled ?? kDebugMode;

  @override
  Widget build(BuildContext context) {
    if (!_isEnabled) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        color: color.withValues(alpha: fillOpacity),
      ),
      child: child,
    );
  }
}

