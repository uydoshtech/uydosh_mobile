import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_listing_dictation_meter_config.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/debug_tap_bounds.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_ai_enhance_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictate_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictation_meter.dart";
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
/// description field. Groups the **description assistant** actions from
/// [ListingDescriptionAiEnhanceButton], [ListingDescriptionTemplateButton], and
/// [ListingDescriptionDictateButton] (see [ListingDescriptionAssistant]).
///
/// * The AI-enhance, template suggestion, and dictate actions on the left.
/// * A `currentLength / maxLength` counter that turns red at 90% usage.
/// * An expand/collapse chevron with haptic + UI sound feedback.
///
/// Two visual layouts are supported — see [DescriptionCounterToolbarLayout].
class DescriptionCounterToolbar extends StatefulWidget {
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
    this.counterVisibleAtFraction = 0.0,
    this.maxDescriptionLength = 1000,
    this.debugShowTapBounds = false,
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

  /// Fraction of [maxLength] at which the `currentLength/maxLength` counter
  /// text becomes visible. Defaults to `0.0` (always visible). The
  /// expand/collapse chevron is always shown regardless.
  ///
  /// Example: `0.7` with `maxLength: 1000` shows the counter starting at
  /// `700` characters.
  final double counterVisibleAtFraction;

  /// Same cap as the description field — dictation trims to this length.
  final int maxDescriptionLength;

  /// When true, draws a visible outline around the action buttons so tap bounds
  /// are obvious while tuning hit targets.
  final bool debugShowTapBounds;

  @override
  State<DescriptionCounterToolbar> createState() =>
      _DescriptionCounterToolbarState();
}

class _DescriptionCounterToolbarState extends State<DescriptionCounterToolbar> {
  late final DictationMeterController _dictationMeter =
      DictationMeterController();

  void _onDictationMeterServerDisabled() {
    if (ClientListingDictationMeterConfig.dictationMeterDisabled.value) {
      _dictationMeter.end();
    }
  }

  @override
  void initState() {
    super.initState();
    ClientListingDictationMeterConfig.dictationMeterDisabled.addListener(
      _onDictationMeterServerDisabled,
    );
  }

  @override
  void dispose() {
    ClientListingDictationMeterConfig.dictationMeterDisabled.removeListener(
      _onDictationMeterServerDisabled,
    );
    _dictationMeter.dispose();
    super.dispose();
  }

  bool get _showCounterText {
    if (widget.counterVisibleAtFraction <= 0.0) return true;
    if (widget.maxLength <= 0) return true;
    return (widget.currentLength / widget.maxLength) >=
        widget.counterVisibleAtFraction;
  }

  Color _resolveCounterColor(BuildContext context) {
    final override = widget.counterColor;
    if (override != null) return override;
    final isNearLimit = widget.maxLength > 0 &&
        (widget.currentLength / widget.maxLength) >= 0.9;
    if (isNearLimit) return Colors.red;
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : Colors.black;
  }

  static const double _actionSpacing = 6;
  static const double _footerHeight = 22;

  /// Inline [TextButton]s use 8px horizontal padding; offset the actions row so
  /// the first chip aligns with description [contentPadding], not padding+12.
  static const double _inlineActionsLeadingInset = 8;

  Widget _wrapAction(Widget child) {
    if (!widget.debugShowTapBounds) return child;
    return DebugTapBounds(
      enabled: true,
      child: child,
    );
  }

  Widget _buildActionsRow(DictationMeterController? dictationMeter) {
    return Transform.translate(
      offset: const Offset(-_inlineActionsLeadingInset, 0),
      child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _wrapAction(
          SizedBox(
            height: _footerHeight,
            child: ListingDescriptionAiEnhanceButton(
              controller: widget.controller,
              inlineWithCounter: true,
            ),
          ),
        ),
        const SizedBox(width: _actionSpacing),
        _wrapAction(
          SizedBox(
            height: _footerHeight,
            child: ListingDescriptionTemplateButton(
              controller: widget.controller,
              listingTypeId: widget.listingTypeId,
              gender: widget.gender,
              inlineWithCounter: true,
            ),
          ),
        ),
        const SizedBox(width: _actionSpacing),
        _wrapAction(
          SizedBox(
            height: _footerHeight,
            child: ListingDescriptionDictateButton(
              controller: widget.controller,
              inlineWithCounter: true,
              maxDescriptionLength: widget.maxDescriptionLength,
              dictationMeter: dictationMeter,
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildCounterColumn(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_showCounterText) ...[
          Text(
            "${widget.currentLength}/${widget.maxLength}",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Semantics(
          button: true,
          label:
              widget.isExpanded ? "Collapse description" : "Expand description",
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              UiFeedbackUtils.tap();
              widget.onToggleExpanded();
            },
            child: SizedBox(
              width: 44,
              height: _footerHeight,
              child: Center(
                child: AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.expand_more,
                    size: 18,
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

  Widget _buildInner(Color color, DictationMeterController? dictateMeterSlot) {
    if (widget.layout == DescriptionCounterToolbarLayout.stack) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: SizedBox(
            height: _footerHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                _buildActionsRow(dictateMeterSlot),
                Positioned(
                  right: widget.stackCounterRightOffset,
                  top: 0,
                  bottom: 0,
                  child: _buildCounterColumn(color),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: SizedBox(
        height: _footerHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildActionsRow(dictateMeterSlot),
            const Spacer(),
            _buildCounterColumn(color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveCounterColor(context);

    return ValueListenableBuilder<bool>(
      valueListenable: ClientListingDictationMeterConfig.dictationMeterDisabled,
      builder: (context, meterDisabled, _) {
        final showMeterUi = !meterDisabled;
        final slot = showMeterUi ? _dictationMeter : null;
        final inner = _buildInner(color, slot);

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showMeterUi)
              ListenableBuilder(
                listenable: _dictationMeter,
                builder: (context, _) {
                  if (!_dictationMeter.active) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
                    child: ListingDescriptionDictationMeterRow(
                      controller: _dictationMeter,
                    ),
                  );
                },
              ),
            inner,
          ],
        );

        return content;
      },
    );
  }
}
