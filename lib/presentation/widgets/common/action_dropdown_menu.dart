import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

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
    return PopupMenuButton<String>(
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
      itemBuilder: (context) {
        return items.map((item) {
          final baseTextStyle = Theme.of(context).popupMenuTheme.textStyle;
          final disabledColor = Theme.of(context).disabledColor;
          final effectiveTextColor =
              item.enabled
                  ? (item.textColor ?? baseTextStyle?.color)
                  : disabledColor;
          final effectiveTextStyle =
              (baseTextStyle ?? const TextStyle()).copyWith(
                color: effectiveTextColor,
              );

          final effectiveIconColor =
              item.enabled
                  ? (item.iconColor ?? baseTextStyle?.color)
                  : disabledColor;

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
