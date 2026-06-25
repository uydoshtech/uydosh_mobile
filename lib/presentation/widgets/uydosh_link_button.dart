import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset((startX + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A reusable link-style button with underlined text.
/// Supports both plain link and outlined variants.
/// Use [destructive] for remove/delete actions so the label matches app error/red styling.
class UydoshLinkButton extends StatelessWidget {
  const UydoshLinkButton({
    required this.text,
    required this.onPressed,
    this.color,
    this.destructive = false,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.outlined = false,
    this.dashed = false,
    this.padding,
    this.alignment = Alignment.center,
    this.maxLines,
    this.icon,
    this.iconSize = 18,
    this.iconAfterText = false,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final Color? color;

  /// When true (and [color] is null), uses [Theme.of(context).colorScheme.error].
  final bool destructive;
  final double fontSize;
  final FontWeight fontWeight;
  final bool outlined;
  final bool dashed;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  /// When set, forces the label to render with at most this many lines.
  /// Combined with no soft-wrap + ellipsis so the button intrinsically sizes
  /// to a single-line label and doesn't grow vertically on narrow screens.
  final int? maxLines;
  final IconData? icon;
  final double iconSize;
  final bool iconAfterText;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (destructive
            ? Theme.of(context).colorScheme.error
            : (ThemeState().isBlueTheme ? Colors.white : Colors.black));

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
    );

    final labelText = Text(
      text,
      style: textStyle,
      maxLines: maxLines,
      softWrap: maxLines == null,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
    );

    final textWidget = outlined
        ? labelText
        : IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelText,
                const SizedBox(height: 1),
                if (dashed)
                  SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: CustomPaint(
                      painter: _DashedLinePainter(color: effectiveColor),
                    ),
                  )
                else
                  Container(
                    height: 1,
                    color: effectiveColor,
                  ),
              ],
            ),
          );

    final child = icon == null
        ? textWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: iconAfterText
                ? [
                    textWidget,
                    const SizedBox(width: 6),
                    Icon(icon, size: iconSize, color: effectiveColor),
                  ]
                : [
                    Icon(icon, size: iconSize, color: effectiveColor),
                    const SizedBox(width: 6),
                    textWidget,
                  ],
          );

    void handleTap() {
      HapticFeedbackUtils.impact();
      onPressed();
    }

    if (outlined) {
      return Align(
        alignment: alignment,
        child: OutlinedButton(
          onPressed: handleTap,
          style: OutlinedButton.styleFrom(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: effectiveColor,
              width: 1,
            ),
          ),
          child: child,
        ),
      );
    }

    return TextButton(
      onPressed: handleTap,
      style: TextButton.styleFrom(
        padding: padding ?? EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }
}
