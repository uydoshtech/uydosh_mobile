import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable dropdown option for [UydoshDropdown].
class DropdownOption {
  const DropdownOption({required this.value, required this.label, this.icon});

  final String? value;
  final String label;
  final IconData? icon;
}

/// Menu overlay + caret styling shared by [UydoshDropdown],
/// [UydoshDropdownFormField], and any other dropdown entry points.
abstract final class UydoshDropdownChrome {
  /// Panel behind open menu items (matches legacy [UydoshDropdown] / app theme).
  static Color menuPanelColor(BuildContext context) {
    final isLightTheme = ThemeState().isLightTheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    if (isBlueTheme) {
      return AppTheme.menuOverlaySurfaceColor.withValues(
        alpha: AppTheme.resolvedMenuOverlaySurfaceOpacity,
      );
    }
    if (isLightTheme) {
      return Colors.white.withValues(
        alpha: AppTheme.resolvedMenuOverlaySurfaceOpacity,
      );
    }
    return Colors.grey.shade800.withValues(
      alpha: AppTheme.resolvedMenuOverlaySurfaceOpacity,
    );
  }

  /// TextStyle for the **closed** selector (compact row / form field trigger).
  static TextStyle? selectedItemStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = ThemeState().isLightTheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    return theme.textTheme.bodyMedium?.copyWith(
      color: isBlueTheme
          ? Colors.white
          : (isLightTheme ? Colors.grey[800] : Colors.grey[200]),
    );
  }

  /// Foreground for rows inside the opened menu panel.
  static Color menuItemForeground(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.primary;
    }
    return ThemeState().isLightTheme ? Colors.grey[800]! : Colors.grey[200]!;
  }

  static TextStyle? menuItemStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: menuItemForeground(context),
        );
  }

  static Color _caretColor(BuildContext context, {Color? override}) {
    if (override != null) return override;
    final isLightTheme = ThemeState().isLightTheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    return isBlueTheme
        ? Colors.white
        : (isLightTheme ? Colors.grey[600]! : Colors.grey[400]!);
  }

  static Widget arrowIcon(BuildContext context, {Color? color}) {
    return ThemeIcon(
      Icons.arrow_drop_down,
      color: _caretColor(context, override: color),
    );
  }
}

