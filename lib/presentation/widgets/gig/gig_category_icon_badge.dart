import "package:flutter/material.dart";

/// Circular badge around a gig category glyph so it reads as its own icon tile
/// beside the uppercase category label (feeds, detail headers, hub ribbon).
///
/// [ClipOval] keeps Material icon ink that extends past the em-box inside the
/// badge instead of overlapping Cyrillic/Latin mixed labels.
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
    return ClipOval(
      child: Container(
        width: dimension,
        height: dimension,
        color: badgeBackgroundColor,
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
