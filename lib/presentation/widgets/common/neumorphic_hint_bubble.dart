import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// Side of the bubble where the speech-bubble tail emerges.
enum HintBubbleTailSide { top, bottom }

/// Speech-bubble shaped contextual hint with a neumorphic "soft UI" raised
/// face: light from the top-left (subtle gradient + outer halo) and a darker
/// shadow falling from the bottom-right.
///
/// Designed for inline contextual hints like the "search across all
/// stations of line X" hint above the metro station picker, or the bell
/// hint pointing at the search-alert button. The tail position is fully
/// configurable so a single instance can attach to any anchor in the
/// surrounding layout.
class NeumorphicHintBubble extends StatelessWidget {
  const NeumorphicHintBubble({
    required this.message,
    super.key,
    this.maxWidth = 240,
    this.tailSide = HintBubbleTailSide.bottom,
    this.tailHorizontalOffset = 0,
  });

  /// Pre-built rich text body shown inside the bubble.
  final InlineSpan message;

  /// Caps the bubble width so it stays compact even when the message wraps.
  final double maxWidth;

  /// Which edge of the bubble the tail points away from.
  final HintBubbleTailSide tailSide;

  /// Offset (logical pixels) of the tail center from the bubble's
  /// horizontal center. Positive = right, negative = left.
  final double tailHorizontalOffset;

  static const double _tailWidth = 14;
  static const double _tailHeight = 7;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    const fillGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Color(0xFFE2E4EC),
      ],
    );
    const innerHighlightGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x66FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: [0.0, 0.55],
    );
    const borderColor = Color(0x14000000);
    const elevationShadows = <BoxShadow>[
      BoxShadow(
        color: Color(0x40FFFFFF),
        offset: Offset(-4, -4),
        blurRadius: 12,
      ),
      BoxShadow(
        color: Color(0x66000000),
        offset: Offset(6, 7),
        blurRadius: 18,
      ),
    ];

    final padding = tailSide == HintBubbleTailSide.bottom
        ? const EdgeInsets.fromLTRB(14, 9, 14, 9 + _tailHeight)
        : const EdgeInsets.fromLTRB(14, 9 + _tailHeight, 14, 9);

    return CustomPaint(
      painter: _BubblePainter(
        fillGradient: fillGradient,
        innerHighlightGradient: innerHighlightGradient,
        borderColor: borderColor,
        tailWidth: _tailWidth,
        tailHeight: _tailHeight,
        tailSide: tailSide,
        tailHorizontalOffset: tailHorizontalOffset,
        radius: _radius,
        elevationShadows: elevationShadows,
      ),
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: RichText(
            text: message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.fillGradient,
    required this.innerHighlightGradient,
    required this.borderColor,
    required this.tailWidth,
    required this.tailHeight,
    required this.tailSide,
    required this.tailHorizontalOffset,
    required this.radius,
    required this.elevationShadows,
  });

  final LinearGradient fillGradient;
  final LinearGradient innerHighlightGradient;
  final Color borderColor;
  final double tailWidth;
  final double tailHeight;
  final HintBubbleTailSide tailSide;
  final double tailHorizontalOffset;
  final double radius;
  final List<BoxShadow> elevationShadows;

  Path _createBubblePath(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final tailCenterX = (w / 2 + tailHorizontalOffset)
        .clamp(r + tailWidth / 2, w - r - tailWidth / 2);

    if (tailSide == HintBubbleTailSide.bottom) {
      final bodyBottom = h - tailHeight;
      return Path()
        ..moveTo(r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, bodyBottom - r)
        ..arcToPoint(Offset(w - r, bodyBottom), radius: Radius.circular(r))
        ..lineTo(tailCenterX + tailWidth / 2, bodyBottom)
        ..lineTo(tailCenterX, h)
        ..lineTo(tailCenterX - tailWidth / 2, bodyBottom)
        ..lineTo(r, bodyBottom)
        ..arcToPoint(Offset(0, bodyBottom - r), radius: Radius.circular(r))
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    } else {
      final bodyTop = tailHeight;
      return Path()
        ..moveTo(r, bodyTop)
        ..lineTo(tailCenterX - tailWidth / 2, bodyTop)
        ..lineTo(tailCenterX, 0)
        ..lineTo(tailCenterX + tailWidth / 2, bodyTop)
        ..lineTo(w - r, bodyTop)
        ..arcToPoint(Offset(w, bodyTop + r), radius: Radius.circular(r))
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, bodyTop + r)
        ..arcToPoint(Offset(r, bodyTop), radius: Radius.circular(r))
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

    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = innerHighlightGradient.createShader(bounds)
        ..isAntiAlias = true,
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      fillGradient != oldDelegate.fillGradient ||
      innerHighlightGradient != oldDelegate.innerHighlightGradient ||
      borderColor != oldDelegate.borderColor ||
      tailWidth != oldDelegate.tailWidth ||
      tailHeight != oldDelegate.tailHeight ||
      tailSide != oldDelegate.tailSide ||
      tailHorizontalOffset != oldDelegate.tailHorizontalOffset ||
      radius != oldDelegate.radius ||
      !listEquals(elevationShadows, oldDelegate.elevationShadows);
}

double _blurRadiusToSigma(double radius) {
  if (radius <= 0) return 0;
  return radius * 0.57735 + 0.5;
}

void _paintPathDropShadow(Canvas canvas, Path path, BoxShadow shadow) {
  if (shadow.color.a == 0) return;
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
