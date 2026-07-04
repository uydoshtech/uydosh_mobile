import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

/// Metro line wheel + multi-select station list, mirroring the control used in
/// the search bottom sheet. A line is chosen on the left wheel; the right plate
/// shows that line's stations as a checkbox list with a "select all on this
/// line" row. Selection is reported back as the full set of selected station
/// ids (across every line) via [onStationsSelected].
class MultiStationPicker extends StatelessWidget {
  const MultiStationPicker({
    required this.selectedSubwayLine,
    required this.currentStations,
    required this.selectedStationIds,
    required this.metroLineScrollController,
    required this.onSubwayLineChanged,
    required this.onStationsSelected,
    this.isLoadingStations = false,
    super.key,
  });

  /// 0 = no line picked, 1..4 = metro line.
  final int selectedSubwayLine;

  /// Stations of the currently selected line.
  final List<SubwayStation> currentStations;

  /// All selected station ids, across every line.
  final Set<int> selectedStationIds;

  final FixedExtentScrollController? metroLineScrollController;
  final void Function(int index) onSubwayLineChanged;

  /// Fires with the new full set of selected ids whenever a station or the
  /// per-line "select all" row is toggled.
  final void Function(List<int> stationIds) onStationsSelected;

  final bool isLoadingStations;

  static Color _lineColor(int line) => AppColors.getMetroLineColor(line);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showStations = selectedSubwayLine > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLineWheel(context),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: showStations
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: currentStations.isNotEmpty
                      ? _buildStationList(context, theme)
                      : _buildPlaceholder(context),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLineWheel(BuildContext context) {
    final language = LanguageState().currentLanguage;
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    return LiquidGlassPlate(
      height: 80,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
        itemExtent: 40,
        scrollController: metroLineScrollController,
        onSelectedItemChanged: (index) {
          SendSoundUtils.playCupertinoWheelSound();
          onSubwayLineChanged(index);
        },
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MLetterIcon(color: Colors.black, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    L10n.get("select_metro_line"),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          for (var line = 1; line <= 4; line++)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MLetterIcon(color: _lineColor(line), size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      MetroCache.getLineName(line, language),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStationList(BuildContext context, ThemeData theme) {
    final language = LanguageState().currentLanguage;
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final selected = {...selectedStationIds};
    final lineStationIds = currentStations.map((s) => s.id).toList();
    final allSelected =
        lineStationIds.isNotEmpty && lineStationIds.every(selected.contains);
    final lineColor = selectedSubwayLine > 0
        ? _lineColor(selectedSubwayLine)
        : theme.colorScheme.onSurfaceVariant;

    void emit(Set<int> next) => onStationsSelected(next.toList()..sort());

    void toggleStation(int id) {
      final next = {...selected};
      if (!next.remove(id)) next.add(id);
      emit(next);
    }

    void toggleAllOnLine() {
      final next = {...selected};
      if (allSelected) {
        next.removeAll(lineStationIds);
      } else {
        next.addAll(lineStationIds);
      }
      emit(next);
    }

    Widget checkbox(bool value, Color color) => ThemeIcon(
          value ? Icons.check_box : Icons.check_box_outline_blank,
          color: value ? color : textColor.withValues(alpha: 0.5),
          size: 22,
        );

    return LiquidGlassPlate(
      height: 220,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: Column(
        children: [
          InkWell(
            onTap: toggleAllOnLine,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  checkbox(allSelected, lineColor),
                  const SizedBox(width: 8),
                  ThemeIcon(Icons.train, color: lineColor, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      L10n.plural("all_stations_count", currentStations.length),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: textColor.withValues(alpha: 0.12)),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 42,
              ),
              itemCount: currentStations.length,
              itemBuilder: (context, index) {
                final station = currentStations[index];
                final isSelected = selected.contains(station.id);
                final transferInfo =
                    MetroCache.getTransferStationInfo(station.id);
                return InkWell(
                  onTap: () {
                    SendSoundUtils.playCupertinoWheelSound();
                    toggleStation(station.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        checkbox(isSelected, _lineColor(station.line)),
                        const SizedBox(width: 6),
                        ThemeIcon(
                          Icons.train,
                          color: _lineColor(station.line),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            MetroCache.getStationName(station, language),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transferInfo != null) ...[
                          const SizedBox(width: 3),
                          ThemeIcon(
                            Icons.train,
                            color: _lineColor(
                              transferInfo["connectedStationLine"] as int,
                            ),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    return LiquidGlassPlate(
      height: 80,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: Center(
        child: isLoadingStations
            ? const CupertinoActivityIndicator()
            : Text(
                L10n.get("select_metro_line_title"),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
