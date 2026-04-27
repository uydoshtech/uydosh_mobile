import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// App-wide three-dot overflow control: circular 3D surface + popup menu,
/// matching listing detail / profile app bar styling.
class TheDotDropMenuButton<T> extends StatefulWidget {
  const TheDotDropMenuButton({
    required this.itemBuilder,
    super.key,
    this.onSelected,
    this.enabled = true,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
    this.icon = Icons.more_vert,
    this.iconSize = 28,
    /// Scales the circular chrome and icon (1.0 = default). Use e.g. 0.8 for ~20% smaller.
    this.visualScale = 1.0,
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
  final double visualScale;
  final Color? iconColor;
  final T? initialValue;
  final Offset? offset;

  @override
  State<TheDotDropMenuButton<T>> createState() =>
      _TheDotDropMenuButtonState<T>();
}

class _TheDotDropMenuButtonState<T> extends State<TheDotDropMenuButton<T>> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (!mounted) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

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
        final scale = widget.visualScale.clamp(0.5, 1.5);
        final innerPad = 6.0 * scale;
        final effectiveIconSize = widget.iconSize * scale;

        return PopupMenuButton<T>(
          enabled: widget.enabled,
          initialValue: widget.initialValue,
          offset: widget.offset ?? Offset.zero,
          borderRadius: pillRadius,
          onOpened: HapticFeedbackUtils.impact,
          onSelected:
              widget.onSelected == null
                  ? null
                  : (value) {
                    HapticFeedbackUtils.impact();
                    widget.onSelected!(value);
                  },
          color: Theme.of(context).popupMenuTheme.color,
          popUpAnimationStyle: style,
          itemBuilder: widget.itemBuilder,
          child: Listener(
            onPointerDown: (_) => _setPressed(true),
            onPointerUp: (_) => _setPressed(false),
            onPointerCancel: (_) => _setPressed(false),
            child: Padding(
              padding: widget.padding,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
                decoration: BoxDecoration(
                  borderRadius: pillRadius,
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    scheme.surface,
                  ),
                  boxShadow:
                      _pressed || !widget.enabled
                          ? ThreeDSurfaceStyle.pressedShadows(context)
                          : ThreeDSurfaceStyle.elevatedShadows(context),
                ),
                child: Padding(
                  padding: EdgeInsets.all(innerPad),
                  child: Tooltip(
                    message: widget.tooltip ?? "",
                    child: ThemeIcon(
                      widget.icon,
                      size: effectiveIconSize,
                      color:
                          widget.iconColor ??
                        (ThemeState().isBlueTheme
                            ? Colors.white
                            : Theme.of(context).iconTheme.color),
                    ),
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
