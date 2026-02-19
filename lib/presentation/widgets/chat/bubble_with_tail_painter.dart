import "package:flutter/material.dart";

/// Custom painter for the bubble with integrated tail pointing towards user avatar.
class BubbleWithTailPainter extends CustomPainter {

  BubbleWithTailPainter({
    required this.color,
    required this.borderColor,
    required this.shadowColor,
    required this.tailPointsRight,
    this.hasBorder = false,
    this.radius = 18,
  });
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final bool hasBorder;
  final bool tailPointsRight;
  final double radius;
  static const double _tailWidth = 10;
  static const double _tailHeight = 16;

  Path _createBubblePath(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final centerY = h / 2;

    if (tailPointsRight) {
      return Path()
        ..moveTo(r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, centerY - _tailHeight / 2)
        ..lineTo(w + _tailWidth, centerY)
        ..lineTo(w, centerY + _tailHeight / 2)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    } else {
      return Path()
        ..moveTo(r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, centerY + _tailHeight / 2)
        ..lineTo(-_tailWidth, centerY)
        ..lineTo(0, centerY - _tailHeight / 2)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createBubblePath(size);
    canvas.drawShadow(path, shadowColor, 6, true);
    canvas.drawPath(
      path,
      Paint()..color = color..style = PaintingStyle.fill,
    );
    if (hasBorder) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubbleWithTailPainter oldDelegate) =>
      color != oldDelegate.color ||
      borderColor != oldDelegate.borderColor ||
      shadowColor != oldDelegate.shadowColor ||
      tailPointsRight != oldDelegate.tailPointsRight ||
      hasBorder != oldDelegate.hasBorder;
}
