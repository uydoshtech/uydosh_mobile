import "package:flutter/material.dart";

import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Neumorphic “inset” surface for form controls (TextField, Dropdown, etc).
///
/// This is intentionally a simple container: the field still controls focus,
/// label, helper/error text via [InputDecoration]; this widget only provides
/// the recessed chrome around it.
class NeumorphicInsetContainer extends StatelessWidget {
  const NeumorphicInsetContainer({
    required this.child,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    this.backgroundColor,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final base = backgroundColor ?? Theme.of(context).colorScheme.surface;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: base,
        boxShadow: ThreeDSurfaceStyle.insetRecessedShadows(context),
      ),
      child: child,
    );
  }
}

