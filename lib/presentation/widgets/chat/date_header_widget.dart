import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class DateHeaderWidget extends StatelessWidget {

  const DateHeaderWidget({
    required this.dateString, required this.date, super.key,
  });
  final String dateString;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final textColor = _getThemeAwareTextColor(themeState);
        final backgroundColor = _getThemeAwareBackgroundColor(themeState);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: _getThemeAwareDividerColor(themeState),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getThemeAwareBorderColor(themeState),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: _getThemeAwareDividerColor(themeState),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get theme-aware text color
  Color _getThemeAwareTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black;
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.textPrimary;
    }
    return Colors.black;
  }

  /// Get theme-aware background color
  Color _getThemeAwareBackgroundColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white;
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.background;
    }
    return Colors.white;
  }

  /// Get theme-aware divider color
  Color _getThemeAwareDividerColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[300]!;
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.divider;
    }
    return Colors.grey[300]!;
  }

  /// Get theme-aware border color
  Color _getThemeAwareBorderColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[300]!;
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.divider;
    }
    return Colors.grey[300]!;
  }
}
