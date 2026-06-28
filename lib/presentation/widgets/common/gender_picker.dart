import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Gender selector — toggle buttons by default; wheel picker when
/// [useToggleButtons] is false (e.g. edit listing).
class GenderPicker extends StatelessWidget {
  const GenderPicker({
    required this.selectedGender,
    required this.onGenderChanged,
    super.key,
    this.height = 56,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
    this.unselectedLabelKey = "not_selected",
    this.scrollController,
    this.useGlassPlate = false,
    this.useToggleButtons = true,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;
  final String unselectedLabelKey;
  final FixedExtentScrollController? scrollController;
  final bool useGlassPlate;
  final bool useToggleButtons;

  @override
  Widget build(BuildContext context) {
    if (useToggleButtons) {
      return _GenderTogglePicker(
        selectedGender: selectedGender,
        onGenderChanged: onGenderChanged,
        height: height,
        includeUnselected: includeUnselected,
        unselectedLabelKey: unselectedLabelKey,
        useGlassPlate: useGlassPlate,
      );
    }

    return _GenderWheelPicker(
      selectedGender: selectedGender,
      onGenderChanged: onGenderChanged,
      height: height == 56 ? 80 : height,
      itemExtent: itemExtent,
      showArrows: showArrows,
      useThemeColors: useThemeColors,
      includeUnselected: includeUnselected,
      unselectedLabelKey: unselectedLabelKey,
      scrollController: scrollController,
      useGlassPlate: useGlassPlate,
    );
  }
}

class _GenderTogglePicker extends StatelessWidget {
  const _GenderTogglePicker({
    required this.selectedGender,
    required this.onGenderChanged,
    required this.height,
    required this.includeUnselected,
    required this.unselectedLabelKey,
    required this.useGlassPlate,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final double height;
  final bool includeUnselected;
  final String unselectedLabelKey;
  final bool useGlassPlate;

  List<_GenderOption> get _options {
    if (includeUnselected) {
      return [
        _GenderOption(1, "male", Icons.male, AppColors.genderMale),
        _GenderOption(2, "female", Icons.female, AppColors.genderFemale),
        _GenderOption(
          0,
          unselectedLabelKey,
          Icons.remove_circle_outline,
          AppColors.genderOther,
        ),
      ];
    }
    return [
      _GenderOption(1, "male", Icons.male, AppColors.genderMale),
      _GenderOption(2, "female", Icons.female, AppColors.genderFemale),
    ];
  }

  Widget _buildOptionButton(BuildContext context, _GenderOption option) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final isSelected = selectedGender == option.value;
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    final textColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        FocusScope.of(context).unfocus();
        HapticFeedbackUtils.impact();
        SendSoundUtils.playSelectionSound();
        onGenderChanged(option.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: includeUnselected ? 8 : 12,
          vertical: includeUnselected ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? null : baseColor,
          gradient: isSelected
              ? ThreeDSurfaceStyle.surfaceGradient(context, baseColor)
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? ThreeDSurfaceStyle.elevatedShadows(context)
              : ThreeDSurfaceStyle.insetRecessedShadows(context),
          border: isSelected
              ? Border.all(
                  color: AuthWizardTheme.getSelectedButtonBorderColor(),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeIcon(option.icon, color: option.iconColor, size: 20),
            SizedBox(width: includeUnselected ? 6 : 8),
            Flexible(
              child: L10n.text(
                option.labelKey,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: includeUnselected ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    final buttons = Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: includeUnselected ? 8 : 12),
          Expanded(child: _buildOptionButton(context, options[i])),
        ],
      ],
    );

    if (useGlassPlate && ThemeState().usesLiquidGlassChrome) {
      return LiquidGlassPlate(
        height: height,
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        padding: const EdgeInsets.all(4),
        child: buttons,
      );
    }

    return SizedBox(height: height, child: buttons);
  }
}

/// Wheel picker — same pattern as LocationPicker: uses persistent scroll
/// controller (from parent or own) so the wheel scrolls smoothly with sound.
class _GenderWheelPicker extends StatefulWidget {
  const _GenderWheelPicker({
    required this.selectedGender,
    required this.onGenderChanged,
    required this.height,
    required this.itemExtent,
    required this.showArrows,
    required this.useThemeColors,
    required this.includeUnselected,
    required this.unselectedLabelKey,
    required this.scrollController,
    required this.useGlassPlate,
  });

  final int selectedGender;
  final ValueChanged<int> onGenderChanged;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool useThemeColors;
  final bool includeUnselected;
  final String unselectedLabelKey;
  final FixedExtentScrollController? scrollController;
  final bool useGlassPlate;

  @override
  State<_GenderWheelPicker> createState() => _GenderWheelPickerState();
}

class _GenderWheelPickerState extends State<_GenderWheelPicker> {
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
  void didUpdateWidget(_GenderWheelPicker oldWidget) {
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
        return AppColors.genderMale;
      case 2:
      default:
        if (gender == 0) return AppColors.genderOther;
        return AppColors.genderFemale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final wheel = Row(
      children: [
        Expanded(
          child: CupertinoPicker(
            backgroundColor: Colors.transparent,
            changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
            itemExtent: widget.itemExtent,
            scrollController: _effectiveController,
            onSelectedItemChanged: (index) {
              FocusScope.of(context).unfocus();
              SendSoundUtils.playCupertinoWheelSound();
              widget.onGenderChanged(_genderOptions[index]);
            },
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemeIcon(
                      Icons.male,
                      color: _getGenderColor(1),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: L10n.text(
                        "male",
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
                    ThemeIcon(
                      Icons.female,
                      color: _getGenderColor(2),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: L10n.text(
                        "female",
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
                      ThemeIcon(
                        Icons.remove_circle_outline,
                        color: _getGenderColor(0),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: L10n.text(
                          widget.unselectedLabelKey,
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
              color: theme.colorScheme.outline.withValues(
                alpha: widget.useGlassPlate ? 0.06 : 0.1,
              ),
              borderRadius:
                  ThreeDSurfaceStyle.wheelPickerPlateArrowStripBorderRadius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIcon(
                  Icons.keyboard_arrow_up,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                ThemeIcon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );

    if (widget.useGlassPlate && ThemeState().usesLiquidGlassChrome) {
      return LiquidGlassPlate(
        height: widget.height,
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        child: wheel,
      );
    }

    return Container(
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: theme,
      ),
      height: widget.height,
      child: wheel,
    );
  }
}

class _GenderOption {
  const _GenderOption(this.value, this.labelKey, this.icon, this.iconColor);

  final int value;
  final String labelKey;
  final IconData icon;
  final Color iconColor;
}
