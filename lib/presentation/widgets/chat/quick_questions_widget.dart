import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uy_dosh/base/constants/app_strings.dart';
import 'package:uy_dosh/base/state/theme_state.dart';
import 'package:uy_dosh/base/constants/app_colors.dart';
import 'package:uy_dosh/presentation/widgets/language_switcher.dart';

class QuickQuestionsWidget extends StatelessWidget {
  final Function(String) onQuestionTap;

  const QuickQuestionsWidget({super.key, required this.onQuestionTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = _getThemeAwareBackgroundColor(themeState);
        final textColor = _getThemeAwareTextColor(themeState);
        final pillColor = _getThemeAwarePillColor(themeState);
        final pillTextColor = _getThemeAwarePillTextColor(themeState);
        final borderColor = _getThemeAwareBorderColor(themeState);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuestionPill(
                  context,
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "quick_question_room_available",
                  ),
                  pillColor,
                  pillTextColor,
                ),
                const SizedBox(width: 8),
                _buildQuestionPill(
                  context,
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "quick_question_move_in_date",
                  ),
                  pillColor,
                  pillTextColor,
                ),
                const SizedBox(width: 8),
                _buildQuestionPill(
                  context,
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "quick_question_people_living",
                  ),
                  pillColor,
                  pillTextColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionPill(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () {
        // Add light haptic feedback when tapping on quick question
        HapticFeedback.lightImpact();
        onQuestionTap(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: backgroundColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Get theme-aware background color
  Color _getThemeAwareBackgroundColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White background for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.background; // Blue background for blue theme
    } else if (themeState.isPurpleTheme) {
      return AppColors.primary; // Purple background for purple theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware text color
  Color _getThemeAwareTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.textPrimary; // White text for blue theme
    } else if (themeState.isPurpleTheme) {
      return AppColors.textPrimary; // White text for purple theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware pill background color
  Color _getThemeAwarePillColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black pills for light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white.withValues(
        alpha: 0.2,
      ); // Semi-transparent white pills for blue theme
    } else if (themeState.isPurpleTheme) {
      return Colors.white.withValues(
        alpha: 0.2,
      ); // Semi-transparent white pills for purple theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware pill text color
  Color _getThemeAwarePillTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White text for light theme pills
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text for blue theme pills
    } else if (themeState.isPurpleTheme) {
      return Colors.white; // White text for purple theme pills
    }
    return Colors.white; // Default to white text
  }

  /// Get theme-aware border color
  Color _getThemeAwareBorderColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey.withValues(
        alpha: 0.2,
      ); // Light grey border for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.divider; // Blue border for blue theme
    } else if (themeState.isPurpleTheme) {
      return AppColors.divider; // Purple border for purple theme
    }
    return Colors.grey.withValues(alpha: 0.2); // Default to light grey
  }
}
