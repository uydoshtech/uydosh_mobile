import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class CustomLogoPainter extends CustomPainter {
  const CustomLogoPainter({
    this.size = 100.0,
    this.roofColor = const Color(0xFF673AB7), // Deep purple
    this.letterColor = const Color(0xFF673AB7), // Deep purple
    this.uRotation = 0.0,
    this.roofPosition = 0.0,
  });

  final double size;
  final Color roofColor;
  final Color letterColor;
  final double uRotation; // Rotation of U letter
  final double roofPosition; // Roof position (0 = above, 1 = final position)

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    // Calculate scaling factor to fit the logo within the canvas
    final scale = canvasSize.width / size;
    canvas.scale(scale);

    // Save canvas state for U letter rotation
    canvas.save();

    // Center the U letter for rotation
    final uCenterX = size / 2;
    final uCenterY = size * 0.65;
    canvas.translate(uCenterX, uCenterY);
    canvas.rotate(uRotation);
    canvas.translate(-uCenterX, -uCenterY);

    // Draw the U letter (lower shape) first
    _drawULetter(canvas, paint);

    // Restore canvas state
    canvas.restore();

    // Note: Roof will now be drawn by the widget layer using SVG
    // This method is kept for compatibility but no longer draws the roof
  }

  void _drawULetter(Canvas canvas, Paint paint) {
    paint.color = letterColor;

    final path = Path();

    // U letter dimensions - larger and more prominent
    final uWidth = size * 0.8; // Increased from 0.65 to 0.8
    final uHeight = size * 0.55; // Increased from 0.45 to 0.55
    final cornerRadius = size * 0.12; // Slightly larger rounded corners

    // Starting position (centered) - adjusted for better alignment
    final startX = (size - uWidth) / 2;
    final startY = size * 0.5; // Adjusted for better vertical centering

    // Left vertical stroke
    path.moveTo(startX, startY);
    path.lineTo(startX, startY + uHeight - cornerRadius);
    path.arcToPoint(
      Offset(startX + cornerRadius, startY + uHeight),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Bottom curve - wide U shape
    path.lineTo(startX + uWidth - cornerRadius, startY + uHeight);
    path.arcToPoint(
      Offset(startX + uWidth, startY + uHeight - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Right vertical stroke
    path.lineTo(startX + uWidth, startY);

    // Fill the U letter
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CustomLogoPainter) {
      return oldDelegate.uRotation != uRotation ||
          oldDelegate.roofPosition != roofPosition;
    }
    return true;
  }
}

// Enhanced animated logo with U rotation and SVG roof falling animation
class AnimatedCustomLogo extends StatefulWidget {
  const AnimatedCustomLogo({
    super.key,
    this.size = 100.0,
    this.roofColor = const Color(0xFF673AB7), // Deep purple
    this.letterColor = const Color(0xFF673AB7), // Deep purple
    this.animationDuration = const Duration(milliseconds: 3000),
  });

  final double size;
  final Color roofColor;
  final Color letterColor;
  final Duration animationDuration;

  @override
  State<AnimatedCustomLogo> createState() => _AnimatedCustomLogoState();
}

class _AnimatedCustomLogoState extends State<AnimatedCustomLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _uRotationAnimation;
  late Animation<double> _roofFallAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // U letter rotation animation (0 to 2π radians = full rotation)
    _uRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6.28318, // Full 360° rotation (2 * pi)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Roof falling animation - starts after house rotation completes
    _roofFallAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.6,
          1.0,
          curve: Curves.bounceOut,
        ), // Starts at 0.6 after rotation
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              // Ensure the entire logo is centered
              child: Transform.translate(
                offset: Offset(
                  0,
                  -widget.size * 0.1,
                ), // Move entire house logo down a bit
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SVG Roof with falling animation - appears from above and falls from the sky
                    Transform.translate(
                      offset: Offset(
                        0,
                        _roofFallAnimation.value * widget.size * 0.4 -
                            widget.size * 0.28,
                      ), // Falls from above and lands just a tiny bit higher
                      child: Opacity(
                        opacity:
                            _roofFallAnimation
                                .value, // Starts invisible, becomes visible as it falls
                        child: SvgPicture.asset(
                          "assets/icon/components/roof.svg",
                          width: widget.size * 0.75 * 1.2, // 1.2x larger
                          height: widget.size * 0.37 * 1.2, // 1.2x larger
                          colorFilter: ColorFilter.mode(
                            widget.roofColor,
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder:
                              (context) => Container(
                                width: widget.size * 0.75 * 1.2,
                                height: widget.size * 0.37 * 1.2,
                                color: widget.roofColor.withValues(alpha: 0.3),
                                child: const Center(
                                  child: Text(
                                    "Roof",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),

                    // U Letter with custom painter - positioned closer to roof and 1.2x larger
                    Transform.translate(
                      offset: Offset(
                        0,
                        -widget.size * 0.37,
                      ), // Move house base up a tiny bit more
                      child: CustomPaint(
                        size: Size(
                          widget.size * 0.8 * 1.2,
                          widget.size * 0.55 * 1.2,
                        ), // 1.2x larger
                        painter: CustomLogoPainter(
                          size: widget.size * 0.8 * 1.2, // 1.2x larger
                          roofColor: widget.roofColor,
                          letterColor: widget.letterColor,
                          uRotation: _uRotationAnimation.value,
                          roofPosition: _roofFallAnimation.value,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
