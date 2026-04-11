import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// App-wide three-dot overflow control: circular 3D surface + popup menu,
/// matching listing detail / profile app bar styling.
class TheDotDropMenuButton<T> extends StatelessWidget {
  const TheDotDropMenuButton({
    required this.itemBuilder,
    super.key,
    this.onSelected,
    this.enabled = true,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
    this.icon = Icons.more_vert,
    this.iconSize = 28,
    this.iconColor,
    this.initialValue,
    this.offset,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;
  final bool enabled;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final T? initialValue;
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        final enableMotion = AnimationSettingsState().uiAnimationsEnabled;
        final style =
            enableMotion
                ? null
                : const AnimationStyle(
                    duration: Duration.zero,
                    reverseDuration: Duration.zero,
                  );

        final scheme = Theme.of(context).colorScheme;
        final pillRadius = BorderRadius.circular(999);

        return PopupMenuButton<T>(
          enabled: enabled,
          initialValue: initialValue,
          offset: offset ?? Offset.zero,
          borderRadius: pillRadius,
          onOpened: HapticFeedbackUtils.impact,
          onSelected:
              onSelected == null
                  ? null
                  : (value) {
                    HapticFeedbackUtils.impact();
                    onSelected!(value);
                  },
          color: Theme.of(context).popupMenuTheme.color,
          popUpAnimationStyle: style,
          itemBuilder: itemBuilder,
          child: Padding(
            padding: padding,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: pillRadius,
                gradient: ThreeDSurfaceStyle.surfaceGradient(
                  context,
                  scheme.surface,
                ),
                boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Tooltip(
                  message: tooltip ?? "",
                  child: ThemeIcon(
                    icon,
                    size: iconSize,
                    color:
                        iconColor ??
                        (ThemeState().isBlueTheme
                            ? Colors.white
                            : Theme.of(context).iconTheme.color),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
