import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";

/// A widget that displays a blinking dot indicator
/// Used for showing unread messages or other notifications
class BlinkingDotWidget extends StatefulWidget {
  const BlinkingDotWidget({
    super.key,
    this.color = Colors.green,
    this.size = 12.0,
    this.duration = const Duration(seconds: 2),
    this.borderColor,
    this.borderWidth = 2.0,
  });

  /// The color of the dot
  final Color color;

  /// The size of the dot
  final double size;

  /// The duration of the blink cycle (default: 2 seconds)
  final Duration duration;

  /// Border color around the dot
  final Color? borderColor;

  /// Border width around the dot
  final double borderWidth;

  @override
  State<BlinkingDotWidget> createState() => _BlinkingDotWidgetState();
}

class _BlinkingDotWidgetState extends State<BlinkingDotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _blinkEnabled = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create a simple on/off animation (0.0 to 1.0 opacity)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBlink();
  }

  void _syncBlink() {
    final enabled = UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    if (enabled) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.value = 1.0;
    }
    _blinkEnabled = enabled;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Show/hide the widget completely based on animation value
        if (_blinkEnabled && _animation.value < 0.5) {
          return const SizedBox.shrink();
        }

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: widget.borderColor != null
                ? Border.all(
                    color: widget.borderColor!,
                    width: widget.borderWidth,
                  )
                : null,
          ),
        );
      },
    );
  }
}
