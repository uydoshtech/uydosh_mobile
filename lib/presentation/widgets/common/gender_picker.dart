import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Gender picker - same pattern as LocationPicker: uses persistent scroll
/// controller (from parent or own) so the wheel scrolls smoothly with sound.
class GenderPicker extends StatefulWidget {
  const GenderPicker({
    required this.selectedGender,
    required this.onGenderChanged,
    super.key,
    this.height = 80,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
    this.scrollController,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;
  final FixedExtentScrollController? scrollController;

  @override
  State<GenderPicker> createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {
  FixedExtentScrollController? _ownScrollController;

  List<int> get _genderOptions =>
      widget.includeUnselected ? [1, 2, 0] : [1, 2];

  FixedExtentScrollController get _effectiveController {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    _ownScrollController ??= FixedExtentScrollController(
      initialItem: _indexOf(widget.selectedGender),
    );
    return _ownScrollController!;
  }

  int _indexOf(int gender) {
    final i = _genderOptions.indexOf(gender);
    return i >= 0 ? i : 0;
  }

  @override
  void didUpdateWidget(GenderPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == null &&
        oldWidget.selectedGender != widget.selectedGender &&
        (_ownScrollController?.hasClients ?? false)) {
      final idx = _indexOf(widget.selectedGender);
      if (idx != _ownScrollController!.selectedItem) {
        _ownScrollController!.animateToItem(
          idx,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _ownScrollController?.dispose();
    super.dispose();
  }

  Color _getItemTextColor(BuildContext context, int gender) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedGender == gender;
    if (isSelected && ThemeState().isBlueTheme) {
      return Colors.white;
    }
    if (ThemeState().isBlueTheme) {
      return theme.colorScheme.onSurfaceVariant;
    }
    return ThemeState().isBlueTheme ? Colors.white : Colors.black;
  }

  Color _getGenderColor(int gender) {
    switch (gender) {
      case 1:
        return Colors.blue;
      case 2:
      default:
        return gender == 0 ? Colors.grey : Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final backgroundColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: widget.itemExtent,
              scrollController: _effectiveController,
              onSelectedItemChanged: (index) {
                FocusScope.of(context).unfocus();
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                widget.onGenderChanged(_genderOptions[index]);
              },
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.male, color: _getGenderColor(1), size: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "male",
                          context,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getItemTextColor(context, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.female, color: _getGenderColor(2), size: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: LanguageAwareStringHelper.getText(
                          "female",
                          context,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getItemTextColor(context, 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.includeUnselected)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color: _getGenderColor(0),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: LanguageAwareStringHelper.getText(
                            "not_selected",
                            context,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _getItemTextColor(context, 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (widget.showArrows)
            Container(
              width: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
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
    );
  }
}
