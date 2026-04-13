import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";

/// 3D chrome for app bar icon actions. Defaults to a rounded square (same shape
/// as the main navigation drawer button). Pass [borderRadius] for circular
/// actions (e.g. profile).
class ThreeDAppBarIconButton extends StatelessWidget {
  const ThreeDAppBarIconButton({
    required this.iconData,
    required this.onPressed,
    required this.semanticsLabel,
    super.key,
    this.iconSize = 26,
    this.iconWidget,
    this.borderRadius,
    this.padding = const EdgeInsets.all(6),
  });

  /// Rounded square used by the main navigation drawer button.
  static const BorderRadius kDefaultSquareRadius = BorderRadius.all(
    Radius.circular(12),
  );

  final IconData iconData;
  final VoidCallback onPressed;
  final String semanticsLabel;
  final double iconSize;
  final Widget? iconWidget;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;

  /// [AppBar.leading] layout: left inset + vertically centered control.
  static Widget leadingSlot({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Align(alignment: Alignment.center, child: child),
    );
  }

  /// Standard back control for [AppBar.leading].
  static Widget backLeading(
    BuildContext context, {
    VoidCallback? onPressed,
    String? semanticsLabel,
  }) {
    return leadingSlot(
      child: ThreeDAppBarIconButton(
        iconData: Icons.arrow_back,
        onPressed: onPressed ?? () => Navigator.maybePop(context),
        semanticsLabel:
            semanticsLabel ??
            MaterialLocalizations.of(context).backButtonTooltip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? kDefaultSquareRadius;
    return ThreeDPillButton(
      padding: padding,
      borderRadius: radius,
      onPressed: () {
        HapticFeedbackUtils.impact();
        onPressed();
      },
      child: ListenableBuilder(
        listenable: ThemeState(),
        builder: (context, _) {
          final iconColor =
              ThemeState().isBlueTheme ? Colors.white : Colors.black;
          return Semantics(
            label: semanticsLabel,
            button: true,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child:
                    iconWidget ??
                    ThemeIcon(
                      iconData,
                      color: iconColor,
                      size: iconSize,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
