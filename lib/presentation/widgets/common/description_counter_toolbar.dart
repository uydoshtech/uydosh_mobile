import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_ai_enhance_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_template_button.dart";

/// Layout style for [DescriptionCounterToolbar].
enum DescriptionCounterToolbarLayout {
  /// Counter column is positioned flush to the right edge with a small
  /// negative inset (`right: -18`), matching the create-listing screen.
  stack,

  /// Counter column sits inside a normal [Row] after a [Spacer], matching the
  /// edit-listing screen.
  row,
}

/// Shared toolbar rendered via [TextField.buildCounter] under the listing
/// description field. Exposes:
///
/// * The AI-enhance and template suggestion buttons on the left.
/// * A `currentLength / maxLength` counter that turns red at 90% usage.
/// * An expand/collapse chevron with haptic feedback.
///
/// Two visual layouts are supported — see [DescriptionCounterToolbarLayout].
class DescriptionCounterToolbar extends StatelessWidget {
  const DescriptionCounterToolbar({
    required this.controller,
    required this.listingTypeId,
    required this.gender,
    required this.currentLength,
    required this.maxLength,
    required this.isExpanded,
    required this.onToggleExpanded,
    super.key,
    this.layout = DescriptionCounterToolbarLayout.row,
    this.counterColor,
    this.stackCounterRightOffset = -18,
  });

  final TextEditingController controller;
  final int listingTypeId;
  final int gender;
  final int currentLength;
  final int maxLength;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final DescriptionCounterToolbarLayout layout;

  /// Overrides the automatic counter color. When `null`, the toolbar shows
  /// red near the limit and a theme-aware color otherwise.
  final Color? counterColor;

  /// Horizontal offset applied to the counter column in stack layout. Defaults
  /// to `-18` so the counter can sit flush with the parent field's padding.
  final double stackCounterRightOffset;

  Color _resolveCounterColor(BuildContext context) {
    final override = counterColor;
    if (override != null) return override;
    final isNearLimit = maxLength > 0 && (currentLength / maxLength) >= 0.9;
    if (isNearLimit) return Colors.red;
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : Colors.black;
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListingDescriptionAiEnhanceButton(
          controller: controller,
          inlineWithCounter: true,
        ),
        ListingDescriptionTemplateButton(
          controller: controller,
          listingTypeId: listingTypeId,
          gender: gender,
          inlineWithCounter: true,
        ),
      ],
    );
  }

  Widget _buildCounterColumn(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$currentLength/$maxLength",
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Semantics(
          button: true,
          label: isExpanded ? "Collapse description" : "Expand description",
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedbackUtils.lightImpact();
              onToggleExpanded();
            },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.expand_more,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveCounterColor(context);

    if (layout == DescriptionCounterToolbarLayout.stack) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              _buildButtonRow(),
              Positioned(
                right: stackCounterRightOffset,
                top: 0,
                bottom: 0,
                child: _buildCounterColumn(color),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListingDescriptionAiEnhanceButton(
            controller: controller,
            inlineWithCounter: true,
          ),
          ListingDescriptionTemplateButton(
            controller: controller,
            listingTypeId: listingTypeId,
            gender: gender,
            inlineWithCounter: true,
          ),
          const Spacer(),
          _buildCounterColumn(color),
        ],
      ),
    );
  }
}
