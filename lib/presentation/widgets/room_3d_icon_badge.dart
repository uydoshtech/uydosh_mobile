import "package:flutter/material.dart";

/// Compact 3D-room indicator for listing rows (matches detail screen icon).
class Room3dIconBadge extends StatelessWidget {
  const Room3dIconBadge({
    super.key,
    this.size = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.borderRadius = 8,
  });

  final double size;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primary, width: 1),
      ),
      child: Icon(Icons.view_in_ar, color: primary, size: size),
    );
  }
}