/// Typed form dropdown using the same menu + typography defaults as [UydoshDropdown].
///
/// Caller supplies [decoration] (outline, fills, labels) so each screen keeps its custom
/// chrome. Use [materialMenuOverlay] when the menu panel should match Material defaults
/// (nullable [menuOverlayColor]) instead of [UydoshDropdownChrome.menuPanelColor].
class UydoshDropdownFormField<T> extends StatelessWidget {
  const UydoshDropdownFormField({
    required this.value,
    required this.decoration,
    required this.items,
    super.key,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.style,
    this.icon,
    this.menuOverlayColor,
    this.materialMenuOverlay = false,
    this.dropdownIconColor,
    this.elevation = AppTheme.menuPanelElevation,
    this.menuBorderRadius,
    this.isExpanded = true,
    this.autovalidateMode,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  /// Applies when this field is placed inside a [Form].
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final InputDecoration decoration;

  /// Trigger + selected-item text; defaults to [UydoshDropdownChrome.selectedItemStyle].
  final TextStyle? style;

  /// Replaces arrow; defaults to [UydoshDropdownChrome.arrowIcon].
  final Widget? icon;

  /// When [materialMenuOverlay] is false (default): inner `dropdownColor` is
  /// `menuOverlayColor ?? UydoshDropdownChrome.menuPanelColor(context)`.
  /// When true: uses [menuOverlayColor] as-is (`null` ⇒ Material default overlay).
  final Color? menuOverlayColor;
  final bool materialMenuOverlay;

  /// Override only the caret color when [icon] is null.
  final Color? dropdownIconColor;

  final int elevation;

  /// Shape of the **open** menu sheet; defaults to 16 to match [UydoshDropdown].
  final BorderRadius? menuBorderRadius;

  final bool isExpanded;
  final AutovalidateMode? autovalidateMode;

  Color? _resolvedMenuColor(BuildContext context) {
    if (materialMenuOverlay) return menuOverlayColor;
    return menuOverlayColor ?? UydoshDropdownChrome.menuPanelColor(context);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? UydoshDropdownChrome.selectedItemStyle(context);
    final menuItemStyle = UydoshDropdownChrome.menuItemStyle(context);
    final menuItemForeground = UydoshDropdownChrome.menuItemForeground(context);
    final selectedItemForeground = effectiveStyle?.color;
    final effectiveIcon = icon ??
        UydoshDropdownChrome.arrowIcon(
          context,
          color: dropdownIconColor,
        );

    void handleChange(T? v) {
      final cb = onChanged;
      if (cb == null) return;
      UiFeedbackUtils.tap();
      cb(v);
    }

    final decoratedItems = items.map((item) {
      return DropdownMenuItem<T>(
        key: item.key,
        value: item.value,
        enabled: item.enabled,
        alignment: item.alignment,
        onTap: item.onTap,
        child: DefaultTextStyle.merge(
          style: menuItemStyle,
          child: IconTheme(
            data: IconThemeData(color: menuItemForeground),
            child: item.child,
          ),
        ),
      );
    }).toList();

    return DropdownButtonFormField<T>(
      value: value,
      items: decoratedItems,
      onTap: onChanged == null ? null : () => HapticFeedbackUtils.impact(),
      onChanged: onChanged == null ? null : handleChange,
      decoration: decoration,
      style: effectiveStyle,
      selectedItemBuilder: (context) {
        return items.map((item) {
          return DefaultTextStyle.merge(
            style: effectiveStyle,
            child: IconTheme(
              data: IconThemeData(color: selectedItemForeground),
              child: item.child,
            ),
          );
        }).toList();
      },
      icon: effectiveIcon,
      elevation: elevation,
      borderRadius: menuBorderRadius ?? BorderRadius.circular(16),
      dropdownColor: _resolvedMenuColor(context),
      isExpanded: isExpanded,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
    );
  }
}

/// A reusable settings row with an icon, label, and dropdown.
/// Theme-aware. Can be wrapped in a container (e.g. [ProfileDropdownControl]) for
/// section styling.
class UydoshDropdown extends StatelessWidget {
  const UydoshDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
    this.icon,
    this.contentPadding,
  });

  final String label;
  final String? value;
  final List<DropdownOption> options;
  final ValueChanged<String?> onChanged;
  final IconData? icon;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = ThemeState().isLightTheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    final menuItemForeground = UydoshDropdownChrome.menuItemForeground(context);
    final menuItemStyle = UydoshDropdownChrome.menuItemStyle(context);
    final selectedItemForeground = isBlueTheme
        ? Colors.white
        : (isLightTheme ? Colors.grey[800] : Colors.grey[200]);

    return Padding(
      padding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            ThemeIcon(
              icon,
              color: isBlueTheme
                  ? Colors.white
                  : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isBlueTheme
                    ? Colors.white
                    : (isLightTheme ? Colors.grey[800] : Colors.grey[200]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                isExpanded: true,
                onTap: () => HapticFeedbackUtils.impact(),
                elevation: AppTheme.menuPanelElevation,
                borderRadius: BorderRadius.circular(16),
                icon: UydoshDropdownChrome.arrowIcon(context),
                style: UydoshDropdownChrome.selectedItemStyle(context),
                selectedItemBuilder: (context) {
                  return options.map((option) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.icon != null) ...[
                          ThemeIcon(
                            option.icon,
                            color: selectedItemForeground,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                            style:
                                UydoshDropdownChrome.selectedItemStyle(context),
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
                dropdownColor: UydoshDropdownChrome.menuPanelColor(context),
                items: options.map((option) {
                  return DropdownMenuItem<String?>(
                    value: option.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.icon != null) ...[
                          ThemeIcon(
                            option.icon,
                            color: menuItemForeground,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                            style: menuItemStyle,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  UiFeedbackUtils.tap();
                  onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
