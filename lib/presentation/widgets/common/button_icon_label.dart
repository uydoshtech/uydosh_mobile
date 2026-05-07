import "package:flutter/widgets.dart";

/// Pairs optional side icons with [label].
///
/// When **both** [leading] and [trailing] are set, fixed-width slots keep the
/// label centered between them. When only one side has an icon, the icon and
/// label are a tight group centered together (no wide gap from a padded slot).
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

  /// Reserved width for each side when [leading] and [trailing] are both set.
  final double slotWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedWidth = constraints.hasBoundedWidth;
        final hasLeading = leading != null;
        final hasTrailing = trailing != null;

        if (hasLeading && hasTrailing) {
          return Row(
            mainAxisSize: boundedWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              SizedBox(
                width: slotWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: leading,
                ),
              ),
              boundedWidth
                  ? Expanded(child: Center(child: label))
                  : Flexible(fit: FlexFit.loose, child: Center(child: label)),
              SizedBox(
                width: slotWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing,
                ),
              ),
            ],
          );
        }

        if (hasLeading || hasTrailing) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: boundedWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (hasLeading) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Flexible(
                fit: FlexFit.loose,
                child: label,
              ),
              if (hasTrailing) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          );
        }

        return Center(child: label);
      },
    );
  }
}

