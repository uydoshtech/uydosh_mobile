import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class PrimaryPhotoPill extends StatelessWidget {
  const PrimaryPhotoPill({
    super.key,
    this.padding,
    this.borderRadius = 4.0,
    this.fontSize = 10.0,
    this.fontWeight = FontWeight.w500,
    this.useAlpha = false,
    this.alphaValue = 0.9,
  });

  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final bool useAlpha;
  final double alphaValue;

  @override
  Widget build(BuildContext context) {
    // Always use transparent background with white border and white text
    const backgroundColor = Colors.transparent;
    const borderColor = Colors.white;
    const textColor = Colors.white;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.5, // Thin border for ghost button style
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        LanguageAwareStringHelper.getCurrent(context, "primary"),
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
