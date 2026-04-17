import "package:flutter/widgets.dart";

/// Keeps the [label] visually centered while optionally showing icons on either side.
///
/// This prevents the label from shifting left/right when leading/trailing icons
/// appear/disappear by reserving fixed-width slots on both sides.
class ButtonIconLabel extends StatelessWidget {
  const ButtonIconLabel({
    required this.label,
    super.key,
    this.leading,
    this.trailing,
    this.slotWidth = 32,
  });

  final Widget label;
  final Widget? leading;
  final Widget? trailing;

  /// Reserved width for both left and right slots.
  final double slotWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            width: slotWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: leading,
            ),
          ),
          Expanded(
            child: Center(
              child: label,
            ),
          ),
          SizedBox(
            width: slotWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}

