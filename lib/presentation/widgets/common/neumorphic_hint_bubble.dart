import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Side of the bubble where the speech-bubble tail emerges.
enum HintBubbleTailSide { top, bottom }

/// Frosted-glass speech-bubble used for inline contextual hints (e.g. the
/// "search across all stations of line X" hint above the metro station
/// picker, or the bell hint pointing at the search-alert FAB).
///
/// Visual recipe:
///  - A backdrop blur clipped to the bubble's path so whatever sits behind
///    the bubble (sheet glass, dark feed) shows through softened.
///  - A very light grey translucent tint on top of the blur.
///  - A subtle top-left highlight gradient for a "lit from above" feel.
///  - A 1px white stroke along the bubble outline.
///  - A soft drop shadow for separation from the underlying surface.
class NeumorphicHintBubble extends StatelessWidget {
  const NeumorphicHintBubble({
    required this.message,
    super.key,
    this.maxWidth = 240,
    this.tailSide = HintBubbleTailSide.bottom,
    this.tailHorizontalOffset = 0,
    this.tailRightInset,
    this.onClose,
    this.closeTooltip,
  });

  /// Pre-built rich text body shown inside the bubble.
  final InlineSpan message;

  /// Caps the bubble width so it stays compact even when the message wraps.
  final double maxWidth;

  /// Which edge of the bubble the tail points away from.
  final HintBubbleTailSide tailSide;

  /// Offset (logical pixels) of the tail center from the bubble's
  /// horizontal center. Positive = right, negative = left.
  ///
  /// Ignored when [tailRightInset] is set.
  final double tailHorizontalOffset;

  /// When set, places the tail this many logical pixels in from the bubble's
  /// right edge (e.g. to point at a FAB whose right edge aligns with the
  /// bubble's right edge). Takes precedence over [tailHorizontalOffset].
  final double? tailRightInset;

  /// When non-null, renders a small "x" close button in the top-right of the
  /// bubble. Consumers are responsible for hiding the bubble in response.
  final VoidCallback? onClose;

  /// Optional tooltip for the close button. Defaults to the platform close
  /// label.
  final String? closeTooltip;

  static const double _tailWidth = 14;
  static const double _tailHeight = 7;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    // Reserve extra room on the right for the close button so the message
    // text never crowds the "x". The left padding stays at the default so the
    // text block shifts visually left, giving the close button breathing room.
    final hasClose = onClose != null;
    const leftPad = 14.0;
    final rightPad = hasClose ? 36.0 : 14.0;
    final padding = tailSide == HintBubbleTailSide.bottom
        ? EdgeInsets.fromLTRB(leftPad, 9, rightPad, 9 + _tailHeight)
        : EdgeInsets.fromLTRB(leftPad, 9 + _tailHeight, rightPad, 9);

    final clipper = _BubbleClipper(
      radius: _radius,
      tailWidth: _tailWidth,
      tailHeight: _tailHeight,
      tailSide: tailSide,
      tailHorizontalOffset: tailHorizontalOffset,
      tailRightInset: tailRightInset,
    );

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableBlur =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

