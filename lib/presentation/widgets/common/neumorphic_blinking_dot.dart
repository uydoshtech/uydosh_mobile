import "package:flutter/material.dart";

/// A softly pulsing, neumorphic-looking dot. Designed for status/attention cues
/// (e.g. "profile is incomplete"). It combines:
///   * a radial highlight on the dot itself for a tiny 3D bead feel,
///   * subtle dark/light neumorphic shadows so it sits on the surface,
///   * a colored halo that pulses in/out instead of a hard on/off blink.
class NeumorphicBlinkingDot extends StatefulWidget {
  const NeumorphicBlinkingDot({
    super.key,
    this.color = const Color(0xFF22C55E),
    this.size = 12.0,
    this.duration = const Duration(milliseconds: 1400),
  });

  final Color color;
  final double size;
  final Duration duration;

  @override
  State<NeumorphicBlinkingDot> createState() => _NeumorphicBlinkingDotState();
}

class _NeumorphicBlinkingDotState extends State<NeumorphicBlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reserve room for the pulsing halo so layout doesn't shift.
    final boxSize = widget.size * 2.4;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = _pulse.value;

          // Pulse the bead itself between a dim and a bright state so the
          // blinking is unmistakable; halo intensity tracks the same beat.
          final dim = Color.lerp(widget.color, Colors.black, 0.45)!;
          final core = Color.lerp(dim, widget.color, t)!;
          final highlight = Color.lerp(core, Colors.white, 0.55 * t + 0.15)!;
          final shade = Color.lerp(core, Colors.black, 0.35)!;

          return Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.45),
                  radius: 0.95,
                  colors: [highlight, core, shade],
                  stops: const [0.0, 0.55, 1.0],
                ),
                boxShadow: [
                  // Pulsing colored halo — biggest swing reads as a blink.
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.05 + 0.65 * t),
                    blurRadius: 4 + 14 * t,
                    spreadRadius: 0.0 + 3.0 * t,
                  ),
                  // Neumorphic light edge (top-left).
                  BoxShadow(
                    color: Colors.white.withValues(
                      alpha: isDark ? 0.10 : 0.55,
                    ),
                    offset: const Offset(-1, -1),
                    blurRadius: 2,
                  ),
                  // Neumorphic dark edge (bottom-right) so it sits on the card.
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.55 : 0.22,
                    ),
                    offset: const Offset(1.2, 1.2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
