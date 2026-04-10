import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

/// Centralizes colors and typography for [PopupMenuItem] content.
///
/// App themes often use a **dark** scaffold [ColorScheme] while
/// [ThemeData.popupMenuTheme] uses a **light** panel (e.g. blue theme). Using
/// [ThemeData.disabledColor] or [ColorScheme.onSurface] for menu rows then
/// fails (e.g. white-on-white or faint grays). Resolve from [PopupMenuThemeData]
/// first, same as Material 3 menu labels.
abstract final class UydoshPopupMenuColors {
  UydoshPopupMenuColors._();

  static Set<WidgetState> _states(bool enabled) =>
      enabled ? const <WidgetState>{} : const <WidgetState>{WidgetState.disabled};

  /// Icon and non-destructive label color for one row.
  static Color itemForeground(BuildContext context, {required bool enabled}) {
    final pop = Theme.of(context).popupMenuTheme;
    final fromLabel = pop.labelTextStyle?.resolve(_states(enabled));
    if (fromLabel?.color != null) {
      return fromLabel!.color!;
    }
    final ts = pop.textStyle;
    final fallback = ts?.color;
    if (fallback != null) {
      return enabled ? fallback : fallback.withValues(alpha: 0.38);
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  /// M3 menu label style from [popupMenuTheme] (falls back to [textStyle]).
  static TextStyle? itemLabelStyle(BuildContext context, {required bool enabled}) {
    final pop = Theme.of(context).popupMenuTheme;
    return pop.labelTextStyle?.resolve(_states(enabled)) ?? pop.textStyle;
  }

  /// Resolved label style for a row; destructive + enabled tints to [AppColors.errorDark].
  static TextStyle rowLabelStyle(
    BuildContext context, {
    required bool enabled,
    bool destructive = false,
  }) {
    final base = itemLabelStyle(context, enabled: enabled);
    if (destructive && enabled) {
      return (base ?? const TextStyle()).copyWith(color: AppColors.errorDark);
    }
    if (base != null) {
      return base;
    }
    return TextStyle(
      color: itemForeground(context, enabled: enabled),
      fontSize: 16,
    );
  }

  /// Delete / destructive icon color (readable on light menu surfaces).
  static Color destructiveForeground(BuildContext context, {required bool enabled}) {
    if (enabled) {
      return AppColors.errorDark;
    }
    return itemForeground(context, enabled: false);
  }
}

/// Standard **icon + label** row for [PopupMenuItem] with theme-safe colors.
class UydoshPopupMenuItemRow extends StatelessWidget {
  const UydoshPopupMenuItemRow({
    required this.text,
    super.key,
    this.icon,
    this.enabled = true,
    this.destructive = false,
    this.iconSize = 20,
    this.gap = 10,
  });

  final IconData? icon;
  final String text;
  final bool enabled;
  final bool destructive;
  final double iconSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        destructive
            ? UydoshPopupMenuColors.destructiveForeground(
              context,
              enabled: enabled,
            )
            : UydoshPopupMenuColors.itemForeground(context, enabled: enabled);
    final textStyle = UydoshPopupMenuColors.rowLabelStyle(
      context,
      enabled: enabled,
      destructive: destructive,
    );

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: iconColor),
          SizedBox(width: gap),
        ],
        Expanded(
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
