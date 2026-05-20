import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// Opaque surface for modal bottom sheets (search, achievements, pickers, etc.).
class GlassBottomSheetSurface extends StatelessWidget {
  const GlassBottomSheetSurface({
    required this.child,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(20)),
    this.padding,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      color: LiquidGlassRendering.bottomSheetFillColor(scheme),
      border: Border(
        top: BorderSide(color: scheme.outlineVariant, width: 0.6),
      ),
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.35),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, -8),
        ),
      ],
    );

    final content =
        padding != null ? Padding(padding: padding!, child: child) : child;

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(decoration: decoration, child: content),
    );
  }
}
