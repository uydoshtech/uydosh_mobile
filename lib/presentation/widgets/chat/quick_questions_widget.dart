import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/quick_questions_config.dart";

class QuickQuestionsWidget extends StatelessWidget {

  const QuickQuestionsWidget({
    required this.onQuestionTap,
    this.listingTypeId,
    this.isViewerListingOwner = false,
    this.blendWithGlassBackdrop = false,
    super.key,
  });

  /// Receives both the resolved (localized) question text and its l10n key.
  /// The key is passed so callers can log analytics without re-matching text.
  final void Function(String questionText, String questionKey) onQuestionTap;

  /// Listing type that scopes the chip set. `null` falls back to the legacy
  /// "asking about housing" set (pre-refactor behaviour).
  final int? listingTypeId;

  /// When the current viewer is the listing's author the chip set inverts —
  /// they talk to a counterparty, not to themselves.
  final bool isViewerListingOwner;

  /// When true, strip has no fill (parent provides frosted glass).
  final bool blendWithGlassBackdrop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final stripColor = themeState.chatInputBarBackgroundColor;
        final pillColor = themeState.pillColor;
        final pillTextColor = themeState.pillTextColor;
        final borderColor = themeState.borderColor;
        final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 12;

        final stripDecoration =
            blendWithGlassBackdrop
                ? const BoxDecoration()
                : BoxDecoration(
                  color: stripColor,
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 0.5),
                  ),
                );

        final keys = quickQuestionKeysFor(
          listingTypeId: listingTypeId,
          isViewerListingOwner: isViewerListingOwner,
        );

        return Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
          decoration: stripDecoration,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildPills(
                context,
                keys: keys,
                pillColor: pillColor,
                pillTextColor: pillTextColor,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPills(
    BuildContext context, {
    required List<String> keys,
    required Color pillColor,
    required Color pillTextColor,
  }) {
    final children = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 10));
      final key = keys[i];
      children.add(
        _buildQuestionPill(
          context,
          text: L10n.get(key),
          questionKey: key,
          backgroundColor: pillColor,
          textColor: pillTextColor,
        ),
      );
    }
    return children;
  }

  Widget _buildQuestionPill(
    BuildContext context, {
    required String text,
    required String questionKey,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackUtils.impact();
        onQuestionTap(text, questionKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
