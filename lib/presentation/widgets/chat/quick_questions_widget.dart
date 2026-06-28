import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/quick_questions_config.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

class QuickQuestionsWidget extends StatelessWidget {
  const QuickQuestionsWidget({
    required this.onQuestionTap,
    this.conversationContextType,
    this.listingTypeId,
    this.isViewerServiceOfferer = false,
    this.isViewerListingAuthor = false,
    this.blendWithGlassBackdrop = false,
    super.key,
  });

  /// Receives both the resolved (localized) question text and its l10n key.
  /// The key is passed so callers can log analytics without re-matching text.
  final void Function(String questionText, String questionKey) onQuestionTap;

  /// Mirrors [ChatScreen.conversationContextType]; used to pick gig vs housing.
  final String? conversationContextType;

  /// For housing threads: backend listing type (`1` = need room, `2` need roommate).
  final int? listingTypeId;

  /// Gig threads only: viewer is service offer side (paired with context type).
  final bool isViewerServiceOfferer;

  /// Housing threads only: viewer wrote the backing listing / lead post.
  final bool isViewerListingAuthor;

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
        final glassAnimationsEnabled =
            LiquidGlassRendering.effectsEnabled(context);

        final stripDecoration = blendWithGlassBackdrop
            ? const BoxDecoration()
            : BoxDecoration(
                color: stripColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              );

        final keys = quickQuestionKeysFor(
          conversationContextType: conversationContextType,
          listingTypeId: listingTypeId,
          isViewerServiceOfferer: isViewerServiceOfferer,
          isViewerListingAuthor: isViewerListingAuthor,
        );

        return Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
          decoration: stripDecoration,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildPills(
                keys: keys,
                pillColor: pillColor,
                pillTextColor: pillTextColor,
                useGlassBluePills: blendWithGlassBackdrop &&
                    themeState.isBlueTheme &&
                    themeState.usesLiquidGlassChrome,
                glassAnimationsEnabled: glassAnimationsEnabled,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPills({
    required List<String> keys,
    required Color pillColor,
    required Color pillTextColor,
    required bool useGlassBluePills,
    required bool glassAnimationsEnabled,
  }) {
    final children = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 10));
      final key = keys[i];
      children.add(
        _buildQuestionPill(
          text: L10n.get(key),
          questionKey: key,
          backgroundColor: pillColor,
          textColor: pillTextColor,
          useGlassBluePills: useGlassBluePills,
          glassAnimationsEnabled: glassAnimationsEnabled,
        ),
      );
    }
    return children;
  }

  Widget _buildQuestionPill({
    required String text,
    required String questionKey,
    required Color backgroundColor,
    required Color textColor,
    required bool useGlassBluePills,
    required bool glassAnimationsEnabled,
  }) {
    const radius = 20.0;
    final borderRadius = BorderRadius.circular(radius);
    final label = Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
    final paddedLabel = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: label,
    );
    final glassPill = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.26),
            BlueThemeColors.primaryLight.withValues(alpha: 0.32),
            BlueThemeColors.primary.withValues(alpha: 0.48),
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: paddedLabel,
    );

    final Widget pillBody = useGlassBluePills
        ? ClipRRect(
            borderRadius: borderRadius,
            child: LiquidGlassRendering.backdropBlur(
              enabled: glassAnimationsEnabled,
              sigma: LiquidGlassRendering.plateBlurSigma,
              child: glassPill,
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: backgroundColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

    return GestureDetector(
      onTap: () {
        HapticFeedbackUtils.impact();
        onQuestionTap(text, questionKey);
      },
      child: pillBody,
    );
  }
}
