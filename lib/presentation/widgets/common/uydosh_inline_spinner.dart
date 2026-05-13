import "package:flutter/material.dart";

/// Theme-aligned small [CircularProgressIndicator] for inline/button slots.
class UydoshInlineSpinner extends StatelessWidget {
  const UydoshInlineSpinner({
    required this.color,
    super.key,
    this.dimension = 16,
    this.strokeWidth = 2,
  });

  final Color color;
  final double dimension;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
