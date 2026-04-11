import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// Converts a blur radius in logical pixels to a sigma value for [MaskFilter.blur]
/// (same mapping as Flutter’s material shadows).
double _blurRadiusToSigma(double radius) {
  if (radius <= 0) {
    return 0;
  }
  return radius * 0.57735 + 0.5;
}

void _paintPathDropShadow(Canvas canvas, Path path, BoxShadow shadow) {
  if (shadow.color.a == 0) {
    return;
  }
  canvas.save();
  canvas.translate(shadow.offset.dx, shadow.offset.dy);
  canvas.drawPath(
    path,
    Paint()
      ..color = shadow.color
      ..isAntiAlias = true
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        _blurRadiusToSigma(shadow.blurRadius),
      ),
  );
  canvas.restore();
}

/// Custom painter for the bubble with integrated tail pointing towards user avatar.
class BubbleWithTailPainter extends CustomPainter {
  BubbleWithTailPainter({
    required this.fillGradient,
    required this.borderColor,
    required this.elevationShadows,
    required this.tailPointsRight,
    this.hasBorder = false,
    this.radius = 18,
  });

  final LinearGradient fillGradient;
  final Color borderColor;
  final List<BoxShadow> elevationShadows;
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
    final bounds = path.getBounds();

    for (final shadow in elevationShadows) {
      _paintPathDropShadow(canvas, path, shadow);
    }

    canvas.drawPath(
      path,
      Paint()
        ..shader = fillGradient.createShader(bounds)
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
    if (hasBorder) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubbleWithTailPainter oldDelegate) =>
      fillGradient != oldDelegate.fillGradient ||
      borderColor != oldDelegate.borderColor ||
      !listEquals(elevationShadows, oldDelegate.elevationShadows) ||
      tailPointsRight != oldDelegate.tailPointsRight ||
      hasBorder != oldDelegate.hasBorder ||
      radius != oldDelegate.radius;
}