    // Very light grey tint with high luminance + low alpha so the backdrop
    // shows through. Two stops give the surface a gentle top-light feel.
    const fillGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xE6FBFBFB), // ~90% alpha near-white
        Color(0xCCECECEC), // ~80% alpha very light grey
      ],
    );
    // Subtle top-left highlight that emulates light hitting glass.
    const highlightGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x66FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: [0.0, 0.55],
    );
    // Soft white outline so the bubble reads even on bright backdrops.
    const strokeColor = Color(0x73FFFFFF); // ~45% white
    const dropShadow = BoxShadow(
      color: Color(0x4D000000), // 30% black
      offset: Offset(0, 6),
      blurRadius: 18,
    );

    final content = Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: RichText(
          text: message,
          textAlign: TextAlign.center,
        ),
      ),
    );

    final Widget bubble = Stack(
      children: [
        // 1. Drop shadow behind everything.
        Positioned.fill(
          child: CustomPaint(
            painter: _BubbleShadowPainter(
              clipper: clipper,
              shadow: dropShadow,
            ),
          ),
        ),
        // 2. Glass backdrop blur + warm tint, clipped to the bubble outline.
        Positioned.fill(
          child: ClipPath(
            clipper: clipper,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: enableBlur ? 18 : 0,
                sigmaY: enableBlur ? 18 : 0,
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: fillGradient),
              ),
            ),
          ),
        ),
        // 3. Inner top-left highlight.
        Positioned.fill(
          child: IgnorePointer(
            child: ClipPath(
              clipper: clipper,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: highlightGradient),
              ),
            ),
          ),
        ),
        // 4. Border stroke.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _BubbleBorderPainter(
                clipper: clipper,
                color: strokeColor,
                strokeWidth: 1,
              ),
            ),
          ),
        ),
        // 5. The text content. Acts as the only non-positioned child so the
        //    Stack sizes itself to it.
        content,
      ],
    );

    if (!hasClose) return bubble;

    // Push the tap target inside the bubble's rounded corner so the icon
    // visually sits on the bubble surface, while keeping a comfortable
    // 28x28 tap target for finger accuracy.
    final closeTopOffset =
        tailSide == HintBubbleTailSide.top ? _tailHeight + 4.0 : 4.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        bubble,
        Positioned(
          top: closeTopOffset,
          right: 4,
          child: Tooltip(
            message: closeTooltip ??
                MaterialLocalizations.of(context).closeButtonTooltip,
            // [GestureDetector] with [HitTestBehavior.opaque] guarantees the
            // entire 28x28 area receives taps, regardless of the icon's
            // smaller painted footprint inside it.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedbackUtils.impact();
                onClose!();
              },
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                color: Colors.transparent,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds the speech-bubble path (rounded rect with a triangular tail).
Path _buildBubblePath(
  Size size, {
  required double radius,
  required double tailWidth,
  required double tailHeight,
  required HintBubbleTailSide tailSide,
  required double tailHorizontalOffset,
  double? tailRightInset,
}) {
  final w = size.width;
  final h = size.height;
  final r = radius;
  final tailCenterX = (tailRightInset != null
          ? w - tailRightInset
          : w / 2 + tailHorizontalOffset)
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
  }
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

class _BubbleClipper extends CustomClipper<Path> {
  const _BubbleClipper({
    required this.radius,
    required this.tailWidth,
    required this.tailHeight,
    required this.tailSide,
    required this.tailHorizontalOffset,
    this.tailRightInset,
  });

  final double radius;
  final double tailWidth;
  final double tailHeight;
  final HintBubbleTailSide tailSide;
  final double tailHorizontalOffset;
  final double? tailRightInset;

  @override
  Path getClip(Size size) => _buildBubblePath(
        size,
        radius: radius,
        tailWidth: tailWidth,
        tailHeight: tailHeight,
        tailSide: tailSide,
        tailHorizontalOffset: tailHorizontalOffset,
        tailRightInset: tailRightInset,
      );

  @override
  bool shouldReclip(covariant _BubbleClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.tailWidth != tailWidth ||
      oldClipper.tailHeight != tailHeight ||
      oldClipper.tailSide != tailSide ||
      oldClipper.tailHorizontalOffset != tailHorizontalOffset ||
      oldClipper.tailRightInset != tailRightInset;
}

class _BubbleShadowPainter extends CustomPainter {
  _BubbleShadowPainter({required this.clipper, required this.shadow});

  final _BubbleClipper clipper;
  final BoxShadow shadow;

  @override
  void paint(Canvas canvas, Size size) {
    if (shadow.color.a == 0) return;
    final path = clipper.getClip(size);
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

  @override
  bool shouldRepaint(covariant _BubbleShadowPainter oldDelegate) =>
      oldDelegate.shadow != shadow ||
      oldDelegate.clipper.shouldReclip(clipper);
}

class _BubbleBorderPainter extends CustomPainter {
  _BubbleBorderPainter({
    required this.clipper,
    required this.color,
    required this.strokeWidth,
  });

  final _BubbleClipper clipper;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      clipper.getClip(size),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.clipper.shouldReclip(clipper);
}

double _blurRadiusToSigma(double radius) {
  if (radius <= 0) return 0;
  return radius * 0.57735 + 0.5;
}
