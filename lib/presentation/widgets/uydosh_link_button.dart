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
class UydoshLinkButton extends StatelessWidget {
  const UydoshLinkButton({
    required this.text,
    required this.onPressed,
    this.color,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.outlined = false,
    this.dashed = false,
    this.padding,
    this.alignment = Alignment.center,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final bool outlined;
  final bool dashed;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (ThemeState().isBlueTheme ? Colors.white : Colors.black);

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
    );

    final textWidget = outlined
        ? Text(text, style: textStyle)
        : IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(text, style: textStyle),
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
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: effectiveColor,
              width: 1,
            ),
          ),
          child: textWidget,
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
      child: textWidget,
    );
  }
}
