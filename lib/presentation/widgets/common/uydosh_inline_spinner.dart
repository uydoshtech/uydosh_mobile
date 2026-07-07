import "package:flutter/material.dart";

/// Plain circular loading indicator for buttons and other small inline
/// controls.
///
/// The rotating brand-mark [UydoshLogoSpinner] is reserved for major
/// screen-level loading states; buttons and controls use this lightweight
/// indicator instead so the brand animation doesn't compete for attention
/// on every tap.
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
