import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Listing type picker - same pattern as LocationPicker: uses persistent scroll
/// controller (from parent or own) so the wheel scrolls smoothly with sound.
class ListingTypePicker extends StatefulWidget {
  const ListingTypePicker({
    required this.selectedListingTypeId,
    required this.onListingTypeChanged,
    super.key,
    this.height = 80,
    this.itemExtent = 40,
    this.showArrows = true,
    this.useThemeColors = false,
    this.includeUnselected = false,
    this.unselectedLabelKey = "not_selected",
    this.scrollController,
    this.useGlassPlate = false,
    this.userGender,
    this.readOnly = false,
  });

  final int selectedListingTypeId;
  final ValueChanged<int> onListingTypeChanged;
  final bool useThemeColors;
  final double height;
  final double itemExtent;
  final bool showArrows;
  final bool includeUnselected;
  final String unselectedLabelKey;
  final FixedExtentScrollController? scrollController;
  final bool useGlassPlate;

  /// User's profile gender (1 = male, 2 = female), used to tailor the
  /// "roommate needed" option label and icon color. When null, the picker
  /// resolves it from the cached/current user profile.
  final int? userGender;

  /// When true, the wheel is visible but not scrollable.
  final bool readOnly;

  @override
  State<ListingTypePicker> createState() => _ListingTypePickerState();
}

class _ListingTypePickerState extends State<ListingTypePicker> {
  FixedExtentScrollController? _ownScrollController;

  /// Profile gender resolved from the session when [ListingTypePicker.userGender]
  /// is not supplied by the parent.
  int? _resolvedGender;

  static const _baseListingTypeOptions = [
    ListingTypeIds.roommateNeeded,
    ListingTypeIds.groupForming,
    ListingTypeIds.roomNeeded,
  ];

  List<int> get _listingTypeOptions => widget.includeUnselected
      ? [..._baseListingTypeOptions, 0]
      : _baseListingTypeOptions;

  /// Effective user gender (1 = male, 2 = female), preferring the explicit
  /// value from the parent and falling back to the resolved profile gender.
  int? get _effectiveGender => widget.userGender ?? _resolvedGender;

  @override
  void initState() {
    super.initState();
    if (widget.userGender == null) {
      _resolveProfileGender();
    }
  }

  Future<void> _resolveProfileGender() async {
    int? gender;
    try {
      var profile = await SessionManager.getCachedUserProfile();
      if (profile?.gender != 1 && profile?.gender != 2) {
        profile = await getIt<IUserProfileService>().getCurrentUserProfile();
      }
      if (profile?.gender == 1 || profile?.gender == 2) {
        gender = profile!.gender;
      }
    } catch (_) {}
    if (!mounted || gender == null) return;
    setState(() => _resolvedGender = gender);
  }

  /// Label key for the "roommate needed" option, gendered to match the user.
  String get _roommateNeededLabelKey => _effectiveGender == 2
      ? "listing_type_roommate_needed_female"
      : "listing_type_roommate_needed";

  /// Icon color for the "roommate needed" option: blue for men, red for women.
  Color get _roommateNeededIconColor {
    switch (_effectiveGender) {
      case 1:
        return AppColors.genderMale;
      case 2:
        return AppColors.genderFemale;
      default:
        return _getListingTypeColor(2);
    }
  }

  FixedExtentScrollController get _effectiveController {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    _ownScrollController ??= FixedExtentScrollController(
      initialItem: _indexOf(widget.selectedListingTypeId),
    );
    return _ownScrollController!;
  }

  int _indexOf(int id) {
    final i = _listingTypeOptions.indexOf(id);
    return i >= 0 ? i : 0;
  }

  @override
  void didUpdateWidget(ListingTypePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == null &&
        oldWidget.selectedListingTypeId != widget.selectedListingTypeId &&
        (_ownScrollController?.hasClients ?? false)) {
      final idx = _indexOf(widget.selectedListingTypeId);
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

  Color _getItemTextColor(BuildContext context, int listingTypeId) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedListingTypeId == listingTypeId;
    if (isSelected && ThemeState().isBlueTheme) {
      return Colors.white;
    }
    if (ThemeState().isBlueTheme) {
      return theme.colorScheme.onSurfaceVariant;
    }
    return ThemeState().isBlueTheme ? Colors.white : Colors.black;
  }

  Color _getListingTypeColor(int listingTypeId) {
    switch (listingTypeId) {
      case ListingTypeIds.roommateNeeded:
        return AppColors.metroLine1;
      case ListingTypeIds.roomNeeded:
        return AppColors.metroLine2;
      case ListingTypeIds.groupForming:
        return ListingTypeHelper.getColor(
          ListingTypeCodes.groupForming,
        );
      default:
        if (listingTypeId == 0) return Colors.grey;
        return AppColors.metroLine1;
    }
  }

  String _labelKeyFor(int listingTypeId) {
    switch (listingTypeId) {
      case ListingTypeIds.roommateNeeded:
        return _roommateNeededLabelKey;
      case ListingTypeIds.groupForming:
        return "listing_type_short_group_forming";
      case ListingTypeIds.roomNeeded:
        return "listing_type_room_needed";
      default:
        return widget.unselectedLabelKey;
    }
  }

  IconData _iconFor(int listingTypeId) {
    if (listingTypeId == 0) return Icons.remove_circle_outline;
    return ListingTypeHelper.getIcon(
      ListingTypeHelper.getCodeFromId(listingTypeId),
    );
  }

  Color _iconColorFor(int listingTypeId) {
    if (listingTypeId == ListingTypeIds.roommateNeeded) {
      return _roommateNeededIconColor;
    }
    return _getListingTypeColor(listingTypeId);
  }

  Widget _buildWheelItem(BuildContext context, int listingTypeId) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemeIcon(
            _iconFor(listingTypeId),
            color: _iconColorFor(listingTypeId),
            size: 20,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: L10n.text(
              _labelKeyFor(listingTypeId),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _getItemTextColor(context, listingTypeId),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget wheel = Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
              itemExtent: widget.itemExtent,
              scrollController: _effectiveController,
              onSelectedItemChanged: widget.readOnly
                  ? null
                  : (index) {
                      FocusScope.of(context).unfocus();
                      SendSoundUtils.playCupertinoWheelSound();
                      widget.onListingTypeChanged(_listingTypeOptions[index]);
                    },
              children: [
                for (final listingTypeId in _listingTypeOptions)
                  _buildWheelItem(context, listingTypeId),
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

    if (widget.readOnly) {
      wheel = Opacity(
        opacity: 0.55,
        child: AbsorbPointer(child: wheel),
      );
    }

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
