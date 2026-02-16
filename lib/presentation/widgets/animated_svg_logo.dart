import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

class AnimatedULetter extends StatelessWidget {

  const AnimatedULetter({
    required this.progress, required this.size, super.key,
  });
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        // Create a linear gradient from top-left to right
        // Blue color (matching the square) to white
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          stops: [progress, progress + 0.1],
          colors: const [
            Colors.white, // White color (final state)
            Color(
              0xFF00426E,
            ), // Blue color matching the square (initial state)
          ],
        ).createShader(bounds);
      },
      child: SvgPicture.asset(
        "assets/icon/components/u_letter.svg",
        width: size * 1.92,
        height: size * 1.44,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        placeholderBuilder:
            (context) => SizedBox(
              width: size * 1.92,
              height: size * 1.44,
              child: const Center(
                child: Text(
                  "U",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
      ),
    );
  }
}

class AnimatedSvgLogo extends StatefulWidget {
  const AnimatedSvgLogo({
    super.key,
    this.size = 100.0,
    this.animationDuration = const Duration(milliseconds: 6000),
  });

  final double size;
  final Duration animationDuration;

  @override
  State<AnimatedSvgLogo> createState() => _AnimatedSvgLogoState();
}

class _AnimatedSvgLogoState extends State<AnimatedSvgLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _squareFadeAnimation;
  late Animation<double> _squareRotationAnimation;
  late Animation<double> _uLetterFadeAnimation;
  late Animation<double> _uLetterColorAnimation;
  late Animation<double> _roofFallAnimation;
  late Animation<double> _chimneyFallAnimation;
  bool _hasLoggedSquareStop = false;
  bool _hasLoggedULetterDone = false;
  bool _hasLoggedRoofDone = false;
  int _lastHalfRotationIndex = 0;

  void _logStage(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
    HapticFeedbackUtils.selection();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Square fades in first (0-500ms)
    _squareFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeInOut,
        ), // 0-20% of total duration
      ),
    );

    // Square rotates 2 times (1.5x faster - takes 67% of duration)
    _squareRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6.0, // 2 full rotations (2 * 2π)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeInOut,
        ), // 0-67% of total duration with constant speed
      ),
    );

    // U letter fades in after square rotation completes
    _uLetterFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.4,
          0.7,
          curve: Curves.easeInOut,
        ), // 67-80% of total duration
      ),
    );

    // U letter color transition from blue to white (top-left to right)
    _uLetterColorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.4,
          0.7,
          curve: Curves.easeInOut,
        ), // Same timing as fade
      ),
    );

    // Roof falls down from above after square rotation completes (even slower)
    _roofFallAnimation = Tween<double>(
      begin: -3.0, // Start much further above to be completely hidden
      end: 0.0, // End at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.7,
          0.9,
          curve: Curves.bounceOut,
        ), // 80-99.8% of total duration with bounce effect
      ),
    );

    // Chimney falls down from above after roof appears (even slower)
    _chimneyFallAnimation = Tween<double>(
      begin: -3.0, // Start much further above to be completely hidden
      end: 0.0, // End at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.8,
          1,
          curve: Curves.bounceOut,
        ), // 90-95% of total duration with bounce effect
      ),
    );

    _controller.addListener(() {
      final currentHalfRotationIndex =
          _squareRotationAnimation.value.floor().clamp(0, 6);
      if (currentHalfRotationIndex > _lastHalfRotationIndex) {
        for (var i = _lastHalfRotationIndex + 1;
            i <= currentHalfRotationIndex;
            i++) {
          HapticFeedbackUtils.selection();
        }
        _lastHalfRotationIndex = currentHalfRotationIndex;
      }
      if (!_hasLoggedSquareStop && _controller.value >= 0.4) {
        _hasLoggedSquareStop = true;
        _logStage("Logo animation: square rotation completed");
      }
      if (!_hasLoggedULetterDone && _controller.value >= 0.7) {
        _hasLoggedULetterDone = true;
        _logStage("Logo animation: U letter drawing completed");
      }
      if (!_hasLoggedRoofDone && _controller.value >= 0.9) {
        _hasLoggedRoofDone = true;
        _logStage("Logo animation: roof animation completed");
      }
    });

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
        return Center(
          child: SizedBox(
            width: widget.size * 1.5, // Larger to accommodate rotated square
            height: widget.size * 1.5, // Larger to accommodate rotated square
            child: Stack(
              children: [
                // Square - fades in first and rotates 2 times
                Positioned(
                  top: widget.size * 0.25, // Center in the larger container
                  left: widget.size * 0.25, // Center in the larger container
                  right: widget.size * 0.25,
                  bottom: widget.size * 0.25,
                  child: Opacity(
                    opacity: _squareFadeAnimation.value,
                    child: Transform.rotate(
                      angle:
                          _squareRotationAnimation.value *
                          3.14159, // Convert to radians
                      child: SvgPicture.asset(
                        "assets/icon/components/square.svg",
                        width: widget.size * 1.44, // 1.2 * 1.2
                        height: widget.size * 1.44, // 1.2 * 1.2
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF00426E),
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder:
                            (context) => SizedBox(
                              width: widget.size * 1.44, // 1.2 * 1.2
                              height: widget.size * 1.44, // 1.2 * 1.2
                              child: const Center(
                                child: Text(
                                  "Square",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                // U Letter - color transition from blue to white
                Positioned(
                  top: widget.size * 0.25, // Center with the square
                  left: widget.size * 0.25, // Center with the square
                  right: widget.size * 0.25,
                  bottom: widget.size * 0.25,
                  child: Opacity(
                    opacity: _uLetterFadeAnimation.value,
                    child: AnimatedULetter(
                      progress: _uLetterColorAnimation.value,
                      size: widget.size,
                    ),
                  ),
                ),

                // Roof - falls down from above
                Positioned(
                  top:
                      widget.size * 0.25 +
                      _roofFallAnimation.value *
                          widget.size *
                          0.5, // Position based on animation, centered with square
                  left: widget.size * 0.25, // Center with the square
                  right: widget.size * 0.25,
                  bottom: widget.size * 0.25,
                  child: ClipRect(
                    child: SvgPicture.asset(
                      "assets/icon/components/red_roof.svg",
                      width: widget.size * 2.16, // 1.8 * 1.2
                      height: widget.size * 0.96, // 0.8 * 1.2
                      colorFilter: const ColorFilter.mode(
                        Color.fromRGBO(255, 0, 0, 1.0),
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder:
                          (context) => SizedBox(
                            width: widget.size * 2.16, // 1.8 * 1.2
                            height: widget.size * 0.96, // 0.8 * 1.2
                            child: const Center(
                              child: Text(
                                "Roof",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),

                // Chimney - falls down from above
                Positioned(
                  top:
                      widget.size * 0.25 +
                      _chimneyFallAnimation.value *
                          widget.size *
                          0.5, // Position based on animation, centered with square
                  left: widget.size * 0.25, // Center with the square
                  right: widget.size * 0.25,
                  bottom: widget.size * 0.25,
                  child: ClipRect(
                    child: SvgPicture.asset(
                      "assets/icon/components/chimney.svg",
                      width: widget.size * 1.44, // 1.2 * 1.2
                      height: widget.size * 1.44, // 1.2 * 1.2
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder:
                          (context) => SizedBox(
                            width: widget.size * 1.44, // 1.2 * 1.2
                            height: widget.size * 1.44, // 1.2 * 1.2
                            child: const Center(
                              child: Text(
                                "Chimney",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
