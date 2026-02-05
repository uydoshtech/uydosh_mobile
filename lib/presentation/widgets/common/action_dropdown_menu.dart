import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/base/state/theme_state.dart";

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
      onOpened: () {
        HapticFeedbackUtils.impact();
      },
      onSelected: (String value) {
        HapticFeedbackUtils.impact();
        final item = items.firstWhere((item) => item.value == value);
        if (!item.enabled) {
          return;
        }
        item.onPressed();
      },
      color: Theme.of(context).popupMenuTheme.color,
      itemBuilder: (BuildContext context) {
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

          return PopupMenuItem<String>(
            value: item.value,
            enabled: item.enabled,
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color:
                      item.enabled
                          ? (item.iconColor ?? baseTextStyle?.color)
                          : disabledColor,
                ),
                const SizedBox(width: 12),
                LanguageAwareStringHelper.getText(
                  item.textKey,
                  context,
                  style: effectiveTextStyle,
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
          child: Icon(
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
  });

  final String value;
  final IconData icon;
  final String textKey;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? textColor;
  final bool enabled;
}
