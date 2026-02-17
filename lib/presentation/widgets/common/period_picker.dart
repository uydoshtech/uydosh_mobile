import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// A rotation spinner (CupertinoPicker wheel) for selecting a time period.
/// Matches the metro/district picker style: vertical scrollable list in a
/// rounded container with icons.
class PeriodPicker extends StatefulWidget {
  const PeriodPicker({
    required this.selectedDays,
    required this.onChanged,
    super.key,
    this.title,
    this.height = 120,
    this.itemExtent = 44,
    this.showArrows = false,
  });

  /// Selected value: 1, 7, 30, 90 for days, or 0 for all time
  final int selectedDays;

  final ValueChanged<int> onChanged;

  /// Optional title shown above the picker
  final String? title;

  final double height;
  final double itemExtent;
  final bool showArrows;

  @override
  State<PeriodPicker> createState() => _PeriodPickerState();
}

class _PeriodPickerState extends State<PeriodPicker> {
  static const List<int> _options = [1, 7, 30, 90, 0]; // 0 = all time

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final index = _options.indexOf(widget.selectedDays);
    _scrollController = FixedExtentScrollController(
      initialItem: index >= 0 ? index : 0,
    );
  }

  @override
  void didUpdateWidget(PeriodPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays &&
        _scrollController.hasClients) {
      final index = _options.indexOf(widget.selectedDays);
      final current = _scrollController.selectedItem;
      if (index >= 0 && index != current) {
        _scrollController.animateToItem(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          height: widget.height,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: widget.itemExtent,
                  scrollController: _scrollController,
                  onSelectedItemChanged: (index) {
                    HapticFeedbackUtils.impact();
                    SendSoundUtils.playSelectionSound();
                    widget.onChanged(_options[index]);
                  },
                  children: _options.map<Widget>((days) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            days == 0 ? Icons.all_inclusive : Icons.calendar_today,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getLabel(context, days),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (widget.showArrows)
                Container(
                  width: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLabel(BuildContext context, int days) {
    if (days == 0) {
      return LanguageAwareStringHelper.getCurrent(
        context,
        "admin_search_analytics_all_time",
      );
    }
    return LanguageAwareStringHelper.getCurrent(
      context,
      "admin_search_analytics_days",
    ).replaceAll("{days}", "$days");
  }
}
