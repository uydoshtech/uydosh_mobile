import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_listing_dictation_meter_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
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
/// * A `currentLength / maxLength` counter that turns red at 90% usage, shown
///   on a second footer row when visible so it does not crowd the action row.
///   The counter aligns with the template icon on row 1.
/// * An expand/collapse chevron pinned to the right of the action row.
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
    this.onTranscriptInserted,
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

  /// Propagates controller-driven dictation inserts to the owning form.
  final VoidCallback? onTranscriptInserted;

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
  static const double _footerHeight = 36;
  static const double _footerVerticalPadding = 12;
  static const double _counterRowGap = 2;
  static const double _counterTextRowHeight = 14;
  static const double _activeFooterSlotHeight = 44;

  /// Pull inline toolbar actions toward the plate edge, leaving a small gutter.
  static const double _inlineActionsLeadingInset = 14;

  /// Matches inline [TextButton] horizontal padding on assistant toolbar buttons.
  static const double _inlineActionButtonHorizontalPadding = 8;

  /// Lines row-2 counter text up with the template icon on row 1.
  static const double _counterRowLeadingOffset =
      _inlineActionButtonHorizontalPadding - _inlineActionsLeadingInset;

  double _footerContentHeight({required bool showCounterText}) {
    var height = _footerHeight;
    if (showCounterText) {
      height += _counterRowGap + _counterTextRowHeight;
    }
    return height;
  }

  double _footerSlotHeightFor({required bool recording, required bool showCounterText}) {
    final contentHeight = _footerContentHeight(showCounterText: showCounterText);
    if (recording) {
      return _activeFooterSlotHeight +
          (showCounterText ? _counterRowGap + _counterTextRowHeight : 0);
    }
    return _footerVerticalPadding + contentHeight;
  }

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
              child: ListingDescriptionDictateButton(
                controller: widget.controller,
                inlineWithCounter: true,
                maxDescriptionLength: widget.maxDescriptionLength,
                dictationMeter: dictationMeter,
                onTranscriptInserted: widget.onTranscriptInserted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterText(Color color) {
    return Text(
      "${L10n.get("listing_description_character_count")}"
      "${widget.currentLength} / ${widget.maxLength}",
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildExpandChevron({required double counterRight}) {
    return Transform.translate(
      offset: Offset(-counterRight, 0),
      child: Semantics(
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
    );
  }

  Widget _buildInner(Color color, DictationMeterController? dictateMeterSlot) {
    final counterRight = widget.layout == DescriptionCounterToolbarLayout.stack
        ? widget.stackCounterRightOffset
        : 0.0;
    final showCounterText = _showCounterText;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: SizedBox(
        height: _footerContentHeight(showCounterText: showCounterText),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _footerHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _buildActionsRow(dictateMeterSlot),
                      ),
                    ),
                  ),
                  _buildExpandChevron(counterRight: counterRight),
                ],
              ),
            ),
            if (showCounterText) ...[
              const SizedBox(height: _counterRowGap),
              SizedBox(
                height: _counterTextRowHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: const Offset(_counterRowLeadingOffset, 0),
                    child: _buildCounterText(color),
                  ),
                ),
              ),
            ],
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
        return ListenableBuilder(
          listenable: _dictationMeter,
          builder: (context, _) {
            final recording = showMeterUi && _dictationMeter.active;
            final showCounterText = _showCounterText;
            final footerSlotHeight = _footerSlotHeightFor(
              recording: recording,
              showCounterText: showCounterText,
            );
            return SizedBox(
              height: footerSlotHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 4,
                    right: 4,
                    bottom: footerSlotHeight,
                    child: IgnorePointer(
                      child: recording
                          ? ListingDescriptionDictationMeterRow(
                              controller: _dictationMeter,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Positioned.fill(child: _buildInner(color, slot)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
