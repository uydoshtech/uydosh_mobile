import "package:flutter/material.dart";
import "package:flutter/services.dart";
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
        HapticFeedback.lightImpact();
      },
      onSelected: (String value) {
        HapticFeedback.lightImpact();
        final item = items.firstWhere((item) => item.value == value);
        item.onPressed();
      },
      color: Theme.of(context).popupMenuTheme.color,
      itemBuilder: (BuildContext context) {
        return items.map((item) {
          return PopupMenuItem<String>(
            value: item.value,
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color:
                      item.iconColor ??
                      Theme.of(context).popupMenuTheme.textStyle?.color,
                ),
                const SizedBox(width: 12),
                LanguageAwareStringHelper.getText(
                  item.textKey,
                  context,
                  style: Theme.of(context).popupMenuTheme.textStyle,
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
  });

  final String value;
  final IconData icon;
  final String textKey;
  final VoidCallback onPressed;
  final Color? iconColor;
}
