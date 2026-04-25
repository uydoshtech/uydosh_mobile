import "dart:ui";

import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/chat/bubble_with_tail_painter.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Reusable chat bubble with tail, matching chat/support message styling.
/// Used in user messaging (chat) and support chat screens.
class ChatBubbleWithTail extends StatelessWidget {
  const ChatBubbleWithTail({
    required this.isFromCurrentUser,
    required this.child,
    super.key,
  });

  /// Whether this is the current user's message (right side, white, with border).
  final bool isFromCurrentUser;

  /// Content to display inside the bubble.
  final Widget child;

  static const double _radius = 18;
  static const double _tailWidth = 10;
  static const double _tailHeight = 16;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        // Glassmorphism only for incoming messages on the dark blue theme,
        // where there is enough background contrast for a frosted look.
        final useGlass = !isFromCurrentUser && themeState.isBlueTheme;

        final solidBubbleColor = isFromCurrentUser
            ? Colors.white
            : (themeState.isBlueTheme
                ? const Color(0xFF3A4A66)
                : Colors.grey[200]!);
        final solidBorderColor =
            themeState.isLightTheme || themeState.isBlueTheme
                ? Colors.grey[300]!
                : Colors.grey[600]!;

        final LinearGradient fillGradient = useGlass
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.08),
                ],
              )
            : ThreeDSurfaceStyle.surfaceGradient(context, solidBubbleColor);

        final Color borderColor = useGlass
            ? Colors.white.withValues(alpha: 0.22)
            : (isFromCurrentUser ? solidBorderColor : Colors.transparent);

        final List<BoxShadow> elevationShadows = useGlass
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  offset: const Offset(0, 4),
                  blurRadius: 14,
                ),
              ]
            : ThreeDSurfaceStyle.elevatedShadows(context);

        final painter = BubbleWithTailPainter(
          fillGradient: fillGradient,
          borderColor: borderColor,
          elevationShadows: elevationShadows,
          tailPointsRight: isFromCurrentUser,
          hasBorder: isFromCurrentUser || useGlass,
          radius: _radius,
        );

        final content = Container(
          padding: EdgeInsets.only(
            left: isFromCurrentUser ? 16 : 20,
            right: isFromCurrentUser ? 20 : 16,
            top: 12,
            bottom: 12,
          ),
          child: child,
        );

        if (!useGlass) {
          return CustomPaint(
            painter: painter,
            child: content,
          );
        }

        return _GlassBubble(
          tailPointsRight: isFromCurrentUser,
          radius: _radius,
          tailWidth: _tailWidth,
          tailHeight: _tailHeight,
          painter: painter,
          child: content,
        );
      },
    );
  }
}

/// Wraps the bubble with a real backdrop blur (frosted glass) clipped to the
/// bubble path including the tail, then layers the painter (translucent fill +
/// border) on top.
class _GlassBubble extends StatelessWidget {
  const _GlassBubble({
    required this.tailPointsRight,
    required this.radius,
    required this.tailWidth,
    required this.tailHeight,
    required this.painter,
    required this.child,
  });

  final bool tailPointsRight;
  final double radius;
  final double tailWidth;
  final double tailHeight;
  final CustomPainter painter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: tailPointsRight ? 0 : -tailWidth,
          right: tailPointsRight ? -tailWidth : 0,
          child: ClipPath(
            clipper: _BubbleTailClipper(
              tailPointsRight: tailPointsRight,
              radius: radius,
              tailWidth: tailWidth,
              tailHeight: tailHeight,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        CustomPaint(
          painter: painter,
          child: child,
        ),
      ],
    );
  }
}

/// Clipper that mirrors [BubbleWithTailPainter]'s path but works in a coordinate
/// space whose width already includes the tail extension. The bubble body
/// occupies `size.width - tailWidth`, with the tail filling the remaining
/// [tailWidth] on the appropriate side.
class _BubbleTailClipper extends CustomClipper<Path> {
  const _BubbleTailClipper({
    required this.tailPointsRight,
    required this.radius,
    required this.tailWidth,
    required this.tailHeight,
  });

  final bool tailPointsRight;
  final double radius;
  final double tailWidth;
  final double tailHeight;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final centerY = h / 2;

    if (tailPointsRight) {
      final bodyW = w - tailWidth;
      return Path()
        ..moveTo(r, 0)
        ..lineTo(bodyW - r, 0)
        ..arcToPoint(Offset(bodyW, r), radius: Radius.circular(r))
        ..lineTo(bodyW, centerY - tailHeight / 2)
        ..lineTo(bodyW + tailWidth, centerY)
        ..lineTo(bodyW, centerY + tailHeight / 2)
        ..lineTo(bodyW, h - r)
        ..arcToPoint(Offset(bodyW - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    } else {
      final bodyStart = tailWidth;
      return Path()
        ..moveTo(bodyStart + r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(bodyStart + r, h)
        ..arcToPoint(Offset(bodyStart, h - r), radius: Radius.circular(r))
        ..lineTo(bodyStart, centerY + tailHeight / 2)
        ..lineTo(0, centerY)
        ..lineTo(bodyStart, centerY - tailHeight / 2)
        ..lineTo(bodyStart, r)
        ..arcToPoint(Offset(bodyStart + r, 0), radius: Radius.circular(r))
        ..close();
    }
  }

  @override
  bool shouldReclip(covariant _BubbleTailClipper oldClipper) =>
      tailPointsRight != oldClipper.tailPointsRight ||
      radius != oldClipper.radius ||
      tailWidth != oldClipper.tailWidth ||
      tailHeight != oldClipper.tailHeight;
}
