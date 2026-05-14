import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/the_dot_drop_menu_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
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
    return TheDotDropMenuButton<String>(
      tooltip: tooltip,
      padding: padding,
      icon: icon ?? Icons.more_vert,
      iconSize: iconSize,
      iconColor: iconColor,
      onSelected: (value) {
        final item = items.firstWhere((item) => item.value == value);
        if (!item.enabled) {
          return;
        }
        item.onPressed();
      },
      itemBuilder: (context) {
        return items.map((item) {
          final defaultFg = UydoshPopupMenuColors.itemForeground(
            context,
            enabled: item.enabled,
          );
          final effectiveTextColor =
              item.enabled ? (item.textColor ?? defaultFg) : defaultFg;
          final baseTextStyle =
              UydoshPopupMenuColors.itemLabelStyle(
                context,
                enabled: item.enabled,
              ) ??
              Theme.of(context).popupMenuTheme.textStyle;
          var effectiveTextStyle =
              (baseTextStyle ?? const TextStyle()).copyWith(
                color: effectiveTextColor,
              );
          if (item.labelFontWeight != null) {
            effectiveTextStyle = effectiveTextStyle.copyWith(
              fontWeight: item.labelFontWeight,
            );
          }

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
    this.labelFontWeight,
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
  /// Heavier label for staff / elevated actions (e.g. moderation and admin tools).
  final FontWeight? labelFontWeight;
}
