import "dart:math" as math;

import "package:flutter/material.dart";

/// Circular badge around a gig category glyph so it reads as its own icon tile
/// beside the uppercase category label (feeds, detail headers, hub ribbon).
///
/// In a tight parent (e.g. a horizontal list with limited cross-axis height),
/// [dimension] is reduced to fit while staying square so the badge stays a
/// true circle — otherwise [ClipOval] can clip a wide ellipse.
class GigCategoryIconBadge extends StatelessWidget {
  const GigCategoryIconBadge({
    required this.icon,
    required this.iconColor,
    required this.badgeBackgroundColor,
    this.dimension = 22,
    this.iconSize = 12,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final Color badgeBackgroundColor;
  final double dimension;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var side = dimension;
        if (constraints.hasBoundedWidth) {
          side = math.min(side, constraints.maxWidth);
        }
        if (constraints.hasBoundedHeight) {
          side = math.min(side, constraints.maxHeight);
        }
        side = math.max(1, side);
        final scale = dimension > 0 ? side / dimension : 1.0;
        final glyph = iconSize * scale;

        return ClipOval(
          child: Container(
            width: side,
            height: side,
            color: badgeBackgroundColor,
            alignment: Alignment.center,
            child: Icon(icon, size: glyph, color: iconColor),
          ),
        );
      },
    );
  }
}
