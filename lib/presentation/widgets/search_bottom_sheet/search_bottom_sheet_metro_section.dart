import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Metro line and station pickers section for the search bottom sheet.
class SearchBottomSheetMetroSection extends StatelessWidget {
  const SearchBottomSheetMetroSection({required this.searchFiltersState, required this.currentStations, required this.metroLineScrollController, required this.stationPickerController, required this.onSubwayLineChanged, required this.onStationChanged, required this.metroLineTutorialKey, required this.metroStationTutorialKey, required this.getLocalizedName, super.key,
  });

  final SearchFiltersState searchFiltersState;
  final List<SubwayStation> currentStations;
  final FixedExtentScrollController? metroLineScrollController;
  final FixedExtentScrollController? stationPickerController;
  final void Function(int index) onSubwayLineChanged;
  final void Function(int index) onStationChanged;
  final GlobalKey<TutorialTargetWrapperState> metroLineTutorialKey;
  final GlobalKey<TutorialTargetWrapperState> metroStationTutorialKey;
  final String Function({String? nameUz, String? nameRu, String? nameEn})
      getLocalizedName;

  static Color _getLineColor(int line) => AppColors.getMetroLineColor(line);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TutorialTargetWrapper(
            key: metroLineTutorialKey,
            child: Container(
              key: ValueKey(
                "metro_line_picker_${searchFiltersState.selectedLocationIndex}",
              ),
              decoration: BoxDecoration(
                color: ThemeState().isBlueTheme
                    ? BlueThemeColors.surface
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: metroLineScrollController,
                      onSelectedItemChanged: (index) {
                        HapticFeedbackUtils.impact();
                        SendSoundUtils.playSelectionSound();
                        onSubwayLineChanged(index);
                      },
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MLetterIcon(
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  L10n.get("select_metro_line"),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeState().isBlueTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...([
                          MetroCache.getLineName(
                            1,
                            LanguageState().currentLanguage,
                          ),
                          MetroCache.getLineName(
                            2,
                            LanguageState().currentLanguage,
                          ),
                          MetroCache.getLineName(
                            3,
                            LanguageState().currentLanguage,
                          ),
                          MetroCache.getLineName(
                            4,
                            LanguageState().currentLanguage,
                          ),
                        ].asMap().entries.map(
                              (entry) => Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MLetterIcon(
                                      color: _getLineColor(entry.key + 1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: ThemeState().isBlueTheme
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TutorialTargetWrapper(
            key: metroStationTutorialKey,
            child: searchFiltersState.selectedSubwayLine > 0 &&
                    currentStations.isNotEmpty
                ? _buildMetroStationPicker(context, theme)
                : _buildMetroStationPlaceholder(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildMetroStationPicker(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.surface
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              key: PageStorageKey(
                "station_picker_${searchFiltersState.selectedSubwayLine}",
              ),
              itemExtent: 40,
              scrollController: stationPickerController,
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                onStationChanged(index);
              },
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThemeIcon(
                        Icons.train,
                        color: searchFiltersState.selectedSubwayLine > 0
                            ? _getLineColor(
                                searchFiltersState.selectedSubwayLine,
                              )
                            : theme.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          L10n.get("all_stations_count").replaceAll(
                            "{count}",
                            "${currentStations.length}",
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeState().isBlueTheme
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                ...currentStations.map((station) {
                  final transferInfo =
                      MetroCache.getTransferStationInfo(station.id);
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeIcon(
                          Icons.train,
                          color: _getLineColor(station.line),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            getLocalizedName(
                              nameUz: station.nameUz,
                              nameRu: station.nameRu,
                              nameEn: station.nameEn,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ThemeState().isBlueTheme
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transferInfo != null) ...[
                          const SizedBox(width: 4),
                          ThemeIcon(
                            Icons.train,
                            color: _getLineColor(
                              transferInfo["connectedStationLine"],
                            ),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetroStationPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
        color: (ThemeState().isBlueTheme
                ? BlueThemeColors.surface
                : theme.colorScheme.surfaceContainerHighest)
            .withValues(alpha: 0.5),
      ),
      height: 80,
      child: Center(
        child: Text(
          L10n.get("select_metro_line_title"),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ThemeState().isBlueTheme ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
