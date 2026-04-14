import "package:flutter/material.dart";

/// Soft raised track + thumb (neumorphic-style).
///
/// Track size matches Material 3 [Switch] (52 × 32 logical pixels) so width aligns
/// with a standard [Switch].
class NeumorphicToggle extends StatelessWidget {
  const NeumorphicToggle({
    required this.activeAccentColor,
    required this.activeTrackColor,
    required this.inactiveThumbColor,
    required this.inactiveTrackColor,
    required this.onChanged,
    required this.value,
    this.height = _kMaterial3SwitchTrackHeight,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeAccentColor;
  final Color activeTrackColor;
  final Color inactiveThumbColor;
  final Color inactiveTrackColor;
  final double height;

  /// Material 3 switch track width.
  static const double _kMaterial3SwitchTrackWidth = 52;

  /// Material 3 switch track height.
  static const double _kMaterial3SwitchTrackHeight = 32;

  static const Duration _anim = Duration(milliseconds: 200);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hi = isDark ? 0.10 : 0.55;
    final lo = isDark ? 0.35 : 0.12;

    return SizedBox(
      width: _kMaterial3SwitchTrackWidth,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(height / 2),
          child: AnimatedContainer(
            duration: _anim,
            curve: _curve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: value ? activeTrackColor : inactiveTrackColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: lo),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: hi),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Square thumb fills the padded inner bounds (Material-like ~80% of track).
                final thumbSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                return AnimatedAlign(
                  duration: _anim,
                  curve: _curve,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? activeAccentColor : inactiveThumbColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: lo + 0.05),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: hi * 0.85),
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
