import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class QuickQuestionsWidget extends StatelessWidget {

  const QuickQuestionsWidget({required this.onQuestionTap, super.key});
  final Function(String) onQuestionTap;

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
        HapticFeedbackUtils.impact();
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
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware text color
  Color _getThemeAwareTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.textPrimary; // White text for blue theme
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
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware pill text color
  Color _getThemeAwarePillTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White text for light theme pills
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text for blue theme pills
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
    }
    return Colors.grey.withValues(alpha: 0.2); // Default to light grey
  }
}
