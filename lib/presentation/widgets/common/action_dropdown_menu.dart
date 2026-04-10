import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_popup_menu.dart";

class ActionDropdownMenu extends StatelessWidget {
  const ActionDropdownMenu({
    required this.items,
    this.icon,
    this.iconSize = 28,
    this.padding = const EdgeInsets.all(8.0),
    this.iconColor,
    this.tooltip,
    super.key,
  });

  final List<ActionMenuItem> items;
  final IconData? icon;
  final double iconSize;
  final EdgeInsets padding;
  final Color? iconColor;
  final String? tooltip;

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

        return PopupMenuButton<String>(
          borderRadius: pillRadius,
          onOpened: HapticFeedbackUtils.impact,
          onSelected: (value) {
            HapticFeedbackUtils.impact();
            final item = items.firstWhere((item) => item.value == value);
            if (!item.enabled) {
              return;
            }
            item.onPressed();
          },
          color: Theme.of(context).popupMenuTheme.color,
          popUpAnimationStyle: style,
          itemBuilder: (context) {
            return items.map((item) {
              final defaultFg = UydoshPopupMenuColors.itemForeground(
                context,
                enabled: item.enabled,
              );
              final effectiveTextColor =
                  item.enabled
                      ? (item.textColor ?? defaultFg)
                      : defaultFg;
              final baseTextStyle =
                  UydoshPopupMenuColors.itemLabelStyle(
                    context,
                    enabled: item.enabled,
                  ) ??
                  Theme.of(context).popupMenuTheme.textStyle;
              final effectiveTextStyle =
                  (baseTextStyle ?? const TextStyle()).copyWith(
                    color: effectiveTextColor,
                  );

              final effectiveIconColor =
                  item.enabled
                      ? (item.iconColor ?? item.textColor ?? defaultFg)
                      : defaultFg;

              return PopupMenuItem<String>(
                value: item.value,
                enabled: item.enabled,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: item.iconWidget != null
                          ? IconTheme(
                              data: IconThemeData(
                                color: effectiveIconColor,
                                size: 20,
                              ),
                              child: item.iconWidget!,
                            )
                          : ThemeIcon(
                              item.icon,
                              size: 20,
                              color: effectiveIconColor,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: L10n.text(
                        item.textKey,
                        context: context,
                        style: effectiveTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
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
                    icon ?? Icons.more_vert,
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

class ActionMenuItem {
  const ActionMenuItem({
    required this.value,
    required this.icon,
    required this.textKey,
    required this.onPressed,
    this.iconColor,
    this.textColor,
    this.enabled = true,
    this.iconWidget,
  });

  final String value;
  final IconData icon;
  final String textKey;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? textColor;
  final bool enabled;
  /// When provided, used instead of ThemeIcon(icon) for the menu item leading widget.
  final Widget? iconWidget;
}
