import "dart:math" as math;

import "package:flutter/material.dart";

/// A [SliderComponentShape] that draws a rectangular value indicator with
/// increased inner padding compared to the default.
class PaddedSliderValueIndicatorShape extends SliderComponentShape {
  const PaddedSliderValueIndicatorShape({this.labelPadding = 24.0});

  /// Inner padding around the label text. Default is 24 (vs 16 in Flutter default).
  final double labelPadding;

  static const double _triangleHeight = 8.0;
  static const double _minLabelWidth = 16.0;
  static const double _bottomTipYOffset = 14.0;
  static const double _upperRectRadius = 4;

  double _upperRectangleWidth(
    TextPainter labelPainter,
    double scale,
    double textScaleFactor,
  ) {
    final unscaledWidth =
        math.max(_minLabelWidth * textScaleFactor, labelPainter.width) +
        labelPadding * 2;
    return unscaledWidth * scale;
  }

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    TextPainter? labelPainter,
    double? textScaleFactor,
  }) {
    assert(labelPainter != null);
    assert(textScaleFactor != null && textScaleFactor >= 0);
    return Size(
      _upperRectangleWidth(labelPainter!, 1, textScaleFactor!),
      labelPainter.height + labelPadding,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final scale = activationAnimation.value;
    if (scale == 0.0) return;
    assert(!sizeWithOverflow.isEmpty);

    const edgePadding = 8.0;
    final rectangleWidth =
        _upperRectangleWidth(labelPainter, scale, textScaleFactor);
    final globalCenter = parentBox.localToGlobal(center);

    final double overflowLeft = math.max(
      0,
      rectangleWidth / 2 - globalCenter.dx + edgePadding,
    );
    final double overflowRight = math.max(
      0,
      rectangleWidth / 2 -
          (sizeWithOverflow.width - globalCenter.dx - edgePadding),
    );

    double horizontalShift;
    if (rectangleWidth < sizeWithOverflow.width) {
      horizontalShift = overflowLeft - overflowRight;
    } else if (overflowLeft - overflowRight > 0) {
      horizontalShift = overflowLeft - (edgePadding * textScaleFactor);
    } else {
      horizontalShift = -overflowRight + (edgePadding * textScaleFactor);
    }

    final rectHeight = labelPainter.height + labelPadding;
    final upperRect = Rect.fromLTWH(
      -rectangleWidth / 2 + horizontalShift,
      -_triangleHeight - rectHeight,
      rectangleWidth,
      rectHeight,
    );

    final trianglePath = Path()
      ..lineTo(-_triangleHeight, -_triangleHeight)
      ..lineTo(_triangleHeight, -_triangleHeight)
      ..close();
    final fillPaint = Paint()..color = sliderTheme.valueIndicatorColor!;
    final upperRRect =
        RRect.fromRectAndRadius(upperRect, const Radius.circular(_upperRectRadius));
    trianglePath.addRRect(upperRRect);

    canvas.save();
    canvas.translate(center.dx, center.dy - _bottomTipYOffset);
    canvas.scale(scale, scale);
    if (sliderTheme.valueIndicatorStrokeColor != null) {
      final strokePaint = Paint()
        ..color = sliderTheme.valueIndicatorStrokeColor!
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(trianglePath, strokePaint);
    }
    canvas.drawPath(trianglePath, fillPaint);

    const preferredHalfHeight = 16.0;
    final bottomTipToUpperRectTranslateY =
        -preferredHalfHeight / 2 - upperRect.height;
    canvas.translate(0, bottomTipToUpperRectTranslateY);
    final boxCenter = Offset(horizontalShift, upperRect.height / 2);
    final halfLabelPainterOffset =
        Offset(labelPainter.width / 2, labelPainter.height / 2);
    final labelOffset = boxCenter - halfLabelPainterOffset;
    labelPainter.paint(canvas, labelOffset);
    canvas.restore();
  }
}
