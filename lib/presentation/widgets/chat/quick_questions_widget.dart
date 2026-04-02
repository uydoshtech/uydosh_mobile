import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

class QuickQuestionsWidget extends StatelessWidget {

  const QuickQuestionsWidget({required this.onQuestionTap, super.key});
  final Function(String) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = themeState.backgroundColor;
        final pillColor = themeState.pillColor;
        final pillTextColor = themeState.pillTextColor;
        final borderColor = themeState.borderColor;

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
                  L10n.get("quick_question_room_available"),
                  pillColor,
                  pillTextColor,
                ),
                const SizedBox(width: 8),
                _buildQuestionPill(
                  context,
                  L10n.get("quick_question_move_in_date"),
                  pillColor,
                  pillTextColor,
                ),
                const SizedBox(width: 8),
                _buildQuestionPill(
                  context,
                  L10n.get("quick_question_people_living"),
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
}
