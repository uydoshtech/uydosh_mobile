import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable dropdown option for [UydoshDropdown].
class DropdownOption {
  const DropdownOption({required this.value, required this.label, this.icon});

  final String? value;
  final String label;
  final IconData? icon;
}

/// A reusable settings row with an icon, label, and dropdown.
/// Theme-aware. Can be wrapped in a container (e.g. ProfileDropdownControl) for
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

    return Padding(
      padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            ThemeIcon(
              icon,
              color:
                  isBlueTheme
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
                color:
                    isBlueTheme
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
                elevation: AppTheme.menuPanelElevation,
                borderRadius: BorderRadius.circular(16),
                icon: ThemeIcon(
                  Icons.arrow_drop_down,
                  color:
                      isBlueTheme
                          ? Colors.white
                          : (isLightTheme
                              ? Colors.grey[600]
                              : Colors.grey[400]),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      isBlueTheme
                          ? Colors.white
                          : (isLightTheme
                              ? Colors.grey[800]
                              : Colors.grey[200]),
                ),
                dropdownColor:
                    isBlueTheme
                        ? Colors.blue.shade600.withValues(
                          alpha: AppTheme.menuOverlaySurfaceOpacity,
                        )
                        : (isLightTheme
                            ? Colors.white.withValues(
                              alpha: AppTheme.menuOverlaySurfaceOpacity,
                            )
                            : Colors.grey.shade800.withValues(
                              alpha: AppTheme.menuOverlaySurfaceOpacity,
                            )),
                items:
                    options.map((option) {
                      return DropdownMenuItem<String?>(
                        value: option.value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (option.icon != null) ...[
                              ThemeIcon(
                                option.icon,
                                color: isBlueTheme
                                    ? Colors.white
                                    : (isLightTheme
                                        ? Colors.grey[700]
                                        : Colors.grey[200]),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                option.label,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isBlueTheme
                                      ? Colors.white
                                      : (isLightTheme
                                          ? Colors.grey[800]
                                          : Colors.grey[200]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
