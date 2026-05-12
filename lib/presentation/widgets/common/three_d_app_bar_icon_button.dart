import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";

/// Neumorphic 3D chrome for app bar icon actions. Defaults to a rounded square
/// (same shape as the main navigation drawer button). Pass [borderRadius] for
/// circular actions (e.g. profile).
///
/// Use [padding] + [contentSlotSize] so the painted control matches neighbors
/// (e.g. `padding: EdgeInsets.zero`, `contentSlotSize: kAppBarAvatarContentSize`
/// for a full-bleed circular avatar).
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
    this.contentSlotSize = 28,
    this.neumorphicSoftUi = false,
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

  /// Width/height of the inner icon or [iconWidget] slot (before [padding]).
  final double contentSlotSize;

  /// Soft raised / inset pressed chrome ([ThreeDPillButton.neumorphicSoftUi]).
  final bool neumorphicSoftUi;

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
      neumorphicSoftUi: neumorphicSoftUi,
      onPressed: onPressed,
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: _iconContent(slot: contentSlotSize),
      ),
    );
  }

  Widget _iconContent({required double slot}) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final iconColor =
            ThemeState().isBlueTheme ? Colors.white : Colors.black;
        return SizedBox(
          width: slot,
          height: slot,
          child: Center(
            child:
                iconWidget ??
                ThemeIcon(
                  iconData,
                  color: iconColor,
                  size: iconSize,
                ),
          ),
        );
      },
    );
  }
}
