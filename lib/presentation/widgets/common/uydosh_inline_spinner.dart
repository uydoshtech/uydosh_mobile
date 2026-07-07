import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

/// Rotating UyDosh logo for inline/button loading slots, replacing the
/// default Material [CircularProgressIndicator].
///
/// [color] and [strokeWidth] are kept for backwards compatibility with
/// existing call sites but are ignored — the spinner always renders the
/// brand mark in its natural colors.
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
    return UydoshLogoSpinner(size: dimension);
  }
}
