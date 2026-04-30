import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_hint_bubble.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/tooltip_fade.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/tutorial/metro_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

/// Metro line and station pickers section for the search bottom sheet.
class SearchBottomSheetMetroSection extends StatefulWidget {
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

  @override
  State<SearchBottomSheetMetroSection> createState() =>
      _SearchBottomSheetMetroSectionState();
}

class _SearchBottomSheetMetroSectionState
    extends State<SearchBottomSheetMetroSection> {
  /// User-dismissed flag for the "search across all stations of line X" hint.
  /// Loaded from SharedPreferences so the dismissal survives across sheet
  /// re-openings and app restarts. Until prefs resolve we keep the hint
  /// hidden to avoid a flicker where it briefly shows then disappears.
  bool _allStationsHintDismissed = true;

  static Color _getLineColor(int line) => AppColors.getMetroLineColor(line);

  @override
  void initState() {
    super.initState();
    _loadAllStationsHintDismissed();
    TooltipsState().addListener(_onTooltipsStateChanged);
  }

  @override
  void dispose() {
    TooltipsState().removeListener(_onTooltipsStateChanged);
    super.dispose();
  }

  void _onTooltipsStateChanged() {
    if (!mounted) return;
    // Re-read the per-tip dismissal flag too: when the user re-enables tips
    // from settings, [TooltipsState.enableAndResetAll] resets per-tip flags
    // back to false and we want this section to surface the hint again
    // without requiring a full sheet remount.
    _loadAllStationsHintDismissed();
  }

  Future<void> _loadAllStationsHintDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed =
          prefs.getBool(TooltipsState.keyMetroAllStationsHintDismissed) ??
              false;
      setStateIfMounted(() => _allStationsHintDismissed = dismissed);
    } catch (_) {
      // If prefs are unavailable, keep the hint hidden by default.
    }
  }

  Future<void> _dismissAllStationsHint() async {
    setStateIfMounted(() => _allStationsHintDismissed = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        TooltipsState.keyMetroAllStationsHintDismissed,
        true,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TooltipFade(
          visible: _shouldShowHint,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: NeumorphicHintBubble(
                      message: _buildHintSpan(context, theme),
                      onClose: _dismissAllStationsHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildPickersRow(context, theme),
      ],
    );
  }

  Widget _buildPickersRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TutorialTargetWrapper(
            key: widget.metroLineTutorialKey,
            child: LiquidGlassPlate(
              height: 80,
              borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      itemExtent: 40,
                      scrollController: widget.metroLineScrollController,
                      onSelectedItemChanged: (index) {
                        HapticFeedbackUtils.impact();
                        SendSoundUtils.playSelectionSound();
                        widget.onSubwayLineChanged(index);
                      },
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MLetterIcon(
                                color: Colors.black,
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
            key: widget.metroStationTutorialKey,
            child: widget.searchFiltersState.selectedSubwayLine > 0 &&
                    widget.currentStations.isNotEmpty
                ? _buildMetroStationPicker(context, theme)
                : _buildMetroStationPlaceholder(context, theme),
          ),
        ),
      ],
    );
  }

  bool get _shouldShowHint =>
      // Suppress entirely while the metro coach-mark tutorial is on screen so
      // the bubble doesn't fight for attention with the spotlight overlay.
      !MetroTutorialOverlay.isActive &&
      // Honor the global tooltips toggle (Settings > Tips).
      TooltipsState().enabled &&
      // Respect per-tip dismissal (small "x" in the bubble corner).
      !_allStationsHintDismissed &&
      widget.searchFiltersState.selectedSubwayLine > 0 &&
      widget.searchFiltersState.selectedStationId == 0 &&
      widget.currentStations.isNotEmpty;

  TextSpan _buildHintSpan(BuildContext context, ThemeData _) {
    final raw = L10n.get("all_stations_explanation")
        .replaceAll("{count}", "${widget.currentStations.length}")
        .replaceAll(
          "{line}",
          MetroCache.getLineName(
            widget.searchFiltersState.selectedSubwayLine,
            LanguageState().currentLanguage,
          ),
        );

    const baseStyle = TextStyle(
      fontSize: 14.5,
      height: 1.3,
      color: Colors.black,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w700);

    final spans = <TextSpan>[];
    final boldRegex = RegExp("<b>(.*?)</b>");
    var lastIndex = 0;
    for (final Match match in boldRegex.allMatches(raw)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: raw.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastIndex = match.end;
    }
    if (lastIndex < raw.length) {
      spans.add(TextSpan(text: raw.substring(lastIndex), style: baseStyle));
    }
    return TextSpan(children: spans);
  }

  Widget _buildMetroStationPicker(BuildContext context, ThemeData theme) {
    return LiquidGlassPlate(
      height: 80,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              itemExtent: 40,
              scrollController: widget.stationPickerController,
              onSelectedItemChanged: (index) {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                widget.onStationChanged(index);
              },
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ThemeIcon(
                        Icons.train,
                        color: widget.searchFiltersState.selectedSubwayLine > 0
                            ? _getLineColor(
                                widget.searchFiltersState.selectedSubwayLine,
                              )
                            : theme.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          L10n.plural(
                            "all_stations_count",
                            widget.currentStations.length,
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
                ...widget.currentStations.map((station) {
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
                            widget.getLocalizedName(
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

  Widget _buildMetroStationPlaceholder(BuildContext context, ThemeData theme) {
    return LiquidGlassPlate(
      height: 80,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
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
