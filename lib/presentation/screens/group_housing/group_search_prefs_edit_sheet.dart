import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

/// Opens the shared "search area" editor for a forming group. Returns the
/// saved [GroupSearchPrefs] when the user persists changes, otherwise null.
Future<GroupSearchPrefs?> showGroupSearchPrefsEditSheet({
  required BuildContext context,
  required int groupListingId,
  required GroupSearchPrefs initial,
}) {
  return showAppBottomSheet<GroupSearchPrefs>(
    context: context,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 12),
        child: GlassBottomSheetSurface(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            type: MaterialType.transparency,
            child: _GroupSearchPrefsEditSheet(
              groupListingId: groupListingId,
              initial: initial,
            ),
          ),
        ),
      );
    },
  );
}

class _GroupSearchPrefsEditSheet extends StatefulWidget {
  const _GroupSearchPrefsEditSheet({
    required this.groupListingId,
    required this.initial,
  });

  final int groupListingId;
  final GroupSearchPrefs initial;

  @override
  State<_GroupSearchPrefsEditSheet> createState() =>
      _GroupSearchPrefsEditSheetState();
}

class _GroupSearchPrefsEditSheetState
    extends State<_GroupSearchPrefsEditSheet> {
  late final Set<int> _stationIds;
  final Set<int> _expandedLines = {};
  int? _locationId;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _stationIds = {...widget.initial.subwayStationIds};
    final loc = widget.initial.locationId;
    _locationId = loc != null && loc > 0 ? loc : null;
  }

  void _toggleStation(int id) {
    HapticFeedbackUtils.selection();
    setState(() {
      if (!_stationIds.remove(id)) _stationIds.add(id);
    });
  }

  void _toggleLine(int line) {
    HapticFeedbackUtils.selection();
    final ids = MetroCache.getStationsForLine(line).map((s) => s.id).toList();
    final allSelected = ids.isNotEmpty && ids.every(_stationIds.contains);
    setState(() {
      if (allSelected) {
        _stationIds.removeAll(ids);
      } else {
        _stationIds.addAll(ids);
      }
    });
  }

  void _toggleLocation(int id) {
    HapticFeedbackUtils.selection();
    setState(() => _locationId = _locationId == id ? null : id);
  }

  void _toggleLineExpanded(int line) {
    HapticFeedbackUtils.selection();
    setState(() {
      if (!_expandedLines.remove(line)) _expandedLines.add(line);
    });
  }

  /// Lines whose every station is selected become "whole line" markers so the
  /// selection stays dynamic if stations are later added to those lines.
  List<int> get _fullLineIds {
    final out = <int>[];
    for (final line in MetroCache.getAvailableLines()) {
      final ids = MetroCache.getStationsForLine(line).map((s) => s.id).toList();
      if (ids.isNotEmpty && ids.every(_stationIds.contains)) out.add(line);
    }
    return out;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_stationIds.isEmpty && (_locationId ?? 0) <= 0) {
      ToastTheme.showError(
        context,
        message: L10n.get("group_search_area_empty"),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final stations = _stationIds.toList()..sort();
      final prefs = await getIt<IListingGroupService>().updateSearchPrefs(
        groupListingId: widget.groupListingId,
        locationId: _locationId,
        subwayStationIds: stations,
        subwayLineIds: _fullLineIds,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_search_area_saved"),
      );
      Navigator.of(context).pop(prefs);
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: ErrorMessageHelper.sanitizeErrorMessage(e, context: context),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final lang = L10n.currentLanguage;
    final media = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ThemeIcon(Icons.travel_explore, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    L10n.get("group_search_area"),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              L10n.get("group_search_area_hint"),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.get("location"),
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final loc in LocationCache.getAllLocations())
                          _buildDistrictChip(
                            context,
                            label: LocationCache.getLocationShortName(
                              loc.id,
                              lang,
                            ),
                            selected: _locationId == loc.id,
                            onTap: () => _toggleLocation(loc.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final line in MetroCache.getAvailableLines())
                      _buildLineSection(theme, onSurface, lang, line),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const UydoshLogoSpinner(size: 18)
                    : Text(L10n.get("save_changes")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final chipBase = selected
        ? (isBlueTheme
            ? BlueThemeColors.buttonPrimary
            : theme.colorScheme.primary)
        : (isBlueTheme
            ? BlueThemeColors.card
            : theme.colorScheme.surfaceContainerHighest);
    final textColor = isBlueTheme
        ? (selected
            ? BlueThemeColors.textPrimary
            : theme.colorScheme.onSurfaceVariant)
        : (selected ? theme.colorScheme.onPrimary : Colors.grey[600]!);

    return InkWell(
      onTap: onTap,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, chipBase),
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLineSection(
    ThemeData theme,
    Color onSurface,
    String lang,
    int line,
  ) {
    final stations = MetroCache.getStationsForLine(line);
    if (stations.isEmpty) return const SizedBox.shrink();
    final lineColor = AppColors.getMetroLineColor(line);
    final ids = stations.map((s) => s.id).toList();
    final allSelected = ids.every(_stationIds.contains);
    final expanded = _expandedLines.contains(line);

    Widget checkbox(bool value, Color color) => ThemeIcon(
          value ? Icons.check_box : Icons.check_box_outline_blank,
          color: value ? color : onSurface.withValues(alpha: 0.4),
          size: 22,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleLine(line),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                checkbox(allSelected, lineColor),
                const SizedBox(width: 8),
                ThemeIcon(Icons.train, color: lineColor, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    MetroCache.getLineName(line, lang),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  L10n.plural("all_stations_count", stations.length),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _toggleLineExpanded(line),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: ThemeIcon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: onSurface.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final station in stations)
            InkWell(
              onTap: () => _toggleStation(station.id),
              child: Padding(
                padding: const EdgeInsets.only(left: 18, top: 6, bottom: 6),
                child: Row(
                  children: [
                    checkbox(_stationIds.contains(station.id), lineColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        MetroCache.getStationName(station, lang),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
      ],
    );
  }
}
